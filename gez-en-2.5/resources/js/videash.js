
function togglElements(id) {
  var x = document.getElementById(id);
  if (x.className.indexOf("w3-show") == -1) {
    x.className += " w3-show";
  } else {
    x.className = x.className.replace(" w3-show", "");
  }
}

/*https://stackoverflow.com/questions/19491336/get-url-parameter-jquery-or-how-to-get-query-string-values-in-js

 * gets the parameters from the url */
var getUrlParameter = function getUrlParameter(sParam) {
    var sPageURL = decodeURIComponent(window.location.search.substring(1)),
    sURLVariables = sPageURL.split('&'),
    sParameterName,
    i;
    
    for (i = 0; i < sURLVariables.length; i++) {
        sParameterName = sURLVariables[i].split('=');
        
        if (sParameterName[0] === sParam) {
            return sParameterName[1] === undefined ? true: sParameterName[1];
        }
    }
};

$('.highlights').change(function () {
    var fullq = getUrlParameter('q');
    //console.log(fullq)
    if (/[\*\?\~\(\"]/g.test(fullq)) {
        var q = fullq.replace(/[\*\?\~\(\"]/g, '')
    } else {
        var q = fullq
    }
    //console.log(q)
    $('.entry span:contains("' + q + '")').toggleClass('queryTerm')
});


$(document).ready(function () {
    
    var fullq = getUrlParameter('q');
    //  console.log(fullq)
    if (/[\*\?\~\(]/g.test(fullq)) {
        var q = fullq.replace(/[\*\?\~\(]/g, '')
    } else {
        var q = fullq
    }
    //console.log(q)
    $('.entry span:contains("' + q + '")').addClass('queryTerm')
    
    
    function popup(id) {
  var x = document.getElementById(id);
  if (x.className.indexOf("w3-show") == -1) {
    x.className += " w3-show";
  } else { 
    x.className = x.className.replace(" w3-show", "");
  }
}

   


    
/*    $('#completeList').dataTable();
    
    $('[data-toggle="popover"]').popover({
        html: true
    });
    
    $('[data-toggle="tooltip"]').tooltip();*/
    /*
    $('div.entry [lang="grc"]').each(function () {
        
        var grc = $(this)
        
        var normspace = $(grc).text().replace(/\s\s+/g, ' ');
        var words = normspace.split(" ");
        
        $(this).empty();
        var url = 'http://www.perseus.tufts.edu/hopper/morph?l='
        var parm = '&la=greek'
        $.each(words, function (i, v) {
            $(grc).append($(" <a target='_blank' href='" + url + v + parm + "'/>").text(v + ' '));
        });
    });
    
    $('div.entry i.translationLa').each(function () {
        
        var la = $(this)
        var normspace = $(la).text().replace(/\s\s+/g, ' ');
        var words = normspace.split(" ");
        
        $(this).empty();
        var url = 'http://www.perseus.tufts.edu/hopper/morph?l='
        var parm = '&la=la'
        $.each(words, function (i, v) {
        if (v.endsWith('!')) {
                console.log('esclamation mark');
                var vv = v.substr(0, v.indexOf('!'));
                $(la).append($("<a target='_blank' href='" + url + vv + parm + "'/>").text(' ' + vv + '! '));
            }else if (v.endsWith('?')) {
                console.log('question mark');
                var vv = v.substr(0, v.indexOf('?'));
                $(la).append($(" <a target='_blank' href='" + url + vv + parm + "'/>").text(' ' + vv + '? '));
            }
            else if (v.endsWith(']')) {
                //console.log('square brace');
                var vv = v.substr(0, v.indexOf(']'));
                $(la).append($(" <a target='_blank' href='" + url + vv + parm + "'/>").text(' ' + vv + '] '));
            } else if (v.endsWith(',') && /!(I|II|III)/g.test(v)) {
                //console.log('comma');
                var vv = v.substr(0, v.indexOf(','));
                $(la).append($(" <a target='_blank' href='" + url + vv + parm + "'/>").text(' ' + vv + ', '));
            }
        else{    $(la).append($(" <a target='_blank' href='" + url + v + parm + "'/>").text(v + ' '));}
        });
    });
    
    $('div.entry span.dilEx').each(function () {
        
        var la = $(this)
        var normspace = $(la).text().replace(/\s\s+/g, ' ');
        var words = normspace.split(" ");
        
        $(this).empty();
        var url = 'http://www.perseus.tufts.edu/hopper/morph?l='
        var parm = '&la=la'
        $.each(words, function (i, v) {
            if (v.endsWith('.') && /!\w\.\w\./g.test(v)) {
                //console.log('fullstop');
                var vv = v.substr(0, v.indexOf('.'));
                $(la).append($(" <a target='_blank' href='" + url + vv + parm + "'/>").text(' ' + vv + '. '));
            }
            
            else if (v.endsWith(',') && v.startsWith('(')) {$(la).text(v)}
            else if (v.endsWith(':')) {
                //console.log('column');
                var vv = v.substr(0, v.indexOf(':'));
                $(la).append($(" <a target='_blank' href='" + url + vv + parm + "'/>").text(' ' + vv + ': '));
            } else if (v.endsWith(';')) {
                //console.log('semi column');
                var vv = v.substr(0, v.indexOf(';'));
                $(la).append($(" <a target='_blank' href='" + url + vv + parm + "'/>").text(' ' + vv + '; '));
            } else if (v.endsWith(']')) {
                //console.log('square brace');
                var vv = v.substr(0, v.indexOf(']'));
                $(la).append($(" <a target='_blank' href='" + url + vv + parm + "'/>").text(' ' + vv + '] '));
            } else if (v.endsWith('!')) {
                console.log('esclamation mark');
                var vv = v.substr(0, v.indexOf('!'));
                $(la).append($("<a target='_blank' href='" + url + vv + parm + "'/>").text(' ' + vv + '! '));
            }else if (v.endsWith('?')) {
                console.log('question mark');
                var vv = v.substr(0, v.indexOf('?'));
                $(la).append($(" <a target='_blank' href='" + url + vv + parm + "'/>").text(' ' + vv + '? '));
            }else if (v.endsWith(',') && /!(I|II|III)/g.test(v)) {
                //console.log('comma');
                var vv = v.substr(0, v.indexOf(','));
                $(la).append($(" <a target='_blank' href='" + url + vv + parm + "'/>").text(' ' + vv + ', '));
            } else {
                //console.log('nocolumn')
                $(la).append($(" <a target='_blank' href='" + url + v + parm + "'/>").text(' ' + v + ' '));
            }
        });
    });
    */
    $('div.entry [lang="gez"]').each(function (wn) {
        
       console.log(wn)
    
    var word = $(this)
    /*make all spaces a single space*/
    var normspace = $(word).text().replace(/\s\s+/g, ' ');
    /*    split the string in words at the white space*/
    var words = normspace.split(" ");
    var countwords = words.length;
    /*    delete all in the element*/
    $(this).empty();
    /*    build fuzzy query search string for lexicon*/
    var url = '/Dillmann/?mode=fuzzy'
    var parm = '&q='
    /*    for each item in the split sequence, which shoud be a word add to the emptied element the word with a link*/
    $.each(words, function (i, v) {
        /*initialize an empty object which will contain the word and the punctionation, to be able to print back all but use in the query the string without punctuation*/
        var nostops = {
        }
        /*check if there is an end of word punctuation mark*/
        if (v.endsWith('፡')) {
            nostops.w = v.substr(0, v.indexOf('፡'));
            nostops.stop = '፡'
        } else if (v.endsWith('።')) {
            nostops.w = v.substr(0, v.indexOf('።'));
            nostops.stop = '።'
        } else {
            nostops.w = v; nostops.stop = ''
        }
        /*        if it is the last word in the span, then add it straight, if it is somewhere else in the span sequence, then add back a white space
         * onmouseover='popup("+'"p'+wn+i+'"'+")' onmouseout='popup("+'"p'+wn+i+'"'+")'
         * */
        if (i == countwords - 1) {
            $(word).append($("<span class='alpheios-word popup' data-value='p" + wn + i + "'>" + nostops.w + nostops.stop + "\
            <span class='popuptext w3-hide w3-tiny w3-padding' id='p" + wn + i + "'>\
            Search " + nostops.w + " :<br/>\
            <a href='/as.html?query=" + nostops.w + "' target='_blank'>in Beta maṣāḥǝft</a><br/>\
            <a href='/morpho?query=" + nostops.w + "' target='_blank'>in the Gǝʿǝz Morphological Parser</a><br/>\
            <a href='/morpho/corpus?query=" + nostops.w + "&type=string' target='_blank'>in the TraCES annotations</a><br/>\
            <a href='" + url + parm + nostops.w + "' target='_blank'>in the Online Lexicon</a><br/>\
            Double click on the word to load the results of the morphological parsing with Alpheios.\
            </span> </span>"));
        } else {
            /*onmouseover='popup("+'"p'+wn+i+'"'+")' onmouseout='popup("+'"p'+wn+i+'"'+")'*/
            $(word).append($("<span class='alpheios-word popup' data-value='p" + wn + i + "'>" + nostops.w + nostops.stop + '&nbsp;' + "\
            <span class='popuptext w3-hide w3-tiny w3-padding' id='p" + wn + i + "'>\
            Search " + nostops.w + " :<br/>\
            <a href='/as.html?query=" + nostops.w + "' target='_blank'>in Beta maṣāḥǝft</a><br/>\
            <a href='/morpho?query=" + nostops.w + "' target='_blank'>in the Gǝʿǝz Morphological Parser</a><br/>\
            <a href='/morpho/corpus?query=" + nostops.w + "&type=string' target='_blank'>in the TraCES annotations</a><br/>\
            <a href='" + url + parm + nostops.w + "' target='_blank'>in the Online Lexicon</a><br/>\
            Double click on the word to load the results of the morphological parsing with Alpheios.\
            </span> </span>"));
        }
    });
    });
    
     $('.popup').on('mouseover mouseout',function () {
    var id = $(this).data('value') 
    console.log(id)
    popup(id)
});

  function blink(id) {
  console.log(id)
  var pointedDiv = document.getElementById(id);
  if (pointedDiv.className.indexOf("w3-card-4") == -1) {
  console.log('no w3 class, add it')
    pointedDiv.className += " w3-card-4";
  } else { 
    console.log('remove w3 class')
    pointedDiv.className = pointedDiv.className.replace(" w3-card-4", "");
  }
}

$('.internalRef').on('mouseover mouseout',function () {
    var id = $(this).data('value') 
    console.log(id)
    blink(id)
});

    
     function nextvideas(v){
    var v2 = v.next("span")
          var vid2 = v2.text()
        var trimvid2 = vid2.replace('፡', '')
        var apiurl = '/api/Dillmann/search/form?q='
        $.getJSON(apiurl + trimvid2, function (data) {
            var newurl2 = data[ "0"].id
            var newa2 = ' <a target="_blank" href="/Dillmann/lemma/' + newurl2 + '">' + vid2 + '</a>'
            $(v2).replaceWith(newa2)
        });
        
        }
    
    $('div.entry [title="videas"]').each(function () {
        var v = $(this).next("span")
        var vid = v.text()
        var trimvid = vid.replace('፡', '')
        var apiurl = '/api/Dillmann/search/form?q='
        $.getJSON(apiurl + trimvid, function (data) {
            var newurl = data[ "0"].id
            var newa = ' <a target="_blank" href="/Dillmann/lemma/' + newurl + '">' + vid + '</a>'
            $(v).replaceWith(newa)
        });
         if(v.next("span")){
            nextvideas(v);
          var v2 = v.next("span")
           if(v2.next("span")){
            nextvideas(v2);
        }
        }
    });
    
    
     $('[title="idem quod"]').each(function () {
        var v = $(this).next("span")
        var vid = v.text()
        var trimvid = vid.replace('፡', '')
        var apiurl = '/api/Dillmann/search/form?q='
        $.getJSON(apiurl + trimvid, function (data) {
            var newurl = data[ "0"].id
            var newa = ' <a target="_blank" href="' + newurl + '">' + vid + '</a>'
            $(v).replaceWith(newa)
        });
    });
    
    $('[title="quod videas"]').each(function () {
       
        if($(this).prev().is("span")){
       // console.log($(this))
             var v = $(this).prev("span")
            var vid = v.text()
        var trimvid = vid.replace('፡', '')
        var apiurl = '/api/Dillmann/search/form?q='
        $.getJSON(apiurl + trimvid, function (data) {
            var newurl = data[ "0"].id
            var newa = ' <a target="_blank" href="' + newurl + '">' + vid + '</a>'
            $(v).replaceWith(newa)
        });
        } else {
        //  console.log($(this))
        var v = $(this)
        var next = $('.smallArrow.next')
        //console.log(next)
        var n = next.data('value')
        var newa = ' <a target="_blank" href="/Dillmann/lemma/' + n + '">' + $(v).text() + ' ' + $(next).text() + '  <i class="fa fa-external-link-square" aria-hidden="true"/></a>'
        $(v).replaceWith(newa) 
        }
        
    });
    
    $('div.entry .internalLink').each(function () {
        var v = $(this)
        var vid = $(this).data('value')
        var apiurl = '/api/Dillmann/column/'
        $.getJSON(apiurl + vid, function (data) {
            var newurl = data.lemma
            var newa = ' <a target="_blank" href="/Dillmann/lemma/' + newurl + '">' + $(v).text() + '  <i class="fa fa-external-link-square" aria-hidden="true"/></a>'
            $(v).replaceWith(newa)
        });
    });
    
    $('div.entry .HINC').each(function () {
        //console.log($(this))
        var v = $(this)
        var next = $('.smallArrow.next')
        //console.log(next)
        var n = next.data('value')
        var newa = ' <a target="_blank" href="/Dillmann/lemma/' + n + '">' + $(v).text() + ' ' + $(next).text() + '  <i class="fa fa-external-link-square" aria-hidden="true"/></a>'
        $(v).replaceWith(newa)
    });
});


$('#rootmembers').click(function () {
    var thisid = $(this).data('value')
    var apicall = '/api/Dillmann/rootmembers/' + thisid
    $.getJSON(apicall, function (data) {
        var h = data.here
        var p = data.prev
        var n = data.next
        //console.log(data)
        //prepare variable for list items from rest
        var ptext = ''
        // add previous members to list
        // if it is one, add it directly, otherways loop
        if (data.prev.length) {
            for (var i = 0; i < data.prev.length; i++) {
                var match = data.prev[i]
                var root = ''
                if (match.role == 'currentRoot') {
                    root += '(This)'
                } else if (match.role == 'nextRoot') {
                    root += '(Next root)'
                } else if (match.role == 'prevRoot') {
                    root += '(Root)'
                }
                ptext += '<li class="nodot"><a href="/Dillmann/lemma/' + match.id + '">' + match.lem + '</a> [#' + match.n + '] ' + root + ' </li>'
            };
        } else {
            var proot = ''
            if (p.role == 'currentRoot') {
                proot += '(This)'
            } else if (p.role == 'nextRoot') {
                proot += '(Next root)'
            } else if (p.role == 'prevRoot') {
                proot += '(Root)'
            }
            ptext += '<li class="nodot"><a href="/Dillmann/lemma/' + p.id + '">' + p.lem + '</a> [#' + p.n + '] ' + proot + ' </li>'
        }
        //add current member to list, without link, in bold
        var hroot = ''
        if (h.role == 'currentRoot') {
            hroot += '(This)'
        } else if (h.role == 'nextRoot') {
            hroot += '(Next root)'
        } else if (h.role == 'prevRoot') {
            hroot += '(Root)'
        }
        ptext += '<li class="nodot"><b>' + h.lem + '</b> [#' + h.n + '] ' + hroot + ' </li>';
        // add next members until next root
        if (data.next.length) { for (var i = 0; i < data.next.length; i++) {
                var match = data.next[i]
                var root = ''
                if (match.role == 'currentRoot') {
                    root += '(This)'
                } else if (match.role == 'nextRoot') {
                    root += '(Next root)'
                } else if (match.role == 'prevRoot') {
                    root += '(Root)'
                }
                ptext += '<li class="nodot"><a href="/Dillmann/lemma/' + match.id + '">' + match.lem + '</a> [# ' + match.n + '] ' + root + ' </li>'
            };
        } else {
            var nroot = ''
            if (n.role == 'currentRoot') {
                nroot += '(This)'
            } else if (n.role == 'nextRoot') {
                nroot += '(Next root)'
            } else if (n.role == 'prevRoot') {
                nroot += '(Root)'
            }
            ptext += '<li class="nodot"><a href="/Dillmann/lemma/' + n.id + '">' + n.lem + '</a> [#' + n.n + '] ' + nroot + ' </li>'
        }
        
        //push items to list
        $("<ul/>", {
            addClass: 'nodot',
            html: ptext
        }).appendTo("#showroot")
    });
});