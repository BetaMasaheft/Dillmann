const username = "admin";

// Lemma unlikely to exist; used only to reach the “new lemma” form state (no Confirm).
const novelLemma = `zzzcypress${Date.now()}`;

// See betmas-e2e Plan/02_contributor.md §3–§4; edit form (§5) is in editor.cy.js.
// The read-only policy (support/read-only.js) blocks any save endpoint, so
// these tests stop at the filled form by construction, not by discipline.
// The Confirm write test runs only with CYPRESS_ALLOW_WRITES=1 (disposable
// local stack only — it persists a new entry under DillmannData/new).
const itWrites = Cypress.env("ALLOW_WRITES") ? it : it.skip;

describe("User page", () => {
  beforeEach(() => {
    cy.visit("/user/admin");
    cy.login(username);
  });

  // Plan §3
  describe("See activity", () => {
    it("shows user activity page with recent visits and change statistics", () => {
      cy.get("h3").contains("The last 50 pages you visited");
      cy.get(".w3-lightygreen > h3")
        .invoke("text")
        .then((text) => {
          const regex =
            /Your made (\d+) changes in these files after the last conversion of the data from the original txt \((\d+)\.(\d+)\.(\d+)\)/;
          const matches = text.match(regex);
          expect(matches, "lexicon activity summary").to.not.be.null;

          // structure over data: a fresh conversion legitimately resets this to 0
          const changeCount = parseInt(matches[1], 10);
          expect(changeCount).to.be.at.least(0);

          const day = parseInt(matches[2], 10);
          expect(day).to.be.within(1, 31);

          const month = parseInt(matches[3], 10);
          expect(month).to.be.within(1, 12);

          const year = parseInt(matches[4], 10);
          expect(year).to.be.within(2000, new Date().getFullYear());
        });
    });
  });

  // Plan §4 — Confirm intentionally not clicked (side effects).
  // Skipped: the New Entry UI is currently disabled app-side — app:newentry
  // (app.xql) is not referenced by any template and there is no newentry.html
  // route (CI: 'New Entry' never renders). Bodies kept so the flow can be
  // re-enabled when the route returns; cf. closed issues #461/#469.
  describe.skip("Create new entry", () => {
    beforeEach(() => {
      // the duplicate check is a GET fired on keyup (resources/js/checkforlemma.js)
      cy.intercept("GET", "**/api/Dillmann/otherlemmas*").as("lemmaCheck");
      cy.contains("New Entry").click();
    });

    it("warns when trying to create a lemma that already exists", () => {
      cy.get("#form").type("አልማዲ");
      cy.wait("@lemmaCheck").its("response.statusCode").should("eq", 200);
      cy.get(".alert-warning").invoke("text").should("include", "Be carefull, this lemma is already there! See: ");
    });

    it("accepts a novel lemma in the form without saving", () => {
      cy.get("#form").type(novelLemma);
      cy.wait("@lemmaCheck").its("response.statusCode").should("eq", 200);
      cy.get(".alert-success").invoke("text").should("include", "this is a new lemma!");
      cy.get("#msg").type("cypress smoke — not saved");
    });

    // Write test (skipped unless CYPRESS_ALLOW_WRITES=1): Plan §4 step 6 —
    // Confirm saves the entry to DillmannData/new and shows the result link.
    itWrites("saves a novel lemma via Confirm (writes to DillmannData/new)", () => {
      cy.get("#form").type(novelLemma);
      cy.wait("@lemmaCheck").its("response.statusCode").should("eq", 200);
      cy.get(".alert-success").should("contain", "this is a new lemma!");
      cy.get("#msg").type("cypress write test — disposable stack only");
      cy.contains("Confirm").click();

      cy.contains(novelLemma, { timeout: 10000 });
    });
  });
});
