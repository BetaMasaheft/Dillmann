describe('Dillman page', () => {
    // TODO(DP): before we can do anything this application error needs to be gone see #4
    // see 03_User 18-20
    // see 02_Contrib 3-6
    // see 06-users/lemma.cy.js
    beforeEach(() => {
        cy.visit('Dillmann/')
    })

    it('should display Beta version warning', () => {
        cy.get('#body')
            .should('contain', 'This app is a prototype Beta version.')
    })

    describe('lemma search with mouse', () => {
        // see 03_user 18
        it('should show results', () => {
            cy.get('[name="q"]')
                .type('ሀሰሰ')
            cy.get('[name="mode"]').should('have.value', 'none')
            // 3_user 18.3 default mode is "Normal, with homophones"
            cy.get('[name="mode"]').find(':selected').contains('Normal, with homophones')
            cy.get('[selected=""]')
            .should('have.length', 1)
            .should('have.value', 'none')
            cy.get('.fa-search').click()
            // 03_user 18.4
            cy.get('#results > .w3-row')
                .should('be.visible')
            cy.get('h3')
                .should('contain', 'You found "ሀሰሰ" in ')
            cy.get('#results').invoke('attr', 'data-template-per-page')
                .then(value => {
                    const pagination_int = parseInt(value);
                    cy.get('#results > .w3-row').its('length').should('be.lte', pagination_int)
                })
 
                cy.get('#results .w3-twothird > a').first().invoke('attr', 'href')
                // first link leads to page with correct mode and searched phrase and any id
                .should('contain', '?mode=none&q=ሀሰሰ&id=')
                .then(href => {
                    cy.request(href)
                        .its('status')
                        .should('eq', 200)
                });
            // 03_user 18.5
            cy.get('#results .w3-twothird').first().click()
            // a record appears indicated by the newly visible h3 dillman section
            cy.get('.entry')
              .contains('Dillman')
        })
    })

    describe('fuzzy search with keyboard', () => {
                it('should work with keyboard', () => {
            // 3_user 18.3 
            // select mode of searching as Fuzzy Search
            cy.get('[name="mode"]').select('fuzzy')
            
            // search for lemma ሀሰሰ
            cy.get('[name="q"]')
                .type('ሀሰሰ')
                .type('{enter}')
            cy.get('#results > .w3-row')
                .should('be.visible');
            cy.get('h3').find('#hit-count').contains(/\d+/)

            // the list of results has >= elements then pagination 
            cy.get('#results').invoke('attr', 'data-template-per-page')
                .then(value => {
                    const pagination_int = parseInt(value);
                    cy.get('#results > .w3-row').its('length').should('be.lte', pagination_int)
                })


            // first link leads to page with correct mode and searched phrase and any id
            cy.get('#results .w3-twothird > a').first().invoke('attr', 'href')
                .should('contain', '?mode=fuzzy&q=ሀሰሰ&id=')
                .then(href => {
                    cy.request(href)
                        .its('body')
                        .should('include','</html>')
                })

            // first link opens the page with lemma description headed with first link text
            cy.get('#results .w3-twothird').first().click()
            cy.get('#results .w3-twothird > a').invoke('prop', 'text')
                .then(value => {
                    cy.get('.w3-container #lemma').first().should('contain', value)
                })
        })
    })
})