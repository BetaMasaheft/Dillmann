// ***********************************************
// This example commands.js shows you how to
// create various custom commands and overwrite
// existing commands.
//
// For more comprehensive examples of custom
// commands please read more here:
// https://on.cypress.io/custom-commands
// ***********************************************
//
//
// -- This is a parent command --
// Cypress.Commands.add('login', (email, password) => { ... })
//
//
// -- This is a child command --
// Cypress.Commands.add('drag', { prevSubject: 'element'}, (subject, options) => { ... })
//
//
// -- This is a dual command --
// Cypress.Commands.add('dismiss', { prevSubject: 'optional'}, (subject, options) => { ... })
//
//
// -- This will overwrite an existing command --
// Cypress.Commands.overwrite('visit', (originalFn, url, options) => { ... })

// Logs in via the #login-nav dropdown on the current page. The form has no
// action attribute (posts to the page itself); the dev stack accepts admin
// with an empty password, so typing the password is optional.
// see BetaMasaheft/Dillmann/issues/387 for the hover workaround
Cypress.Commands.add('login', (username = 'admin', password = '') => {
  cy.get('#logging')
  cy.get('.w3-dropdown-content')
    .invoke('removeAttr', 'class')
  cy.get('input[name="user"]')
    .type(username)
  if (password !== '') {
    cy.get('input[name="password"]').type(password)
  }
  cy.get('#login-nav > .w3-button')
    .click()
  cy.get('#about', { timeout: 10000 })
    .should('contain', `Hi ${username}!`)
})

// TODO(DP): needs tuning see login.cy.js
Cypress.Commands.add('loginByApi', (username, password) => {
  cy.request({
    method: 'POST',
    url: 'user/',
    form: true,
    body: {
      username,
      password
    }
  }).then((resp) => {
    expect(resp.status).to.eq(200);
  });
});