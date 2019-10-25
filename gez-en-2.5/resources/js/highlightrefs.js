$('#sensela').highlightWithinTextarea({

highlight: [
        {
            highlight: /\*[a-zA-Z\.\s]+\|[a-zA-Z0-9\s,\.]+\*/gi,
            className: 'red'
        },
        {
            highlight: /\\\*\w{2,3}\*/gi,
            className: 'blue'
        },
        {
            highlight: /\<S\w{2,3}\</gi,
            className: 'yellow'
        },
        {
            highlight: /\<[A-Z0-9a-z]\</gi,
            className: 'yellow'
        },{
            highlight: /\>[A-Z0-9a-z]\>/gi,
            className: 'yellow'
        },{
            highlight: /\(\([a-zA-Z0-9\s,\.]+\)\)/gi,
            className: 'green'
        }
    ]
    
});


$("#toggleGuidelines").click(function () {
    $('[id^="dataentrysupport"]').toggle("slow");
   var editor = document.getElementById('editform'); 
    editor.classList.toggle("w3-container");
     editor.classList.toggle("w3-half");
});

function toggleGuidelinesElements(id) {
  var x = document.getElementById(id);
  if (x.className.indexOf("w3-show") == -1) {
    x.className += " w3-show";
  } else {
    x.className = x.className.replace(" w3-show", "");
  }
}

$("#showlabels").click(function () {
  var x = document.getElementById('labels');
  if (x.className.indexOf("w3-show") == -1) {
    x.className += " w3-show";
  } else { 
    x.className = x.className.replace(" w3-show", "");
  }
});

$("#showbibliopointers").click(function () {
    $('[id^="bibliopointers"]').toggle("slow");
});

$("#showposvalues").click(function () {
    $('[id^="posvalues"]').toggle("slow");
});
$("#showplaceTypes").click(function () {
    $('[id^="placeTypes"]').toggle("slow");
});
$("#showpersTypes").click(function () {
    $('[id^="persTypes"]').toggle("slow");
});
$("#showpersRoles").click(function () {
    $('[id^="persRoles"]').toggle("slow");
});



 
