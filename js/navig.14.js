var navig={keepAlive:'keepAlive.asp'}

navig.menu=function(){
	var bolder= function(x){
		return gl_page.query==x?'style="font-weight:bolder"':'';
	}

	var doAdv=function(more){
		var ticket_url = "&amp;query="+gl_page.query;
		return '<li class="advancedBar"><a href="#">Advanced...</a>'+
	'<ul><li><a id="addSearchProvider" href="#">Browser search plugin...</a></li><li>-</li><li><a href="#" id="exportPopUp">Export...</a></li><li><a href="#" id="mapComments">Remark lines with comments</a></li><li><a href="data.asp?t='+gl_page.selector+'&amp;s='+gl_page.sens+more+ticket_url+'&amp;Lina=y">Download SQL</a></li><li>-</li>'+
	'<li><a href="#">NGDC features...</a><ul>'+
		'<li><a href="?t=CRQ-TEMPLATE&amp;s=a'+more+'" title=" where TAS are assigned to current team">Active change\'s template with assignement</a></li><li><a href="?t=CRQ-TEMPLATE&amp;s=c'+more+'" title="where CRQ is coordinated by current team">Active change\'s template coordinated</a></li><li><a href="?t=CRQ-TEMPLATE&amp;s=m'+more+'" title="where CRQ is managed by current team">Active change\'s template managed</a></li><li><a href="?t=CRQ-TEMPLATE&amp;s=s'+more+'" title="where current team is author">Active change\'s template submitted</a></li></ul></li>'+
	'<li>-</li><li><a href="#" id="activeSort" class="ui-state-disabled">Activate Sorting</a></li><li><a id="RemedyKeepAlive" href="'+navig.keepAlive+'#">Remedy Keep Alive</a></li></ul></li>'+"\n";
	}

	var doCRQ=function(more){
	return '<li class="ngdcBar"><a href="#" class="">ITSM Changes...</a>'+
			'<ul><li><a class="TicketSubmitted" href="?t=CRQ&amp;s=s'+more+'">CHANGES submitted</a>'+
			'<ul><li><a href="?t=CRQ&amp;s=s'+more+'">by current team</a></li></ul></li><li><a class="TicketManaged" href="?t=CRQ&amp;s=m'+more+'">CHANGES managed</a></li><li><a	class="TicketAssigned"	href="?t=CRQ&amp;s=a'+more+'">CHANGES assigned</a></li><li style="display:none"><a class="TicketPendingApprobation" href="?t=CRQ-AP&amp;s=m'+more+'" >APPRO waiting:<span class="approbationCount">?</span></a></li></ul></li>'+"\n";
	}

	var doINC=function (more){
		return '<li class="ngdcBar"><a href="#" class="">ITSM Incidents...</a>'+
			'<ul><li><a class="TicketSubmitted" href="?t=INC&amp;s=m'+more+'">INCIDENTS submitted</a></li><li><a class="TicketAssigned" href="?t=INC&amp;s=a'+more+'">INCIDENTS assigned</a></li></ul></li>'+"\n";
	}

	var doTAS=function(more){
		return '<li  class="ngdcBar"><a href="#" class="">ITSM Task... <span class="taskCount"></span></a><ul>'+
		'<li><a class="TicketAssigned" href="?t=TAS&amp;s=a'+more+'">Tasks assigned</a></ul></li>'+"\n";
	}

	var doPBI=function(more){
	return '<li class="ngdcBar"><a href="#" class="">ITSM Problems...</a>'+
		'<ul><li><a class="TicketSubmitted" href="?e=N&amp;t=PBI&amp;s=s'+more+'">PROBLEMS submitted</a><ul><li><a href="?t=PBI&amp;s=s'+more+'" >by current team</a></li></ul></li><li><a class="TicketManaged" href="?t=PBI&amp;s=m'+more+'" >PROBLEMS managed</a></li><li><a class="TicketAssigned" href="?t=PBI&amp;s=a'+more+'" >PROBLEMS assigned</a></li></ul></li>'+"\n";
	}

	var doREQ=function(more){
		return '<li class="ngdcBar"><a href="?t=REQ&amp;s='+gl_page.sens+more+'" title="Help find INIT created ticket" >ITSM Service Request...</a><ul><li><a href="?t=REQ-AP&amp;s='+gl_page.sens+more+'"  title="Verify personnal REQ approbation">My Service request Approbation</a></li></ul></li>';
	}
	
	var generateMenu=function(){
		var html;
		var less = "&amp;g="+gl_page.group+"&amp;tz="+gl_page.timezone ;
		var more ='&amp;e='+gl_page.env+less;
		var $sub;
		html = doAdv(more)+"<li>-</li>\n";;
	 
		if ((( gl_page.group == "ORA-L3" || gl_page.group == "MSSQL-L3" ) || ( gl_page.group == "UNIX-L3"||gl_page.group == "ETL-L3")) ||  gl_page.group=="SAP-L3" ){ 
			html+='<li class="legacyBar"><a href="#" class="">ARS ...</a><ul><li	class=""><a	href="?t=INC&amp;e=L'+less+'">INCIDENTS</a></li><li	class=""><a	href="?t=PBI&amp;e=L'+less+'">PROBLEMS</a></li><li	class=""><a	href="?t=WKO&amp;e=L'+less+'">WORK ORDERS</a></li></ul></li>';
		} // ORA & MSSQL & UNIX & ETL & SAP

		html+=doINC(more)+doCRQ(more)+doTAS(more)+doPBI(more);
		html+='<li>-</li><li class="ngdcBar"><a href="?t=WO&amp;s='+gl_page.sens+more+'"  title="still beta" >ITSM Work Order</a></li>'+doREQ(more)+'<li>-</li><li class="ngdcBar"><a href="?t=PEOPLE&amp;s='+gl_page.sens+more+'" title="Help find Promise ITSM users">ITSM People</a></li>';
		return html;
	}
	
	$('#mysubmenu').append( generateMenu() );
	$("#mymenu").menu( {position:{my:"top",at:"right"}}).show();
		$('#activeSort').click( function(){
		addSort($('#PromiseGate'),0);
		$(this).addClass("ui-state-disabled");
	});
	$('#exportPopUp').click(function(){makeExportPopup();return false;});
	$('#refresh').click(function(){refresh_data();return false;});
	$('#addSearchProvider').click(function(){openSearchProvider();return false;});
	$('#timezone').change(function(){window.location.search='?t='+gl_page.selector+'&s='+gl_page.sens+'&e='+gl_page.env+'&g='+gl_page.group+'&tz='+$(this).val()+'&query='+gl_page.query;});
	$('#mapComments').click(function(){
		if ( run.comments.binded ){mapComments( $('#PromiseGate tbody tr'));}
		else {initComments();}
		return false;
	});
	$('#RemedyKeepAlive').click( function(){
		window.open(navig.keepAlive,'remedyKeepAlive','scrollbars=yes,resizable=yes,location=yes,status=no,width=400,height=300');return false;
	});
}

navig.search=function(){
	var tmp
	var generateSearch=function(){
		var html='<form action="?" method="get" id="search"><fieldset><legend>Search form</legend>';
		html+='<p><label for="search_type">Type:</label><select id="search_type" name="t"><optgroup label="Ngdc"><option value="INC">Incident</option><option value="CRQ">Change</option><option value="TAS">Task</option><option value="PBI">Problem</option><option value="REQ">Request</option><option value="WO">Work Order</option><option value="PEOPLE">Support group member</option><option value="CI">Configuration Item</option></optgroup><optgroup label="Ngdc approvals"><option value="REQ-AP">Request approvals</option><option value="CRQ-AP">Change approvals</option></optgroup><optgroup label="Ngdc special"><option value="CRQ-TEMPLATE">Change template</option><option value="CRQ-COOK">Compliancy of changes</option><option value="CRQ-FREESE">Changes with buggy tasks</option></optgroup><optgroup label="Legacy"><option>INC</option><option>PBI</option><option>WKO</option></optgroup></select>';
		html+=' <label for="search_sens" title="">View:</label><select id="search_sens" name="s"><optgroup label="Ngdc"><option value="a" title="Generic and default">Assignee</option><option value="s" title="Ticket you submitted">Submitter</option><option value="m" title="CRQ and PBI only">Manager</option><option value="c" title="CRQ and PBI only">Coordinator</option></optgroup></select>'+"\n";
		html+=' <label for="search_group">Support&nbsp;group:</label><select id="search_group" name="g"><optgroup label="Smart group"><option value="AUTO">my default support group</option><option value="MYSELF">myself, alone</option><option value="ALL">all my support groups</option></optgroup>';
			html+='<optgroup label="Data Management"><option value="DTMG">Data Management</option><option value="ORA-L3">L3 Oracle</option><option value="ORA-L2">L2 Oracle</option><option value="MSSQL-L3">L3 SQL Server</option><option value="MSSQL-L2">L2 SQL Server</option><option value="BDOTHER-L3">L3 Other databases</option><option value="ETL-L3">L3 ETL/EAI</option></optgroup>'
			+'<optgroup label="Infrastructure"><option value="SAN-L3">L3 Backup/SAN</option><option value="SAN-L2">L2 Storage</option><option value="BKP-L2">L2 Backup Restore</option><option value="MDW-L3">L3 Middelware</option><option value="MDW-L2">L2 Middleware</option><option value="UNIX-L3">L3 Unix</option><option value="UNIX-L2">L2 Unix</option><option value="WIN-L3">L3 Windows</option><option value="WIN-L2">L2 Windows</option><option value="NETWK-L2">L2 Network</option><option value="NETDIR-L2">L2 Network Directory</option><option value="OS400-L2">L2 OS400</option><option value="SAP-L2">L2 SAP</option><option value="EXCHG-L3">L3 Exchange</option><option value="MSG-L3">L3 Instant messaging</option></optgroup>'
			+'<optgroup label="Tools"><option value="MON-L3">L3 Monotoring tools</option><option value="MON-L2">L2 Monitoring</option><option value="SCHED-L3">L3 Scheduling tools</option><option value="SCHED-L2">L2 Scheduling</option><option value="PROVI-L3">L3 Provisioning tools</option><option value="PROVI-L2">L2 Provisioning </option><option value="CTOOL-L3">L3 configuration tools</option><option value="OPTOOL-L2">L2 Operation Tools Others</option><option value="COLLAB-L2">L2 Collaboration</option><option value="EROOM-L2">L2 EROOM</option></optgroup>'
			+'<optgroup label="Application services"><option value="AS_ALL-L3">L3 Application Services (all)</option><option value="AS_IA-L3">L3 IA</option><option value="AS_PO-L3">L3 PO</option><option value="AS_RSC-L3">L3 R&amp;D</option><option value="AS_VAX-L3">L3 Vaccines</option><option value="AS_CORP-L3">L3 Corporate</option><option value="AS_GZM-L3">L3 Genzime</option><option value="AS_MER-L3">L3 Merial</option></optgroup>'
			+'<optgroup label="L1"><option value="OP-L1">Operation &amp; Monitoring</option><option value="SDP-L1">Service desk Pasteur</option></optgroup>'
			+'<optgroup label="Misc"><option value="COORD-L2">Accenture coordinators</option><option value="PTC">PTC</option><option value="AMTF-L3">AMTF L3 Group</option><option value="POD">POD Provisioning On Demand</option></optgroup></select>'+"\n";
		html+='<button id="verifyTeam" title="Check selected support group">Check</button> <button id="addGroup" title="add support group">Add</button> <button id="showAdvanced" title="Show advanced settings">...</button></p>';
		html+='<div id="search_sub1" style="display:none"><label for="search_env">Environment:</label><select name="e" id="search_env"><optgroup label="Ngdc"><option value="N" selected="selected">Production Reporting Database</option><option value="S" selected="selected">UAT transactional database</option><option value="T" selected="selected">Test reporting database</option><option value="P" selected="selected">Production transactional database</option><option value="O" selected="selected">Retired production database</option></optgroup><optgroup label="Legacy"><option value="L">ARS -Pasteur</option></optgroup></select>'+
		' <label for="search_tz">TimeZone:</label><select name="tz" id="search_tz"><option selected="selected">'+gl_page.timezone+'</option><optgroup label="available timezone"><option value="PST">[-08:00] PST</option><option value="MST">[-07:00] MST</option><option value="CST">[-06:00] CST</option><option value="EST">[-05:00] EST(Reston)</option><option value="CET">[+01:00] CET(Marcoussis)</option><option value="GMT">[+00:00] GMT</option><option value="Asia/Calcutta">[+05:30] Asia/Calcutta</option><option value="Singapore">[+08:00] Singapore</option><option value="Japan">[+09:00] Japan</option></optgroup></select>'
	+' <label>Results&nbsp;as&nbsp;login:</label><input id="search_user" type="text" name="user" value="" disabled="disabled" title="To use with MYSELF or Auto team group."/> <button id="allTypes" title="Add them into type select box">Additional types</button></div><hr/>'+"\n";
		html+='<div id="search_sub2"><label for="search_query">Below write tickets, magic word, login or support group name and select the correct type. You can search changes by REQ or CRQ number, tasks by TAS or CRQ number. You can also search changes and incidents by CI (asset) with @"&lt;CI-name-with-space&gt;" or @&lt;CI-name-without-space&gt; syntaxes.</label><textarea name="query" id="search_query"></textarea>';
			html+='<div id="collect1Colum">Fill</div><div id="restaureValues">Current values</div><div class="mw_ngdc mw_CRQ mw_INC mw_PBI">P1</div><div class="mw_ngdc mw_CRQ mw_TAS">AMTF</div><div class="mw_ngdc mw_CRQ mw_INC mw_PBI mw_REQ" >REVIEW</div><div class="mw_ngdc mw_CRQ mw_TAS mw_INC mw_PBI mw_REQ mw_CRQ-FREESE" >IMPLEMENTATION</div><div class="mw_ngdc mw_CRQ mw_TAS mw_INC mw_PBI mw_REQ" >PENDING</div><div class="mw_ngdc mw_CRQ mw_INC mw_PBI mw_REQ" >DONE</div><div class="mw_ngdc mw_CRQ mw_TAS mw_INC mw_REQ mw_PBI mw_CRQ-COOK" >FRESH_CLOSED</div><div class="mw_ngdc mw_CRQ mw_INC mw_REQ" >FROM_TOOL</div><div class="mw_ngdc mw_CRQ" >NO_TASK</div><div class="mw_ngdc mw_CRQ" >NO_DB</div><div class="mw_ngdc mw_CRQ" >NO_SERVER</div><div class="mw_ngdc mw_CRQ" >NO_CI</div><div class="mw_ngdc mw_CRQ" >NO_APP</div><div class="mw_ngdc mw_TAS" >OLD</div><div class="mw_ngdc mw_TAS">SLOW</div><div class="mw_ngdc mw_CRQ mw_TAS">CHECK_TEMPLATE</div></div><div class="reset"></div>';
		html+='<div><input type="checkbox" id="activateComments"/><label for="activateComments" title="Ctrl+double-click">Use&nbsp;comments</label>, <input type="checkbox" id="inNewWindows"/><label for="inNewWindows">Open in a new window</label>, <input type="checkbox" id="autoTicketType"/><label for="autoTicketType">Auto ticket type</label></div></fieldset><div id="search_sub3"><input class="submit" type="submit" value="Retrieve" style="width:100%;height:4em" /></div></form>'
		+"\n";
		return html;
	}
	
	var handleMagicWords = function( envSelected,typeSelected){
		$('#search_sub2 .mw_ngdc').hide();
		if (envSelected!=='L'){$('#search_sub2 .mw_'+typeSelected).show();}
	}
	
	var handleQueryUpdate = function(){
		if ($('#autoTicketType').filter(':checked').length){
			var matches=$('#search_query').val().match(/\b(PBI|INC|CRQ|REQ|WO|TAS|WKO)[0-9]{4,13}\b/i)
			if (matches && matches[1]){$('#search_type').val(matches[1]).trigger("change");}
		}
	}
	
	//if the page was saved localy, we don't need to rebuild the search form.
	if ($('#search').lenght!==1 ){$('body').append(generateSearch());}
	
	//but we need to rebuild all the handler
	$('#allTypes').click(function(){
		$(this).prop('disabled',true);
		$('#search_type').append('<optgroup label="Ngdc additional [Only with tickets]"><option value="CRQ-CWL">Changes workinfos</option><option value="CRQ-LOG">Change audit log</option><option value="CRQ-MORE">Change details</option><option value="INC-MORE">Incident details</option><option value="INC-WLG">Incident workinfos</option><option value="INC-HDA">Incident assignement</option><option value="INC-LOG">Incident Audit</option><option value="TAS-LOG">Task audit log</option><option value="TAS-MORE">Task details</option><option value="TAS-SCHED">Task schedule check</option><option value="TAS-TWI">Task workinfos</option><option value="REQ-ANSWER">Request answer</option><option value="REQ-RWI">Request workinfos</option><option value="REQ-LOG">Request audit log</option><option value="PBI-PIW">Problem workinfos</option><option value="PBI">Problem audit log</option></optgroup>');
		return false;
	});
	$('#autoTicketType').prop('checked',cookie.read('itsm-form-ATT')==='0'?false:true);
	$('#activateComments').prop('checked',cookie.read('itsm-form-CMT')==='1'?true:false);
	//$('#inNewWindows').prop('checked',cookie.read('itsm-form-INW')==='0'?false:true);
	
	var $tmp=$('#search_type');
	$tmp.change(function(){handleMagicWords($('#search_env').val(),$(this).val());})
	if ($tmp.find('option[value="'+gl_page.selector+'"]').length===0){
		$tmp.prepend('<option>'+gl_page.selector+'</option>');}
	$tmp.val(gl_page.selector);
	
	
	$tmp=$('#search_group');
	if ($tmp.find('option[value="'+gl_page.group+'"]').length===0){
		$tmp.append('<optgroup legend="From Query"><option>'+gl_page.group+'</option></optgroup>');}
	$tmp.val(gl_page.group);
	
	$('#addGroup').click(function(){
		var tmp=htmlEncode($.trim(prompt('Enter support group name (separated by "," without space)','')).toUpperCase());
		if ( tmp.length!=""){$('#search_group').prepend('<option>'+tmp+'</option>').val(tmp);}return false;
	});
	
	$('#verifyTeam').click(function(){var tmp=$('#search_group').val();makeDetailsPopup(run.url.data+'?t=PEOPLE&thead=y&g='+tmp+'&user='+$('#search_user').val(),'Support group(s) members '+tmp);return false;});
	$('#search_query').val(gl_page.query).bind('click change keyup',function(){handleQueryUpdate();});
	$('#search_sens').val(gl_page.sens);
	$('#showAdvanced').click(function(){$('#search_sub1').toggle();$('#search_user').prop('disabled',false);return false;});
	$('#search_env').val(gl_page.env).change(function(){
		var tmp = $(this).val();
		handleMagicWords(tmp,$('#search_type').val());
		if (tmp==='L'){$('#verifyTeam').attr('disabled','disabled').addClass('ui-state-disabled');}
		else{$('#verifyTeam').removeAttr('disabled').removeClass('ui-state-disabled');}
	});
	
	$('#collect1Colum').click( function(){
		var tmp=columnToArray('td:first-child');$('textarea#search_query').val(tmp.join(' ')).trigger("change");return false; 
	}).text('fill with '+$('#PromiseGate thead').find('tr:first-child').find('th:first-child').text());
	$('#search_sub2 .mw_ngdc').click(function(){$('#search_query').val( $(this).text() );return false;});
	
	$('#showSearch').click( function(){
		$('#search').dialog({
			buttons:{'Submit': function(){ $('#search').trigger('submit');},
			'Close':function(){$(this).dialog('close');}},
			modal:false,width:560,dialogClass:"popup",title:"New search",
			close: function(){$(this).dialog("destroy").find('#search_sub3').show();},
			open: function(){$(this).find('#search_sub3').hide();}
		});
		return false;
	});
	
	$('#restaureValues').click(function(){$('#search_query').val(gl_page.query);return false;});
	$('#activateComments').click(function(){
		run.comments.enabled=$(this).prop('checked');
		if (!run.comments.binded && run.comments.enabled){initComments();}	
	}).prop('checked',false);
	
	handleMagicWords(gl_page.env,gl_page.selector);
	//form submit 
	$('#search').submit( function() {
		if ( $('#inNewWindows').filter(':checked').length ) {$(this).attr('target','_blank');}
		else {$(this).removeAttr('target');}
		
		var $tmp=$('#search_user').filter(':enabled');
		if ($tmp.lenght ){
			if ( $.trim($tmp.val()).length===0 ){$('#search_user').prop('disabled',true);}
			else {$tmp.val($tmp.val().toUpperCase());}
		}
		cookie.create('itsm-form-ATT',$('#autoTicketType').filter(':checked').length,8);
		cookie.create('itsm-form-CMT',$('#activateComments').filter(':checked').length,8);
		//cookie.create('itsm-form-INW',$('#inNewWindows').filter(':checked').length,8);
	});
}

var cookie={
create: function(name,value,days){
	if (days){var date=new Date();date.setTime(date.getTime()+(days*24*3600000));var expires="; expires="+date.toGMTString();}else{var expires="";}document.cookie=name+"="+value+expires+"; path=/";},
read:function(name){
	var nameEQ=name + "=";var ca=document.cookie.split(';');for(var i=0;i < ca.length;i++){var c=ca[i];while (c.charAt(0)==' ') c=c.substring(1,c.length);if (c.indexOf(nameEQ)==0)return c.substring(nameEQ.length,c.length);}return null;},
erase:function(name){
	createCookie(name,"",-1);}
}
