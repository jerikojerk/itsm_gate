//itsm gate main JS file.
var run={};

run.rooturl=location.origin+location.pathname;
run.url={downloadify_js:"js/downloadify/downloadify.min.js", flashLib_js:"js/downloadify/SWFObject.js", csv_js:"js/csvExport.js", data:"data.asp",opensearch:{
crq:'opensearch/change.xml',inc:'opensearch/incident.xml',pbi:'opensearch/problem.xml',req:'opensearch/request.xml',people:'opensearch/people.xml',crqa:'opensearch/change-assigned.xml',inca:'opensearch/incident-assigned.xml',pbia:'opensearch/problem-assigned.xml',reqa:'opensearch/request-assigned.xml'}};
run.land=document.location;
run.promisegate='/promise_gate_index.asp?msg=wig';
run.downloadify={swf:'js/downloadify/downloadify.swf',downloadImage:'js/downloadify/download.png'}
run.filters=false;
run.sort	= false;
run.currentSort=false;
run.sortDefault={selectorHeaders:'thead tr th',cancelSelection:true,sortMultiSortKey:"ctrlKey",sortResetKey:'shiftKey', textExtraction:function(node){ return $(node).text()}};
run.sortSlowBrowserDivisor=2;
// custom action for promisegate 
run.tempo={age1:4000,age2:60000,age3:3600000,approbation:600000,garbage:60000,storeMaxAge:17280000000,remainingTime:20,sort:99}; //
run.cycleId={age1:null,age2:null,age3:null,approbation:null};
run.notParkinson=true;
run.comments={supported:supports_html5_storage(),latestkey:null,node:null,binded:false, enabled:true};
run.csvDefault={separator:';',popup:false};
run.ignoreSelector='.noCsv';
run.timePattern =/(\d{4})-(\d{1,2})-(\d{1,2})\s*(\d{1,2})?:?(\d{1,2})?:?(\d{1,2})?/;



// from the web
run.QueryString=function () {
  // This function is anonymous, is executed immediately and 
  // the return value is assigned to QueryString!
  var query_string={};
  var query=window.location.search.substring(1);
  var vars=query.split("&");
  var j,pair;
  for (var i=0;i<vars.length;i++) {
		j= vars[i].indexOf('=');
		pair=[vars[i].slice(0,j), vars[i].slice(j+1)];
    	// If first entry with this name
	if ( pair[0] === "" ) {}
    else if (typeof query_string[pair[0]] === "undefined") {
      query_string[pair[0]]=pair[1];
    	// If second entry with this name
    } else if (typeof query_string[pair[0]] === "string") {
      var arr=[ query_string[pair[0]], pair[1] ];
      query_string[pair[0]]=arr;
    	// If third or later entry with this name
    } else {
      query_string[pair[0]].push(pair[1]);
    }
  } 
    return query_string;
} ();


run.isIE=function(){
  var myNav=navigator.userAgent.toLowerCase();
  return (myNav.indexOf('msie') != -1) ? parseInt(myNav.split('msie')[1]):false;
}();

run.readJavascriptArg=function( ){
	var js={filters:[]}
	var json,tmp=run.QueryString.js;
	try {
		if ( tmp ){
			json=Base64.decode( decodeURIComponent(tmp) );
			js= $.extend( js, JSON.parse(json));
		}
	}
	catch( e ){alert("Can not read your filters"+ e.message );}
	return js;
}()

function supports_html5_storage() {
  try {
    return 'localStorage' in window && window['localStorage'] !== null;
  } catch (e) {
    return false;
  }
}

function saveStorage(key, value) {
	try{
		return localStorage.setItem(key, JSON.stringify(value));
	}
	catch(e){
		alert('Some error occured during storage');
	}
}

function readStorage(key) {
    var value=localStorage.getItem(key);
	try {
		if ( value ){
			return JSON.parse(value);
		}
		else {
			return undefined;
		}
	}
	catch(e){
		return undefined;
	}
}

function removeStorage(key){
	localStorage.removeItem(key);
}

function cleanGarbage( callback ){
	for( key in localStorage ){
		if ( callback( readStorage(key) ) ){
			localStorage.removeItem(key);
		}
	}
}

isOldComment=function ( obj ){
	if (  ( typeof obj=="object" ) && ( obj.itsm !== undefined ) ){
		var tmp=(new Date()).getTime() - obj.itsm.t;
		return  tmp > run.tempo.storeMaxAge ;
	}
	else {
		return false;
	}	
}

function addSort( $table, rowcount){
	var $th=$table.find('thead th');
	var $td=$th.filter(':contains("SUBMIT DATE")');
	var pos=$td.prevAll().length;
	if (!run.sort){
		
		var test=false;
		
		var s={};
		var reg=/\bTIME$|\bDATE$/

		$th.each( function (index,elem) {
			if ( reg.test($(elem).text())){
				s[index]={sorter:'isoPEPdate'};
				test=true;
			}
		});
		
		run.sort=true;
		var options=run.sortDefault;
		if (test){
			options.headers=s;
		}
		var tmp=gl_page.lesser_mode;
		
		if (run.isIE){tmp=tmp/run.sortSlowBrowserDivisor;}
		
		if ( rowcount <  tmp ){	
			if ( gl_page.type=='TAS'){
				options.sortList=[[1,0],[5,0]];
			}
			else if (gl_page.type=='WKO'){
				options.sortList=[[1,0],[0,0]];
			}
			else if ( gl_page.type=='CRQ'||gl_page.type=='INC' ){
				options.sortList=[[pos,0]];
			}
		}
		
		$table.bind("sortEnd", function(sorter) {
			run.currentSort=sorter.target.config.sortList;
		});
		
		$table.tablesorter( options );
	}
}

function agePage(){
	var now=new Date();
	now=now.getTime();
	var sec=Math.round((now-run.timeJs)/1000 );
	if ( sec < 60 ){
		$('#generationTime').text(sec+' secondes ago');
	}
	else{
		var mn=Math.round(sec/6)/10;
		if (mn<60){
			$('#generationTime').text(mn+' minutes ago');
		}
		else {
			var hr=Math.round(mn/6)/10;
			if ( hr < 24 ){
				$('#generationTime').text(hr+' hours ago');
			}
			else {
				$('#generationTime').text(Math.round(hr/24)+' days ago');
			}
		}
	}
}

function columnToArray(columnSelector){
	var cumul=new Array()
	var $rows=$('#PromiseGate tbody tr.selected');
	var $cell,tmp;
	if ( $rows.length < 1 ){
		$rows=$('#PromiseGate tbody tr');
	}
	
	$rows.filter(':visible').find(columnSelector).each(function(){
		$cell=$(this);
		cumul.push(getCellText($cell));
	});
	return cumul;
}


function getCellText($cell){
	if ( $cell.children().length ){
		var tmp=$cell.clone(false);
		tmp.children().remove(run.ignoreSelector );
		return tmp.text()
	}
	else {
		return $cell.text();
	}
}	
	

/*
function checkLibVersion(){
	if ( Base64.decode( run.security ).search( gl_page.security )>0 ){
		window.setTimeout(  function(){run.land.href=run.promisegate}, 15000 );
	}else{
//		ping_server( "" );
	}
};*/

function dateFormaterAmerican(o){
	var hh,ampm;
	var h=o.getUTCHours();
	if (h<12){
		if(0==h){hh=12}else{hh=h;}
		ampm=' AM';
	}else{
		if (12==h){hh=h;}else{hh=h-12;}
		ampm=' PM'
	}
	return (o.getUTCMonth()+1)+'/'+o.getUTCDate()+'/'+o.getUTCFullYear()+' '+hh+':'+o.getUTCMinutes()+':'+o.getUTCSeconds()+ampm;
}

function dateComparator(node, refTS, highlight){
	var content= $.trim(node.text());
	if (""==content){
		return  0;
	}
	var ticketDt=parseTimeString(content);
	var tmp=Math.round((ticketDt.getTime()-refTS)/360000)/10;	
	var abs=Math.abs(tmp);
	
	if ( abs > 24 ){
		node.text('').append('<span class="date">'+content+'</span><br/><span class="noCsv quiet">'+Math.round(tmp/24)+' days,<br/>'+dateFormaterAmerican(ticketDt)+'</span>');
	}
	else{
		node.text('').append('<span class="date">'+content+'</span><br/><span class="noCsv quiet">0 days, '+ tmp+' hrs,<br/>'+dateFormaterAmerican(ticketDt)+'</span>');
		if ( highlight ) {
			if ( tmp < 0 ){
				node.addClass('overDueLittle');
			}
			else{
				node.addClass('overDueAlmost');
			}
		}
	}
}

function scheduledJobs(){
	var tmp=parseTimeString($('#generationTime').text());
	run.timeGenerate=tmp.getTime();
	tmp=new Date();
	run.timeJs=tmp.getTime();
	run.timeDelta=run.timeGenerate-run.timeJs;
	if ( gl_page.action === "W" ){
		return false;
	}
	
	//remove all.
	if ( run.cycleId.age1 ) {window.clearTimeout( run.cycleId.age1 );}
	if ( run.cycleId.age2 ) {window.clearTimeout( run.cycleId.age2 );}
	if ( run.cycleId.age3 ) {window.clearTimeout( run.cycleId.age3 );}
	
	//set 4 refresh intervals, 
	//if ( !run.cycleId.approbation ){run.cycleId.approbation=setInterval( function(){refresh_counts();}, run.tempo.approbation);}
	run.cycleId.age1=window.setInterval( function(){ agePage();}, run.tempo.age1);
	window.setTimeout( function(){	run.cycleId.age2=window.setInterval( function(){if(run.cycleId.age1){window.clearInterval( run.cycleId.age1);run.cycleId.age1=null;};agePage();},run.tempo.age2/4);}, run.tempo.age2 );
	window.setTimeout( function(){run.cycleId.age3=window.setInterval( function(){if(run.cycleId.age2){window.clearInterval( run.cycleId.age2);run.cycleId.age2=null};/*if(run.cycleId.approbation){window.clearInterval(run.cycleId.approbation);run.cycleId.approbation=null};refresh_counts();*/},run.tempo.age3/4);}, run.tempo.age3 );
	
	refresh_counts();
	return true;
}

function initComments(){
	if ( run.comments.supported ){
		var tmp= $( '#PromiseGate tbody tr').dblclick(function(event){
					if ( run.comments.enabled &&  event.ctrlKey  ){
						run.comments.latestkey=$(this).attr('title')
						makeCommentPopup();
					}
			});
		mapComments(tmp);
		run.comments.binded=true
	}
	else {
		$('#activateComments').hide();
	}
}

function mapComments( $selectors ){
	$selectors.each( function(){
		var $this=$(this);
		var key=$.trim($this.attr('title'));
		var tmp=readStorage(  key );
		if ( ( tmp === undefined || tmp === null ) || tmp.itsm === undefined ){
			$this.removeClass("withComment");
		}
		else{
			if ( ! $this.hasClass("withComment") ) {
				$this.addClass("withComment");
			}
		}
	});
}

function installSearchEngine(url) {
	if (window.external && ("AddSearchProvider" in window.external)) {
	   // Firefox 2 and IE 7, OpenSearch
		window.external.AddSearchProvider(url);
		} else if (window.sidebar && ("addSearchEngine" in window.sidebar)) {
	   // Firefox <= 1.5, Sherlock
		window.sidebar.addSearchEngine(url);
		} else {
	   // No search engine support (IE 6, Opera, etc).
		alert("No search engine support");
	 }
}

function initTable(){
	var $row=$('#PromiseGate tbody tr')
	var rowcount=$row.length;
	$('#rowTotalCount').text( rowcount );

	if ( rowcount <= gl_page.lesser_mode ){
		window.setTimeout(function(){ remainingTime($('#PromiseGate')) ;}, run.tempo.remainingTime );
		//addSort( $('#PromiseGate') ,rowcount);
		window.setTimeout(function(){ addSort( $('#PromiseGate') ,rowcount)}, run.tempo.sort );	
	}
	else {
		$("#activeSort").removeClass("ui-state-disabled");
		if (rowcount==gl_page.max_row){
			alert( "The server hit max row limit, unknown number of rows were not retreived and page will run with limited functionnality.");
		}
		else{
			alert( "Your request found a great number of results... you have activate sort manually with the menu");
		}
	}
	
	$row.click(function (e){
		if(e.ctrlKey){
			$(this).toggleClass('selected');
		}
	}).children("td.ticket").click(function(event){
		if ( event.ctrlKey==false ){
			var n=$(this).children(':first-child');
			if ( n.length > 0 ){
				return selectText( n[0] );			
			}
			else {
				return selectText( $(this)[0] );
			}
		}
	});	

	
	$('#PromiseGate tbody td.ticket').on("mouseenter",function(){
		makeDrillDown($(this));
		return false;
	});
	$('#PromiseGate tbody a.mail').click(function(){
		handlerMail($(this));
		return true;
	}).each(function(){postToAccountChecker($(this));});
	
	$('#PromiseGate tbody .restrict,#PromiseGate tbody .console').dblclick( function(){
		var my_width=Math.max($(window).width()*0.8,300);
		var my_height=Math.max($(window).height()*0.5,80);
		var $popup=$(this).clone().removeClass('restrict,console');
//		$('body').append( $popup );
//		var position;
		$popup.dialog({
			buttons:{Close:function(){$(this).dialog("close");}},
			title:"Zoom",
			modal:true,
			width:	my_width,
			height:	my_height,
			dialogClass:"popup",
			close: function(){$popup.dialog("destroy");}/*,
			resizeStart: function (){
				var $this=$(this).parents('.ui-dialog');
				position.top=$this.position();
			},
			resizeStop: function( event, ui ) {
				var $this=$(this).parents('.ui-dialog');
				$this.css( { top: position.top + window.scrollY, left: position.left + window.scrollX}  );
			}*/
		}).css({display:'block'});
	});
	
	
	return rowcount
}



function handlerMail($this){
	var $row=$this.parents('tr');
	var regx =/^mailto:([^?]*)\?/
	var cc=Array();
	var summary,to,index,$head,id,relative;
	var mail=$this.attr('href').match(regx)[1];
	to=mail?mail:'';

	$row.find('a.mail').each(function(){
		var $me=$(this);
		if (!$me.parent().hasClass('sAssigneeMyself')){
		mail=$me.attr('href').match(regx)[1];
		if (mail && mail!==to){cc.push(mail);}}
	});
	id=$row.attr('title');
	$head=$this.parents('table').find('thead tr').eq(0);
	index=$head.children().index($head.find('th:contains("SUMMARY")'));
	if ( index < 0 && gl_page.type === "TAS" ){
		index=$head.children().index($head.find('th:contains("TASKNAME")'));			
	}
	summary=(index>=0)?$row.find('td').eq(index).text():'';
	
	index=$head.children().index($head.find('th:contains("PARENT ID"),th:contains("CHILD ID")').eq(0));
	if (index>=0){
		relative='/'+getCellText($row.find('td').eq(index));
	}
	else {
		relative='';
	}
	
	$this.attr('href','mailto:'+to+'?subject='+id+relative+': '+escape(summary.substring(0,80))+(cc.length?'&cc='+cc.join(';'):''));
}

function htmlEncode(value){
  return $('<div/>').text(value).html();
}

function handlerPopup( $this, title ){
	makeDetailsPopup( run.url.data +$this.attr('href') + '&thead=y', title + $this.parents('td').children('a:first-child').text()+' '+$this.text() );
	//track users
	$.get('ping.asp?');
}

function makeCommentPopup(key){
	var $popup=$('<div><p>This comment for <span class="commentKey"></span> <span class="commentDate">is new</span>.</p><textarea cols="40" rows="4"></textarea><p class="help">On Internet explorer: this comment will persist until browser shutdown, on other browsers, it will persist maximum '+(run.tempo.storeMaxAge/86400000)+' days.</p></div>');
	//$('body').append( $popup);
	$popup.dialog({
			buttons:{
				Cancel: function(){
					$(this).dialog("close");
				},
				"Save and quit":function(){
					var $this=$(this);
					var key=$this.find('.commentKey').text();
					var content=$.trim( $this.find('textarea').val());
					
					if (content.length > 0){
						var tmp={itsm:{t:(new Date()).getTime(),m:content}}
						saveStorage(key, tmp);	
					}
					else {
						removeStorage(key);
					}
					$this.dialog("close");
				}
			},
			title:"Comment a ticket",
			modal:false,
			dialogClass:"popup",
			open: function (){
				var $this=$(this);
				var tmp=readStorage(run.comments.latestkey);
				$this.find('.commentKey').text(run.comments.latestkey);
				if ((tmp !== null && tmp !== undefined ) && tmp.itsm !== undefined ){
					$this.find('textarea').val(tmp.itsm.m);
					$this.find('.commentDate').text('was saved at '+tmp.itsm.t);
				}
				else {
					$this.find('textarea').val("");
					$this.find('.commentDate').text("is new");
				}
			},//open 
			close: function(){
				var $this=$(this);
				var key=$this.find('.commentKey').text();
				var node=$('#PromiseGate tbody tr').filter("[title='"+key+"']");
				var tmp=readStorage(key );
				if ( tmp === undefined || tmp === null ){
					if (node.hasClass("withComment")){
						node.removeClass("withComment");
					}
				}
				else {
					if (node.hasClass("withComment")== false){
						node.addClass("withComment");
					}
				}
				$popup.dialog("destroy");
			} //close
		});
}

function makeDetailsPopup( url, title ){
	var my_width=Math.max( $(window).width() * 0.8, 300 );
	var my_height	= Math.max( $(window).height() * 0.5, 80 );
	var $popup=$('<div  title="'+title+'"><table></table></div>"');
		
	$popup.dialog({
		buttons:{
			"Maximise":	function(){$popup.dialog( "option", "width",  $(window).width()  ).dialog( "option", "height",  $(window).height());},
			"Minimise":	function(){$popup.dialog( "option", "width",  260  ).dialog( "option", "height",  60 );},
			"Close":	function(){$popup.dialog("close");}
		},
		modal:	false,
		width:	my_width,
		height:	my_height,
		dialogClass:	"bigPopup",
		close:	function(){$popup.dialog("destroy");},
		open:	function(){
			$popup.append('<p class="loading">loading data...</p>');
			$.ajax( url, {
				success: function (data){
					var $table=$popup.find('table');
					$table.append(data);
					if( $table.find('tr').length ){
						remainingTime($table);
						$table.tablesorter( {selectorHeaders:'thead tr th',cancelSelection:true,sortMultiSortKey:"ctrlKey",sortResetKey:'shiftKey'} );
						$table.find('a.pop').click(function(){handlerPopup($(this),title+' > ');return false;});
						$table.find('a.mail').click(function(){handlerMail($(this));return true;}).each(function(){
	postToAccountChecker($(this));});
						$table.find('td.ticket').on('mouseenter',function(){makeDrillDown($(this));return false;})
					}
				},
				error: function () {
					alert("error !");$popup.dialog("close");
				},
				complete:function(){
					$popup.find('p.loading').remove();
				}
			});
		} 
	});
}

function makeDrillDown($this){
	$this.unbind('mouseenter');
	var ticket=$this.find('a').eq(0).text();
	if (!ticket){return false;}
	var type=ticket.match(/\b(INC|CRQ|REQ|WO|TAS|PBI|WKO)[0-9]{4,13}\b/i)[1];
	var content='';
	var locallink='&amp;g='+gl_page.group+'&amp;tz='+gl_page.timezone+'&amp;e='+gl_page.env+'&amp;s='+gl_page.sens+'&amp;query='+ticket;
	if ( gl_page.env==='L'){
		return false;
	}else if ( type==='TAS'){
		content='(<a class="pop" href="?t=TAS-TWI'+locallink+'">Workinfo</a>, <a class="pop" href="?t=TAS-LOG'+locallink+'">Audit</a>, <a class="pop" href="?t=TAS-MORE'+locallink+'">More</a>, <a class="pop" href="?t=TAS-SCHED'+locallink+'">T.Schedule</a>)';
	}else if (type==='CRQ'){
		content='(<a class="pop" href="?t=CRQ'+locallink+'">CRQ</a>, <a class="pop" href="?t=CRQ-AP'+locallink+'">Approvals</a>,  <a class="pop" href="?t=CRQ-LOG'+locallink+'">Audit</a>, <a class="pop" href="?t=CRQ-COOK'+locallink+'">Cook-me!</a>, <a class="pop" href="?t=CI'+locallink+'">CI</a>, <a target="_blank" title="Graph" href="graph.asp?'+locallink+'">Graph</a>, <a class="pop" href="?t=TAS'+locallink+'">Tasks</a>, <a class="pop" href="?t=TAS-SCHED'+locallink+'">T.Schedule</a>, <a class="pop" href="?t=CRQ-CWL'+locallink+'">W.Details</a>, <a class="pop" href="?t=CRQ-MORE'+locallink+'">More</a>)';
	}else if (type==='INC'){
		content='(<a class="pop" href="?t=INC-WLG'+locallink+'">Workinfo</a>, <a target="_blank" href="graph.asp?'+locallink+'">Graph</a>, <a class="pop" href="?t=INC-LOG'+locallink+'">Audit</a>, <a class="pop" title="Previous assignments" href="?t=INC-HDA'+locallink+'">Owners</a>, <a class="pop" href="?t=CI'+locallink+'">CI</a>, <a class="pop" href="?t=INC-MORE'+locallink+'">More</a>)';
	}else if (type==='REQ'){
		content='(<a target="_blank" href="https://SERVER6/arsys/forms/itsm-ars/SRS%3ARequestDetails/SRS+User+View/?mode=display&amp;F1000000829='+ticket+'&amp;F302832400=LaunchedViaURL">Show</a>, <a class="pop" href="?t=REQ-AP'+locallink+'">Approvals</a>, <a class="pop" href="?t=REQ-LOG'+locallink+'">Audit</a>, <a class="pop" href="?t=REQ-RWI'+locallink+'">W. Infos</a>, <a class="pop" href="?t=REQ-ANSWER'+locallink+'">Answers</a>';
		var tmp =$this.siblings().filter(':contains("SRD00")').eq(0).text();
		if (tmp){
			content+=', <a target="_blank" href="http://SERVER7/pages/service-consult.aspx?ServiceID='+tmp+'">Ask it</a>)'
		}
		else {
			content+=')';
		}
	}else if (type==='WO'){
		content='(<a class="pop" href="?t=TAS'+locallink+'">Tasks</a>)';
	}else if (type==='PBI'){
		content='(<a class="pop" href="?t=PBI'+locallink+'">PBI</a>, <a class="pop" href="?t=TAS'+locallink+'">Tasks</a>, <a href="graph.asp?'+locallink+'" target="_blank">Graph</a>, <a class="pop" href="?t=CI'+locallink+'">CI</a>)';
	}
	$this.find("span.quiet").empty().append(content);
	$this.find('a.pop').click( function(){handlerPopup($(this),'');return false;});
}

function makeExportPopup(){
	var $popup=$('<div><p>Please select one action below.</p><p>If you bolded some rows (Ctrl+click), only those will be exported.</p><p id="exportAction">Page is loading components...</p></div>"');
	$popup.dialog({
			buttons:{Cancel:function(){$(this).dialog("close");}},
			modal:false,
			dialogClass:"popup",
			title:"Export to CSV",
			open:	function(){$('#exportPopUp').addClass("ui-state-disabled");},
			close:	function(){$('#exportPopUp').removeClass("ui-state-disabled");$popup.dialog('destroy');}
		});
	$.ajaxSetup({cache: true});
	$.when(
		jQuery.getScript(run.url.downloadify_js), 
		jQuery.getScript(run.url.flashLib_js),
		jQuery.getScript(run.url.csv_js))
	 .done( function(){ 
		makeExportMenu($popup);
		})
	.fail( function(){
		alert('Can not load component');$popup.dialog("close");
		});
}


function makeExportMenu($popup){
	$('#exportAction').downloadify({
		filename: "export_"+gl_page.env+"_"+gl_page.group+"_"+gl_page.selector+".csv",
		data: function(){ 
			return readCsvData();
		},
		onComplete: function(){ 
			$popup.dialog('close');
		},
		onError: function(){ 
		  alert('Nothing saved - some error occured!'); 
		},
		transparent: false,
		swf: run.downloadify.swf,
		downloadImage: run.downloadify.downloadImage,
		width: "100px",
		height: "25px",
		transparent: false,
		append: false
	});
}

function openSearchProvider(){
	var $popup=$('<p>Please click below to install a new browser search plugin. You have 2 kinds for the same opensearch plugin,  with different option on point of view setting (role submitter or role assignee). It will impact you only if you search using magic words or when you continue your browsing.</p>');
	$popup.dialog( {
		title:"Seach plugin",
		buttons:{
			"Changes Submitted":function(){installSearchEngine(run.rooturl+run.url.opensearch.crq);},
			"Changes Assigned":function(){installSearchEngine(run.rooturl+run.url.opensearch.crqa);},
			"Incidents Submitted": function(){installSearchEngine(run.rooturl+run.url.opensearch.inc);},
			"Incidents Assigned": function(){installSearchEngine(run.rooturl+run.url.opensearch.inca);},
			"Problems Submitted": function(){installSearchEngine(run.rooturl+run.url.opensearch.pbi);},
			"Problems Assigned": function(){installSearchEngine(run.rooturl+run.url.opensearch.pbia);},
			"Request Submitted": function(){installSearchEngine(run.rooturl+run.url.opensearch.req);},
			"Request Assigned": function(){installSearchEngine(run.rooturl+run.url.opensearch.reqa);},			
			Peoples: function(){installSearchEngine(run.rooturl+run.url.opensearch.people)},
			Cancel:function(){$(this).dialog("close");}
		},
		close: function (){$popup.dialog("destroy");},
		modal: true,
		dialogClass:"popup"
	});
}


function parseTimeString( string ){
	var parts;
	parts=string.match(run.timePattern);
	var d= new Date();
	if ( null === parts ){
		return d;
	}
	d.setUTCFullYear(parts[1]);
	d.setUTCMonth(parts[2]-1,parts[3]);//day of the month
	d.setUTCHours(parts[4]?parts[4]:0);
	d.setUTCMinutes(parts[5]?parts[5]:0);
	d.setUTCSeconds(parts[6]?parts[6]:0);
	return d;
}

function postToAccountChecker($this){
	//$this.after(' <form target="_blank" method="post" action="http://SERVER8/?"><input name="tbAccountName" type="hidden" value="'+$this.attr('title')+'"><input type="submit" value="mail?"/></form>');
}

function readCsvData(){
	var tmp=$('#PromiseGate tbody tr.selected').length;
	var options=run.csvDefault;
	if ( tmp > 0 ){
		options.dataRowSelector='tbody tr.selected:visible';
		return $('#PromiseGate').table2CSV(options)
	}
	else {
		return $('#PromiseGate').table2CSV(options);
	}
}

function refresh_data(){
	if ( run.notParkinson ){
		window.setTimeout( function(){
			run.notParkinson=false;
			var newData;
			var url=run.url.data + '?action=D&e='+gl_page.env+'&g='+gl_page.group+'&t='+gl_page.selector+'&s='+gl_page.sens+'&query='+gl_page.query+'&tz='+gl_page.timezone;
			var $table =$('#PromiseGate');
			$table.addClass('reloading');
			$.when(
				$.ajax( url ,{
					dataType:"text",
					success: function(data){ newData=data;},
					error: function(){alert("failed to fetch data ");}
				})//ajax 1
			).done( function(){
				var dump;
				$table.find( 'tbody').remove();
				$table.append( newData );
				$table.trigger('update.columnFilter');
				$table.trigger('updateRows.tablesorter');
				var tmp=new Date();
				run.timeJs=tmp.getTime();
				
				initTable();
				if ( run.comments.binded ){
					initComments();
				}
			}).fail( function(){
				alert('Can not refresh the datas...');
			})
			.always( function(){
				$table.removeClass('reloading');
				run.notParkinson=true;
			});
		}, 1);
		//track users
		$.get('ping.asp?');
		refresh_counts();
	}//parkinson
}

function refresh_counts(){
	var url=run.url.data + '?action=A&e=N&g='+gl_page.group
	return $.ajax( url ,{
		dataType:"json",
		success: function(data){
			//console.log (data)
			if ( data.ap > 0 ){
				$('.approbationCount').text( '('+data.ap+')' ).parent().parent().show();
			}
			else {
				$('.approbationCount').empty().parent().parent().hide();
			}
			if ( data.task > 0 ){
				$('.taskCount').text('('+data.task+')');
			}
			else {
				$('.taskCount').empty();
			}
		},
		error: function(){
			$('.approbationCount,.taskCount').text('(?)');	
			$('.approbationCount').parent().parent().show();
		}
	})//ajax 1

}

function remainingTime($table){
	var n=$table.find('thead tr:first-child th:contains(DATE),thead tr:first-child th:contains(TIME)' );
	var today=new Date();
	today=today.getTime()+run.timeDelta;
	
	var ticketTs;
	var $tmp=$table.find('tbody tr');
	$(n).each( function(){
		var tmp=$(this).text();
		tmp=(tmp!='SUBMIT DATE' && tmp!='ACTIVATE TIME')&&(tmp!='LAST MODIFIED DATE' && tmp!='CREATE DATE');
		var colindex=n.parent().children().index($(this))+1;
		var content;
		$tmp.children("td:nth-child("+colindex+")").each(function(){
			dateComparator($(this),today,tmp);	
		});
	});
}

function selectText(node) {
    var doc=document, range, selection; 
	if (doc.body.createTextRange) { //ms
		range=doc.body.createTextRange();
		range.moveToElementText(node);
		range.select();
	} else if (window.getSelection) { //all others
		selection=window.getSelection(); 
		selection.removeAllRanges();
		range=doc.createRange();
		range.selectNodeContents(node);
		selection.addRange(range);
	}
}

function saveJavascriptFilters(  $table, activeFilters  ){
	var tmp,url,param=run.QueryString;
	
	try {
		tmp ='';
		if (activeFilters){
			run.readJavascriptArg.filters=activeFilters;
			json=JSON.stringify(run.readJavascriptArg);
			param.js=Base64.encode(json);
		}
		url=location.origin+location.pathname+"?"+jQuery.param(param); 
		$('#filterLink').attr('href',url);
	}
	catch( e ){
		console.log(" can not save: "+ e.message);
	}
}

function ping_server( ticket ){
	var tmp;
	if ( gl_page.env='L' ){
		tmp='ARS'
	} 
	else {
		tmp= 'PROMISE'
	}
	$.get( '/display_PROMISE_N3_get.asp?o='+tmp+'&a=CONSULT&d='+ticket+'&e='+gl_page.group);
}

//-----------------------------------------------------------------------
setTimeout( function(){ cleanGarbage( isOldComment ); }, run.tempo.garbage);
//track users
$.get('ping.asp?');

$(document).ready(function(){
	var rowcount=initTable();
	$('#rowFilteredCount').text(rowcount);
	$('#PromiseGate').columnFilter({forceInputRegex:/DATE$|ID$|TIME$/i,importFilters:run.readJavascriptArg.filters,exportFilters:saveJavascriptFilters});
	run.filters=true;
	scheduledJobs();
	//checkLibVersion();

});

