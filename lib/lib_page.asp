<%
'On this lib, function that allow to build the full page (so called by index.asp)
'There is no reason to keep here some function that are requiered even if we perform the ajax refresh
'------------------------------------------------------------------------------------------------
sub page_toolBarWriter ( options )
%>
<table id="navig" class="<%=options.env%>" >
<tr>
<td><%
select case options.sens_rech
	case SENS_ASSIGNED
		response.write "(Assignee)"
	case SENS_MANAGED
		response.write "(Manager)"
	case SENS_SUBMITED
		response.write "(Submitter)"
	case SENS_COORDINATE
		response.write "(Coordinator)"
end select
%></td>
<td>All: <span id="rowTotalCount">?</span>, Showing: <span id="rowFilteredCount">?</span>  |  <a title="copy this url to retrieve page with filters (beta function)" href="#" id="filterLink">Filters</a></td>
<td><a id="refresh" href="<%="?t="&options.type_ticket&"&amp;g="&options.group&"&amp;s="&options.sens_rech&"&amp;e="&options.env&"&amp;tz="&options.timezone& "&amp;query=" & writer_protectHtml(options.ticket_user,true) %>"><img src="../../img/refresh_24_2.png"  title="Refresh page" alt="Refresh" /></a></td>
<td><a href="#top">Top</a> | <a href="#down">Down</a></td>
<td><a href="#search" id="showSearch">Search</a></td>
<td> 
<ul id="mymenu"><li>Menu... <span class="taskCount"></span><ul id="mysubmenu"></ul></li></ul>
</td>
<td>Generated <span id="generationTime"><% 
	'let's hope server and database are on the same timezone with same daylight saving
	response.write writer_FormatDateX(now ) 
%></span></td>
<td><button id="clearFilters" disabled="disabled">Reset Filters</button></td>
<td><select name="tz" id="timezone">
	<option value="<%=options.timezone%>" selected="selected">timezone: <%=options.timezone%></option>
	<optgroup label="available timezone">
	<option value="EST">[-05:00] EST(Reston)</option>
	<option value="CET">[+01:00] CET (Marcoussis)</option>
	<option value="GMT">[+00:00] GMT</option>
	<option value="Asia/Calcutta">[+05:30] Asia/Calcutta</option>
	<option value="Singapore">[+08:00] Singapore</option>
	</optgroup>
</select></td>
</tr>
</table>
<script type="text/javascript">navig.menu();</script>
<%
end sub 'toolBarWriter
'------------------------------------------------------------------------------------------------
'------------------------------------------------------------------------------------------------
'------------------------------------------------------------------------------------------------
sub page_embededJavascriptGlobalsWriter( options  )
%>
<script type="text/javascript">
var gl_page={
env:'<% = options.env %>',
type:'<%= options.type_ticket%>',
selector:'<%=options.query_selector%>',
group:'<%=options.group%>',
sens:'<%=options.sens_rech%>',
query:'<%=options.ticket_user%>',
max_row:<%=C_MAX_ROW%>,
timezone:'<%=options.timezone%>',
security:'<%=SECURITY_USER%>',
current_user:'<%=options.current_user%>',
action:'<%=options.action%>',
lesser_mode:800};
</script>
<%
end sub 'embededJavascriptGlobalsWriter

sub page_search(  )
%>
<script type="text/javascript">navig.search();</script>
<%
end sub  'form

function page_prepare( options, byref field_id, byref caption)
	dim factory
	set factory = new QueryFactory
	set page_prepare = factory.init(options,field_id,caption )
	if factory.isInvalidSelector then
		options.setDefaultType
	end if
	set factory=nothing 
end function 
	
sub page_result (sql, options, auth_user, byval field_id, byval caption)
	dim rs, writer
	 ' var set in sub and used in another sub
	set rs = sql.execute()
	set writer = new PromiseWriter 
	writer.init rs, empty, field_id
	
%>
<table id="PromiseGate" class="<%=options.env%>" >
<caption>Try to use ctrl+clic on datarow or in filters. <%=caption%></caption>
<thead>
<tr>
<%
	writer.doHeaders    
%>
</tr>
</thead>
<tbody>
<% 
	writer.doTableContent options
%>
</tbody>
<tfoot>
<tr>
<%
	writer.doHeaders 
%>
</tr>
</tfoot>
</table>
<%
	rs.Close
	set writer=nothing
	Set rs = Nothing
	set sql = nothing

end sub 'page_result

'------------------------------------------------------------------------------------------------

function page_title ( options )
	if options.action = P_WELCOME then
		page_title = "WELCOME !"
		exit function
	end if

	select case options.query_selector
		case "CRQ"
			page_title = "Changes "
		case "INC"
			page_title = "Incidents "
		case "TAS"
			page_title = "Tasks "
		case "PBI"
			page_title = "Problems "
		case "PEOPLE"
			page_title = "People "
			exit function
		case "WKO", "WO"
			page_title = "Work orders"
		case "REQ"
			page_title = "Service Requests"
		case "AP"
			page_title = "Approval of tickets"
		case "TAS-TWI"
			page_title= "Tasks Work Infos "
			exit function
		case "CRQ-CWL"
			page_title = "Change Worklog "
			exit function
		case "INC-WLG"
			page_title = "Incident Worklog "
		case "CRQ-TEMPLATE"
			page_title=" Change templates "
			exit function
		case "CRQ-COOK"
			page_title=" Compliancy of changes "
		case else
			page_title = "Misc "
			exit function
	end select 
	
	if options.isFeature then
		page_title = page_title & " (featured: " & options.ticket_user &")" 
	elseif isArray( options.ticket_sql2 ) then
		page_title = page_title & " (filtered on CI)" 
	elseif isArray( options.ticket_sql1 ) then
		page_title = page_title & " (filtered on tickets ID)"
	else
		select case options.sens_rech
			case SENS_ASSIGNED
				page_title = page_title & " assigned"
			case SENS_MANAGED
				page_title = page_title & " managed"
			case SENS_SUBMITED
				page_title = page_title & " submited"
		end select
		if options.isMyself then 
			page_title = page_title & " by me"
		elseif options.isAutoTeam then
			page_title = page_title & " by my support group "
		else 
			page_title = page_title & " by support group " & options.group
		end if
	end if
end function
%>