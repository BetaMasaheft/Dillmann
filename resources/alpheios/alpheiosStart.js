// alpheios-embedded 3.x loads its components library on demand; both bundles are vendored
// (see scripts/copy-vendor-libs.js) and located through the appBase global that the page
// templates inject (config:appBaseScript).
document.addEventListener("DOMContentLoaded", function () {
  var base = (window.appBase || "") + "/resources/js/external/alpheios/";
  import(base + "alpheios-embedded.min.js")
    .then(function () {
      return window.AlpheiosEmbed.importDependencies({
        mode: "custom",
        libs: { components: base + "alpheios-components.min.js" },
      });
    })
    .then(function (Embedded) {
      new Embedded({ clientId: "https://betamasaheft.eu", enabledSelector: ".word" }).activate();
    })
    .catch(function (e) {
      console.error("Import of the Alpheios libraries failed: " + e);
    });
});
