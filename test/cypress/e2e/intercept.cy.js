describe('Dillman start', () => {
    // TODO(DP): before we can do anything this application error needs to be gone see #4
    // see 03_User 18-20
    // see 02_Contrib 3-6
    // see 06-users/lemma.cy.js
    beforeEach(() => {
        // DP: I don't understand why this works here but not in e2e.js
        cy.intercept({ resourceType: /image|font|script/ }, { log: false }).as('staticAssets')
        cy.visit('Dillmann/')
    })

    it('should show startpage', () => {
        cy.get('#body')
            .should('contain', 'This app is a prototype Beta version.')
    })

})