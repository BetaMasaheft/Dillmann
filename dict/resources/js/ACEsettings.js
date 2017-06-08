ace.require("ace/ext/language_tools");
    var txt = document.getElementById('ACEeditor').innerHTML;
    var editor = ace.edit("ACEeditor");
    editor.resize()
    editor.setTheme("ace/theme/github");
    editor.getSession().setMode("ace/mode/xml");
    editor.setValue(txt);