// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require codemirror
//= require codemirror-autorefresh
//= require codemirror/modes/css
//= require jquery3
//= require jquery_ujs
//= require jquery.fontselect
//= require cropper.min

//= require dataTables/jquery.dataTables
//= require dataTables/bootstrap/3/jquery.dataTables.bootstrap
//= require stat_slider
//= require turbolinks
//= require cocoon
//= require tether
// Required by Blacklight
//= require blacklight/blacklight

// Moved the Hyku JS *above* the Hyrax JS to resolve #1187 (following
// a pattern found in ScholarSphere)
//
//= require hyku/admin/appearance/colors
//= require hyku/admin/appearance/default_images
//= require hyku/admin/appearance/fonts
//= require hyku/admin/appearance/themes
//= require hyku/groups/per_page
//= require hyku/groups/add_member
//= require proprietor
//= require bootstrap_carousel
//= require bootstrap-datepicker

//= require bulkrax/application

//= require hyrax
//= require iiif_print

//= require jquery.flot.pie
//= require flot_graph
//= require statistics_tab_manager
//= require blacklight_gallery/default


// For blacklight_range_limit built-in JS, if you don't want it you don't need
// this:
//= require 'blacklight_range_limit'

//= require blacklight_advanced_search
