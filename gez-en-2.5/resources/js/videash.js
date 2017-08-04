
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
    if (/[\*\?\~\(]/g.test(fullq)) {
        var q = fullq.replace(/[\*\?\~\(]/g, '')
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
    
    
    $('#completeList').dataTable();
    
    $('[data-toggle="popover"]').popover({
        html: true
    });
    
    $('[data-toggle="tooltip"]').tooltip();
    
    $('div.entry [lang="grc"]').each(function () {
        
        var grc = $(this)
        
        var normspace = $(grc).text().replace(/\s\s+/g, ' ');
        var words = normspace.split(" ");
        
        $(this).empty();
        var url = 'http://www.perseus.tufts.edu/hopper/morph?l='
        var parm = '&la=greek'
        $.each(words, function (i, v) {
            $(grc).append($("<a target='_blank' href='" + url + v + parm + "'/>").text(v + ' '));
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
            $(la).append($("<a target='_blank' href='" + url + v + parm + "'/>").text(v + ' '));
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
                console.log('fullstop');
                var vv = v.substr(0, v.indexOf('.'));
                $(la).append($("<a target='_blank' href='" + url + vv + parm + "'/>").text(' ' + vv + '. '));
            } else if (v.endsWith(':')) {
                console.log('column');
                var vv = v.substr(0, v.indexOf(':'));
                $(la).append($("<a target='_blank' href='" + url + vv + parm + "'/>").text(' ' + vv + ': '));
            } else {
                console.log('nocolumn')
                $(la).append($("<a target='_blank' href='" + url + v + parm + "'/>").text(' ' + v + ' '));
            }
        });
    });
    
    $('div.entry [lang="gez"]').each(function () {
        
        var gez = $(this)
        var normspace = $(gez).text().replace(/\s\s+/g, ' ');
        var words = normspace.split(" ");
        
        $(this).empty();
        var url = '/search.html?query='
        $.each(words, function (i, v) {
            $(gez).append($("<a target='_blank' href='" + url + v + "'/>").text(v + ' '));
        });
    });
    
    $('div.entry [data-title="videas"]').each(function () {
        var v = $(this).next("span")
        var vid = v.text()
        var trimvid = vid.replace('፡', '')
        var apiurl = '/api/Dillmann/search/form?q='
        $.getJSON(apiurl + trimvid, function (data) {
            var newurl = data[ "0"].id
            var newa = '<a target="_blank" href="/Dillmann/lemma/' + newurl + '">' + vid + '</a>'
            $(v).replaceWith(newa)
        });
    });
    
    $('div.entry .internalLink').each(function () {
        var v = $(this)
        var vid = $(this).data('value')
        var apiurl = '/api/Dillmann/column/'
        $.getJSON(apiurl + vid, function (data) {
            var newurl = data.lemma
            var newa = '<a target="_blank" href="/Dillmann/lemma/' + newurl + '">' + $(v).text() + '  <i class="fa fa-external-link-square" aria-hidden="true"/></a>'
            $(v).replaceWith(newa)
        });
    });
    
    $('div.entry .HINC').each(function () {
        console.log($(this))
        var v = $(this)
        var next = $('.smallArrow.next')
        console.log(next)
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