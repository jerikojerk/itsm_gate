<%
Const ANTI_CACHE_SEED=13
%><!DOCTYPE html>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
<title>Promise Keep Alive</title>
<link href="favicon.ico" rel="shortcut icon" />
<link rel="stylesheet" type="text/css" media="screen" href="js/ui/jquery-ui.css" /> 
<link rel="stylesheet" type="text/css" media="print" href="print.css" /> 
<link rel="stylesheet" type="text/css" media="screen" href="itsm_gate.<%=ANTI_CACHE_SEED%>.css" />
<link rel="stylesheet" type="text/css" media="screen" href="js/columnFilter.css" />
<script type="text/javascript" src="js/jquery-1.11.1.min.js"></script>
<script type="text/javascript" src="js/ui/jquery-ui-1.10.4.custom.min.js"></script>
<link rel="search" href="opensearch/change.xml" type="application/opensearchdescription+xml" title="Change search" />
<link rel="search" href="opensearch/incident.xml" type="application/opensearchdescription+xml" title="Incident search" />
<link rel="search" href="opensearch/problem.xml" type="application/opensearchdescription+xml" title="Problem search" />
<link rel="search" href="opensearch/people.xml" type="application/opensearchdescription+xml" title="People search" />
<style type="text/css">
iframe {width:100%;height:100%;border:dashed 6px orange;overflow:hidden;}

</style>
</head>
<body>
<h1>Keep Alive Popup</h1>
<p><a href="?">Reload</a> or <a href="index.asp" target="_blank">ITSM GATE home page</a>. This keep alive will expire at <span id="expire"></span>.</p>
<div id="RemedyFrame">
</div>
<script type="text/javascript">
var remedyKeepAlive={
delay:170000,
job:0,
horizon:20000100,
killjob:0,
url:'https://SERVER/arsys/forms/itsm-ars/SHR%3AOverviewConsole_SelectRequestType_dlg/Dialog+View/?'};

var $popup=$('#RemedyFrame').append('<iframe src="'+remedyKeepAlive.url+'"></iframe>');	
remedyKeepAlive.job=window.setInterval(function(){
	$popup.empty().append('<iframe src="'+remedyKeepAlive.url+'" ></iframe>');
},remedyKeepAlive.delay+Math.random()*100-50);

remedyKeepAlive.killjob=window.setTimeout(function(){
	if (remedyKeepAlive.job){
		window.clearInterval(remedyKeepAlive.job);remedyKeepAlive.job=null;
//		window.clearTimeout(remedyKeepAlive.killjob);remedyKeepAlive.killjob=null;
		$popup.empty().append('<p>keep alive is too old now!</p>');
		$('title,h1').each( function(){var $me=$(this);$me.text($me.text()+'(expired)');}); 
	}
},remedyKeepAlive.horizon);
var dt=new Date();
dt.setTime(dt.getTime()+remedyKeepAlive.horizon);
$('#expire').text( dt.toString());

</script>
</body>
</html>
