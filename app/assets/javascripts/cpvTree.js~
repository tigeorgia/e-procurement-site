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


checkExisting = function()
{
  var myTree = $("#demo1");
  var codestring = $("#codes").val();
  var codes = codestring.split(",");
  var myTreeContainer = $.jstree._reference(myTree).get_container();
  var childNodes = myTreeContainer.find("li");

  for( var i = 0; i < codes.length; i++){
    for (var k = 0; k < childNodes.length; ++k){
      var full_string = $("#demo1").jstree("get_text",childNodes[k]);
      var strings = full_string.split(":");
      var cpv = $.trim(strings[0]);
      if(cpv == codes[i]){
        $("#demo1").jstree("check_node",childNodes[k]);
      }
    }
  }
}

initTree = function()
{
  var myTree = $("#demo1").bind("check_node.jstree uncheck_node.jstree",saveData).jstree({
      "plugins" : [ "themes", "html_data", "checkbox", "sort", "ui" ]
  });

  $("#demo1").bind("loaded.jstree",checkExisting)
  

}
