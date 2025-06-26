const username = "admin" 

describe('Contributor pages', () => {

    beforeEach(() => {
        cy.visit('gez-en')
        //In Navigation bar (left), select Login, in the dropdown insert login credentials
        cy.get('#logging')
        cy.get('.w3-dropdown-content')
          .invoke('removeAttr', 'class')
        cy.get('input[name="user"]')
          .type(username)
        cy.get('#login-nav > .w3-button')
          .click()
    })

    

    describe('See activity', () => {
        // see 02_03    
        it('logs in using env variables', () => {
            expect(username, 'username was set').to.be.a('string').and.not.be.empty
          });

          it('See activity', () => {
            // Click on "Hi, USERNAME!"
            cy.get('[title=about] > a')
            //See the page documenting activities (The last 50 pages you visited)
            .invoke('attr', 'href')
            .then(href => {
                cy.request(href)
                    .its('body')
                    .should('include', 'The last 50 pages you visited') 

            })
            //See the page documenting activities (Your made XXX changes in these files after the last conversion of the data from the original txt)
            cy.get('[title=about] > a')
            .invoke('attr', 'href')
            .then(href => {
                cy.visit(href)
                .get('.w3-lightygreen > h3').invoke('text').then((text) => {
                    // Use a regular expression to extract the numbers
                    const regex = /Your made (\d+) changes in these files after the last conversion of the data from the original txt \((\d+)\.(\d+)\.(\d+)\)/;
                    const matches = text.match(regex);
                     
                    // matches will contain an array of matched values
                    if (matches) {
                        const how_many_text = matches[1]; // Group 1 contains the captured number
                        const how_many = parseInt(how_many_text, 10);
                        expect(how_many).to.be.greaterThan(0);

                        const day_text = matches[2]; // Group 1 contains the captured number
                        const day = parseInt(day_text, 10);
                        cy.wrap(day).should('be.lte', 31)
                        .and('be.gte', 1)

                        const month_text = matches[3]; // Group 1 contains the captured number
                        const month = parseInt(month_text, 10);
                        cy.wrap(month).should('be.lte', 12)
                        .and('be.gte', 1)

                        const currentDate = new Date();
                        const currentYear = currentDate.getFullYear();

                        const year_text = matches[4]; // Group 1 contains the captured number
                        const year = parseInt(year_text, 10);
                        cy.wrap(year).should('be.lte', currentYear)
                        .and('be.gte', 2000)
                    }
                })
            })
           });
    })

    describe('Create new entry', () => {
        // see 02_04    
        it('logs in using env variables', () => {
            expect(username, 'username was set').to.be.a('string').and.not.be.empty
          });

          it('Create new entry existing', () => {
            // Click "New Entry" button
            cy.contains("New Entry").click()
            cy.get('#form')
              .type('አልማዲ') 
            cy.get('.alert-warning').invoke('text')
              .should('include','Be carefull, this lemma is already there! See: ')
            // .should('include','this is a new lemma')
            
        });

        it('Create new entry not existing', () => {
            // Click "New Entry" button
            cy.contains("New Entry").click()
            cy.get('#form')
              .type('test') 
            cy.get('.alert-success')
              .invoke('text')
              .should('include','this is a new lemma!')
            // cy.intercept('/gez-en/newentry.html', (req) => {
            //     req.reply({
            //       statusCode: 200, // default
            //     })
            // })
            cy.get('#msg')
              .type('test') 
            // The last step is disabled
            // cy.contains("Confirm").click()
        });
        
    })

    describe('Edit existing entry', () => {
        // see 02_05    

          it('Edit existing entry', () => {
            cy.visit('gez-en/lemma/L111j0m1v77fds7qynv79wee76jx62ae1')
            // Click "Update" button
            cy.contains("Update").click()
            cy.get('.w3-panel')
              .invoke('text')
              .should('include','You are updating')
            // cy.intercept('/gez-en/update.html', (req) => {
            //     req.reply({
            //       statusCode: 200, // default
            //     })
            // })
            cy.get('#msg')
              .type('test') 
            // The last step is disabled
            // cy.contains("Confirm").click()
        });
    })
})