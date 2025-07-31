const username = "admin"
describe('Single Lemma', () => {

    beforeEach(() => {
        cy.visit('Dillmann/lemma/L111j0m1v77fds7qynv79wee76jx62ae1')
        // In Navigation bar (left), select Login, in the dropdown insert login credentials
        // see BetaMasaheft/Dillmann/issues/387
        cy.get('#logging')
        cy.get('.w3-dropdown-content')
            .invoke('removeAttr', 'class')
        cy.get('input[name="user"]')
            .type(username)
        cy.get('#login-nav > .w3-button')
            .click()
    })


    describe('Edit existing entry', () => {
        // see 02_05    

        it.skip('allows editing an existing lemma and displays update confirmation', () => {        // Click "Update" button
            cy.contains("Update").click()
            cy.get('.w3-panel')
                .invoke('text')
                .should('include', 'You are updating')
            cy.intercept('/Dillmann/update.html', (req) => {
                req.reply({
                    statusCode: 200, // default
                })
            })
            cy.get('#msg')
                .type('test')
            // The last step is disabled
            // cy.contains("Confirm").click()
        })
    })
})