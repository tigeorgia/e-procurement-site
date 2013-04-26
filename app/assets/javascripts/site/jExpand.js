$(document).ready(function() {
    var advancedToggle = $("#advancedToggle");
    var advancedDiv = $("#advancedDiv");
    var advancedHeight = advancedDiv.height();
    advancedDiv.hide();
    advancedToggle.click(function() {
     advancedToggle.find(".arrow").toggleClass("up");
     advancedDiv.slideToggle({duration:"slow"});   
    });
});
