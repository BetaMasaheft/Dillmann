#!/usr/bin/env node
// Copies the browser-facing files of each package.json "dependencies" entry from
// node_modules into resources/{js,css,fonts}/external, where the app's
// <script>/<link> tags load them from. Run via `npm run vendor:copy` (or
// `npm run vendor`, which also installs first) - this is the "vendor" Ant target in build.xml.
//
// Only the specific dist file(s) actually used by the app are copied, not whole
// packages. Add an entry here whenever a new vendor dependency is added to package.json.
//
// resources/{js,css,fonts}/external are reproducible from package.json + this script,
// so they're gitignored.

const fs = require("node:fs");
const path = require("node:path");

const ROOT = path.resolve(__dirname, "..");
const NODE_MODULES = path.join(ROOT, "node_modules");
const DEST_ROOTS = {
  js: path.join(ROOT, "resources", "js", "external"),
  css: path.join(ROOT, "resources", "css", "external"),
  fonts: path.join(ROOT, "resources", "fonts", "external"),
};

// Each entry: [destination subfolder, [ [sourceRelativeToPackage, destFilename, root?, subdir?], ... ]]
// root selects which of DEST_ROOTS the file lands under and defaults to "js".
// subdir overrides the package's destination subfolder for that file ("" = directly under the root).
// Keep a stylesheet together with any asset directory (images/) it reaches through a relative
// url() - same root and subfolder. Webfonts of font-awesome and bootstrap go flat into the shared
// "fonts" root instead; their CSS url() is rewritten below (see rewriteFontUrls).
const MANIFEST = {
  "ace-builds": [
    "ace",
    [
      // ace loads modes, themes and workers at runtime relative to its own <script src>
      ["src-min-noconflict/ace.js", "ace.js"],
      ["src-min-noconflict/ext-language_tools.js", "ext-language_tools.js"],
      ["src-min-noconflict/mode-xml.js", "mode-xml.js"],
      ["src-min-noconflict/theme-github.js", "theme-github.js"],
      ["src-min-noconflict/worker-xml.js", "worker-xml.js"],
    ],
  ],
  "alpheios-components": [
    "alpheios",
    [
      ["dist/alpheios-components.min.js", "alpheios-components.min.js"],
      ["dist/style/style-components.min.css", "style-components.min.css", "css"],
    ],
  ],
  "alpheios-embedded": ["alpheios", [["dist/alpheios-embedded.min.js", "alpheios-embedded.min.js"]]],
  bootstrap: [
    "bootstrap",
    [
      ["dist/css/bootstrap.min.css", "bootstrap.min.css", "css"],
      ["dist/js/bootstrap.min.js", "bootstrap.min.js"],
      ["dist/fonts/glyphicons-halflings-regular.eot", "glyphicons-halflings-regular.eot", "fonts", ""],
      ["dist/fonts/glyphicons-halflings-regular.svg", "glyphicons-halflings-regular.svg", "fonts", ""],
      ["dist/fonts/glyphicons-halflings-regular.ttf", "glyphicons-halflings-regular.ttf", "fonts", ""],
      ["dist/fonts/glyphicons-halflings-regular.woff", "glyphicons-halflings-regular.woff", "fonts", ""],
      ["dist/fonts/glyphicons-halflings-regular.woff2", "glyphicons-halflings-regular.woff2", "fonts", ""],
    ],
  ],
  "datatables.net-bs": ["datatables", [["css/dataTables.bootstrap.css", "dataTables.bootstrap.css", "css"]]],
  "font-awesome": [
    "font-awesome",
    [
      ["css/font-awesome.min.css", "font-awesome.min.css", "css"],
      ["fonts", "", "fonts", ""],
    ],
  ],
  jquery: ["jquery", [["dist/jquery.min.js", "jquery.min.js"]]],
  "jquery-migrate": ["jquery-migrate", [["dist/jquery-migrate.min.js", "jquery-migrate.min.js"]]],
  "jquery-ui-dist": [
    "jquery-ui",
    [
      ["jquery-ui.min.js", "jquery-ui.min.js"],
      ["jquery-ui.min.css", "jquery-ui.min.css", "css"],
      ["images", "images", "css"],
    ],
  ],
  "jquery.easing": ["jquery.easing", [["jquery.easing.min.js", "jquery.easing.min.js"]]],
  "virtual-keyboard": [
    "virtual-keyboard",
    [
      ["dist/js/jquery.keyboard.js", "jquery.keyboard.js"],
      ["dist/js/jquery.keyboard.extension-altkeyspopup.min.js", "jquery.keyboard.extension-altkeyspopup.min.js"],
      ["dist/js/jquery.keyboard.extension-typing.min.js", "jquery.keyboard.extension-typing.min.js"],
      ["dist/js/jquery.mousewheel.min.js", "jquery.mousewheel.min.js"],
      ["dist/css/keyboard-basic.min.css", "keyboard-basic.min.css", "css"],
    ],
  ],
  "w3-css": ["w3-css", [["w3.css", "w3.css", "css"]]],
};

let copied = 0;
for (const [pkg, [destSubdir, files]] of Object.entries(MANIFEST)) {
  const pkgDir = path.join(NODE_MODULES, pkg);
  if (!fs.existsSync(pkgDir)) {
    throw new Error(`${pkg} is listed in the vendor manifest but missing from node_modules - run npm install first`);
  }
  for (const [from, to, root = "js", subdir = destSubdir] of files) {
    const destDir = path.join(DEST_ROOTS[root], subdir);
    fs.mkdirSync(destDir, { recursive: true });
    const src = path.join(pkgDir, from);
    if (!fs.existsSync(src)) {
      throw new Error(`${pkg}: expected file ${from} not found at ${src}`);
    }
    fs.cpSync(src, path.join(destDir, to), { recursive: true });
    copied += 1;
  }
}

// Some vendored stylesheets reference their webfonts via a relative url() that only worked when the
// font files sat next to the CSS in the original package. Since every such font now lands flat in
// resources/fonts/external, rewrite each of those references to point there.
function rewriteFontUrls(cssSubdir, cssFilename, oldPrefix) {
  const cssPath = path.join(DEST_ROOTS.css, cssSubdir, cssFilename);
  const fontsRel = path.relative(path.dirname(cssPath), DEST_ROOTS.fonts).split(path.sep).join("/");
  const original = fs.readFileSync(cssPath, "utf8");
  const rewritten = original.split(oldPrefix).join(`${fontsRel}/`);
  if (rewritten === original) {
    throw new Error(
      `${cssPath}: expected to rewrite ${oldPrefix} references, but found none - did the package's CSS change?`,
    );
  }
  fs.writeFileSync(cssPath, rewritten);
}

rewriteFontUrls("font-awesome", "font-awesome.min.css", "../fonts/");
rewriteFontUrls("bootstrap", "bootstrap.min.css", "../fonts/");

console.log(`Copied ${copied} vendor files/dirs into resources/{js,css,fonts}/external`);
