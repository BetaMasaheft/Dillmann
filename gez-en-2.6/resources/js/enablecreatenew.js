
    $('#form').on('change paste keyup', function() {

        var empty = false;
        $('#form').each(function() {
            if ($(this).val() == '') {
                empty = true;
            }
        });

        if (empty) {
            $('#confirmcreatenew').attr('disabled', 'disabled'); // updated according to http://stackoverflow.com/questions/7637790/how-to-remove-disabled-attribute-with-jquery-ie
        } else {
        
            $('#confirmcreatenew').removeAttr('disabled'); // updated according to http://stackoverflow.com/questions/7637790/how-to-remove-disabled-attribute-with-jquery-ie
       var t = $(this).val()
       //console.log(t)
       if(/፡$/.test(t)){
            if(confirm('Your lemma entry ends with ፡ ! Click OK to remove the final separator. ')){
            var nosep = t.slice(0,-1)
            $(this).val(nosep);
            alert('thanks for removing it')}
            else{'you will see twice ፡፡ in the app for this lemma unless you add a second world'}
        } 
        
        }
       
        
    });
    