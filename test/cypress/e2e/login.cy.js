const username = "admin" 

describe('Login', () => {

    beforeEach(() => {
      // see 02_03 02_04
        cy.visit('/')
    })

    it('should login with valid credentials', () => {
         //In Navigation bar (left), select Login, in the dropdown insert login credentials
         cy.get('#logging')
         cy.get('.w3-dropdown-content')
           .invoke('removeAttr', 'class')
         cy.get('input[name="user"]')
           .type(username)
         cy.get('#login-nav > .w3-button')
           .click()
        cy.get('#about')
          .contains('Hi admin!')
    })
    
    it('should not login with invalid credentials', () => {
        cy.get('#logging')
        cy.get('.w3-dropdown-content')
          .invoke('removeAttr', 'class')
        cy.get('input[name="user"]')
          .type('blabla')
        cy.get('#login-nav > .w3-button')
          .click()
       cy.get('#about')
         .contains('Hi guest!')
   }) 

   it.skip('should login via API', () => {
    cy.visit('/user/admin')
    cy.loginByApi(username, 'admin')
    cy.get('#content > p')
      .should('not.contain', 'not logged in')
   })
})