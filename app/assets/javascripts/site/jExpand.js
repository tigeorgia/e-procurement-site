$(document).ready(function() {
    var toggles = $("div.expansion").find("div.expandToggle");
    var expandables = $("div.expansion").find("div.expandable");
    expandables.hide();

    toggles.click(function() {
     $(this).parent().find(".arrow").toggleClass("up");
     $(this).parents("div.expansion").find("div.expandable").slideToggle({duration:"slow"});
    });
});

