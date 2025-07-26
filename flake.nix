{
  description = "A Nix-flake-based R development environment";
  inputs = {
    nixpkgs = {
      url = "github:NixOS/nixpkgs/nixos-unstable";
    };

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    pre-commit-hooks = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
      ];
      imports = [
        inputs.pre-commit-hooks.flakeModule
      ];

      perSystem =
        {
          config,
          pkgs,
          ...
        }:
        let
          rEnv = pkgs.rWrapper.override {
            packages = with pkgs.rPackages; [
              colourpicker
              shiny
              shinylive
              shinyFeedback
              DBI
              RSQLite
              visNetwork
              bslib
              usethis
            ];
          };
        in
        {
          devShells.default = pkgs.mkShell {
            packages = with pkgs; [
              rEnv
              sqlite
              sqlitestudio
            ];
            shellHook = ''
              ${config.pre-commit.installationScript}
            '';
          };
          pre-commit = {
            check.enable = true;
            settings = {
              excludes = [
                "\.age$"
                "\.sqlite3$"
                "\.envrc$"
              ];

              hooks =
                let
                  rEnv = pkgs.rWrapper.override {
                    packages = [ pkgs.rPackages.styler ];
                  };
                in
                {
                  styler = {
                    enable = true;
                    entry = "${rEnv}/bin/Rscript -e 'styler::style_file(commandArgs(TRUE))'";
                    types = [ "r" ];
                  };

                  nixfmt-rfc-style.enable = true;
                  deadnix.enable = true;
                  statix.enable = true;

                  commitizen.enable = true;
                  editorconfig-checker.enable = true;

                  # typos.enable = true;
                  markdownlint.enable = true;
                };
            };
          };
        };
    };
}
