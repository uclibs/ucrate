/*
This javascript sets the creator when a new work is created.

Initially creator is set to the current user, then if the user
chooses to submit on behalf of another user, the creator field
is updated to switch to that user.
*/

/*
This javascript sets the creator when a new work is created.

Initially creator is set to the current user, then if the user
chooses to submit on behalf of another user, the creator field
is updated to switch to that user.
*/

var setCurrentUserAsCreator = function() {
  // if the creator field is present...
  if( $('input[id$=_creator]').length ) {
    // and it's not collection_creator
    if( $('input[id$=collection_creator]').length == 0 && $('input[id$=etd_creator]').length == 0) {
      // read the current user's name from the data attribute
      var creator = document.querySelector('#current_user').dataset.name;

      // set the current user's name as the first creator
      $('input[id$=_creator]').first().val(creator);
    }
  }
}

var setProxySelectionAsCreator = function() {
  // function to check if element is visible
  function isElementInViewport (el) {

    //special bonus for those using jQuery
    if (typeof jQuery === "function" && el instanceof jQuery) {
        el = el[0];
    }

    var rect = el.getBoundingClientRect();

    return (
        rect.top >= 0 &&
        rect.left >= 0 &&
        rect.bottom <= (window.innerHeight || document.documentElement.clientHeight) && /*or $(window).height() */
        rect.right <= (window.innerWidth || document.documentElement.clientWidth) /*or $(window).width() */
    );
	}

  // when the *_on_behalf_of is changed...
  $('[id$=_on_behalf_of]').change(function() {
    var target = $('input[id$=_creator]').first();

    // check if we're on the metadata tab
    var selected = $("a[aria-controls='metadata']").attr('aria-expanded');

    // if not, select it
    if (selected != 'true') {
      $("a[aria-controls='metadata']").click();
    }

    // check if the creators field is in the viewport
    var visible = isElementInViewport(target);

    // if not visible, scroll to the element
    if (visible == false) {
      $('html, body').animate({
        scrollTop: target.parents('div.form-group').offset().top
      }, 250);
    }

    // grab the id of the person being selected
    ownerId = $('[id$=_on_behalf_of] option:selected').val();

    // highlight the field
    target.effect("highlight", {}, 1000);

    if (ownerId == '') {
      setCurrentUserAsCreator();
    } else {
      // gather all the email ids and the matching creator names
      var depositorDictionary = {}
      $('user').each(function() {
        var email = $(this).attr('id');
        var name = $(this).attr('data-name')
        depositorDictionary[email] = name;
      });

      var creator = depositorDictionary[ownerId];
      target.val(creator);
    }
  });
}

$(document).on('turbolinks:load', setCurrentUserAsCreator)
$(document).on('turbolinks:load', setProxySelectionAsCreator)
