
$('#form').on('paste keyup', function () {
    var lemma = $(this).val()
    if ($(this).val() == '') {$('#checkifitalreadyexists').html('<div class="alert alert-info">Please paste or write something above and I will tell you if it is already in.</div>')}
    else {
    var api = '/api/Dillmann/otherlemmas?lemma='
    $.getJSON(api + lemma, function (data) {
        
        //console.log(data)
        if (data.total == 0) {
            //console.log('0results');
            $('#checkifitalreadyexists').empty().html('<div class="alert alert-success">this is a new lemma!</div>')
        } 
        else  if (data.total == 1) {
            $('#checkifitalreadyexists').empty();
            var items =[]
                var match = data.response
                var id = match.id;
                var hit = match.hit;
                items.push('<a target="_blank" href="/Dillmann/lemma/' + id + '">' + hit + "</a> ")
            
            $("<div/>", {
                class: 'alert alert-warning',
                html: 'Be carefull, this lemma is already there! See: ' + items.join(', ')
            }).appendTo("#checkifitalreadyexists");
        }
        else {
            $('#checkifitalreadyexists').empty();
            var items =[]
            for (var i = 0; i < data.total; i++) {
                var match = data.response[i]
                var id = match.id;
                var hit = match.hit;
                items.push('<a target="_blank" href="/Dillmann/lemma/' + id + '">' + hit + "</a> ")
            };
            $("<div/>", {
                class: 'alert alert-warning',
                html: 'Be carefull, this lemma is already there! See: ' + items.join(', ')
            }).appendTo("#checkifitalreadyexists");
        }
    });
    }
});