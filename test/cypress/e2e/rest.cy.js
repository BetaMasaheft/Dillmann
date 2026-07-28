// generated from modules/rest.xqm
// happy-path checks use a real fixture entry from DillmannData (also used as the
// worked example in apidoc.html): La320bde8c90b4a769a9826eafc8004e2, n=3839,
// form "ባሕቲት", column marker c0497

it("GET /api/Dillmann/SPARQL", () => {
  cy.request({
    url: "/api/Dillmann/SPARQL?query=" + encodeURIComponent("SELECT * WHERE { ?s ?p ?o } LIMIT 1"),
    failOnStatusCode: false,
  }).then((res) => {
    // depends on the "dillmann" dataset being seeded in Fuseki, which CI's generic
    // fuseki container isn't - just confirm the route itself is wired up (not a
    // router 404) rather than assert on query results
    expect(res.status).to.not.eq(404);
  });
});

it("GET /api/Dillmann/rootmembers/La320bde8c90b4a769a9826eafc8004e2", () => {
  cy.request({
    url: "/api/Dillmann/rootmembers/La320bde8c90b4a769a9826eafc8004e2",
    failOnStatusCode: false,
  }).then((res) => {
    // same Fuseki-dataset caveat as SPARQL above
    expect(res.status).to.not.eq(404);
  });
});

it("GET /api/Dillmann/search/form?q=...", () => {
  cy.request({
    url: "/api/Dillmann/search/form?q=" + encodeURIComponent("ባሕቲት"),
    failOnStatusCode: false,
  }).then((res) => {
    expect(res.status).to.eq(200);
    expect(res.body).to.be.an("array");
  });
});

it("GET /api/Dillmann/search/{element}?q=... with a quote does not break the query", () => {
  // element and q used to be spliced into a util:eval string; a quote in either
  // one used to break out of the generated XPath and crash the request
  cy.request({
    url: "/api/Dillmann/search/form?q=" + encodeURIComponent("o'clock"),
    failOnStatusCode: false,
  }).then((res) => {
    expect(res.status).to.eq(200);
  });
});

it("GET /api/Dillmann/list/xml", () => {
  cy.request({ url: "/api/Dillmann/list/xml?start=1", failOnStatusCode: false }).then((res) => {
    expect(res.status).to.eq(200);
    expect(res.body).to.include("<list>");
    expect(res.body).to.include("<lemmas>");
  });
});

it("GET /api/Dillmann/list/json", () => {
  cy.request({ url: "/api/Dillmann/list/json?start=1", failOnStatusCode: false }).then((res) => {
    expect(res.status).to.eq(200);
    expect(res.body).to.have.property("total");
  });
});

it("GET /api/Dillmann/La320bde8c90b4a769a9826eafc8004e2/teientry", () => {
  cy.request({
    url: "/api/Dillmann/La320bde8c90b4a769a9826eafc8004e2/teientry",
    failOnStatusCode: false,
  }).then((res) => {
    expect(res.status).to.eq(200);
    expect(res.body).to.include("La320bde8c90b4a769a9826eafc8004e2");
  });
});

it("GET /api/Dillmann/{unknown}/teientry returns 400", () => {
  cy.request({
    url: "/api/Dillmann/doesnotexist12345/teientry",
    failOnStatusCode: false,
  }).then((res) => {
    expect(res.status).to.eq(400);
  });
});

it("GET /api/Dillmann/La320bde8c90b4a769a9826eafc8004e2/json", () => {
  cy.request({
    url: "/api/Dillmann/La320bde8c90b4a769a9826eafc8004e2/json",
    failOnStatusCode: false,
  }).then((res) => {
    expect(res.status).to.eq(200);
    expect(JSON.stringify(res.body)).to.include("La320bde8c90b4a769a9826eafc8004e2");
  });
});

it("GET /api/Dillmann/{unknown}/json returns 400", () => {
  cy.request({
    url: "/api/Dillmann/doesnotexist12345/json",
    failOnStatusCode: false,
  }).then((res) => {
    expect(res.status).to.eq(400);
  });
});

it("GET /api/Dillmann/La320bde8c90b4a769a9826eafc8004e2/txt", () => {
  cy.request({
    url: "/api/Dillmann/La320bde8c90b4a769a9826eafc8004e2/txt",
    failOnStatusCode: false,
  }).then((res) => {
    expect(res.status).to.eq(200);
    expect(res.body.length).to.be.greaterThan(0);
  });
});

it("GET /api/Dillmann/{unknown}/txt returns 400", () => {
  cy.request({
    url: "/api/Dillmann/doesnotexist12345/txt",
    failOnStatusCode: false,
  }).then((res) => {
    expect(res.status).to.eq(400);
  });
});

it("GET /api/Dillmann/all/txt", () => {
  cy.request({ url: "/api/Dillmann/all/txt?start=1&total=2", failOnStatusCode: false }).then((res) => {
    expect(res.status).to.eq(200);
    expect(res.body.length).to.be.greaterThan(0);
  });
});

it("GET /api/Dillmann/number/3839", () => {
  cy.request({ url: "/api/Dillmann/number/3839", failOnStatusCode: false }).then((res) => {
    expect(res.status).to.eq(200);
    expect(res.body.lemma).to.eq("La320bde8c90b4a769a9826eafc8004e2");
  });
});

it("GET /api/Dillmann/column/c0497", () => {
  cy.request({ url: "/api/Dillmann/column/c0497", failOnStatusCode: false }).then((res) => {
    expect(res.status).to.eq(200);
    expect(res.body.lemma).to.eq("La320bde8c90b4a769a9826eafc8004e2");
  });
});

it("GET /api/Dillmann/otherlemmas?lemma=...", () => {
  cy.request({
    url: "/api/Dillmann/otherlemmas?lemma=" + encodeURIComponent("ባሕቲት"),
    failOnStatusCode: false,
  }).then((res) => {
    expect(res.status).to.eq(200);
    expect(res.body).to.have.property("total");
  });
});

it("GET /api/Dillmann/otherlemmas?lemma=... with a quote does not break the query", () => {
  // lemma used to be spliced into a util:eval string; a quote in it used to
  // break out of the generated XPath and crash the request
  cy.request({
    url: "/api/Dillmann/otherlemmas?lemma=" + encodeURIComponent("o'clock"),
    failOnStatusCode: false,
  }).then((res) => {
    expect(res.status).to.eq(200);
    expect(res.body).to.have.property("total");
  });
});
