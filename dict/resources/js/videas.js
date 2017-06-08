$(document).ready(function () {
    $('#completeList').dataTable();
    $('[data-toggle="popover"]').popover({
        html: true
    });
    
    $('[data-toggle="tooltip"]').tooltip();
    
    $('[lang="grc"]').each(function () {
    
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
   
   $('i.translationLa').each(function () {
    
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
   
     $('span.dilEx').each(function () {
    
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
    
    $('[lang="gez"]').each(function () {
    
    var gez = $(this)
    var words = $(gez).text().split(" ");
    
    $(this).empty();
    var url = 'http://betamasaheft.aai.uni-hamburg.de/search.html?query='
$.each(words, function(i, v) {
    $(gez).append($("<a target='_blank' href='" + url + v +"'/>").text(v + ' '));
  
});
   } );
    
    $('[data-title="videas"]').each(function () {
        var v = $(this).next("span")
        var vid = v.text()
        var trimvid = vid.replace('፡', '')
        var apiurl = 'http://betamasaheft.aai.uni-hamburg.de/api/Dillmann/search/form?q='
        $.getJSON(apiurl + trimvid, function (data) {
            var newurl = data[ "0"].id
            var newa = '<a target="_blank" href="'+ newurl+  '">'+ vid+ '</a>'
            $(v).replaceWith(newa)
        });
    });
    
    $('.internalLink').each(function () {
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