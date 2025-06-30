describe('viewing lemma in the scan of Dillmann’s Lexicon', () => {
  // see 03-menu/dillman.cy.js

  beforeEach(() => {
    cy.visit('Dillmann/lemma/La28f0d661a324ba5a2364e70e63ef317')

  })

  // see 03_user 19
  it('click on Load button loads the attestations', () => {
    // intercept the attestations search call
    cy.intercept('GET', '**/api/Dillmann/search/form?**').as('attest');
    // Optionally, still intercept rootmembers for other uses
    cy.intercept('GET', '/api/Dillmann/rootmembers/**').as('rootmembers');

    // 2) click, wait, and assert on the JSON
    cy.get('#loadattestations').click();
    cy.wait('@attest', { timeout: 10000 })
      .its('response.body.items')
      .should('have.length.at.least', 2);

    // 3) assert on the rendered DOM
    cy.get('#attestations')
      .children()
      .should('have.length.at.least', 1);
    cy.get('#EMML4398').should('be.visible');
  });

  // see 03_user 20
  it('click on page icon takes you to the relevant lexicon page', () => {
    // see 03_user 20.2
    cy.get('.w3-badge > a')
      .invoke('attr', 'href')
      // the test uses 'contain' instead of 'eq' to avoid inconsistencies with the protocol definition 
      .should('contain', 'www.tau.ac.il/~hacohen/Lexicon/pp583.html')
      // see 03_user 20.3
      .then(href => {
        cy.request(href)
          .its('body')
          .should('include', '</html>')
          .and('include', 'pp583')
      })
  })
})