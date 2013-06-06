var graphColors = [
]

for(var i=80; i<255; i+=12){
  graphColors.push( new boxColor(0,0,i) );
}
for(var i=80; i<255; i+=12){
  graphColors.push( new boxColor(0,i,0) );
}
for(var i=80; i<255; i+=12){
  graphColors.push( new boxColor(i,0,0) );
}
for(var i=80; i<255; i+=12){
  graphColors.push( new boxColor(0,i,i) );
}
for(var i=80; i<255; i+=12){
  graphColors.push( new boxColor(i,0,i) );
}
for(var i=80; i<255; i+=12){
  graphColors.push( new boxColor(i,i,0) );
}
for(var i=80; i<255; i+=12){
  graphColors.push( new boxColor(i,i,i) );
}

function countZeros( cpvCode ){
  var count = 0; 
  code = cpvCode.toString();
  pos = code.length;
  while(pos > 0){
    if(code[pos-1] == '0'){
      count = count +1;
    }
    else{
      break;
    }
    pos = pos - 1;
  }
  return count;
}


function boxColor( pR,pG,pB ) { // constructor function

  this.r = pR;
  this.g = pG;
  this.b = pB;
}

function formatGEL(num, useFractions) {
    var p = num.toFixed(2).split(".");
    var num =  "GEL " + p[0].split("").reverse().reduce(function(acc, num, i, orig) {
        return num + (i && !(i % 3) ? "," : "") + acc;
    }, "")
    if(useFractions){
      num += "." + p[1];
    }
    return num;
}


function createD3Graphs( root )
{
  var labelHeight = 50;
  var width = $('#cpvChart').width();
  var height = 600 - labelHeight;
  

  var formatNumber = d3.format(",d");
  var transitioning;

  var x = d3.scale.linear()
      .domain([0, width])
      .range([0, width]);

  var y = d3.scale.linear()
      .domain([0, height])
      .range([0, height]);

  var treemap = d3.layout.treemap()
      .children(function(d, depth) { return depth ? null : d.children; })
      .sort(function(a, b) { return a.value - b.value; })
      .ratio(height / width * 0.5 * (1 + Math.sqrt(5)))
      .round(false);

  var svg = d3.select("#cpvChart").append("svg")
      .attr("width", width)
      .attr("height", height + labelHeight)
    .append("g")
      .attr("transform", "translate(" + 0 + "," + labelHeight + ")")
      .style("shape-rendering", "crispEdges");

  var grandparent = svg.append("g")
      .attr("class", "grandparent");

  grandparent.append("rect")
      .attr("y", -labelHeight)
      .attr("width", width)
      .attr("height", labelHeight);

  grandparent.append("text")
      .attr("x", 6)
      .attr("y", 6 - labelHeight)
      .attr("dy", ".75em");
            
               
  initialize(root);
  layout(root);
  display(root);

  function initialize(root) {
    root.x = root.y = 0;
    root.dx = width;
    root.dy = height;
    root.depth = 0;
  }

  // Compute the treemap layout recursively such that each group of siblings
  // uses the same size (1×1) rather than the dimensions of the parent cell.
  // This optimizes the layout for the current zoom state. Note that a wrapper
  // object is created for the parent node for each group of siblings so that
  // the parent’s dimensions are not discarded as we recurse. Since each group
  // of sibling was laid out in 1×1, we must rescale to fit using absolute
  // coordinates. This lets us use a viewport to zoom.
  function layout(d) {
    if (d.children) {
      treemap.nodes({children: d.children});
      d.children.forEach(function(c) {
        c.x = d.x + c.x * d.dx;
        c.y = d.y + c.y * d.dy;
        c.dx *= d.dx;
        c.dy *= d.dy;
        c.parent = d;
        layout(c);
      });
    }
  }

  function display(d) {
    //Math.seedrandom('88');
    grandparent
        .datum(d.parent)
        .on("click", transition)
      .select("text")
        .text(name(d));

    var g1 = svg.insert("g", ".grandparent")
        .datum(d)
        .attr("class", "depth");

    var g = g1.selectAll("g")
        .data(d.children)
      .enter().append("g");

    g.filter(function(d) { return d.children; })
        .classed("children", true)
        .on("click", transition);

    g.selectAll(".child")
        .data(function(d) { return d.children || [d]; })
      .enter().append("rect")
        .attr("class", "child")
        .call(rect);

    g.append("rect")
            .attr("class", "parent")
            .call(rect)
            .call(applyRectColoring)
            .append("title")
              .text(function(d) { return d.name + "\n"+"(CPV Code: "+d.code + ") \n" + formatGEL(d.value)});

    g.append("text")
        .attr("dy", ".75em")
        .text(function(d) { return d.name })
        .call(text);

    function transition(d) {
      if (transitioning || !d) return;
      transitioning = true;

      var g2 = display(d),
          t1 = g1.transition().duration(750),
          t2 = g2.transition().duration(750);

      // Update the domain only after entering new elements.
      x.domain([d.x, d.x + d.dx]);
      y.domain([d.y, d.y + d.dy]);

      // Enable anti-aliasing during the transition.
      svg.style("shape-rendering", null);

      // Draw child nodes on top of parent nodes.
      svg.selectAll(".depth").sort(function(a, b) { return a.depth - b.depth; });

      // Fade-in entering text.
      g2.selectAll("text").style("fill-opacity", 0);

      // Transition to the new view.
      t1.selectAll("text").call(text).style("fill-opacity", 0);
      t2.selectAll("text").call(text).style("fill-opacity", 1);
      t1.selectAll("rect").call(rect);
      t2.selectAll("rect").call(rect);

      // Remove the old node when the transition is finished.
      t1.remove().each("end", function() {
        svg.style("shape-rendering", "crispEdges");
        transitioning = false;
      });
    }

    return g;
  }

  function text(svgText) {

    svgText.attr("x", function(d) { return x(d.x) + 6; })
        .attr("y", function(d) { return y(d.y) + 6; })
        .attr("font-size", function(d) { 
        var width = x(d.x + d.dx) - x(d.x);
        var height = y(d.y + d.dy) - y(d.y);
        var heightSize = height
        var letters = d.name.length
        var widthSize = width / (letters / 1.6)
        if(heightSize < widthSize){
          return heightSize;
        }
        else{
          if( widthSize < 10 && (widthSize * 2) < heightSize )
          {   
            widthSize = widthSize * 2;
          }
          return widthSize;

        }}).text( function(d) {
            var width = x(d.x + d.dx) - x(d.x);
            var heightSize = y(d.y + d.dy) - y(d.y);
            var letters = d.name.length
            var widthSize = width / (letters / 1.6)
            if( widthSize < 10 && (widthSize * 2.5) < heightSize ){
              var words = d.name.split(" ");
              var newString = ""
              var ending = ".."
              var count = 0
              while( (newString.length + words[count].length + ending.length) < d.name.length/2 )
              {
                newString += words[count] + " "
                count += 1
              }
              newString = newString.trim()
              newString += ending
              return newString;
            }
            else{ return d.name; } 
          });
  }

  function getColor(code)
  {
    var w = 0;
    zeros = countZeros( code );
    minimizedCode = code/Math.pow(10,zeros);
    if(zeros >= 6){
      w = minimizedCode;
    }
    else{
      //get last digit
      w = (minimizedCode%10)*10;
    }
    
    return graphColors[w];
  }

  function applyRectColoring(rect) {
    rect.attr("style",function(d) 
                      { 
                        var color = getColor(d.code);
                        return "fill:rgb("+Math.round(color.r)+","+Math.round(color.g)+","+Math.round(color.b)+");";
                      }
              ); 
  }

  function rect(rect) {

    rect.attr("x", function(d) { return x(d.x); })
        .attr("y", function(d) { return y(d.y); })
        .attr("width", function(d) { return x(d.x + d.dx) - x(d.x); })
        .attr("height", function(d) { return y(d.y + d.dy) - y(d.y); });
  }

  function name(d) {
    return d.parent
        ? name(d.parent) + "." + d.name
        : d.name;
  }
}
