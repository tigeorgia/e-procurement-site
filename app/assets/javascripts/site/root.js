$(function() {
  initDatePickers();
});

initDatePickers = function ()
{
  $('.dp2').datepicker({ format: "yyyy/mm/dd"});
}


$(document).ready(function() {
    $('.dataTable').dataTable( {
        "sDom": '<"top"flp><"bottom"irt><"clear">',
        "sPaginationType": "full_numbers"
    } );
     $( ".tabs" ).tabs();
});
