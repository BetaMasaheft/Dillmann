/**
 * Read-only policy: this suite must never persist creates, updates, or deletes
 * (edit/edit.xq, edit/save-new-entity.xql, DillmannData, …). Session
 * login/logout POSTs are recognised by body and allowed; every other mutating
 * request to an app host is blocked and fails the test. Covers browser
 * traffic (cy.intercept) and cy.request.
 *
 * Escape hatch: CYPRESS_ALLOW_WRITES=1 disables the guard AND un-skips the
 * write tests (editor.cy.js, user_admin.cy.js). Only use it against a
 * disposable local stack (docker compose) — never against production.
 */

import { isDataWriteRequest, DEFAULT_APP_HOSTNAMES } from "./read-only-policy.js";

const allowWrites = () => Boolean(Cypress.env("ALLOW_WRITES"));

let readOnlyViolations = [];

function getAppHostnames() {
  const hostnames = [...DEFAULT_APP_HOSTNAMES];
  const baseUrl = Cypress.config("baseUrl");

  if (baseUrl) {
    const baseHostname = new URL(baseUrl).hostname;
    if (!hostnames.includes(baseHostname)) {
      hostnames.push(baseHostname);
    }
  }

  return hostnames;
}

Cypress.Commands.overwrite("request", (originalFn, ...args) => {
  const options =
    typeof args[0] === "object" && args[0] !== null
      ? args[0]
      : args.length >= 2
        ? { method: args[0], url: args[1], body: args[2] }
        : { url: args[0] };

  const method = String(options.method || "GET");
  const url = String(options.url || "");

  if (!allowWrites() && isDataWriteRequest({ method, url, body: options.body }, getAppHostnames())) {
    throw new Error(`[read-only E2E] blocked cy.request ${method.toUpperCase()} ${url}`);
  }

  return originalFn(...args);
});

beforeEach(() => {
  readOnlyViolations = [];

  if (allowWrites()) {
    Cypress.log({ name: "read-only", message: "guard DISABLED via ALLOW_WRITES — writes will persist" });
    return;
  }

  const appHostnames = getAppHostnames();

  cy.intercept({ middleware: true }, (req) => {
    if (!isDataWriteRequest(req, appHostnames)) {
      return;
    }

    const message = `[read-only E2E] blocked ${req.method} ${req.url}`;
    readOnlyViolations.push(message);
    req.reply({ statusCode: 503, body: message });
  });
});

afterEach(() => {
  if (readOnlyViolations.length === 0) {
    return;
  }

  const message = readOnlyViolations.join("; ");
  readOnlyViolations = [];
  throw new Error(message);
});
