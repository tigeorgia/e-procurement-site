if (gon.tender_pie_chart)
	{
    var w = 460,
    h = 300,
    r = 150,
    color = d3.interpolateRgb("#f05", "#ff5")

    var vis = d3.select("div#tender_piechart")
        .append("svg:svg")
				.attr("id", "tender_chart")
        .data([gon.tender_pie_chart])
            .attr("width", w)
            .attr("height", h)
        .append("svg:g")
            .attr("transform", "translate(" + (r+80) + "," + r + ")")

    var arc = d3.svg.arc()
        .outerRadius(r);

    var pie = d3.layout.pie()
        .value(function(d) { return d.number; });

    var arcs = vis.selectAll("g.slice")
        .data(pie)
        .enter()
            .append("svg:g")
                .attr("class", "slice");
        arcs.append("svg:path")
                .attr("fill", function(d, i) { return color(Math.random()); })
                .attr("d", arc);

        arcs.append("svg:text")
                .attr("transform", function(d) {
                d.innerRadius = 0;
                d.outerRadius = r;
                return "translate(" + arc.centroid(d) + ")";
            })
            .attr("text-anchor", "middle")
            .text(function(d, i) { return gon.tender_pie_chart[i].percent; });

	}
