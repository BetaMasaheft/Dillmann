describe('viewing lemma in the scan of Dillmann’s Lexicon', () => {
    // see 03-menu/dillman.cy.js

    beforeEach(() => {
        cy.visit('gez-en/lemma/La28f0d661a324ba5a2364e70e63ef317')

    })

     // see 03_user 19
     it('click on Load button loads the attestations', () => {
        cy.intercept( { method: 'GET', pathname: '**/api/*' }).as('attest')        
        cy.get('#loadattestations').click()
        // check that the clicked button disappears
        cy.get('#loadattestations').should('have.css', 'display', 'none')
        // check if response contains result
        cy.wait('@attest').its('response.body.items').should('have.length.least', 2)
        // check display of attestations results
        cy.get('#attestations')
          .children()
          .should('have.length.least', 1)
        cy.get('#EMML4398')
          .should('be.visible')   
    })

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