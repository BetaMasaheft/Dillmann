$('#confirmDelete').on('click', function(){

    var nE = ""
    if ( $('#notifyEditors').is(":checked")) {
 
    nE+='yes';
 
} else {nE+='no' }

    var id = $('#Lid').text()
    var user = $('#user').text()
$.post("/Dillmann/edit/delete.xq", {
       id: id, notifyEditors : nE, user : user
    }).done(function (data) {
       // console.log(data);
    }); 
    $('#choice').html('<div class="col-md-4 col-md-offset-4"  style="text-align: center; "><h1> Farewell !</h1><p class="lead">A backup copy has been made, you and the editors have been emailed.</p><a role="button" href="/Dillmann/" class="btn btn-info">Home</a></div>')
});

$('#abortDelete').on('click', function(){
var id = $('#Lid').text()
var url = "/Dillmann/lemma/" + id
window.location.href= url
});
