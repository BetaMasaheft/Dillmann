describe("permalinks to versions of a lemma", () => {
  const id = "La28f0d661a324ba5a2364e70e63ef317";

  it("the lemma page has a permalinks panel pointing at the file in DillmannData", () => {
    cy.visit(`Dillmann/lemma/${id}`);
    cy.get("#permanentIDs").should("have.attr", "data-id", id);
    cy.get("#permanentIDs")
      .invoke("attr", "data-path")
      .should("match", new RegExp(`^[^/]+/${id}\\.xml$`));
  });

  it("lists the commits from GitHub with permalinks", () => {
    cy.intercept("GET", "https://api.github.com/repos/BetaMasaheft/DillmannData/commits*", [
      {
        sha: "0123456789abcdef0123456789abcdef01234567",
        commit: { committer: { date: "2026-01-01T00:00:00Z" }, author: { name: "someone" }, message: "<b>edit</b>" },
      },
    ]).as("commits");
    cy.visit(`Dillmann/lemma/${id}`);
    cy.contains("a", "Permalinks").click();
    cy.get("#LoadPermanentIDs").click();
    cy.wait("@commits");
    cy.get("#permanentIDs a[href$='/Dillmann/permanent/0123456789abcdef0123456789abcdef01234567/" + id + "']").should(
      "exist",
    );
    // commit messages are text, never markup
    cy.get("#permanentIDs b").should("not.exist");
  });

  it("says so when the lemma has no merged commits", () => {
    cy.intercept("GET", "https://api.github.com/repos/BetaMasaheft/DillmannData/commits*", []).as("commits");
    cy.visit(`Dillmann/lemma/${id}`);
    cy.get("#LoadPermanentIDs").click({ force: true });
    cy.wait("@commits");
    cy.contains("has not been merged").should("exist");
  });

  it("a permanent URL with an unknown commit explains that no version exists", () => {
    cy.visit(`Dillmann/permanent/0000000000000000000000000000000000000000/${id}`);
    cy.contains("No version of the lemma");
  });
});
