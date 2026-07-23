import { isDataWriteRequest, isSessionPost } from "../support/read-only-policy.js";

/**
 * Unit tests for the read-only request policy (support/read-only-policy.js).
 * Every request shape here is observed app behaviour, not hypothetical URLs —
 * the policy and this spec must both be updated from real traffic.
 */

const appHosts = ["betamasaheft.eu", "localhost"];

describe("read-only guard", () => {
  it("allows the login POST on any page (pageless #login-nav form, empty password ok)", () => {
    const allowed = [
      // dev stack: admin without password, login from the user page
      { method: "POST", url: "http://localhost/Dillmann/user/admin", body: "user=admin&password=" },
      // login from the home page
      { method: "POST", url: "http://localhost/Dillmann/", body: "user=admin&password=" },
      // production login via BetMas routing
      { method: "POST", url: "https://betamasaheft.eu/Dillmann/", body: "user=JinntecLexicon&password=secret" },
      // logout form posts a single hidden field
      { method: "POST", url: "http://localhost/Dillmann/", body: "logout=true" },
    ];

    allowed.forEach((req) => {
      expect(isDataWriteRequest(req, appHosts), `${req.url} (${req.body})`).to.eq(false);
    });
  });

  it("allows the GET duplicate-lemma check and other reads", () => {
    const reads = [
      { method: "GET", url: "http://localhost/api/Dillmann/otherlemmas?lemma=%E1%8A%A0" },
      { method: "GET", url: "http://localhost/Dillmann/newentry.html" },
      { method: "GET", url: "http://localhost/Dillmann/update.html?id=L111" },
      { method: "GET", url: "http://localhost/api/Dillmann/L111/json" },
    ];

    reads.forEach((req) => {
      expect(isDataWriteRequest(req, appHosts), req.url).to.eq(false);
    });
  });

  it("blocks the write endpoints (default-deny)", () => {
    const blocked = [
      // update form action (app.xql #updateEntry)
      { method: "POST", url: "http://localhost/Dillmann/edit/edit.xq", body: "form=x&msg=y" },
      // create form action (app.xql #createnew)
      { method: "POST", url: "http://localhost/Dillmann/edit/save-new-entity.xql", body: "form=x" },
      { method: "POST", url: "http://localhost/Dillmann/update.html?id=L111", body: "form=x" },
      { method: "POST", url: "https://betamasaheft.eu/DillmannData/new/foo.xml" },
      // an endpoint the policy has never heard of must be blocked, not let through
      { method: "POST", url: "http://localhost/Dillmann/some/new-endpoint.xq" },
      // loginByApi's shape ({username, password} to user/) is not the eXist
      // session form — the command is skipped/TODO; revisit the policy with it
      { method: "POST", url: "http://localhost/Dillmann/user/", body: { username: "admin", password: "" } },
    ];

    blocked.forEach((req) => {
      expect(isDataWriteRequest(req, appHosts), req.url).to.eq(true);
    });
  });

  it("blocks a write POST even when credentials ride along in the body", () => {
    expect(
      isDataWriteRequest(
        {
          method: "POST",
          url: "http://localhost/Dillmann/edit/edit.xq",
          body: "user=admin&password=&form=x&msg=y",
        },
        appHosts,
      ),
    ).to.eq(true);

    expect(isSessionPost("user=admin&password=&form=x")).to.eq(false);
    expect(isSessionPost("user=admin&password=")).to.eq(true);
    expect(isSessionPost("")).to.eq(false);
    expect(isSessionPost(undefined)).to.eq(false);
  });

  it("blocks all PUT, PATCH, and DELETE requests to the app", () => {
    const methods = ["PUT", "PATCH", "DELETE"];

    methods.forEach((method) => {
      expect(
        isDataWriteRequest(
          {
            method,
            url: "http://localhost/Dillmann/lemma/L111",
          },
          appHosts,
        ),
      ).to.eq(true);
    });
  });

  it("ignores mutating requests to third-party hosts", () => {
    const thirdParty = [
      { method: "POST", url: "https://www.google-analytics.com/collect" },
      { method: "GET", url: "https://api.zotero.org/groups/358366/items" },
    ];

    thirdParty.forEach((req) => {
      expect(isDataWriteRequest(req, appHosts), req.url).to.eq(false);
    });
  });
});
