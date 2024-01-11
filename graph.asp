<!--#INCLUDE FILE="lib/lib_graph.asp"--><%
Const ANTI_CACHE_SEED=14
Const C_TICKET_DIGIT=15

security_identify_dba false
response.AddHeader "x-ua-compatible", "ie=edge"

dim safe_query,safe_env,glf, safe_withCI
set glf= new GraphLinkFinder

safe_env=validateEnv(trim(Request.querystring("e")))
safe_query= validateAddToGraph(glf,trim(Request.querystring("query")))
safe_withCI= validateWithCI( trim(Request.querystring("withCI")) )


'if VERBOSE then response.write "</font>"
%><!DOCTYPE html>
<html xmlns:xlink="http://www.w3.org/1999/xlink">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
<title>Tickets graphers</title>
<link href="favicon.ico" rel="shortcut icon" />
<link rel="stylesheet" type="text/css" media="screen" href="js/ui/jquery-ui.css" /> 
<link rel="stylesheet" type="text/css" media="screen" href="itsm_gate.<%=ANTI_CACHE_SEED%>.css" />
<link rel="stylesheet" type="text/css" media="screen" href="js/columnFilter.css" />
<script type="text/javascript" src="js/jquery-1.11.1.min.js"></script>
<script type="text/javascript" src="js/ui/jquery-ui-1.10.4.custom.min.js"></script>
<script type="text/javascript" src="js/graphers.<%=ANTI_CACHE_SEED%>.js"></script>
<link rel="search" href="opensearch/change.xml" type="application/opensearchdescription+xml" title="Change search" />
<link rel="search" href="opensearch/incident.xml" type="application/opensearchdescription+xml" title="Incident search" />
<link rel="search" href="opensearch/problem.xml" type="application/opensearchdescription+xml" title="Problem search" />
<link rel="search" href="opensearch/people.xml" type="application/opensearchdescription+xml" title="People search" />
<script type="text/javascript" src="js/d3/d3.min.3.4.8.js"></script>
<style>
.link {fill:none;stroke:#666;stroke-width:1.5px;}
.link.related {stroke:green;}
.link.relatedCI {stroke-dasharray:0,2 1;}
circle {fill:#ccc;stroke:#333;stroke-width:1.5px;}
text {fill:black;font: 10px sans-serif;pointer-events:none;text-shadow:0 1px 0 #fff,1px 0 0 #fff,0 -1px 0 #fff,-1px 0 0 #fff;}
svg {margin:0;padding:0;}
.PBI{fill:red}
circle.INC{fill:orange;stroke:orange;}
circle.CRQ{fill:blue;stroke:blue;}
circle.RLM{fill:purple;stroke:purple;}
circle.dontMove{stroke:white;stroke-width:2px;stroke:black}
</style>
</head>
<body>
<div id="top"></div>
<h1>Ticket graphers</h1>
<!--[if lt IE 9]>
<p style="font-size:48pt;color:red"> Your browser is too old and can not draw the page. Contact you helpdesk to get a better browser.</p>
<![endif]-->
<form id="search" method="get" action="?">
	<fieldset><legend>Search form</legend>
	<p><button id="showAdvanced">Avanced settings</button></p>
	<fieldset style="display:none" id="search_sub1"><label for="search_env">Environment:</label><select id="search_env" name="e"><optgroup label="Ngdc"><option selected="selected" value="N">Production Reporting Database</option><option selected="selected" value="S">UAT transactional database</option><option selected="selected" value="P">Production transactional database</option><option selected="selected" value="O">Retired production database</option></optgroup><optgroup label="Legacy"><option value="L">ARS -Pasteur</option></optgroup></select></fieldset>
	<div id="search_sub2"><p><label for="search_query">Below types ticket.</label></p><textarea id="search_query" name="query" style="width:99%;margin:auto"></textarea>
	<label for="skipCI">With CI</label><input type="checkbox" id="skipCI" name="withCI" checked="" />
	</div>
	<div id="search_sub3"><input type="submit" style="width:100%;height:4em" value="Graph" class="submit"></div>
	</fieldset>
</form>
<script type="text/javascript">
var gl_page={
env:'<% =safe_env %>',
query:'<%=safe_query%>',
withCI:<%=safe_withCI%>
}

$('#showAdvanced').click(function(){
	$('#search_sub1').toggle();return false;
}); 
$('#search_env').val(gl_page.env);
$('#search_query').val(gl_page.query);
$('#skipCI').prop("checked",gl_page.withCI);

</script>
<%
response.flush
glf.findThemAll safe_env
%>
<script type="text/javascript">


var links = <% glf.printLinks() %>;
var nodes_plus = <% glf.printNodes() %>;
render_relationships_graph( links, nodes_plus, gl_page.withCI);


</script>
</body>
</html>
