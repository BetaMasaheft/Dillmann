
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
            return sParameterName[1] === undefined ? true : sParameterName[1];
        }
    }
};

$('.highlights').change(function () {
var fullq = getUrlParameter('q');
console.log(fullq)
/*var split = fullq.split(/\s/g);
console.log(split)
for(var i = 0; i < split.length; i++) {
*/
if(/[\*\?\~\(]/g.test(fullq)){var q = fullq.replace(/[\*\?\~\(]/g, '')} else {var q = fullq}
console.log(q)
$('.entry span:contains("' + q + '")').toggleClass('queryTerm')
/*}*/
});


$(document).ready(function () {
$('#highlights').click(function () {
var fullq = getUrlParameter('q');
console.log(fullq)
var split = fullq.split(/\s/g);
console.log(split)
for(var i = 0; i < split.length; i++) {

if(/[\*\?\~\(]/g.test(split[i])){var q = split[i].replace(/[\*\?\~\(]/g, '')} else {var q = split[i]}
console.log(q)
$('.entry span:contains("' + q + '")').addClass('queryTerm')
}
});
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
$.each(words, function(i, v) {
    $(grc).append($("<a target='_blank' href='" + url + v + parm + "'/>").text(v + ' '));
  
});
   } );
   
   $('div.entry i.translationLa').each(function () {
    
    var la = $(this)
    var normspace = $(la).text().replace(/\s\s+/g, ' ');
    var words = normspace.split(" ");
    
    $(this).empty();
    var url = 'http://www.perseus.tufts.edu/hopper/morph?l='
    var parm = '&la=la'
$.each(words, function(i, v) {
    $(la).append($("<a target='_blank' href='" + url + v + parm + "'/>").text(v + ' '));
  
});
   } );
    
    $('div.entry span.dilEx').each(function () {
    
    var la = $(this)
    var normspace = $(la).text().replace(/\s\s+/g, ' ');
    var words = normspace.split(" ");
    
    $(this).empty();
    var url = 'http://www.perseus.tufts.edu/hopper/morph?l='
    var parm = '&la=la'
$.each(words, function(i, v) {
    $(la).append($("<a target='_blank' href='" + url + v + parm + "'/>").text(v + ' '));
  
});
   } );
    
    $('div.entry [lang="gez"]').each(function () {
    
    var gez = $(this)
    var normspace = $(gez).text().replace(/\s\s+/g, ' ');
    var words = normspace.split(" ");
    
    $(this).empty();
    var url = 'http://betamasaheft.aai.uni-hamburg.de/search.html?query='
$.each(words, function(i, v) {
    $(gez).append($("<a target='_blank' href='" + url + v +"'/>").text(v + ' '));
  
});
   } );
    
    $('div.entry [data-title="videas"]').each(function () {
        var v = $(this).next("span")
        var vid = v.text()
        var trimvid = vid.replace('፡', '')
        var apiurl = 'http://betamasaheft.aai.uni-hamburg.de/api/Dillmann/search/form?q='
        $.getJSON(apiurl + trimvid, function (data) {
            var newurl = data[ "0"].id
            var newa = '<a target="_blank" href="/Dillmann/lemma/'+ newurl+  '">'+ vid+ '</a>'
            $(v).replaceWith(newa)
        });
    });
    
    $('div.entry .internalLink').each(function () {
        var v = $(this)
        var vid = $(this).data('value')
        var apiurl = 'http://betamasaheft.aai.uni-hamburg.de/api/Dillmann/column/'
        $.getJSON(apiurl + vid, function (data) {
            var newurl = data.lemma
            var newa = '<a href="/Dillmann/lemma/'+ newurl+  '">'+ $(v).text() + '  <i class="fa fa-external-link-square" aria-hidden="true"/></a>'
            $(v).replaceWith(newa)
        });
    });
    
  
});