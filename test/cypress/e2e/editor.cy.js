const username = 'admin'
const testEntryId = 'L111j0m1v77fds7qynv79wee76jx62ae1'

// See betmas-e2e Plan/02_contributor.md §5 — update an existing entry.
// Read-only policy: by default this spec covers opening and filling the
// update form only; the edit/edit.xq POST is blocked by support/read-only.js.
// The full Confirm flow runs only with CYPRESS_ALLOW_WRITES=1 (disposable
// local stack only — it persists a new entry version, so no restore cycle).
const itWrites = Cypress.env('ALLOW_WRITES') ? it : it.skip

describe('Single Lemma', () => {
  beforeEach(() => {
    cy.visit(`lemma/${testEntryId}`)
    cy.login(username)
    // Update button is only rendered for the lexicon group
    cy.contains('Update', { timeout: 10000 })
      .should('be.visible')
  })

  describe('Edit existing entry', () => {
    it('opens the update form pre-filled, without saving', () => {
      cy.contains('Update').click()

      cy.get('.w3-panel')
        .invoke('text')
        .should('include', 'You are updating')

      cy.get('#updateEntry').should('exist')
      cy.get('input[name="form"]')
        .should('exist')
        .invoke('val')
        .should('not.be.empty')
      cy.get('#msg').should('exist')

      // fill the change message like a real edit would, then stop before Confirm
      cy.get('#msg')
        .clear()
        .type('cypress smoke — not saved')
    })

    // Write test (skipped unless CYPRESS_ALLOW_WRITES=1): catches the known
    // submit failure modes — session loss on the form page (#387) and
    // transformer/upconversion errors on save (#535).
    itWrites('submits the edit via Confirm and saves successfully (writes a new version)', () => {
      cy.contains('Update').click()
      cy.get('#updateEntry').should('exist')

      cy.get('#msg')
        .clear()
        .type('cypress write test — disposable stack only')
      cy.get('button[type="submit"]').contains('Confirm').click({ force: true })

      cy.url({ timeout: 10000 }).should('include', '/edit/')
      cy.get('body').invoke('text').then((text) => {
        expect(text, 'session held on submit (#387)').to.not.include('Authentication Required')
        expect(text, 'upconversion succeeded (#535)').to.not.match(/Unable to set up transformer|stylesheet compilation|upconvertSense/)
        expect(text).to.include('has been updated successfully')
      })
    })
  })
})
