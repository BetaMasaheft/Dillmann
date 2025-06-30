// ***********************************************************
// This example support/e2e.js is processed and
// loaded automatically before your test files.
//
// This is a great place to put global configuration and
// behavior that modifies Cypress.
//
// You can change the location of this file or turn off
// automatically serving support files with the
// 'supportFile' configuration option.
//
// You can read more here:
// https://on.cypress.io/configuration
// ***********************************************************

// Import commands.js using ES2015 syntax:
import './commands'

Cypress.on('uncaught:exception', (err, runnable) => {
  // we expect a 3rd party library error with message 'trimmed is undefined'
  // and don't want to fail the test so we return false
  // see #4
  if (err.message.includes('trimmed is undefined')) {
    return false
  }
})

Cypress.on('uncaught:exception', (err, runnable) => {
  // we expect a 3rd party library error with message 'trimmed is undefined'
  // and don't want to fail the test so we return false
  // see #4
  if (err.message.includes('activation element [object NodeList] is missing')) {
    return false
  }
})

Cypress.on('uncaught:exception', (err, runnable) => {
  // we expect a 3rd party library error with message 'trimmed is undefined'
  // and don't want to fail the test so we return false
  // see #4
  if (err.message.includes('Cannot read properties of undefined ')) {
    return false
  }
})

// Ignore generic cross-origin script errors (e.g., “Script error.”)
Cypress.on('uncaught:exception', (err) => {
  if (err.message.includes('Script error') || err.message.includes('cross origin script')) {
    return false;
  }
});

// Silence logs for xhr and fetch requests
// beforeEach(() => {
//   cy.intercept({ resourceType: /xhr|fetch/ }, { log: false })
// })
beforeEach(() => {
  // only silence GA pings, not our real API
  cy.intercept('POST', 'https://www.google-analytics.com/**', (req) => {
    req.reply({ statusCode: 204, body: '' });
  });
});


// 2a) Stub font files to prevent sanitizer errors
beforeEach(() => {
  cy.intercept(
    { url: '**/Dillmann/resources/**/fonts/*.{woff,woff2,ttf,eot}' },
    { statusCode: 204, body: '' },
    { log: false }
  )
})

// Globally silence and group static assets by resourceType and resources path
beforeEach(() => {
  // by resourceType (images, scripts, styles, fonts)
  cy.intercept(
    {
      resourceType: /^(image|script|stylesheet|font)$/,
      url: '**/Dillmann/**'
    },
    (req) => {
      req.alias = 'static';
      req.continue({ log: false });
    }
  );
  // any other static resources under /Dillmann/resources/
  cy.intercept(
    {
      url: '**/Dillmann/resources/**'
    },
    (req) => {
      // Rewrite the path to point at the exist/apps/gez-en resources
      const proxiedUrl = req.url.replace('/Dillmann', '/exist/apps/gez-en')
      req.alias = 'static'
      req.continue({ url: proxiedUrl })
    },
    { log: false }
  );
});


// Globally intercept all requests to /Dillmann/** and proxy them to /exist/apps/gez-en/**
beforeEach(() => {
  cy.intercept({
    method: '*',
    url: /\/Dillmann(\/(search|index\.html|api)\/?|[/?].*)?$/
  },
    async (req) => {
      const controller = new AbortController();
      // Abort the fetch if it takes longer than 7 seconds
      const timeoutId = setTimeout(() => controller.abort(), 7000);

      const originalUrl = new URL(req.url);
      originalUrl.pathname = originalUrl.pathname.replace(/^\/Dillmann/, '/exist/apps/gez-en');
      const proxyUrl = originalUrl.toString();

      // Build fetch options conditionally
      const fetchOptions = {
        method: req.method,
        headers: req.headers,
        signal: controller.signal,
      };

      // Only include body for methods that support it
      if (!['GET', 'HEAD'].includes(req.method.toUpperCase()) && req.body) {
        fetchOptions.body = req.body;
      }

      try {
        const response = await fetch(proxyUrl, fetchOptions);
        const responseBody = await response.text();
        const contentType = response.headers.get('content-type') || '';

        req.reply({
          statusCode: response.status,
          headers: { 'content-type': contentType },
          body: responseBody
        });
      } catch (error) {
        req.reply({
          statusCode: 504,
          body: 'Proxy request timed out or failed'
        });
      } finally {
        clearTimeout(timeoutId);
      }
    });
});
