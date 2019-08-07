var setPublisher = function()   {
    var changedValue = false;
    var field = $('input[class*=publisher]').first();

    // When the DOI form is changed
    $('.set-doi').change(function() {
        if ($("input[type=radio]:checked").val() == "not_now")  {
            removeValue();
        } else  {
            changeValue();
        }
    })

    function changeValue()  {
        if (field.val() == "") {
            $('#setPublisher').show();
            field.val("University of Cincinnati");
            changedValue = true;
        }
    }

    function removeValue()  {
        if (changedValue == true && field.val() == "University of Cincinnati")   {
            field.val("");
            changedValue = false;
            $('#setPublisher').hide();
        }
    }
}
document.addEventListener("turbolinks:load", function() {
    setPublisher();
})