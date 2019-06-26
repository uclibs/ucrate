$(document).on('turbolinks:load', function() {
    var radioButton = $('#no-doi');
    var form = $("form[id^=new_]");
    var element = $('.validation-needed');
   
    //listen on whole form
    form.on('change keydown keyup mouseenter mouseleave', function() {
      var errorMessage = $('#doi-error');
      var successMessage = $('#doi-success');
      //if radio button for existing doi is checked
      if (radioButton.is(':checked')) {
        //if the element's value is not an empty string
        if (!(element.val() == '')) {
          if (runValidations(element)) {
            //if the entered value is a valid doi
            enableSubmitButton();
            appendSuccessMessages(element.parent());
            removeErrorMessages(errorMessage);
          } else {
          //if the entered value is not a valid doi
            disableSubmitButton();
            appendErrorMessages(element.parent(), element);
            removeSuccessMessages(successMessage);
          }
        } else {
          //if the element's value is an empty string, proceed as normal
          removeErrorMessages(errorMessage);
        }
      } else {
        removeErrorMessages(errorMessage);
        removeSuccessMessages(successMessage);
      }
    });
  });
  
  function runValidations(unvalidated_element) {
    if (!validateDoiField(unvalidated_element)) {
      return false;
    } else return true;
  };
  
  function validateDoiField(unvalidated_element) {
    value = unvalidated_element.val();
    var regexPattern  = new RegExp(/^doi:\d+\.?\d+\/[\w|-]+\.?[\w|-]+$/);
    if (regexPattern.test(value)) {
      return true;
    } else return false;
  };

  function startsWithDOI(unvailidated_element) {
    value = unvailidated_element.val();
    var regexPattern = new RegExp(/^doi:/);
    if (regexPattern.test(value)) {
      return true;
    }
    return false;
  }
  
  function disableSubmitButton() {
    return $(':input[type="submit"]').prop('disabled', true);
  };
  
  function enableSubmitButton() {
    return $(':input[type="submit"]').prop('enabled', true);
  };
  
  function appendErrorMessages(attaching_field, element) {
    if (element != undefined && !startsWithDOI(element)) {
      var doiHint = 'DOIs are required to begin with "doi:".';
      var doiHintHTML = '<div id="doi-error" class="alert alert-danger">' + doiHint + '</div>';
      if ($('#doi-error').length < 1) {
        attaching_field.append(doiHintHTML);
      }
    }
    var helpLink ='<a href="/doi_help/" class="alert-link target="_blank"">this page</a>';
    var errorMessage = 'Invalid DOI detected. Please see ' + helpLink + ' for tips on submitting an existing DOI.';
    var errorMessageHTML = '<div id="doi-error" class="alert alert-danger">' + errorMessage + '</div>'; 
    if ($('#doi-error').length < 1) {
      attaching_field.append(errorMessageHTML);
    }
  };
  
  function appendSuccessMessages(attaching_field) {
    var successMessage = 'Congratulations, a valid DOI was detected!';
    var successMessageHTML = '<div id="doi-success" class="alert alert-success">' + successMessage + '</div>';
    if ($('#doi-success').length < 1) {
      attaching_field.append(successMessageHTML);
    }
  };
  
  function removeErrorMessages(errorMessage) {
    errorMessage.remove();
  };
  
  function removeSuccessMessages(successMessage) {
    successMessage.remove();
  };
  
