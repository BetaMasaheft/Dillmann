const username = "admin" 

describe('Contributor pages', () => {

    beforeEach(() => {
        cy.visit('/user/admin')
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

    

    describe('See activity', () => {    

        it('shows user activity page with recent visits and change statistics', () => {
            // Click on "Hi, USERNAME!"
            cy.get('h3')
              .contains('The last 50 pages you visited')
            cy.get('h3')
              .contains('changes in these files')             
           })
    })

    describe('Create new entry', () => {
      // (DP): New Entry seems to have been disabled
        it.skip('warns when trying to create a lemma that already exists', () => {
            // Click "New Entry" button
            cy.contains("New Entry").click()
            cy.get('#form')
              .type('አልማዲ') 
            cy.get('.alert-warning').invoke('text')
              .should('include','Be carefull, this lemma is already there! See: ')
            // .should('include','this is a new lemma')
            
        })

        it.skip('confirms creation of a new lemma when it does not exist', () => {
            // Click "New Entry" button
            cy.contains("New Entry").click()
            cy.get('#form')
              .type('test') 
            cy.get('.alert-success')
              .invoke('text')
              .should('include','this is a new lemma!')
            cy.intercept('/Dillmann/newentry.html', (req) => {
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