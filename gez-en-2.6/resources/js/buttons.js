/*http://stackoverflow.com/questions/19606115/firing-javascript-event-on-every-dom-change-complete*/
    /*http://stackoverflow.com/questions/18491828/javascript-array-of-key-value-pairs-uses-literal-variable-name-for-key*/
    
var mapping = [
{'button' : 'translation', 'string' : '>>>'}, 
{'button' : 'ND', 'string' : '{ND}'}, 
{'button' : 'transcription', 'string' : '>gez!>'}, 
{'button' : 'PoS', 'string' : '++'}, 
{'button' : 'reference', 'string' : '*|*'}, 
{'button' : 'bibliography', 'string' : '[,]bm:'}, 
{'button' : 'otherLanguage', 'string' : '\\**\\*'}, 
{'button' : 'internalReference', 'string' : '{DiL.}'},  
{'button' : 'label', 'string' : '(())'},  
{'button' : 'gramGroup', 'string' : '[[]]'},  
{'button' : 'case', 'string' : '@@'},  
{'button' : 'gen', 'string' : 'ˆˆ'},  
{'button' : 'NestSense', 'string' : '<S< >S>'}

]

$(document).ready(function() {
 for (var i = 0; i <mapping.length; i++) {
     matching(mapping[i].button, mapping[i].string)
 }

});

$('#addsense').bind('DOMSubtreeModified', function() {

 for (var i = 0; i <mapping.length; i++) {
     matchingadd(mapping[i].button, mapping[i].string)
 }

});


function matching(button, string) {
    $("a[id$='"+button+"']").on('click', function () {
        var id = this.id;
    var lang = id.substring(0, id.indexOf(button));
    
    var destination = 'sense' + lang
        insertAtCaret(destination, string)
       
    });
}

function matchingadd(button, string) {
    $("#addsense div:last-child a[id$='"+button+"']").on('click', function () {
        var id = this.id;
    var lang = id.substring(0, id.indexOf(button));
    
    var destination = 'sense' + lang
        insertAtCaret(destination, string)
       
    });
}


/*From Stackoverflow 
http://stackoverflow.com/questions/1064089/inserting-a-text-where-cursor-is-using-javascript-jquery
* */
function insertAtCaret(areaId, text) {
    var txtarea = document.getElementById(areaId);
    if (! txtarea) {
        return;
    }
    
    var scrollPos = txtarea.scrollTop;
    var strPos = 0;
    var br = ((txtarea.selectionStart || txtarea.selectionStart == '0') ?
    "ff": (document.selection ? "ie": false));
    if (br == "ie") {
        txtarea.focus();
        var range = document.selection.createRange();
        range.moveStart ('character', - txtarea.value.length);
        strPos = range.text.length;
    } else if (br == "ff") {
        strPos = txtarea.selectionStart;
    }
    
    var front = (txtarea.value).substring(0, strPos);
    var back = (txtarea.value).substring(strPos, txtarea.value.length);
    txtarea.value = front + text + back;
    strPos = strPos + text.length;
    if (br == "ie") {
        txtarea.focus();
        var ieRange = document.selection.createRange();
        ieRange.moveStart ('character', - txtarea.value.length);
        ieRange.moveStart ('character', strPos);
        ieRange.moveEnd ('character', 0);
        ieRange.select();
    } else if (br == "ff") {
        txtarea.selectionStart = strPos;
        txtarea.selectionEnd = strPos;
        txtarea.focus();
    }
    
    txtarea.scrollTop = scrollPos;
}