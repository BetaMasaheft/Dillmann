function callformpart(file, id) {
    
    // check first that the element is not there already
    var myElem = document.getElementById(id);
    // if it is not there, load it
    if (myElem === null) {
        $.ajax(file, {
            success: function (data) {
                $("#searchForm").append(data);
            }
        });
    }
    // else it has already been loaded, therefore simply show it.
    var jid = '#' + id
    $(jid).toggle();
};

$("#erweitertesuche").one("click", function () {
    callformpart('as.html', 'erweiterte');
});

$("#erweitertesuche").click(function () {
    $('.erweit').toggle("slow");
});

$(document).ready(function () {
    
    var base = 'https://betamasaheft.eu/'
    $("a.reference").on("click", function () {
        var el = this;
        
        var reference = $(this).data('value')
        var splitref = reference.split("/");
        var sourceReference = $(this).data('ref')
        var bmid = $(this).data('bmid')
        var apiDTS = base + '/api/dts/text/'
        var result = ""
        
        $.getJSON(apiDTS + reference, function (data) {
            var id = data[ "0"].id
            var cit = data[ "0"].citation
            var title = data[ "0"].title
            var text = data[ "0"].text
            if (data[ "0"].info) {
                result += '<p>There is no text yet for this passage in Beta maṣāḥǝft.</p><a target="_blank" href="/works/' + bmid + '">See Work record</a>'
            } else {
                result += '<p>Text of ' + cit + ' .</p><p>' + text + '</p><a target="_blank" href="/works/' + bmid + '/text?start=' + splitref[1] + '">See full text</a>'
            }
            $(el).popover({
                html: true,
                content: result,
                title: 'Text Passage'
            });
        })
    })
    
    var lemma = ''
    var lem = $('#lemma').text()
    //console.log(lem)
    // this assumes a case exactely like "ሲኖዶስ et ሴኖዶስ" and that the kwic search rest function will read the white space as OR
    if (/et/i.test(lem)) {
        var split = lem.split(' ');
        lemma = split[0] + ' ' + split[2]
    } else {
        lemma = $('#lemma').text()
    }
    //console.log(lemma)
    var apiurl = base + '/api/kwicsearch?element=ab&element=title&element=q&element=p&element=l&element=incipit&element=explicit&element=colophon&element=summary&element=persName&element=placeName&q='
    
    var call = apiurl + lemma
    //console.log(call)
    
    $('#lemma').append('፡')
    $('.navlemma').append('፡')
    $.getJSON(call, function (data) {
        // console.log(data)
        
        var items =[];
        var listitems = data.items
            var numberofitems = ''
            if($.isArray(listitems)){numberofitems += listitems.length} else {numberofitems += 1}
           // console.log(numberofitems)
            
        if (numberofitems > 1) {
            
            $('#NumOfAtt').text(data.total + ' records contain ');
            
            for (var i = 0; i < numberofitems ; i++) {
                
                var match = data.items[i];
          //console.log(match)      
          
                var view = match.text;
                
                var id = match.id;
                
                
                var coll = match.collection;
                
                var title = match.title
                
                var parsedtext = '';
                
                if (match.hitsCount > 1) {
                    var text =[];
                    $.each(match.results, function (i, val) {
                        text.push(val)
                    })
                    parsedtext += text.join(' ')
                } else {
                    parsedtext += match.results
                }
     //           console.log(parsedtext)
                items.push("<div class='w3-panel w3-Pale-Blue w3-card-4 w3-third' id='" + id + "'><h3><a target='_blank' href='/" + coll + '/' + id + "/" + view + "?hi=" + lemma + '&start=' + match.textpart + "'>" + title + "</a> <span class='w3-badge'>" + match.hitsCount + "</span></h3><div lang='gez' class='word'>" + parsedtext + "</div></div>");
            }
            $("<div/>", {
                addClass : 'w3-white alpheios-enabled',
                html: items.join("")
            }).appendTo("#attestations");
        } else {
            
            if (numberofitems == 1) {
                var match = data.items
                
                var id = match.id;
                
                var coll = match.collection;
                
                var title = match.title
                
                var parsedtext = '';
                
                if (match.hitsCount > 1) {
                    var text =[];
                    $.each(match.results, function (i, val) {
                        text.push(val)
                    })
                    parsedtext += text.join(' ')
                } else {
                    parsedtext += match.results
                }
//                console.log(parsedtext)
                var url = "/" + coll + '/' + id + "/main?hi=" + encodeURIComponent(lemma)
                items.push('<div  class="w3-panel w3-pale-blue w3-card-4 w3-padding-64"><h3><a href="' + url + '">' + title + "</a><span class='w3-badge'>" + match.hitsCount + "</span></h3><div lang='gez' class='word'>" + parsedtext + "</div></div>");
                
                
                $("<div/>", {
                    html: items.join("")
                }).appendTo("#attestations");
            } else {
                
                $("<div/>", {
                addClass : 'w3-card-4 w3-white w3-panel alpheios-enabled',
                    html: 'no attestations of ' + lemma + ' exactly'
                }).appendTo("#attestations");
            }
        }
    });
});

$( document ).ajaxComplete(function() {
 $('div#attestations [lang="gez"] p span').each(function (wn) {
        
      // console.log(wn)
    
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
            $(word).append($("<span class='alpheios-word attpopup' data-value='atp" + wn + i + "'>" + nostops.w + nostops.stop + "\
            <span class='popuptext w3-hide w3-tiny w3-padding' id='atp" + wn + i + "'>\
            Search " + nostops.w + " :<br/>\
            <a href='/as.html?query=" + nostops.w + "' target='_blank'>in Beta maṣāḥǝft</a><br/>\
            <a href='/morpho?query=" + nostops.w + "' target='_blank'>in the Gǝʿǝz Morphological Parser</a><br/>\
            <a href='/morpho/corpus?query=" + nostops.w + "&type=string' target='_blank'>in the TraCES annotations</a><br/>\
            <a href='" + url + parm + nostops.w + "' target='_blank'>in the Online Lexicon</a><br/>\
            Double click on the word to load the results of the morphological parsing with Alpheios.\
            </span> </span>"));
        } else {
            /*onmouseover='popup("+'"p'+wn+i+'"'+")' onmouseout='popup("+'"p'+wn+i+'"'+")'*/
            $(word).append($("<span class='alpheios-word attpopup' data-value='atp" + wn + i + "'>" + nostops.w + nostops.stop + '&nbsp;' + "\
            <span class='popuptext w3-hide w3-tiny w3-padding' id='atp" + wn + i + "'>\
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
       $('.attpopup').on('mouseover mouseout',function () {
    var id = $(this).data('value') 
  //  console.log(id)
    popupatt(id)
});
 function popupatt(id) {
  var x = document.getElementById(id);
  if (x.className.indexOf("w3-show") == -1) {
    x.className += " w3-show";
  } else { 
    x.className = x.className.replace(" w3-show", "");
  }
}
    });