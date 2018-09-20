$(document).ready( function() {
  $("a[href='#files']").last().click( function() {
    //    Remove .active class from all .tab class elements
    $('li').removeClass('active');
    //    Add .active class to currently clicked element
    $("a[href='#files']").parent().addClass('active');
  });
});
