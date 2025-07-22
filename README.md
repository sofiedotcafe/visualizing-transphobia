<!-- markdownlint-disable MD033 MD013-->

# Visualizing transphobia

<a href="https://creativecommons.org/publicdomain/zero/1.0/"><img src="https://img.shields.io/badge/-CC0--1.0-white?logo=creative-commons&logoColor=black&labelColor=white&color=white" alt="GitHub License" height="20"/></a>
<a href="https://github.com/sofiedotcafe/visualizing-transphobia/actions/workflows/deploy-app.yaml"><img src="https://img.shields.io/github/actions/workflow/status/sofiedotcafe/visualizing-transphobia/deploy-app.yaml?logo=github&logoColor=black&label=Deploy%20app%20to%20Pages&labelColor=white" alt="GitHub Actions Workflow Status" height="20"/></a><br>
<a href="https://www.r-project.org/"><img src="https://img.shields.io/badge/R-%23276DC3.svg?logo=r&logoColor=white" alt="R" height="20"/></a>
<a href="https://shiny.posit.co/"><img src="https://img.shields.io/badge/Shiny-%23276DC3.svg?logo=rstudioide&logoColor=white" alt="RStudio Shiny" height="20"/></a>
<a href="https://builtwithnix.org"><img src="https://builtwithnix.org/badge.svg" alt="Built with Nix" height="20.25"/></a><br>
A visualization to structurally represent the influence networks within the spheres of transphobic pseudoscience "discourse"

This project uses `visNetwork` and `shiny` in **R** to visualize influence networks around transphobic discourse and related topics. The app can be exported as a static `shinylive` site, which runs fully in the browser without a server. Source data is stored in a `sqlite3` database. The development environment is managed with **Nix** for easy setup and reproducibility.

You can explore the live visualization [here on GitHub Pages](https://sofiedotcafe.github.io/visualizing-transphobia/).

## Usage

A `Makefile` is included to simplify common development and deployment tasks. Run `make help` to view all available commands.

To run the interactive app locally, use:

```sh
make run
````

To export a static Shinylive version and serve it locally:

```sh
make serve
```

The exported version is placed in the `dist/` directory, which can be deployed to GitHub Pages or other static hosts. To use an automatic script to make the necessary files for GitHub actions, run:

```sh
make gh-actions
```

---

## Development Environment

This project uses **Nix** to ensure consistent builds and development environments across systems.

To enter a development shell:

```sh
nix develop
```

An optional Nix package is also provided. If you're using flakes:

```sh
nix run .#app
```

This will provide a clean, isolated environment with R, required packages, and supporting tools pre-installed.

---

## License and Legal Notice

This analytical work is released into the public domain by the author(s) under the [Creative Commons CC0 1.0 Universal Public Domain Dedication](https://creativecommons.org/publicdomain/zero/1.0/legalcode).  
To the fullest extent permitted by applicable law, the author(s) waive all copyright and neighboring rights.  
Users are authorized to reproduce, adapt, transmit, and utilize this work, in whole or in part, including for commercial purposes, without obtaining prior permission.

---

## GDPR and Data Protection Compliance

The processing of personal and organizational data is conducted on the basis of **legitimate interest** pursuant to **[Article 6(1)(f)](https://gdpr-info.eu/art-6-gdpr/)** of the General Data Protection Regulation (GDPR), with the stated objective of academic research, civic transparency, and public interest.  
**Reference**: European Data Protection Board Guidelines 1/2024 on Article 6(1)(f)

Due to the structural nature of this research, **anonymization is not feasible**. Accordingly, rights to erasure and rectification are lawfully restricted in accordance with **[GDPR Recital 156](https://gdpr-info.eu/recitals/no-156/)** and **[Article 17(3)(d)](https://gdpr-info.eu/art-17-gdpr/)**.  
The data model is constructed in compliance with the principle of **data minimization** as prescribed by **[GDPR Article 5(1)(c)](https://gdpr-info.eu/art-5-gdpr/)**.

Appropriate technical and organizational measures are employed to ensure the **integrity, confidentiality, and resilience** of data processing systems, in accordance with **[GDPR Article 32](https://gdpr-info.eu/art-32-gdpr/)**.

Data is retained solely for the duration necessary to accomplish the intended research objectives, in accordance with **[GDPR Article 5(1)(e)](https://gdpr-info.eu/art-5-gdpr/)**.  
Nevertheless, because the dataset is released under a CC0 license, future retention, distribution, and modification by third parties are outside the control of the author(s), consistent with **[GDPR Recital 26](https://gdpr-info.eu/recitals/no-26/)**.

Additional safeguards apply to the protection of whistleblower disclosures, which constitute an essential component of the research corpus.  
Processing complies with **[Directive (EU) 2019/1937](https://eur-lex.europa.eu/eli/dir/2019/1937/oj)** on the protection of persons reporting breaches of Union law, and ensures strict confidentiality of disclosers except where public attribution is central to the structural analysis.

---

## Citations and Data Sources

- Reed, E. (2023). *Abusive practices and conversion therapy ties: The right latches onto Finnish doctor Kaltiala?* Retrieved from [https://www.erininthemorning.com/p/abusive-practices-and-conversion](https://www.erininthemorning.com/p/abusive-practices-and-conversion)

- Reed, E. (2024). *New problematic “Finnish study” actually shows trans care saves lives.* Retrieved from [https://www.erininthemorning.com/p/fact-checked-new-problematic-finnish](https://www.erininthemorning.com/p/fact-checked-new-problematic-finnish)

- Reed, E. (2025). *New German, Swiss, and Austrian guidelines recommend trans youth care.* Retrieved from [https://www.erininthemorning.com/p/new-german-swiss-and-austria-guidelines](https://www.erininthemorning.com/p/new-german-swiss-and-austria-guidelines)

- Reed, E. (2025). *The myth of "low quality evidence" around transgender care.* Retrieved from [https://www.erininthemorning.com/p/the-myth-of-low-quality-evidence](https://www.erininthemorning.com/p/the-myth-of-low-quality-evidence)

- Assigned Media. (2024). *Fifteen-year-old assigned masturbation as “homework” in Finland transgender clinic.* Retrieved from [https://www.assignedmedia.org/breaking-news/transgender-youth-speak-about-finland-transpoli](https://www.assignedmedia.org/breaking-news/transgender-youth-speak-about-finland-transpoli)

- Kehrääjä. (2021). *“Kuvaile minulle miten masturboit?” – Transnuorten asema hoitojärjestelmässä on synkkä.* Retrieved from [https://kehraaja.com/kuvaile-minulle-miten-masturboit-julkikuvan-takaa-paljastuu-transpolien-nuorten-synkka-tilanne/](https://kehraaja.com/kuvaile-minulle-miten-masturboit-julkikuvan-takaa-paljastuu-transpolien-nuorten-synkka-tilanne/)  
  English translation available at: [Google Translate](https://translate.google.com/translate?hl=en&sl=fi&u=https://kehraaja.com/kuvaile-minulle-miten-masturboit-julkikuvan-takaa-paljastuu-transpolien-nuorten-synkka-tilanne/)

- Gender Analysis. (2024). *Gender Analysis Project.* Retrieved July 22, 2025, from [https://genderanalysis.net](https://genderanalysis.net)

- Southern Poverty Law Center. (2024, June). *Group dynamics and division of labor within the anti-LGBTQ+ pseudoscience network.* Retrieved from [https://www.splcenter.org/resources/reports/defining-pseudoscience-network/](https://www.splcenter.org/resources/reports/defining-pseudoscience-network/)

- Health Liberation Now! (2022). *Anti-trans conversion therapy map of influence.* Retrieved from [https://healthliberationnow.com/anti-trans-conversion-therapy-map-of-influence](https://healthliberationnow.com/anti-trans-conversion-therapy-map-of-influence)

- Dasper, J. (2024). *Debunking transphobia* [Video]. YouTube. [https://www.youtube.com/watch?v=JiOc0r31-Os](https://www.youtube.com/watch?v=JiOc0r31-Os)

---

## Purpose

This work is undertaken to further the objectives of research transparency, public accountability, and critical literacy regarding structural disinformation in healthcare-related discourse.
