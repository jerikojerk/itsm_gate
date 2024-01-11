<!--#INCLUDE FILE="lib/lib_common.asp"--><!--#INCLUDE FILE="lib/lib_page.asp"--><%
Const ANTI_CACHE_SEED=14
security_identify_dba false
response.AddHeader "x-ua-compatible", "ie=edge"

dim options, caption, field_id, query, buffer_title
set options = new UserOptions
options.init SECURITY_USER

set query=page_prepare(options, field_id, caption)
buffer_title=page_title (options)
'if VERBOSE then response.write "</font>"
%><!DOCTYPE html>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
<title><%= buffer_title & " on ITSM Gate" %></title>
<link href="favicon.ico" rel="shortcut icon" />
<link rel="stylesheet" type="text/css" media="screen" href="js/ui/jquery-ui.css" /> 
<link rel="stylesheet" type="text/css" media="print" href="print.css" /> 
<link rel="stylesheet" type="text/css" media="screen" href="itsm_gate.<%=ANTI_CACHE_SEED%>.css" />
<link rel="stylesheet" type="text/css" media="screen" href="js/columnFilter.css" />
<script type="text/javascript" src="js/jquery-1.11.1.min.js"></script>
<script type="text/javascript" src="js/columnFilter.js"></script>
<script type="text/javascript" src="js/columnFilterExport.js"></script>
<script type="text/javascript" src="js/sort/jquery.tablesorter.min.js"></script>
<script type="text/javascript" src="js/sort/parser-date-pep.js"></script>
<script type="text/javascript" src="js/itsm_gate.<%=ANTI_CACHE_SEED%>.js"></script>
<script type="text/javascript" src="js/ui/jquery-ui-1.10.4.custom.min.js"></script>
<script type="text/javascript" src="js/navig.<%=ANTI_CACHE_SEED%>.js"></script>
<link rel="search" href="opensearch/change.xml" type="application/opensearchdescription+xml" title="Change search" />
<link rel="search" href="opensearch/incident.xml" type="application/opensearchdescription+xml" title="Incident search" />
<link rel="search" href="opensearch/problem.xml" type="application/opensearchdescription+xml" title="Problem search" />
<link rel="search" href="opensearch/people.xml" type="application/opensearchdescription+xml" title="People search" />
<link rel="search" href="opensearch/task-assigned.xml" type="application/opensearchdescription+xml" title="Task search" />
</head>
<body>
<div id="top"></div>
<h1>ITSM Gate: <%= buffer_title %></h1>
<p style="background:yellow;border:black;size:16pt">Hello, this tool is now at its end of life and will be removed soon.</p>
<%
'pass some const / values / to JS.
page_embededJavascriptGlobalsWriter options
page_toolBarWriter options 
'print the page according to users's options
if  options.action = P_WELCOME then 
	%><!--#INCLUDE FILE="lib/lib_home.asp"--><%
	home_welcome2 options
else 
	page_result query,options, SECURITY_USER,field_id,caption
end if 'WELCOME 
	page_search
set options= nothing
%>
<div id="down">
</div>
</body>
</html>