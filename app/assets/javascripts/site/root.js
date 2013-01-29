// set focus to first text box on page
$(document).ready(function(){
	if (gon.highlight_first_form_field){
	  $(":input:visible:enabled:first").focus();
	}
});

$(function() {
  initDatePickers();
});

initDatePickers = function ()
{
  $('.dp2').datepicker();
}

