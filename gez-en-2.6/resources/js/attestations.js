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
    callformpart('newSearch.html', 'erweiterte');
});

$("#erweitertesuche").click(function () {
    $('.erweit').toggle("slow");
});

$(document).ready(function () {
    
    var base = 'https://betamasaheft.eu/'
    $("a.reference").on("click", function () {
        var el = this;
        
        var reference = $(this).data('value')
       // console.log('searching ' + reference)
        var splitref = reference.split("/");
        var sourceReference = $(this).data('ref')
        var bmid = $(this).data('bmid')
        var apiDTS = '/api/dts/text/'
        var result = ""
        
        $.getJSON(apiDTS + reference, function (data) {
            var id = data[ "0"].id
            var cit = data[ "0"].citation
            var title = data[ "0"].title
            var text = data[ "0"].text
            if (data[ "0"].info) {
                result += '<span class="RefPopup popup" data-value="'+reference+'"><i class="fa fa-file-text-o" aria-hidden="true"/><span class="w3-hide w3-small w3-padding popuptext" id="'+reference+'">Text of the passage   <span ><p>There is no text yet for this passage in Beta maṣāḥǝft.</p><a target="_blank" href="/works/' + bmid + '">See Work record</a></span></span></span>'
            } else {
                result += '<span class="RefPopup popup" data-value="'+reference+'"><i class="fa fa-file-text-o" aria-hidden="true"/><span class="w3-hide w3-small w3-padding popuptext" id="'+reference+'">Text of the passage  <span  ><p>Text of ' + cit + ' .</p><p>' + text + '</p><a target="_blank" href="/works/' + bmid + '/text?ref=' + splitref[1] + '">See full text</a></span></span></span>'
            }
            $(el).html(result);
        })
    });
    
    
    var lemma = ''
    var lem = $('#lemma').text()
   // console.log(lem)
    // this assumes a case exactely like "ሲኖዶስ et ሴኖዶስ" and that the kwic search rest function will read the white space as OR
    if (/et/i.test(lem)) {
        var split = lem.split(' ');
        lemma = split[0] + ' ' + split[2]
    } else {
        lemma = $('#lemma').text()
    }
    //console.log(lemma)
    var apiurl =  '/api/kwicsearch?element=ab&element=title&element=q&element=p&element=l&element=incipit&element=explicit&element=colophon&element=summary&element=persName&element=placeName&q='
    
    var call = apiurl + lemma.replace(/I/gi, '')
   // console.log(call)
    
    $('#lemma').append('፡')
    $('.navlemma').append('፡')
    $("#loadattestations").on("click", function () {
    
     $("#loadattestations").addClass("w3-hide");
        
        $.getJSON(call, function (data) {
            // console.log(data)
            
            var items =[];
            var listitems = data.items
            var numberofitems = ''
            if ($.isArray(listitems)) {
                numberofitems += listitems.length
            } else {
                numberofitems += 1
            }
            // console.log(numberofitems)
            
            if (numberofitems > 1) {
                
                $('#NumOfAtt').text(data.total + ' records contain ');
                
                for (var i = 0; i < numberofitems; i++) {
                    
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
                    items.push("<div class='w3-third' id='" + id + "'><div class='w3-container w3-margin w3-panel w3-card-2 '><div class='w3-bar'><h3 class='w3-bar-item'><a target='_blank' href='/" + coll + '/' + id + "/" + view + "?hi=" + lemma + '&start=' + match.textpart + "'>" + title + "</a></h3> <span class='w3-badge w3-bar-item w3-right'>" + match.hitsCount + "</span></div><div lang='gez' class='word'>" + parsedtext + "</div></div></div>");
                }
                $("<div/>", {
                    addClass: 'w3-white alpheios-enabled',
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
                    items.push('<div  class="w3-third w3-panel w3-card-4 w3-padding-64"><h3><a href="' + url + '">' + title + "</a><span class='w3-badge'>" + match.hitsCount + "</span></h3><div lang='gez' class='word'>" + parsedtext + "</div></div>");
                    
                    
                    $("<div/>", {
                        html: items.join("")
                    }).appendTo("#attestations");
                } else {
                    
                    $("<div/>", {
                        addClass: 'w3-card-4 w3-white w3-panel alpheios-enabled',
                        html: 'no attestations of ' + lemma + ' exactly'
                    }).appendTo("#attestations");
                }
            }
        });
    });
});

$(document).ajaxComplete(function () {
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
                <a href='/newSearch.html?searchType=text&mode=none&query=" + nostops.w + "' target='_blank'>in Beta maṣāḥǝft</a><br/>\
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
                <a href='/newSearch.html?query=" + nostops.w + "&searchType=text&mode=none' target='_blank'>in Beta maṣāḥǝft</a><br/>\
                <a href='/morpho?query=" + nostops.w + "' target='_blank'>in the Gǝʿǝz Morphological Parser</a><br/>\
                <a href='/morpho/corpus?query=" + nostops.w + "&type=string' target='_blank'>in the TraCES annotations</a><br/>\
                <a href='" + url + parm + nostops.w + "' target='_blank'>in the Online Lexicon</a><br/>\
                Double click on the word to load the results of the morphological parsing with Alpheios.\
                </span> </span>"));
            }
        });
    });
    $('.attpopup').on('mouseover mouseout', function () {
        var id = $(this).data('value')
        //  console.log(id)
        popupatt(id)
    });
    $('.RefPopup').on('mouseover mouseout', function () {
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