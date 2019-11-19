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
            var language = prompt("Please enter the language ISO 639-1 id (e.g. de it es fr...)", "en");
            var idlanguage = $('textarea#sense' + language)
            if ($(idlanguage).length == 0) { if (language != null) {
                    var divgroups = "<div> \
                    <div class='w3-container'> \
                    <label for='source" + language + "' class='w3-quarter'>Source of " + language + " meaning</label> \
                    <div class='w3-threequarter w3-bar'> \
                    <select class='w3-select w3-border w3-bar-item' id='source" + language + "' name='source" + language + "' required='required'> \
                    <option value='dillmann'>Dillmann</option> \
                    <option value='traces'>TraCES</option> \
                    </select> \
                    <small class='w3-item w3-bar-item'>type here the " + language + " Gǝʿǝz form to be added</small> \
                    </div> \
                    </div> \
                    <div class='w3-container'> \
                    <label for='sense" + language + "' class='w3-quarter'>" + language + " Meaning</label> \
                    <div class='w3-threequarter'> \
                    <div class='w3-bar'> \
                    <a id='" + language + "NestSense' class='w3-button w3-xsmall w3-blue'>Meaning</a> \
                    <a id='" + language + "translation' class='w3-button w3-xsmall w3-blue'>Translation</a> \
                    <a id='" + language + "transcription' class='w3-button w3-xsmall w3-blue'>Transcription</a> \
                    <a id='" + language + "PoS' class='w3-button w3-xsmall w3-blue'>PoS</a> \
                    <a id='" + language + "reference' class='w3-button w3-xsmall w3-blue'>Reference</a> \
                    <a id='" + language + "bibliography' class='w3-button w3-xsmall w3-blue'>Bibliography</a> \
                    <a id='" + language + "otherLanguage' class='w3-button w3-xsmall w3-blue'>Language</a>  \
                    <a id='" + language + "internalReference' class='w3-button w3-xsmall w3-blue'>Internal Reference</a> \
                    <a id='" + language + "gramGroup' class='w3-button w3-xsmall w3-blue'>Grammar Group</a> \
                    <a id='" + language + "label' class='w3-button w3-xsmall w3-blue'>Label</a> \
                    <a id='" + language + "case' class='w3-button w3-xsmall w3-blue'>Case</a> \
                    <a id='" + language + "gen' class='w3-button w3-xsmall w3-blue'>Gender</a> \
                    <a id='" + language + "ND' class='w3-button w3-xsmall w3-blue'>ND</a> \
                    </div> \
                    <textarea class='w3-input w3-border' id='sense" + language + "' name='sense" + language + "' style='height:250px;'>&lt;S" + language + "&lt;&gt;S&gt;</textarea> \
                    <small class='w3-small'>type here your " + language + " definition. Do not remove the language please.</small> \
                    </div> \
                    </div> \
                    </div>"
                    
                    $(place).append('<div>' + divgroups + '<a href="#" class="w3-button w3-small w3-red">Remove ' + language + ' meaning permanently</a></div>');
                    //add input box
                }
            }
        
             else {   //console.log(idlanguage);
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