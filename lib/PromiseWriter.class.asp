<%
	' in this file, only function related to PromiseGateTable generation.

function writer_protectHtml(str,needProtect)
	if needProtect then
		needProtect=false
		writer_protectHtml=Server.HtmlEncode(str&"")
	else
		writer_protectHtml=str&""
	end if
end function

function writer_FormatDateX(strDate)
	writer_FormatDateX= DatePart("yyyy",strDate)&"-"&DatePart("m", strDate)&"-"&DatePart("d",strDate)&" "&DatePart("h",strDate)&":"&DatePart("n",strDate) &":"& DatePart("s",strDate)
end function 


Class PromiseWriter
	private rs
	private email_field_id
	private options
	private internalLink
	private caption
	private subject_email
	private tdClass
	private titleLogin
	private isITSM
	private lastCode
	private hasVisibilty
	
	sub init(rs_,caption_,email_field_id_)
		set rs=rs_
		caption=caption_
		email_field_id=email_field_id_
	end sub

	private function writer_encodeMail(str)
		writer_encodeMail=replace(replace(Server.URLEncode(str),"+","%20"),"#","X")	
	end function


	private function convertToClass(status )
		dim tmp
		if left(status,3)="UNK" then
			convertToClass=""
		else 
			tmp=replace(status," FOR ","_")
			tmp=replace(tmp," IN ","_")
			convertToClass="s"&replace(tmp," ","_")
		end if
	end function 


	private function getStatusColor(type_ticket,sqlStatus)
		dim posL,posR,reason,status,tmp	
		tmp=UCase(sqlStatus)

		select case type_ticket 
			case "CRQ"		
				if "PEN"=left(tmp,3) then
					posL=inStr(tmp,"/")
				else 
					posL=inStr(tmp,"(")
				end if

				if posL>0 then 
					status=left(tmp,posL-1)
				else
					status=tmp
				end if
				status=trim(status)
				select case status 
					case "IMPLEMENTATION IN PROGRESS"
						if posL > 0 then 
							getStatusColor=ST_IMPLEMENT_REA 
						else
							getStatusColor=convertToClass(status)
						end if
					case else
						getStatusColor=convertToClass(status)
				end select 
			case "TAS"
				posL=inStr(tmp,"(")
				if posL>0 then 
					status=left(tmp,posL-1)
				else
					status=tmp
				end if
				
				status=trim(status)
				
				select case status 
					case "PENDING"
						if posL > 0 then 
							reason=trim(mid(tmp,posL+1,inStrRev(tmp,")")-posL-1))
						else
							reason =""
						end if
						if reason="ASSIGNMENT" then
							getStatusColor=ST_PENDING_ASSIG
						else
							getStatusColor=convertToClass(status)
						end if 
					case "CLOSED"
						if posL > 0 then 
							reason=trim(mid(tmp,posL+1,inStrRev(tmp,")")-posL-1))
						else
							reason =""
						end if
						if reason="" then
							getStatusColor=convertToClass(status)
						elseif reason="SUCCESS"  then
							getStatusColor=ST_CLOSED_SUCCES
						elseif reason="CANCELLED" then
							getStatusColor=ST_CLOSED_CANCEL
						else 
							getStatusColor=ST_CLOSED_FAILED
						end if 
					case else
						getStatusColor=convertToClass(status)
				end select
			'not a change/task thing
			case else
				getStatusColor=convertToClass(tmp)
		end select
	end function


	private sub makeUserMail(byref contenu,options,fieldname,needProtect)
		dim email_dest
		if isITSM then
			email_dest=rs("X_"&fieldname&"_EMAIL")&""
			if len(contenu)>0 then
				'if len(email_dest)>0 then
					contenu="<a class=""mail"" href=""mailto:"&Server.HtmlEncode(email_dest)&"?subject="&subject_email&""" "&titleLogin&" >"&writer_protectHtml(contenu,needProtect)&"</a>"
				'else
				'	contenu=writer_protectHtml(contenu,needProtect)
				'end if
			else
				tdClass=C_UNASSIGNED
				contenu="<a class=""mail"" href=""mailto:?subject="&subject_email&""" ></a>"
				needProtect=false
			end if
		end if
		titleLogin=empty
	end sub

	function writer_recordset_special(rs,name,defaultValue)
		on error resume next
		writer_recordset_special=rs(name)
		if Err.number<>0 then
			writer_recordset_special=defaultValue
		end if
	end function

	private function makeTicketLinks(contenu,needProtect,options,fieldname)
		dim tmp,prefix,remedylink
		
		if len(contenu)<1 then 
			exit function
		end if
		prefix=left(contenu,3)
		if isITSM then
			'code=writer_recordset_special(rs,fieldname,"")
			remedylink=options.GetPromiseWebUrl(lastCode,prefix)
		else
			remedylink=options.GetArsWebUrl(contenu,prefix)
		end if
		tmp=writer_protectHtml(contenu,needProtect)
		if left(remedylink,4)<>"http" then
			makeTicketLinks="<a class=""self"" href=""?t="&remedylink&internalLink&"&amp;query="&tmp&""" target=""_blank"">"&tmp&"</a><br><span class=""noCsv quiet"">(...)</span>"
		else
			makeTicketLinks="<a href="""&remedylink&""" target=""_blank"" >"&tmp&"</a><br><span class=""noCsv quiet"">(...)</span>"
		end if
	end function

	private function makeProfileLinks(contenu,needProtect,options)
		dim prefix
		prefix=left(lastCode,3)
		if isITSM then
			makeProfileLinks="<a href="""&options.GetPromiseWebUrl(lastCode,prefix)&""" target=""_blank"">"&writer_protectHtml(contenu,needProtect)&"</a>"
		else
			makeProfileLinks=contenu
		end if
	end function	
	
	
	sub doHeaders()
		dim Icount 
		dim fieldname
		' a dupliquer en fin de tableau
		For Icount=0 to rs.fields.count -1
			fieldname =rs.fields(Icount).name
			if left( fieldname,2) <> "X_" then
				select case fieldname
				case "CI","DESCRIPTION","SUMMARY","CHG_CI","CHANGE_FILES","TASK_FILES","TASK_WORKINFO_FILES","ROLES"
					response.write "<th class=""filterWrite"">"&replace( fieldname ,"_"," ")&" "&"</th>"
				case else
					response.write "<th>"&replace( fieldname ,"_"," ")&"</th>"
				end select
			end if
		next
	end sub


	sub doTableRow( options )
		dim contenu,dofill,Icount,fieldname,tmp,needProtect,firstCol
		dim tdTitle, hasRequestor
		dim ticket, count
		isITSM=(DBENV_TOOL_ITSM=options.dbEnv.toolName)
		firstCol=true
		hasRequestor=false
		subject_email= writer_encodeMail("["&rs(email_field_id)&"] ")
		count=rs.fields.count-1
		For Icount=0 to count
			needProtect=true
			fieldname=rs.fields(Icount).name
			contenu= trim(rs.fields(Icount)&"" )
			'IF the column is visible ....
			if left(fieldname,2)<>"X_" then 
				dofill=True
				if firstCol then
					response.write "<tr title="""&rs(email_field_id)
					tmp=writer_recordset_special(rs,"X_VISIBILITY",empty)
					if len(tmp)>0 then 
						response.write """ class="""&tmp&""">"
					else 
						response.write """>"
					end if
					firstCol=false
				end if
				Select case fieldname								
					case "INCIDENT_ID","TASK_ID","CHANGE_ID","PROBLEM_ID","SERVICE_REQUEST_ID","WORK_ORDER_ID"
						contenu=makeTicketLinks(contenu,needProtect, options,fieldname)
						lastCode=""
						tdClass="ticket"
					case "STATUS", "TASK_STATUS"
						if len(contenu)>0 then
							tdClass=getStatusColor(options.type_ticket,contenu) 
						end if
					case "REGION"
					   if len(contenu)>0 then
							if instr(contenu,"EMEA") then
								tdClass=C_EMEA 
							   contenu="EMEA"
							 elseif instr(contenu,"AMER") then
								tdClass=C_AMER
								contenu="AMER"
							 elseif instr(contenu,"APAC") then
								tdClass=C_APAC	
								contenu="APAC"
							 end if
						end if
					case "LOGIN","SUPPORT_GROUP"
						contenu=makeProfileLinks(contenu,needProtect,options)
						lastCode=""
						tdClass="ticket"
					case "CHILD_ID","PARENT_ID"
						tmp= rs("X_"&replace( fieldname, "_ID","_STATUS"))&""
						tdTitle= "Status: "&Server.HtmlEncode(tmp)	
						tdClass= getStatusColor(left( contenu,3),tmp)& " ticket"
						contenu=makeTicketLinks (contenu,needProtect, options,fieldname)						
					case "ASSIGNEE","COORDINATOR","MANAGER", "PEOPLE","RECIPIENT","SUBMITTER","REQUESTOR"
						makeUserMail contenu,options,fieldname,needProtect
					case "CI","DESCRIPTION","RELATIONSHIPS","APPROVERS"
						if len(contenu)>0 then contenu="<div class=""restrict"">"&writer_protectHtml(contenu,needProtect)& "</div>"
					case "DETAILS","LOG","RESOLUTION","COMMENTS"
						if len(contenu)>0 then contenu="<pre class=""console"">"&writer_protectHtml(contenu,needProtect)& "</pre>"
					case "CHANGE_FILES"
						contenu="<dl><dt class=""noCsv quiet"">Changes files:</dt><dd>"&writer_protectHtml( contenu,needProtect)&"</dd><dt class=""noCsv quiet""> Task files:</dt><dd>"&writer_protectHtml(rs("X_TASK_FILES"),needProtect)&"<dt class=""noCsv quiet""> TWI files:</dt><dd>"&writer_protectHtml( rs("X_TASK_WORKINFO_FILES"),needProtect)&"</dd><dl>"
						needProtect=false
'					case "APPROVERS"
'						contenu="<a href=""?t=PEOPLE"&internalLink&"&amp;ticket="&rs("X_APPROVERS")&""">"&contenu&"</a>"
'						needProtect=false
					case "TASK_COUNT"
						contenu=contenu&" (in "&rs("X_SEQ_COUNT")&" seq.)"
						needProtect=false
					case "SEQ_ACTIVE" 
						if not IsNumeric(contenu) then 
							contenu="none"
						else
							contenu=contenu&" ("&rs("X_TAS_ACTIVE")&" tasks actives)"
							needProtect=false
						end if

					case "APPROVE_REQ"
				'		if rs("APPRO_STATUS")="Waiting Approval" then 
							contenu="<a class=""init noCsv"" target=""_blank"" href=""http://SERVER3/PAGES/APPROVAL-CONSULT.ASPX?SOURCE=LIST&amp;SERVICEID="&rs("X_SERVICE_REQUEST_CODE")&"&amp;REQUESTID="&rs("SERVICE_REQUEST_ID")&"""><button>approve with init</button></a>"
							needProtect=false
				'		end if
					'legacy only
					case "INFOS"
						if len(contenu)>0 then contenu=replace(contenu,chr(9),"<br/>")
					case "WLOG_DESCRIPTION"
						contenu=rs("X_WLOG_DATE")&" by "&rs("X_WLOG_FULL_NAME")&iif(rs("X_WLOG_FULL_NAME")="OVO",""," ("&rs("X_WLOG_ORGANIZATION")&")")
				end select
			else ' THOSE ARE HIDEN FIELD
				dofill=False
				tmp=right(fieldname,5)
				if  tmp="LOGIN" then 
					titleLogin= " title="""&contenu&""" " 
					if contenu=options.current_user then tdClass=C_MYSELF
				elseif tmp="_CODE" then
						lastCode=contenu
				end if 
			end if ' if begin by X_

			if dofill then
				response.write "<td"&iif(len(tdClass)>0," class="""&tdClass&""" ","")&iif(len(tdTitle)>0," title="""&tdTitle&""" ", "")&">"
				response.write writer_protectHtml(contenu,needProtect)
				response.write "</td>"
				'maintenant que c'est affiché on peut effacer la classe css courante
				tdClass=""
				tdTitle=""
			end if
		Next
		response.write "</tr>"
		response.write vbcrlf
	end sub

	sub doMoveNext( rs )
		on error resume next
		rs.MoveNext
		if err.number<>0 then
			response.write "<tr class=""sorry""><td colspan="""&rs.fields.count&""">One record couldn't be retrieved properly, giving up with incomplete results.</td></tr>"
		end if 
	end sub
	
	sub doTableContent( options )
		dim no_record,tmp
		
		no_record=rs.EOF
		internalLink="&amp;g="&options.group&"&amp;s="&options.sens_rech&"&amp;tz="&options.timezone&"&amp;e="&options.env 
		if no_record=False then
	'		rs.movefirst
			'lignes à flusher... we want to flush after the first 50 rows, so starting 150 instead of 0... so browser can start rendering then we preserve perf and flush every 200
			tmp=240
			Do until rs.EOF
				tmp=tmp + 1 
				'bigTableRowWriterDebug rs, dbEnv, options, email_field_id, email_field_description
				doTableRow options
				'only for the larger pages...
				if tmp > 300 then
					Response.Flush
					tmp=0
				end if
				doMoveNext rs 
			Loop 
		else
			response.write "<tr class=""sorry""><td colspan="""&rs.fields.count&"""> No records were found using your criterias. </td></tr>"
		end if
	end sub 'bigTableContentWriter

end Class

%>