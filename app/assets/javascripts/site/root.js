$(function() {
  initDatePickers();
});

var initDatePickers = function ()
{
  $('.dp2').datepicker({ format: "yyyy/mm/dd"});
}


$.fn.arrowClick = function()
{  
  var cur_value = this.data('arrow-state');

  $('.arrow-link').data('arrow-state',0);
  $('.arrow-link').parent().css('background-image','url(http://0.0.0.0:3000/assets/arrows.png)');

  if( cur_value == 0 ){
    this.data('arrow-state',1);
  }
  else{
    this.data('arrow-state', cur_value * -1);
  }
}

$(document).ready(function() {
    $('.dataTable').dataTable( {
        "sDom": '<"top"flp><"bottom"irt><"clear">',
        "sPaginationType": "full_numbers"
    } );
    $( ".tabs" ).tabs();

    if($('.arrow-link').data('arrow-state')===undefined){
      $('.arrow-link').data('arrow-state', 0);
    }
    $('.arrow-link').click( function(){ $(this).arrowClick(); } );
});



