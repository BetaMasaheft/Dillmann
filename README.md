# Dillmann Lexicon eXist-db app

This application, built in eXist-db, uses basic techniques to display data from the digitization process of the *Lexicon Linguae Aethiopicae* of Augustus Dillmann. It is deployed at the moment only for registered users with the relevant data at the University of Hamburg. The application assumes a local collection [DillmannData](https://github.com/BetaMasaheft/DillmannData) where the files are stored. Data is encoded in TEI using the Dictionary module.

This dataset has the following doi:10.25592/uhhfdm.130


## Requirements

- [Java](https://adoptium.net/) with [Ant](https://ant.apache.org/) (for building)
- [Docker](https://www.docker.com/) (for local development)
- [Node.js](https://nodejs.org/) (for testing)
- [Bats](https://bats-core.readthedocs.io/en/stable/) (for testing)


## Features


### Preprocessing

Heavy preprocessing of data has been carried out with regex in oxygen to encode the text starting from a txt version provided by Andreas Ellwardt. The data is being processed within this application to improve the structure and the reusability of the large amount of information provided by this work. all parts of speech, abbreviations, citations, translations, notes, nesting of meaning, column breaks, internal references etc., have been marked up in TEI XML and the app relies on that markup as a structure.


### Search

* homophones of the ethiopic language are searched as a standard if not otherwise specified. 
* modes as per eXist-db sample app are also provided, with code from the demo application of eXist-db only slightly modified.


### XQuery

* the functions allow a group of editors to edit records with a simplified syntax in simple text, with no editor, with two XSLT transformations. The form contains also the guidelines for the editing
* before submitting the new file this is validated against the schema.
* columns are computed from the data and linked to the pdf version available [here](http://www.tau.ac.il/~hacohen/Lexicon.html)


### jquery

* The bibliography is pulled from [Zotero EthioStudies group library](https://www.zotero.org/groups/358366/ethiostudies).
* The queries to Beta Masaheft for related passages and text citations are also done with jquery. Each citation in the format John 1.1 is linked in a popup to the exact passage, if this is available in Beta Masaheft, otherwise it is linked to the record of the edition.

### RESTXQ

* api search of text is also set for use
* list from api can be obtained
* records can be called by id


## Deployment

To deploy the latest version of the full Dillmann application on ExistDB, use the provided `docker-compose.yml` file. This will set up all required services (ExistDB, Nginx, etc.) and handle the deployment process for you.

1. Make sure you have [Docker](https://docs.docker.com/engine/install/) and [Docker Composer plugin](https://docs.docker.com/compose/install/linux/) installed.

2. In your project directory, run:

```sh
sudo docker compose up -d
```

This will start all services in the background. You can then access the application as described in your configuration.

If you need to rebuild the containers (for example, after updating the code), run:

```sh
ant

sudo docker compose up -d --build
```

For more details, see the `docker-compose.yml` file in the repository.


## Development and testing

This project includes both smoke tests and end-to-end (E2E) tests to ensure the application works as expected.

- **Smoke tests** are located in the `test/01-smoke.bats` file and check that the containers start up and the main services are reachable.

- **Cypress E2E tests** are located in the `test/cypress/e2e/` directory and cover user interactions and application flows. The Cypress configuration is in `cypress.config.js`. Lexicon contributor flows (betmas-e2e Plan/02_contributor §3–§5) are in `user_admin.cy.js` and `editor.cy.js`; betmas-e2e keeps only a thin production login smoke against Dillmann via BetMas.

  The suite is **read-only by default**: `test/cypress/support/read-only.js` blocks every request that would persist data (create/update/delete) and fails the test that attempted it. The tests that actually save entries are skipped by default; to run them against a **disposable local stack only**, set `CYPRESS_ALLOW_WRITES=1` — this disables the guard and enables the write tests in `editor.cy.js` and `user_admin.cy.js`. Never use it against production.

To run all tests using Docker Compose, ensure that exist-db has started and finished indexing the collections. Then:

```sh
bats --tap test/*.bats
```

Or, to run Cypress tests (from the project root):

```sh
npx cypress run
```

You can also run tests as part of the CI workflow (see `.github/workflows/`).

For more information, see the `test/` directory and the `cypress.config.js` file.

The code is provided without data for documentation purposes and for reuse of parts for other dictionary projects. Where possible documentation has also been provided in the code.
