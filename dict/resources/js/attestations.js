$(document).ready(function () {
$("a.reference").on("click", function () {
 var el = this;
var reference = $(this).data('value')
var sourceReference = $(this).data('ref')
var bmid = $(this).data('bmid')

var apiDTS = 'http://betamasaheft.aai.uni-hamburg.de/api/dts/text/'
var result =""

 $.getJSON(apiDTS + reference, function (data) {
 var id = data["0"].id
 var cit = data["0"].citation
 var title = data["0"].title
 var text = data["0"].text
 if(data["0"].info){result+='<p>There is no text yet for this passage in Beta maṣāḥǝft.</p><a target="_blank" href="http://betamasaheft.aai.uni-hamburg.de/works/' + bmid+ '">See Work record</a>'} else {
 result += '<p>Text of ' +cit +' .</p><p>'+text+'</p><a target="_blank" href="http://betamasaheft.aai.uni-hamburg.de/text/' + bmid+ '">See full text</a>'}
$(el).popover({
        html: true, 
        content: result, 
        title: 'Text Passage'
    });
})
 
})

    var lemma = $('#lemma').text()
        var apiurl = 'http://betamasaheft.aai.uni-hamburg.de/api/kwicsearch?element=ab&element=title&element=q&element=p&element=l&element=incipit&element=explicit&element=colophon&element=summary&element=persName&element=placeName&q='
        $.getJSON(apiurl + lemma, function (data) {
       var items = [];
      if (data.total > 1){ for (var i = 0; i < data.items.length; i++) {
            var match = data.items[i]
           
            var id = match.id;
            
            var title = match.title
            
            var parsedtext = '';
            
           if(match.hitsCount > 1){ 
           var text = [];
            $.each(match.results, function( i, val ) {text.push(val)}) 
            parsedtext += text.join(' ')} 
            else {parsedtext += match.results}
            items.push( "<div class='row'><div id='" + id + "' class='card'><div class='col-md-3'><div class='col-md-10'><a href='http://betamasaheft.aai.uni-hamburg.de/"+ id +"?hi="+lemma+"'>" + title +"</a></div><div class='col-md-2'><span class='badge'>"+ match.hitsCount +"</span></div></div><div class='col-md-9'><p>"  + parsedtext +"</p></div></div></div>" );
  
        }
$( "<div/>", {
    html: items.join( "" )
  }).appendTo( "#attestations" );
        } else {
        
        if (data.total == 1){
            var match = data.items
           
            var id = match.id;
            
            var title = match.title
            
            var parsedtext = '';
            
           if(match.hitsCount > 1){ 
           var text = [];
            $.each(match.results, function( i, val ) {text.push(val)}) 
            parsedtext += text.join(' ')} 
            else {parsedtext += match.results}
            var url = "http://betamasaheft.aai.uni-hamburg.de/"+ id +"?hi="+encodeURIComponent(lemma)
            items.push( '<div class="row"><div id="' + id + '" class="card"><div class="col-md-3"><div class="col-md-10"><a href="'+ url +'">' + title +"</a></div><div class='col-md-2'><span class='badge'>"+ match.hitsCount +"</span></div></div><div class='col-md-9'><p>"  + parsedtext +"</p></div></div></div>" );
  
        
$( "<div/>", {
    html: items.join( "" )
  }).appendTo( "#attestations" );
        } else {
        
        $( "<div/>", {
    html: 'no attestations of ' + lemma  + ' exactely'
    }).appendTo( "#attestations" );
    
    }} });
         
});


