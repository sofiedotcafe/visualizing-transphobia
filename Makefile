APP_DIR = .
DIST_DIR = dist
GH_ACTION_URL = https://github.com/posit-dev/r-shinylive/blob/actions-v1/examples/deploy-app.yaml

.PHONY: all
all: run

## run           : Run the app using standard Shiny
run:
	Rscript -e "shiny::runApp('$(APP_DIR)')"

## export        : Export as a static Shinylive site to $(DIST_DIR)/
export:
	Rscript -e "shinylive::export('$(APP_DIR)', '$(DIST_DIR)')"

## serve         : Export and serve the Shinylive site locally
serve:
	Rscript -e "shinylive::export('$(APP_DIR)', '$(DIST_DIR)')" \
	        -e "httpuv::runStaticServer('$(DIST_DIR)')"

## gh-actions    : Add GitHub Actions workflow for automatic deployment
gh-actions:
	Rscript -e "usethis::use_github_action(url='$(GH_ACTION_URL)')"

## clean         : Remove the output directory
clean:
	rm -rf $(DIST_DIR)

## help          : Show this help message
help:
	@grep -E '^##' Makefile | sed -E 's/## (.+?): (.+)/\1\t\2/' | expand -t 20 | sort