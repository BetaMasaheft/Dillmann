const username = "admin";

// Lemma unlikely to exist; used only to reach the “new lemma” form state (no Confirm).
const novelLemma = `zzzcypress${Date.now()}`;

// See betmas-e2e Plan/02_contributor.md §3–§4; edit form (§5) is in editor.cy.js.
// The read-only policy (support/read-only.js) blocks any save endpoint, so
// these tests stop at the filled form by construction, not by discipline.
// The Confirm write test runs only with --expose ALLOW_WRITES=1 (disposable
// local stack only — it persists a new entry under DillmannData/new).
const itWrites = Cypress.expose("ALLOW_WRITES") ? it : it.skip;

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

  // Plan §4 — the Confirm test saves a new entry to DillmannData/new, so it
  // needs --expose ALLOW_WRITES=1 (CI sets it: the stack is disposable).
  // It also guards against the save running as guest instead of the logged-in user.
  describe("Create new entry", () => {
    beforeEach(() => {
      // the duplicate check is a GET fired on keyup (resources/js/checkforlemma.js)
      cy.intercept("GET", "**/api/Dillmann/otherlemmas*").as("lemmaCheck");
      // the "New Entry" link lives on the home page, not on the user page
      cy.visit("newentry.html");
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

    // Write test (skipped unless --expose ALLOW_WRITES=1): Plan §4 step 6 —
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
