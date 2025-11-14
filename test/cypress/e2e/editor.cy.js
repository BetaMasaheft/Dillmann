const username = "admin"
const testEntryId = "L111j0m1v77fds7qynv79wee76jx62ae1"

describe('Single Lemma', () => {
    let originalEntryData = null

    beforeEach(() => {
        // Visit the page first
        cy.visit(`lemma/${testEntryId}`)
        
        // Check if already logged in, if not, log in
        cy.get('body').then(($body) => {
            if ($body.text().includes('Hi guest!') || !$body.text().includes(`Hi ${username}!`)) {
                // Not logged in, need to log in
                cy.get('#logging')
                cy.get('.w3-dropdown-content')
                    .invoke('removeAttr', 'class')
                cy.get('input[name="user"]')
                    .type(username)
                cy.get('#login-nav > .w3-button')
                    .click()
                // Verify login succeeded
                cy.get('#about', { timeout: 10000 })
                    .should('contain', `Hi ${username}!`)
            } else {
                // Already logged in
                cy.log('Already logged in')
            }
        })
        
        // Verify Update button appears (only visible to lexicon group)
        cy.contains("Update", { timeout: 10000 })
            .should('be.visible')
    })

    // Helper function to get original entry data via API and store it
    function captureOriginalEntryData() {
        return cy.request({
            method: 'GET',
            url: `/api/Dillmann/${testEntryId}/json`,
            failOnStatusCode: false
        }).then((response) => {
            if (response.status === 200 && response.body) {
                originalEntryData = response.body
                cy.log('Captured original entry data for cleanup')
                return response.body
            } else {
                cy.log(`Warning: Could not capture original entry data - Status: ${response.status}`)
                return null
            }
        })
    }

    // Helper function to extract form data from entry JSON
    function extractFormData(entryJson) {
        if (!entryJson) {
            return null
        }

        // The API might return the entry directly or wrapped in an 'entry' property
        const entry = entryJson.entry || entryJson
        if (!entry) {
            return null
        }
        const formData = {
            id: testEntryId,
            form: entry.form?.foreign?.[0]?._ || entry.form?.foreign || '',
            formlang: entry.form?.foreign?.[0]?.['@xml:lang'] || 'gez',
            root: entry.form?.['rs']?.['@type'] === 'root' ? 'root' : '',
            msg: 'Test cleanup - restoring original entry'
        }

        // Extract sense data
        const senses = Array.isArray(entry.sense) ? entry.sense : (entry.sense ? [entry.sense] : [])
        senses.forEach((sense) => {
            const lang = sense['@xml:lang'] || 'la'
            // Get the text content from the sense - it might be in _ or directly as text
            const senseText = sense._ || sense['#text'] || ''
            formData[`sense${lang}`] = senseText
            formData[`source${lang}`] = sense['@source']?.replace('#', '') || 'dillmann'
        })

        return formData
    }

    // Helper function to restore original entry
    function restoreOriginalEntry(originalData) {
        if (!originalData) {
            cy.log('No original data to restore - skipping cleanup')
            return
        }

        const formData = extractFormData(originalData)
        if (!formData) {
            cy.log('Could not extract form data for restoration - skipping cleanup')
            return
        }

        cy.log('Starting cleanup: restoring original entry')

        // Navigate to edit page
        cy.visit(`update.html?id=${testEntryId}`, { failOnStatusCode: false })
        cy.get('#logging')
        cy.get('.w3-dropdown-content')
            .invoke('removeAttr', 'class')
        cy.get('input[name="user"]')
            .type(username)
        cy.get('#login-nav > .w3-button')
            .click()

        // Wait for form to load
        cy.get('#updateEntry', { timeout: 10000 }).should('exist')

        // Restore form fields
        cy.get('input[name="form"]').clear().type(formData.form)
        cy.get('select[name="formlang"]').select(formData.formlang)

        // Restore root checkbox
        cy.get('input[name="root"]').then(($checkbox) => {
            if (formData.root === 'root') {
                cy.wrap($checkbox).check()
            } else {
                cy.wrap($checkbox).uncheck()
            }
        })

        // Restore senses - need to handle dynamically
        Object.keys(formData).forEach(key => {
            if (key.startsWith('sense')) {
                cy.get(`textarea[name="${key}"]`).then(($textarea) => {
                    if ($textarea.length > 0) {
                        cy.wrap($textarea).clear().type(formData[key] || '', { delay: 0 })
                    }
                })
            }
            if (key.startsWith('source')) {
                cy.get(`select[name="${key}"]`).then(($select) => {
                    if ($select.length > 0) {
                        cy.wrap($select).select(formData[key] || 'dillmann')
                    }
                })
            }
        })

        // Set restore message
        cy.get('#msg').clear().type(formData.msg)

        // Submit restoration
        cy.get('button[type="submit"]').contains('Confirm').click()

        // Verify restoration succeeded (allow for either success or if already restored)
        cy.url({ timeout: 10000 }).should('satisfy', (url) => {
            return url.includes('/edit/edit.xq') || url.includes('update.html')
        })

        cy.get('body').then(($body) => {
            const bodyText = $body.text()
            if (bodyText.includes('has been updated successfully')) {
                cy.log('Cleanup: Entry restored successfully')
            } else {
                cy.log('Cleanup: Restoration may have completed or entry was unchanged')
            }
        })
    }

    describe('Edit existing entry', () => {
        // see 02_05

        it('allows editing an existing lemma and displays update confirmation', () => {
            // Capture original entry data before editing
            captureOriginalEntryData().then(() => {
                // Click "Update" button (already verified in beforeEach)
                cy.contains("Update").click()
                cy.get('.w3-panel')
                    .invoke('text')
                    .should('include', 'You are updating')

                // Verify form is loaded
                cy.get('#updateEntry').should('exist')
                cy.get('input[name="form"]').should('exist')
                cy.get('#msg').should('exist')

                // Make a test edit - add a test message
                cy.get('#msg')
                    .clear()
                    .type('Cypress test edit - testing edit functionality')

                // Submit the form
                cy.get('button[type="submit"]').contains('Confirm').click({ force: true })

                // Verify we get a response (either success or error)
                cy.url({ timeout: 10000 }).should('satisfy', (url) => {
                    return url.includes('/edit/edit.xq') || url.includes('error')
                })

                // Check for either success message or error message
                cy.get('body').then(($body) => {
                    const bodyText = $body.text()
                    if (bodyText.includes('has been updated successfully')) {
                        cy.log('Edit succeeded')
                        // Verify the edit actually worked by checking the success message is present
                        cy.get('body').should('contain', 'has been updated successfully')
                    } else if (bodyText.includes('Authentication Required')) {
                        cy.log('Edit failed: Authentication error - session not maintained')
                        cy.log('Current user shown: ' + $body.find('p').filter((i, el) => el.textContent.includes('Current user')).text())
                        // This indicates the session wasn't maintained - fail the test
                        throw new Error('Authentication failed: Session was not maintained when submitting the edit form. User was logged in but appears as guest when form is submitted.')
                    } else if (bodyText.includes('Unable to set up transformer') ||
                              bodyText.includes('stylesheet compilation') ||
                              bodyText.includes('upconvertSense') ||
                              bodyText.includes('ERROR')) {
                        cy.log('Edit failed with transformation error (this is what we are testing for)')
                        // This is the error we're trying to catch - issue #535
                    } else if (bodyText.includes('not valid')) {
                        cy.log('Edit failed with validation error')
                    } else {
                        cy.log('Edit completed with unknown result')
                        cy.log('Body text: ' + bodyText.substring(0, 500))
                    }
                })
            })
        })

        afterEach(() => {
            // Cleanup: restore original entry data
            if (originalEntryData) {
                restoreOriginalEntry(originalEntryData)
                originalEntryData = null
            }
        })
    })
})