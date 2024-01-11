<!--#INCLUDE FILE="lib/lib_common.asp"-->
<%
' This front script should only be called by ajax requests.
security_identify_dba false
Const DEBUG_SQL=false

'------------------------------------------------
function count_approbation(dbEnv,query,current_user)
	dim  rs

	query.setSQL  "SELECT count(*) from "&dbEnv.schema1&".CHG_CHANGEAPDETAILSIGNATURE ap where ap.APPLICATION='CHG:Infrastructure Change'  and ap.APPROVAL_STATUS2 in ('0','3','4') and ap.CHANGE_REQUEST_STATUS not in ('9','10','11','12') and ap.APAPPROVERS like "&query.protect("USER","%"&current_user&"%") 
	set rs=query.execute()

    count_approbation=Clng(rs(0))
	set rs=nothing
end function 


function count_tasks(dbEnv,query,current_user)
	dim  rs
	
	query.setSQL  "SELECT count(*) from "&dbEnv.schema1&".TMS_Task TSK where tsk.ASSIGNED_TO like "&query.protect("USER","%"&current_user&"%")&" AND TSK.status in (2000,3000,4000,5000) "
	set rs=query.execute()

    count_tasks=Clng(rs(0))
	rs.close
	set rs=nothing
end function 


'------------------------------------------------
sub main()
	dim options,rs,email_field_id,factory,query,mytask,myappro,writer,caption
	set options=new UserOptions
	'because i'm not trusting Microsoft magic for vb class. 
	options.init SECURITY_USER

	if options.action=P_APPRO then
		set query=new QuerySQL
		query.init options.dbEnv.getConnection() 
		mytask=count_tasks(options.dbEnv,query,options.current_user)
		query.haveNewCommand
		myappro=count_approbation(options.dbEnv,  query,  options.current_user)
		response.ContentType="application/json"
		response.write "{""ap"":"& myappro &",""task"":"& mytask&"}"
	else 
		set factory=new QueryFactory
		set query=factory.init(options,email_field_id,caption)
		if "y"=Request.queryString("Lina") then
			Response.AddHeader "content-disposition","attachment; filename=query.sql "
			response.ContentType="application/x-sql"
			response.write query.sql	
		else 
			set rs=query.execute()
			set writer=new PromiseWriter 
			writer.init rs, empty, email_field_id
			if Request.querystring("thead")="y" then
%>
<thead>
<tr><%
				writer.doHeaders 
%>
</tr></thead>
<%
			end if
%>
<tbody>
<%
			writer.doTableContent options
%>
</tbody>
<%
			set writer=nothing
			rs.close
			set rs=nothing
		end if
	end if
	set factory=nothing
	set query=nothing	
	set options=nothing
	response.end
end sub 

main

%>