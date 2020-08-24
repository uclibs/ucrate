// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require dataTables/jquery.dataTables
//= require dataTables/bootstrap/3/jquery.dataTables.bootstrap
//= require jquery_ujs
//= require jquery-ui-1.9.2/jquery.ui.widget
//= require jquery-ui-1.9.2/jquery.ui.core
//= require jquery-ui-1.9.2/jquery.ui.menu
//= require jquery-ui-1.9.2/jquery.ui.position
//= require jquery-ui-1.9.2/jquery.ui.autocomplete
//= require jquery-ui-1.9.2/jquery.ui.effect
//= require jquery-ui-1.9.2/jquery.ui.effect-highlight
//= require turbolinks
//
// Required by Blacklight
//= require blacklight/blacklight

//= require bulkrax/application
//= require_tree .
//= require hyrax

//= require lodash
//= require license-selector
//= require select-license
//= require form-tab-nav

document.cookie = "timezone=" + Intl.DateTimeFormat().resolvedOptions().timeZone + "; path=/; secure";
