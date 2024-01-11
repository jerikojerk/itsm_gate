
var additional_lines = ['line init', 'line emergency', 'line amtf'];

// Mapping of step names to colors.
	var colors = {
	"Draft": "#E9DF7B",
	"R. For Change": "#E9DF7B",
	"R. For Authorization": "#E9DF7B",
	"Planning In Pr.": "#A6C2E7",
	"Sch. For Review": "#1560BD",
	"Sch. For Approval": "#1560BD",
	"Scheduled": "#20B2AA",
	"Implementation In Pr.": "#20B2AA",
	"Pending": "#EA2D28",
	"Rejected": "#800080",
	"Completed": "#C4D79B",
	"Closed": "#808000",
	"Cancelled":"#C0C0C0",
	"To Be Re-Scheduled":"#A6C2E7",
	"Resources Not Available":"red",
	"Funding Not Available":"#800080",
	"No Longer Required":"#D0D0D0",
	"Accepted":"#A37B45",
	"Successful with Issues":"#C4D79B",
	"Successful":"#507642",
	"Final Review Complete":"#A37B45",
	"":"ivory",
	"EMEA": "LightSkyBlue",
	"APAC": "PaleGreen",
	"AMER": "#fabf8f",
	"NO RSD":"#AFAF00",
	"GIS":"#FFFFFF",
	"Staged":"#E9DF7B",
	"St. in Progress":"#E9DF7B",
	'St. Complete':"#E9E07C",
	"Assigned":"#1560BD",
	"Assignment":'#A6C2E7',
	'Waiting':"#20B2AA",
	'Work in Progress':"#20B2AA",
	'Bypassed':'pink',
	'FAIL':'#8A0829',
	'Error':'red'
	};
	
	var color_change_full = ['#E9DF7B','#A6C2E7','#1560BD','#20B2AA','#EA2D28','#800080','#C4D79B','#808000','#C0C0C0'];
	var color_change_partial=['#808000','#C0C0C0'];

	var color_task_simple=['#808000','red','#C0C0C0','#E9DF7B','blue'];

function renderStackChart_legend(){

	var css='<style type="text/css" class="startupRemove">'+
'.d3-tip {line-height: 1;font-weight: bold;padding: 12px;background: rgba(0, 0, 0, 0.8);color: #fff;border-radius: 2px;}'+"\n"+ 
'/* Creates a small triangle extender for the tooltip */ .d3-tip:after {box-sizing: border-box;display: inline;font-size: 10px;width: 100%;line-height: 1;color: rgba(0, 0, 0, 0.8);content: "\25BC";position: absolute;text-align: center;}'+"\n"+ 
'/* Style northward tooltips differently */ .d3-tip.n:after {margin: -1px 0 0 0;top: 100%;left: 0;}'+"\n"+ 
'<style>';
	$('head').append(css);

/*
	$('.graphMe1 table').each( function(){
		$(this).find('th').each(function(index){
		var $this=$(this);
		$this.addClass('ca'+index);
		});
	});	

	$('.graphMe2 table').each( function(){
		$(this).find('th').each(function(index){
		var $this=$(this);
		$this.addClass('ca'+index+7);
		});
	});
*/
}



function readDataTables1(selector, colors ) {
	var src_data = new Array();
	var yGroupMax=null;
	var yStackMax=null;

	var last_stack_num=colors.length+1;
	$(selector).find('thead tr th').each(function(index,elem){
		if (0<index && index<last_stack_num){
			$(elem).css('background-color',colors[index-1]);
		}
	});

	$(selector).find('tbody tr').each(function(rownum){
		var cumul=0;
		var $td=$(this).find('td');
		var colcount=$td.length;
		var colcount_1= colcount-1;
		$td.each(function(colnum,value){
			var tmp,toto;
			if ( !src_data[colnum] ){src_data[colnum]=new Array();}
			
			if (0===colnum){
				src_data[colnum][rownum]=$(value).text();
			}else if (colnum===colcount_1){
				toto=parseFloat($(value).text());
			}else if (colnum===colcount){
				src_data[colnum][colcount_1]={'total':toto,time:$(value).text()}
			}
			else{
				tmp=parseFloat($(value).text());
				if ( yGroupMax === null ){
					yGroupMax=tmp;
				}
				if ( yStackMax === null ){
					yStackMax=tmp;
				}
				yStackMax=Math.max(yStackMax,tmp);
				if ( colnum < last_stack_num ){
					cumul=cumul+tmp;
					yGroupMax=Math.max(yGroupMax,tmp);
				}
				src_data[colnum][rownum] ={x:rownum,y:tmp,c:colnum};
			}
		});
		yStackMax=Math.max(cumul,yStackMax);
	});
	return {data:src_data, yGroupMax:yGroupMax,yStackMax:yStackMax}
}


function renderStackChart(src,here, colors,additional_lines){
	var timeout,number_layer=colors.length;
	var yGroupMax=src.yGroupMax,yStackMax=src.yStackMax, src_data=src.data;
	var serial_count=src_data.length-3;
	var line_count=serial_count-number_layer;

	var m = src_data[0].length; // number of samples per layer
	var stack = d3.layout.stack();
	var layers = stack(d3.range(number_layer).map(function(value,index,all) { 
			return src_data[index+1];
			//toto= bumpLayer(m, .3);
			 }));
	//yGroupMax = d3.max(layers, function(layer) { return d3.max(layer, function(d) { return d.y; }); }),
	//yStackMax = d3.max(layers, function(layer) { return d3.max(layer, function(d) { return d.y0 + d.y; }); });

	
	var margin = {top: 40, right: 10, bottom: 20, left: 30},
		width = 1200 - margin.left - margin.right,
		height = 500 - margin.top - margin.bottom;

	var x = d3.scale.ordinal()
		.domain(d3.range(0,m+1))
		.rangeRoundBands([0, width], .05);

	var y = d3.scale.linear()
		.domain([0, yStackMax])
		.range([height, 0]);

	//x.domain(data.map(function(d) { return d.State; }));
	
	var line = d3.svg.line()
		.interpolate("basis")
		.x(function(d) { return x(d.x); })
		.y(function(d) { return y(d.y); });
	
	var xAxis = d3.svg.axis()
		.scale(x)
		.tickSize(2)
		.tickPadding(8)
		.ticks(0)
		.orient("bottom")
//		.tickValues(src_data[0])
		.tickFormat(function(d){
			if ( d % 5 === 0 ){return  src_data[0][d];}else{return "";}})
//		.text("Week")
		;
	var yAxis = d3.svg.axis()
		.scale(y)
		.tickSize(1)
		.tickPadding(6)
		.ticks(10)
		.orient("left")
	;
		
	var svg = d3.select(here).append("svg")
		.attr("width", width + margin.left + margin.right)
		.attr("height", height + margin.top + margin.bottom)
		.attr("class","startupRemove")
	  .append("g")
		.attr("transform", "translate(" + margin.left + "," + margin.top + ")");

	var layer = svg.selectAll(".layer")
		.data(layers)
	  .enter().append("g")
		.attr("class", "layer")
		.style("fill", function(d, i){return colors[i]; });
	;

	var rect = layer.selectAll("rect")
		.data(function(d) { return d; })
	  .enter().append("rect")
		.attr("x", function(d) { return x(d.x); })
		.attr("transform", "translate("+x.rangeBand()*0+",0)")
		.attr("y", height)
		.attr("width", x.rangeBand())
		.attr("height", 0)
	;
	
	rect.transition()
		.delay(function(d, i){return i * 10; })
		.attr("y",function(d){return y(d.y0 + d.y); })
		.attr("height",function(d) {return y(d.y0)-y(d.y0 + d.y);})
	;
	
	
	for( var it=0;it<line_count;it++){
		svg.append("path")
		  .datum(src_data[number_layer+it+1])
		  .attr('class', additional_lines[it])
		  .attr("transform", "translate("+x.rangeBand()/2+",0)")
		  .attr('d', line);
	}
	
	svg.append("g")
		.attr("class", "x axis")
		.attr("transform", "translate(0," + height + ")")
		.call(xAxis)
	;
	svg.append("g")
		.attr("class", "y axis")
		.call(yAxis)
	;

	
	d3.select(here).selectAll('input')
		.on("change",change);
	
	//obsolete
	function change() {
	  clearTimeout(timeout);
	  if (this.value === "grouped") transitionGrouped();
	  else transitionStacked();
	}
	
	//obsolete
	function transitionGrouped() {
	  y.domain([0, yGroupMax]);

	  rect.transition()
		  .duration(500)
		  .delay(function(d, i) { return i * 10; })
		  .attr("x", function(d, i, j) { return x(d.x) + x.rangeBand() / n * j; })
		  .attr("width", x.rangeBand() / n)
		.transition()
		  .attr("y", function(d) { return y(d.y); })
		  .attr("height", function(d) { return height - y(d.y); });
	}
	//obsolete
	function transitionStacked() {
	  y.domain([0, yStackMax]);

	  rect.transition()
		  .duration(500)
		  .delay(function(d, i) { return i * 10; })
		  .attr("y", function(d) { return y(d.y0 + d.y); })
		  .attr("height", function(d) { return y(d.y0) - y(d.y0 + d.y); })
		.transition()
		  .attr("x", function(d) { return x(d.x); })
		  .attr("width", x.rangeBand());
	}
	return svg;

} //end for render.


function renderLines(src, here, classes, names ){

	var yGroupMax=src.yGroupMax,yStackMax=src.yStackMax, src_data=src.data;
	var m = src_data[0].length; // number of samples per layer

	var margin = {top: 40, right: 100, bottom: 20, left: 50};
	var	width = 1200 - margin.left - margin.right,
		height = 500 - margin.top - margin.bottom;

	var x = d3.scale.ordinal()
		.domain(d3.range(0,m+1))
		.rangeRoundBands([0, width], .05);

	var y = d3.scale.linear()
		.domain([0, yStackMax])
		.range([height, 0]);

	//x.domain(data.map(function(d) { return d.State; }));
	
	var line = d3.svg.line()
		.interpolate("basis")
		.x(function(d) { return x(d.x); })
		.y(function(d) { return y(d.y); });
	
	var xAxis = d3.svg.axis()
		.scale(x)
		.tickSize(2)
		.tickPadding(8)
		.ticks(0)
		.orient("bottom")
//		.tickValues(src_data[0])
		.tickFormat(function(d){
			if ( d % 5 === 0 ){return  src_data[0][d];}else{return "";}})
//		.text("Week")
		;
	var yAxis = d3.svg.axis()
		.scale(y)
		.tickSize(1)
		.tickPadding(6)
		.ticks(10)
		.orient("left")
	;
		
	var svg = d3.select(here).append("svg")
		.attr("width", width + margin.left + margin.right)
		.attr("height", height + margin.top + margin.bottom)
		.attr("class","startupRemove")
	  .append("g")
		.attr("transform", "translate(" + margin.left + "," + margin.top + ")");


	function drawLine( svg, data, class_curve, class_text,label ){
		svg.append("path")
		  .datum(data)
		  .attr('class', class_curve)
		  .attr('d', line)
		;
		svg.append('text')
			.text(label)
			.attr("transform", "translate(" + x(data[m-1].x) + "," + y(data[m-1].y) + ")")
			.attr('class', class_text)
			.attr("dy", ".35em")
			.attr("text-anchor", "start")
		;	
	
	} 

	
	var maxi= classes.length;
	for ( var it=0; it<maxi ; it++ ){
		drawLine( svg, src_data[1+it],classes[it],'', names[it]);
	}
//	drawLine( svg, src_data[1],'', );
//	drawLine( svg, src_data[2],'', );
//	drawLine( svg, src_data[3],'');
//	drawLine( svg, src_data[4],'');
//	drawLine( svg, src_data[5],'');
//	drawLine( svg, src_data[6],,'');
	

	svg.append("g")
		.attr("class", "x axis")
		.attr("transform", "translate(0," + height + ")")
		.call(xAxis)
	;
	svg.append("g")
		.attr("class", "y axis")
		.call(yAxis)
	;


}



function readDataSunburst( selector){
	var new_node=function(name){
		return {'name':name,'children':[],depth:0};
	}
	
	var update_rdepth=function(node,prev){
		if (!node.redeph || prev>node.rdepth){
			node.rdepth=prev;
			if( node.parent){
				update_rdepth(node.parent, prev+1)
			}
		}
	}
	
	var search_node=function(currentNode,nodeName){ 
		var children=currentNode.children,foundChild=false,k;
		for (var k = 0; k < children.length; k++) {
			if (children[k]["name"] == nodeName) {
			childNode = children[k];
			foundChild = true;
			break;
			}
		}
		if (!foundChild) {
			childNode = new_node(nodeName);
//			childNode.depth=currentNode.depth+1;
			childNode.parent=currentNode;
			children.push(childNode);
			update_rdepth(childNode,0);
		}
		return childNode;
	}	
	var currentNode,root=new_node('GIS');

	$(selector).find('tbody tr').each(function(rownum){
		currentNode=root;
		var tmp;
		var $td=$(this).find('td');
		var colcount=$td.length-1;
		$td.each(function(colnum,value){
			tmp=$(value).text();
			if (colcount===colnum){
				currentNode.size=parseFloat(tmp);
			}else {
				currentNode=search_node(currentNode,tmp);
			}
		});
	});
	return root;
}


function renderSunburst(data,here, customLevel){
	var width = 640,
		height = 640,
		radius = 13*Math.min(width, height) /30,
		whiteHole=80,
		textPadding=4,
		duration = 1000,
		noTextAngle=0.020*Math.PI;
	var b = {w: 180, h: 30, s: 3, t: 10};
	
	var x = d3.scale.linear()
		.range([0, 2 * Math.PI]);

	var y = d3.scale.linear()
		.range([0, radius]);

	var colors2Legend={};

	var customLabel=function(d){
		return d.depth===customLevel?+d.name+'+ weeks':d.name;
	}
	var customColor=function(d){
		return d.depth===customLevel?colors[d.parent.name]:colors[d.name];
	}
	
	var svg = d3.select(here).append("svg")
		.attr("width", width)
		.attr("height", height)
	  .append("g")
		.attr("transform","translate(" + width/2+ "," + (height / 2 + 10) + ")");

	var partition = d3.layout.partition()
		.sort(null)
		.value(function(d) { return d.size; });

	var arc = d3.svg.arc()
		.startAngle(function(d) { return Math.max(0, Math.min(2 * Math.PI, x(d.x))); })
		.endAngle(function(d) { return Math.max(0, Math.min(2 * Math.PI, x(d.x + d.dx))); })
		.innerRadius(function(d) { return Math.max(0, y(d.y)); })
		.outerRadius(function(d) { return Math.max(0, y(d.y + d.dy)); });

	var nodes=partition.nodes(data);
	
	var vis = svg.data([data]).selectAll("g")
	 .data(nodes)
	 .enter().append("g");

	var path = vis.append("path")
	 .attr("d", arc)
	 .style("fill",function(d) { 
		if (!colors2Legend[d.name]&& d.depth){ colors2Legend[d.name]=colors[d.name];}
		return customColor(d);
		})
	 .on("click", click)
	 .on("mouseover",mouseover)
	;

	var text = vis.append('text')
	 .each(function(d){
		var me=d3.select(this);
		var angle=computeTextAngle(d);
		var correct=needQuarterCorrect(angle);
		me
		 .text(customLabel(d))
		 .attr("transform", function(d){ 
			return 'rotate('+angle+') rotate('+getCorrectedAngle(correct)+')';})
		 .attr('display', Math.abs(x(d.dx))<noTextAngle?'none':'')
		 .attr("x", getCorrectedX(correct,y(d.y)))
		 .attr('text-anchor',getTextAlign(correct))
		 .attr("dx", getCorrectedX(correct,textPadding)) // margin
		 .attr("dy", ".35em") // vertical-align
		 .on("click", click)
		 .on("mouseover",mouseover)
		 ;
	});
	
	// Get total size of the tree = value of root node from partition.
	totalSize = path.node().__data__.value;	
	initializeBreadcrumbTrail();
	
	// Add the mouseleave handler to the bounding circle.
	d3.select(here).select(".sun_container").on("mouseleave", mouseleave);
		
	drawLegend();
	
//-----------------------------------------

//	function click2(d
	function click(d) {
		path.transition()
		 .duration(duration)
		 .attrTween("d", arcTween(d));

		// Somewhat of a hack as we rely on arcTween updating the scales.
		text.style("visibility", function(e) {
			return isParentOf(d, e) ? null : d3.select(this).style("visibility");})
		 .transition()
		 .duration(duration)
		 .attrTween("text-anchor", function(d){
			return function(){
				return x(d.x + d.dx / 2) < Math.PI ? "start" :"end";}
		 })
		 .attrTween("transform", function(d){
			return function(){
				var angle=computeTextAngle(d);
				var correct=needQuarterCorrect(angle);				
				return 'rotate('+angle+') rotate('+getCorrectedAngle(correct)+')';}
		 })
		 .attrTween("x",function(d){return function(){
				return getCorrectedX( x(d.x + d.dx/2) < Math.PI, y(d.y))}
		 })
		 .attrTween("dx", function(d){
				return function(){
					return getCorrectedX(x(d.x + d.dx/2) < Math.PI,textPadding);}
			}) // margin
		 .attrTween('display', function(d){
				return function(){
					return Math.abs(x(d.dx))<noTextAngle?'none':'';}
		 })
		 .style("fill-opacity", function(e){return isParentOf(d, e) ? 1 : 0; })
		 .each("end", function(e){
			d3.select(this).style("visibility", isParentOf(d, e) ? null : "hidden");
		 });
	}

	
	function computeTextAngle(d) {
	  return x(d.x + d.dx / 2) / Math.PI * 180-90;
	}
	function needQuarterCorrect(angle){
		return (Math.abs(angle)<=90)?true:false;
	}
	function getTextAlign(correct){
		return correct?'start':'end';
	}
	function getCorrectedX(correct,x){
		return correct?x:-x;
	}
	function getCorrectedAngle(correct){
		return correct?0:180;
	}	
	function isParentOf(p, c) {
		if (p === c) return true;
		if (p.children){
			return p.children.some(function(d){
				return isParentOf(d, c);});
		}
		return false;
	}

//	d3.select(self.frameElement).style("height", height + "px");

	// Interpolate the scales!
	function arcTween(d) {
	  var xd = d3.interpolate(x.domain(), [d.x, d.x + d.dx]),
		  yd = d3.interpolate(y.domain(), [d.y, 1]),
		  yr = d3.interpolate(y.range(), [d.y ? 20 : 0, radius]);
	  return function(d, i) {
		return i
			? function(t) { return arc(d); }
			: function(t) { x.domain(xd(t)); y.domain(yd(t)).range(yr(t)); return arc(d); };
	  };
	}

// Fade all but the current sequence, and show it in the breadcrumb trail.
	function mouseover(d) {
		var $here=d3.select(here);
		var percentage = (100 * d.value / totalSize).toPrecision(3);
		var percentageString = percentage + "%";
		var glue;
		if (percentage < 0.1) {percentageString = "< 0.1%";}

		$here.select(".sun_percentage").text(percentageString);
		$here.select(".sun_selected").text(d.value)
		$here.select(".sun_total").text(totalSize);
		$here.select('.sun_name').text(customLabel(d));
		if ( d.parent ){
		$here.select('.sun_parent_percentage').text((100 * d.value / d.parent.value).toPrecision(3)+'% of its parent.');
		$here.select(".sun_explanation").style("visibility", "");
		}
		else{
			$here.select('.sun_parent_percentage').text('');
		}
		
		var sequenceArray = getAncestors(d);
		updateBreadcrumbs(sequenceArray, d.value+' / '+percentageString);

		// Fade all the segments.
		$here.selectAll("path")
			.style("opacity", 0.8);

		// Then highlight only those that are an ancestor of the current segment.
		vis.selectAll("path")
			.filter(function(node) {return (sequenceArray.indexOf(node) >= 0);})
			.style("opacity", 1);
	}

	// Restore everything to full opacity when moving off the visualization.
	function mouseleave(d) {
		var $here=d3.select(here);
		// Hide the breadcrumb trail
		$here.select(".sun_trail").style("visibility", "hidden");

		// Deactivate all segments during transition.
		$here.selectAll("path").on("mouseover", null);

		// Transition each segment to full opacity and then reactivate it.
		$here.selectAll("path")
		.transition()
		.duration(1000)
		.style("opacity", 1)
		.each("end", function() {d3.select(this).on("mouseover", mouseover);});

		$here.select(".sun_percentage").text('100%');
		$here.select(".sun_selected").text(totalSize)
		$here.select(".sun_total").text(totalSize);
		$here.select('.sun_parent_percentage').text('');
		$here.select('.sun_name').text('');

//		$here.select(".sun_explanation").style("visibility", "hidden");
	}

	// Given a node in a partition layout, return an array of all of its ancestor
	// nodes, highest first, but excluding the root.
	function getAncestors(node) {
		var path = [];
		var current = node;
		while (current.parent) {
		path.unshift(current);
		current = current.parent;
		}
		return path;
	}

	function initializeBreadcrumbTrail() {
		// Add the svg area.
		var $here=d3.select(here);
		var trail = $here.select(".sun_sequence").append("svg:svg")
		.attr("width", width)
		.attr("height", 50)
		.attr("class", "sun_trail startupRemove");
		// Add the label at the end, for the percentage.
		trail.append("svg:text")
		.attr("class", "sun_endlabel")
		.style("fill", "#000");
	}

	// Generate a string that describes the points of a breadcrumb polygon.
	function breadcrumbPoints(d, i) {
		var points = [];
		points.push("0,0");
		points.push(b.w + ",0");
		points.push(b.w + b.t + "," + (b.h / 2));
		points.push(b.w + "," + b.h);
		points.push("0," + b.h);
		if (i>0) { // Leftmost breadcrumb; don't include 6th vertex.
		points.push(b.t + "," + (b.h / 2));
		}
		return points.join(" ");
	}

	// Update the breadcrumb trail to show the current sequence and percentage.
	function updateBreadcrumbs(nodeArray, percentageString) {
		// Data join; key function combines name and depth (= position in sequence).
		var $here=d3.select(here)
		var g = $here.select(".sun_trail")
		  .selectAll("g")
		  .data(nodeArray, function(d) { return d.name + d.depth; });

		// Add breadcrumb and label for entering nodes.
		var entering = g.enter().append("svg:g");

		entering.append("svg:polygon")
		  .attr("points", breadcrumbPoints)
		  .style("fill",function(d){ return customColor(d)} );

		entering.append("svg:text")
		  .attr("x", (b.w + b.t) / 2)
		  .attr("y", b.h / 2)
		  .attr("dy", "0.35em")
		  .attr("text-anchor", "middle")
		  .text(function(d){return customLabel(d)});

		// Set position for entering and updating nodes.
		g.attr("transform", function(d, i) {
		return "translate(" + i * (b.w + b.s) + ", 0)";
		});

		// Remove exiting nodes.
		g.exit().remove();

		// Now move and update the percentage at the end.
		$here.select(".sun_trail").select(".sun_endlabel")
		  .attr("x", (nodeArray.length) * (b.w + b.s) +8)
		  .attr("y", b.h / 2)
		  .attr("dy", "0.35em")
		  .attr("text-anchor", "left")
		  .text(percentageString);
		
		
		// Make the breadcrumb trail visible, if it's hidden.
		$here.select(".sun_trail")
		  .style("visibility", "");
	}
	//obsolete
	function drawLegend() {
	// Dimensions of legend item: width, height, spacing, radius of rounded rect.
		var li = {w: 180, h: 30, s: 3, r: 3};

		var legend = d3.select(here).select(".sun_legend").append("svg:svg")
		  .attr("width", li.w)
		  .attr("height", d3.keys(colors2Legend).length * (li.h + li.s))
		  .attr("class",'startupRemove');

		var g = legend.selectAll("g")
		  .data(d3.entries(colors2Legend))
		  .enter().append("svg:g")
		  .attr("transform", function(d, i) {
				  return "translate(0," + i * (li.h + li.s) + ")";
			   });

		g.append("svg:rect")
		.attr("rx", li.r)
		.attr("ry", li.r)
		.attr("width", li.w)
		.attr("height", li.h)
		.style("fill", function(d) { return d.value; });

		g.append("svg:text")
		.attr("x", li.w / 2)
		.attr("y", li.h / 2)
		.attr("dy", "0.35em")
		.attr("text-anchor", "middle")
		.text(function(d) { return d.key; });
	}

//obsolete
	function toggleLegend() {
	  var legend = d3.select(here).select(".sun_legend");
	  if (legend.style("visibility") == "hidden") {
		legend.style("visibility", "");
	  } else {
		legend.style("visibility", "hidden");
	  }
	}
	
	
//------------------
	
} //renderSunburst


function createModalPopup( title,data ){
	dialog({title:'data for '+$sub.find('h3').text(),dialogClass:'popup',height:500,width:500});
}

//---------------------------------------------------------------------------------------------
function removeSvg($here){
	$here.find('svg, .startupRemove').remove();	
}

function generateSvg($here){
	$here.find('.graphMe1').each( function(){
		var $this=$(this);
		var $table=$this.find('table').eq(0);
		var tmp=readDataTables1($table,color_change_full);
		renderStackChart(tmp,this,color_change_full,additional_lines);
	});

	$here.find('.graphMe2').each( function(){
		var $this=$(this);
		var $table=$this.find('table').eq(0);
		var tmp=readDataTables1($table, color_change_partial);
		renderStackChart(tmp,this,color_change_partial,additional_lines);
	});

	$here.find('.graphMe3').each( function(){
		var $this=$(this);
		$this.append('<div class="sun_sequence startupRemove"></div>'+
		'<div class="sun_chart"><div class="sun_explanation" style="visibility: hidden;"><span class="sun_percentage"></span><br/>of total changes<br/>'+
		'<span class="sun_selected"></span>/<span class="sun_total"></span><br/><span class="sun_name"></span><br>'+
		'<span class="sun_parent_percentage"></span></div></div></div>');
		var $table=$this.find('table').eq(0);
		var tmp=readDataSunburst($table)
		renderSunburst(tmp,this,3);
	});
	
	$here.find('.graphMe3c').each( function(){
		var $this=$(this);
		$this.append('<div class="sun_sequence startupRemove"></div>'+
		'<div class="sun_chart"><div class="sun_explanation" style="visibility: hidden;"><span class="sun_percentage"></span><br/>of total changes<br/>'+
		'<span class="sun_selected"></span>/<span class="sun_total"></span><br/><span class="sun_name"></span><br>'+
		'<span class="sun_parent_percentage"></span></div></div></div>');
		var $table=$this.find('table').eq(0);
		var tmp=readDataSunburst($table)
		renderSunburst(tmp,this, 4);
	});	
	
	$here.find('.graphMe3b').each( function(){
		var $this=$(this);
		$this.append('<div class="sun_sequence startupRemove"></div>'+
		'<div class="sun_chart"><div class="sun_explanation" style="visibility: hidden;"><span class="sun_percentage"></span><br/>of total changes<br/>'+
		'<span class="sun_selected"></span>/<span class="sun_total"></span><br/><span class="sun_name"></span><br>'+
		'<span class="sun_parent_percentage"></span></div></div></div>');
		var $table=$this.find('table').eq(0);
		var tmp=readDataSunburst($table)
		renderSunburst(tmp,this, 1000);
	});
	
	
	$here.find('.graphMe4').each( function(){
		var $this=$(this);
		var $table=$this.find('table').eq(0);
		var classes=['line delegated','line delegatedNS','line escalated','line non_init','line managed','line total'];
		var names=['INIT:Standard delegated','INIT:Non standard delegated', 'INIT:Non delegated/Escalated', 'Non Init', 'L3 managed changes', 'Total changes'];
		var tmp=readDataTables1($table,[]);
		renderLines(tmp,this,classes,names);
	});
	
	
	$here.find('.graphMe6').each( function(){
		var $this=$(this);
		var $table=$this.find('table').eq(0);
		var tmp=readDataTables1($table,[]);
		var classes=['line yourTeam','line total'];
		var names=['team','Total changes'];
		renderLines(tmp,this,classes,names);
	});
	
	
	$here.find('.graphMe5').each( function(){
		var $this=$(this);
		var $table=$this.find('table').eq(0);
		var tmp=readDataTables1($table,color_task_simple);
		renderStackChart(tmp,this,color_task_simple,[]);
	});


}
//------------------------------------------


 $(document).ready(function(){
	
	$('svg').remove();
	renderStackChart_legend();
	
	$('h2').click(function(){
			var $this=$(this);
			if ( $this.hasClass('expend')){
				$this.siblings('div').show();
				$this.removeClass('expend').addClass('minimize');
			}else{
				$(this).siblings('div').hide();
				$this.removeClass('minimize').addClass('expend');
			}
		
		});
		
	$('h3').click(function(){
		var $this=$(this);
		if ( $this.hasClass('minimize')){
			$(this).siblings('div').hide();
			$this.removeClass('minimize').addClass('expend');
			removeSvg($this.parent());
		}else{
			$this.siblings('div').show();
			$this.removeClass('expend').addClass('minimize');
			generateSvg($this.parent());
		}
	
	});
 

	
	$('button.showTable').click(function(){
		var $sub=$(this).parents('.subbox');
		var $container=$sub.find('.dataContainer');
		$container.dialog({
			title:'data for '+$sub.find('h3').text(),
			modal:false,
			dialogClass:'popup',
			width:600,height:500,
			close: function(){$(this).dialog("destroy");$container.find('table').hide();},
			open: function(){$container.find('table').show();}
		});
		
		return false;
	});
	

	$('button.showSQL').click(function(){
		var $sub=$(this).parents('.subbox');
		var $container=$sub.find('.sqlContainer');
		$container.dialog({
			title:'data for '+$sub.find('h3').text(),
			modal:false,
			dialogClass:'popup',
			width:600,height:500,
			close: function(){$(this).dialog("destroy");$container.find('code').hide();},
			open: function(){$container.find('code').show();}
		});
		
		return false;
	});

 });







