$(document).ready(function () {
    
    
    var max_fields = 10; //maximum input boxes allowed
    var wrapper = $(".input_fields_wrap");
    //Fields wrapper
    var place = $("#addsense");
    //Fields wrapper
    var add_button = $(".add_field_button");
    //Add button ID
    
    var x = 1; //initlal text box count
    $(add_button).click(function (e) {
        //on add input button click
        e.preventDefault();
        if (x < max_fields) {
            //max input box allowed
            x++; //text box increment
            var language = prompt("Please enter the language ISO 639-1 id (e.g. de it es fr...)", "de");
            var idlanguage = $('textarea#sense' + language)
            if ($(idlanguage).length == 0) { if (language != null) {
                    var divgroups = "<div> \
                    <div class='form-group'> \
                    <label for='source" + language + "' class='col-md-2 col-form-label'>Source of " + language + " meaning</label> \
                    <div class='col-md-10'> \
                    <select class='form-control' id='source" + language + "' name='source" + language + "' required='required'> \
                    <option value='dillmann'>Dillmann</option> \
                    <option value='traces'>TraCES</option> \
                    </select> \
                    <small class='form-text text-muted'>type here the " + language + " Gǝʿǝz form to be added</small> \
                    </div> \
                    </div> \
                    <div class='form-group'> \
                    <label for='sense" + language + "' class='col-md-2 col-form-label'>" + language + " Meaning</label> \
                    <div class='col-md-10'> \
                    <div class='btn-group'> \
                    <a id='" + language + "NestSense' class='btn btn-primary btn-sm'>Meaning</a> \
                    <a id='" + language + "translation' class='btn btn-primary btn-sm'>Translation</a> \
                    <a id='" + language + "transcription' class='btn btn-primary btn-sm'>Transcription</a> \
                    <a id='" + language + "PoS' class='btn btn-primary btn-sm'>PoS</a> \
                    <a id='" + language + "reference' class='btn btn-primary btn-sm'>Reference</a> \
                    <a id='" + language + "bibliography' class='btn btn-primary btn-sm'>Bibliography</a> \
                    <a id='" + language + "otherLanguage' class='btn btn-primary btn-sm'>Language</a>  \
                    <a id='" + language + "internalReference' class='btn btn-primary btn-sm'>Internal Reference</a> \
                    <a id='" + language + "gramGroup' class='btn btn-primary btn-sm'>Grammar Group</a> \
                    <a id='" + language + "label' class='btn btn-primary btn-sm'>Label</a> \
                    <a id='" + language + "case' class='btn btn-primary btn-sm'>Case</a> \
                    <a id='" + language + "gen' class='btn btn-primary btn-sm'>Gender</a> \
                    <a id='" + language + "ND' class='btn btn-primary btn-sm'>ND</a> \
                    </div> \
                    <textarea class='form-control' id='sense" + language + "' name='sense" + language + "' style='height:250px;'>&lt;S" + language + "&lt;&gt;S&gt;</textarea> \
                    <small class='form-text text-muted'>type here your " + language + " definition. Do not remove the language please.</small> \
                    </div> \
                    </div> \
                    </div>"
                    
                    $(place).append('<div>' + divgroups + '<a href="#" class="btn btn-danger remove_field btn-xs">Remove ' + language + ' meaning permanently</a></div>');
                    //add input box
                }
            }
        
             else {   console.log(idlanguage);
                alert('a sense with this language already exists')
            } 
        }
    });
    
    $(wrapper).on("click", ".remove_field", function (e) {
        //user click on remove text
        e.preventDefault();
        $(this).parent('div').remove();
        x--;
    })
});