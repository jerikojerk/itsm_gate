

function  render_relationships_graph( linksRaw, nodes_plus, withCI  ){

var nodes={};
var links=[];

//remove CI link from list
linksRaw.forEach(function(link){
	if ( withCI || "relatedCI"!==link.type ){
		links.push( link);
	}
});

// Compute the distinct nodes from the links.
links.forEach(function(link ) {
		link.source = nodes[link.source] || (nodes[link.source] = {name: link.source});
		link.target = nodes[link.target] || (nodes[link.target] = {name: link.target});
	//  link._length=(detectTickets(link.target.name).length>0?40:60)+(detectTickets(link.source.name).length>0?40:60);
});
//, _length: ?1:undefined}


var width = Math.max(800,$(window).width()-20),
    height = 800;

var force = d3.layout.force()
    .nodes(d3.values(nodes))
    .links(links)
    .size([width, height])
//    .linkDistance(function(d){return d.length})
	.linkDistance(120)
    .charge(-400)
    .on("tick", tick)
    .start();

var drag = force.drag()
    .on("dragstart", dragstart);
	
var svg = d3.select("body").append("div").append("svg")
    .attr("width", width)
    .attr("height", height)
	.style("border","dotted orange 3px")
	.attr('xmlns',"http://www.w3.org/2000/svg")
	.attr('xmlns:xmlns:xlink',"http://www.w3.org/1999/xlink")
	.attr('version','1.1');

// Per-type markers, as they don't inherit styles.
svg.append("defs").selectAll("marker")
    .data(["related","relatedCI"])
  .enter().append("marker")
    .attr("id", function(d) { return d;})
    .attr("viewBox", "0 -5 10 10")
    .attr("refX", 15)
    .attr("refY", -1.5)
    .attr("markerWidth", 6)
    .attr("markerHeight", 6)
//    .attr("orient", "auto")
  .append("path")
    .attr("d", "M0,-5L10,0L0,5");
//	  .attr("d",line);

var path = svg.append("g").selectAll("path")
    .data(force.links())
  .enter().append("path")
    .attr("class", function(d) {  return "link " + d.type; })
//    .attr("marker-end", function(d) { return "url(#" + d.type + ")"; });
;

var circle = svg.append("g").selectAll("circle")
    .data(force.nodes())
	.enter().append("circle")
    .attr("r", function(d){
		return ( gl_page.query.indexOf(d.name)>=0 )?14:7;
	})
	.attr("class", function(d){
		return detectTickets(d.name)
	})
	.on("dblclick", dblclick)
    .call(force.drag)
	
svg.selectAll('circle')
	.append("svg:title").text(function(d) {return nodes_plus[d.name]?nodes_plus[d.name].title:''});

	
  /*
	.append("svg:a")
	.attr("xlink:href", function(d){
		var prefix=d.name.substring(0,3)
		if ((prefix==='CRQ')||(prefix==='INC' || prefix ==='PBI')){return '?t='+prefix+'&query='+d.name;}else {return ''}})
  */		
var text = svg.append("g").selectAll("a")
    .data(force.nodes())
  .enter()
  .append('a')
	.attr('xlink:xlink:href',function (d){ return makeIgLink(d);})
	.attr('xlink:xlink:target','_blank')
  .append("text")
    .attr("x", 7)
    .attr("y", ".31em")
    .text(function(d){return d.name;});

// Use elliptical arc path segments to doubly-encode directionality.
function tick() {
  path.attr("d", linkArc);
  circle.attr("transform", transform);
  text.attr("transform", transform);
}

function linkArc(d) {
  var dx = d.target.x - d.source.x,
      dy = d.target.y - d.source.y,
      dr = Math.sqrt(dx * dx + dy * dy);
  return "M" + d.source.x + "," + d.source.y + "A" + dr + "," + dr + " 0 0,1 " + d.target.x + "," + d.target.y;
}

function transform(d) {
  return "translate(" + d.x + "," + d.y + ")";
}

function detectTickets(name){
	var prefix=name.substring(0,4)
	if (prefix === "PBI0"){
		return 'PBI';
	}
	else if ( prefix==='INC0'){
		return 'INC';
	}
	else if ( prefix==='CRQ0'){
		return 'CRQ';
	}
	else if ( prefix==='RLM0'){
		return 'RLM';
	}
	else {
		return '';
	}
}

function makeIgLink(d){
	tmp=detectTickets(d.name);
	if (tmp!==''){
		return '/ppn/itsm_gate/?t='+tmp+'&e='+gl_page.env+'&amp;g=AUTO&amp;query='+d.name;
	}
	else {
		return 'index.asp?t='+detectTickets(gl_page.query)+'&e='+gl_page.env+'&amp;g=AUTO&amp;query=%40'+d.name;
	}
}

function dblclick(d) {
  var tmp=d3.select(this);
  tmp.classed("fixed", d.fixed = false).attr("class", function(d){return detectTickets(d.name)});
}

function dragstart(d) {
  var tmp=d3.select(this);
  tmp.classed("fixed", d.fixed = true).attr("class", function(d){return detectTickets(d.name)+' dontMove'});
}
}

