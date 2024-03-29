

function toggletabletextview(source) {
    var tableid = 'tabularView' + source
    var textid = 'textView' + source
    //console.log(tableid + textid)
    var table = document.getElementById(tableid);
    
    var text = document.getElementById(textid);
    
    if (table.className.indexOf("w3-show") == -1) {
        table.className += " w3-show";
        text.className = text.className.replace("w3-show", "w3-hide");
    } else {
        table.className = table.className.replace("w3-show", "");
        text.className += " w3-show";
    }
}

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
    if (fullq.length = 0) {
    } else { if (/[\*\?\~\(\"]/g.test(fullq)) {
            var q = fullq.replace(/[\*\?\~\(\"]/g, '')
        } else {
            var q = fullq
        }
        //console.log(q)
        $('.entry span:contains("' + q + '")').toggleClass('queryTerm')
    }
});


$(document).ready(function () {
    
    var fullq = getUrlParameter('q');
    // console.log(fullq)
    if (fullq == '') {//console.log(fullq.length)
    } else { if (/[\*\?\~\(]/g.test(fullq)) {
            var q = fullq.replace(/[\*\?\~\(]/g, '')
        } else {
            var q = fullq
        }
        //console.log(q)
        $('.entry span:contains("' + q + '")').addClass('queryTerm')
    }
    
    function popup(id) {
        var x = document.getElementById(id);
        if (x.className.indexOf("w3-show") == -1) {
            x.className += " w3-show";
        } else {
            x.className = x.className.replace(" w3-show", "");
        }
    }
    
    
    $('div.entry [lang="gez"]').each(function (wn) {
        
      //  console.log(wn)
        
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
                $(word).append($("<span class='alpheios-word popup' lang='gez' data-value='p" + wn + i + "'>" + nostops.w + nostops.stop + "\
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
                $(word).append($("<span class='alpheios-word popup' lang='gez' data-value='p" + wn + i + "'>" + nostops.w + nostops.stop + '&nbsp;' + "\
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
    
    $('.popup').on('mouseover mouseout', function () {
        var id = $(this).data('value')
        //console.log(id)
        popup(id)
    });
    
    $('.RefPopup').on('click', function () {
        var id = $(this).data('value')
       // console.log(id)
        popup(id)
    });
    
    function blink(id) {
     //   console.log(id)
        var pointedDiv = document.getElementById(id);
        if (pointedDiv.className.indexOf("w3-card-4") == -1) {
        //    console.log('no w3 class, add it')
            pointedDiv.className += " w3-card-4";
        } else {
          //  console.log('remove w3 class')
            pointedDiv.className = pointedDiv.className.replace(" w3-card-4", "");
        }
    }
    
    $('.internalRef').on('mouseover mouseout', function () {
        var id = $(this).data('value')
       // console.log(id)
        blink(id)
    });
    
    
    function nextvideas(v) {
        var v2 = v.next("span")
        var v2text = v2.text()
        var v2tooltip = v2.children("span").children("span")
        var vid2 = v2text.substring(0, v2text.indexOf('፡'))
        var trimvid2 = vid2.replace('፡', '')
        var apiurl = '/api/Dillmann/search/form?q='
        $.getJSON(apiurl + trimvid2, function (data) {
            var newurl2 = data[ "0"].id
            var newa2 = ' </br> Or go directly to <a target="_blank" href="/Dillmann/lemma/' + newurl2 + '">' + vid2 + '</a>'
            $(v2tooltip).append(newa2)
        });
    }
    
    $('div.entry [title="videas"]').each(function () {
        var v = $(this).next("span")
        var vtext = v.text()
        var vtooltip = v.children("span").children("span")
        var vid = vtext.substring(0, vtext.indexOf('፡'))
        var trimvid = vid.replace('፡', '')
      //  console.log(trimvid)
        var apiurl = '/api/Dillmann/search/form?q='
        $.getJSON(apiurl + trimvid, function (data) {
            var newurl = data[ "0"].id
            var newa = ' </br> Or go directly to <a target="_blank" href="/Dillmann/lemma/' + newurl + '">' + vid + '</a>'
            $(vtooltip).append(newa)
        });
        if (v.next("span")) {
            nextvideas(v);
            var v2 = v.next("span")
            if (v2.next("span")) {
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
        
        if ($(this).prev().is("span")) {
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
    
    //$('div.entry .HINC').each(function () {
   //     //console.log($(this))
 //       var v = $(this)
  //      var next = $('.smallArrow.next')
  //      //console.log(next)
  //      var n = next.data('value')
  //      var newa = ' <a class="clean" target="_blank" href="/Dillmann/lemma/' + n + '">' + $(v).text() + ' ' + $(next).text() + '  <i class="fa fa-external-link-square" aria-hidden="true"/></a>'
  //      $(v).replaceWith(newa)
  //  });
});


$(document).ready(function () {
    var thislemma = $('#lemma a').text()
    var apicall = '/api/Dillmann/lemmatranslit?q=' + thislemma
   // $.getJSON(apicall, function (data) {
      //  console.log(data)
//        $('#lemma').append('<span class="w3-medium w3-tooltip"> ' + data.translit + '<span class="w3-text">From TraCES annotations.</span></span>')
 //   });
    var trimmed = $('#rootmembers').data('value')
    var removeOrdinals = trimmed.replace(/I/gi,'')
    var thisid = removeOrdinals
    var apicall = '/api/Dillmann/rootmembers/' + thisid
    $.getJSON(apicall, function (data) {
       // console.log(data)
        var h = data.here
        var p = data.prev
        var n = data.next
        //console.log(data)
        //prepare variable for list items from rest
        var ptext = ''
        // add previous members to list
        // if it is one, add it directly, otherways loop
        if (data.prev == null) {
        } else {
            if (data.prev.length >= 1) {
                for (var i = 0; i < data.prev.length; i++) {
                    var match = data.prev[i]
                    
                    ptext += '<li class="nodot"><a href="/Dillmann/lemma/' + match.id + '">' + match.lem + '</a> [#' + match.n + '] </li>'
                };
            } else {
                
                ptext += '<li class="nodot"><a href="/Dillmann/lemma/' + p.id + '">' + p.lem + '</a> [#' + p.n + ']  </li>'
            }
        }
        //add current member to list, without link, in bold
         if (data.here == null) {
        } else {
        ptext += '<li class="nodot"><b>' + h.lem + '</b> [#' + h.n + '] </li>';
        }
        // add next members until next root
        if (data.next == null) {
        } else {
            if (data.next.length >= 1) { for (var i = 0; i < data.next.length; i++) {
                    var match = data.next[i]
                    
                    ptext += '<li class="nodot"><a href="/Dillmann/lemma/' + match.id + '">' + match.lem + '</a> [# ' + match.n + ']  </li>'
                };
            } else {
                
                ptext += '<li class="nodot"><a href="/Dillmann/lemma/' + n.id + '">' + n.lem + '</a> [#' + n.n + ']  </li>'
            }
        }
        //push items to list
        $("<ul/>", {
            class: 'w3-ul w3-small',
            html: ptext
        }).appendTo("#showroot")
    });
});