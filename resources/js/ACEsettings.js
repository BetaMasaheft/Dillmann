// Both call sites render #ACEeditor in the same branch as this script tag,
// but guard anyway - cheap insurance against the two ever drifting apart
// (see BetaMasaheft/Dillmann#558, the same shape of crash for #rootmembers).
var ACEeditorEl = document.getElementById('ACEeditor');
if (ACEeditorEl) {
    ace.require("ace/ext/language_tools");
    var txt = ACEeditorEl.innerHTML;
    var editor = ace.edit("ACEeditor");
    editor.resize()
    editor.setTheme("ace/theme/github");
    editor.getSession().setMode("ace/mode/xml");
    editor.setValue(txt);
}