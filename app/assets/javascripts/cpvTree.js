$(document).ready( function() {
  initTree();
})

saveData = function(event, data)
{
  var checked = $("#demo1").jstree("get_checked",null,true);
  var codestring = "";
  $(checked).each(function (i,node){
    var full_string = $("#demo1").jstree("get_text",node);
    var strings = full_string.split(":");
    var cpv = $.trim(strings[0]);
    codestring = codestring + cpv + ','
  })
  $("#codes").val(codestring);
}


initTree = function()
{
  $("#demo1").bind("check_node.jstree uncheck_node.jstree",saveData).jstree({
      "plugins" : [ "themes", "html_data", "checkbox", "sort", "ui" ]
  });
}
