<% option explicit %><!--#INCLUDE FILE="QuerySQL.class.asp"--><!--#INCLUDE FILE="DatabaseEnv.class.asp"--><!--#INCLUDE FILE="lib_security.asp"-->
<!--#INCLUDE FILE="JsonTool.class.asp"--><%



class GraphLink
	public src
	public tgt
	public dep
	
	sub init(byval src_,byval tgt_,byVal typeLink_)
		src=src_
		tgt=tgt_
		dep=typeLink_
	end sub
	
	function toJson
		toJson="{source:"""&JSON.escape(src)&""",target:"""&JSON.escape(tgt)&""",type:"""&JSON.escape(dep)&"""}"
	end function
end class


class GraphNode
	public name
	public title
	public isTicket

	sub init(byVal n,byVal t,byval i)
		name=n
		title=t
		isTicket=i
	end sub
	
	function toJson
		toJson="{name:"""&JSON.escape(name)&""",title:"""&JSON.escape(title)&""",_isTicket:"""&JSON.escape(isTicket)&"""}"
	end function
end class

	
class GraphLinkFinder 

	private neighbor
	private visited
	private dbEnv
	private connection 
	private nodesName
	
	private sub Class_initialize 
		set visited=Server.CreateObject("Scripting.Dictionary")
		set neighbor=Server.CreateObject("Scripting.Dictionary")
		set nodesName=Server.CreateObject("Scripting.Dictionary")
		set dbEnv=new DatabaseEnv	
	end sub
	
	private sub Class_terminate
		reset
		set visited=nothing
		set neighbor=nothing
		set nodesName=nothing
		set dbEnv=nothing
	end sub
	
	sub addEntryPoint( entry_point)
		visited.add entry_point,0
	end sub
	
	sub reset
		visited.removeAll
		neighbor.removeAll
		nodesName.removeAll
	end sub
	
	function findThemAll( env )		
		dbEnv.init(env)
		dbEnv.open 
		dbEnv.securityQuery SECURITY_USER
		connection = dbEnv.getConnection
		launchModule
	end function
	
	function findAllCRQ( )
		dim sql
		sql="select request_id02 source, CASE WHEN request_type01=6000 then request_description01 else request_id01 END target, CASE when request_type01=6000 then null else request_description01 END name, CASE when request_type01=6000 then 0 else 1 END isticket from "&dbEnv.schema1&".chg_associations where request_id02=?"
		findAllCRQ=findAllGeneric("CRQ",sql)
	end function 

	
	function findAllINC( )
		dim sql
		sql="select request_id02 source, CASE WHEN request_type01=6000 then request_description01 else request_id01 END target, CASE when request_type01=6000 then null else request_description01 END name, CASE when request_type01=6000 then 0 else 1 END isticket from "&dbEnv.schema1&".hpd_associations where request_id02=?"
		findAllINC=findAllGeneric("INC",sql)
	end function 	
	
	function findAllPBI( )
		dim sql
		sql="SELECT problem_investigation_id source,CASE WHEN request_type03 = 6000 THEN request_description01 ELSE request_id01 END target, CASE WHEN request_type03 = 6000 THEN NULL ELSE request_description01 END name, CASE WHEN request_type03 = 6000 THEN 0 ELSE 1 END isticket FROM "&dbEnv.schema1&".PBM_PBM_SEARCH_ASSOCIATIONS WHERE problem_investigation_id = ?"
		findAllPBI=findAllGeneric("PBI",sql)
	end function
	
	
	private function findAllGeneric(prefix,sql) 
		dim rs,command,param,tmp,affectedRow, loopControl, have_new
		Set command = Server.CreateObject("ADODB.Command")
		command.ActiveConnection = connection
		command.CommandTimeout=120
		command.CommandText=sql
		command.Prepared = True
		command.CommandType = adCmdText
		Set param=command.CreateParameter(prefix,adChar,adParamInput,16,"")
		command.parameters.append param
		have_new=0
		
		Do until false 'eternal loop	
			tmp=searchTicketToVisit(prefix)
			if tmp=empty then
				exit do
				'response.write " ( studying "& tmp & ") "	
			end if
			command(prefix)=tmp
			set rs=command.execute(affectedRow)
			have_new=addNeighbourgs(rs)+have_new
			rs.close
		Loop
		Set param=nothing
		set command=nothing	
		findAllGeneric=have_new
	end function

	private function addNeighbourgs(rs)
		dim have_new,tmp,tmp0,tmp1,tmp2,tmp3,link,doit
		have_new=0
		
		Do until rs.EOF
			'force cast in char !
			tmp0=Cstr(rs(0))
			tmp1=Cstr(rs(1))
			tmp2=rs(2)&""
			tmp3=Cint(rs(3))
			'response.write " {"&rs(0)&"##"&rs(1)&"##"&rs(2)&"##"&rs(3)&"} "

			if tmp3 then
				if not visited.exists(tmp1) then
					visited.add tmp1,0
					'response.write " (new visit for "&tmp1&")"
					have_new=have_new+1
				end if
				if not nodesName.exists(tmp1) then 
					set tmp = new GraphNode
					tmp.init tmp1,tmp2,tmp3
					nodesName.add tmp1,tmp
					'response.write " (new node "&tmp1&") "
				end if
				link="related"
				doit=(tmp0<tmp1)
			else 
				link="relatedCI"
				'response.write "[ NO OP, " & tmp3 & ", "& tmp1 &"]"
				doit=true
			end if
			if doit then
				set tmp = new GraphLink
				tmp.init tmp0,tmp1,link
				neighbor.add neighbor.count+1, tmp
				'response.write " (adding neighbor "&tmp0&"~"&tmp1&")"
			'else 
				'response.write " (nothing) "
			end if
			rs.movenext
		Loop
	end function

	private function searchTicketToVisit( prefix )
		dim tmp
		'response.write " (to visit "&visited.count&") "
		for each tmp in visited.keys
			if 0=visited(tmp) and left(tmp,3)=prefix then
				searchTicketToVisit=tmp
				visited(tmp)=1
				exit function
			end if
		next 
		searchTicketToVisit=empty
	end function

	
	sub launchModule()
		dim tmp, prefix, replay
		replay=false
		Do until replay 'à faire qu'on explore des nouveaux 
			'response.write "<br/><br/> outer loop "
			replay=true
			for each tmp in visited.keys
				'response.write " [launcher]key=>" & tmp 
				if 0=visited(tmp) then 
					prefix=left(tmp,3)
					select case prefix
						case "CRQ"
							replay=false
							findAllCRQ()
			'				response.write "{ replay:"&replay&"-"&visited.count&"}"
							exit for
						case "INC"
							replay=false
							findAllINC()
			'				response.write "{ replay:"&replay&"-"&visited.count&"}"
							exit for						
						case "PBI"
							replay=false
							findAllPBI()
			'				response.write "{ replay:"&replay&"-"&visited.count&"}"
							exit for							
			'			case else 
			'				response.write " (NODE TYPE NOT SUPPORTED)"
					end select
			'	else 
			'		response.write " ("&tmp&" no action) "
				end if
			Next
			'response.write " { replay:"&replay&" end for loop} "
		Loop
		'response.write " {there are "& visited.count &" (end of func)}"
	end sub
	
	
	sub printLinks
		dim tmp,first,buf
		first=true
		response.write "["
		buf=","&vbCrLf
		for each tmp in neighbor.items
			if first then 
				first = false
			else
				response.write buf
			end if			
			response.write tmp.toJson
		next
		response.write "]"
	end sub
	
	sub printNodes
		dim tmp,first,k,buf
		first=true
		buf=","&vbCrLf
		response.write "{"
		for each tmp in nodesName.items
			if first then 
				first = false
			else
				response.write buf
			end if
			response.write """"&tmp.name& """:"&tmp.toJson
		next
		response.write "}"
	end sub
end class

Function regexMatch(regExp,strTarget, strPattern)
	regExp.Pattern=strPattern
	regExp.Global=true
	regExp.IgnoreCase=True
	Set regexMatch=regExp.Execute(strTarget)
End Function	
	
function fixTicket( regExp, byref ticket_u )
	dim ticket_num, ticket_numero, tmp, ticket_prefix, ticket_s
	ticket_prefix=left(ticket_u,3)
	tmp=left(ticket_prefix,2)
	if tmp = "WO" then
		ticket_prefix="WO"
	end if
	'completion avec n° basée sur onglet actif
	ticket_num=StripAlphaChars( regExp, ticket_u )
	ticket_u=ticket_num ' now ticket is safe !
	tmp=len(ticket_num)+len(ticket_prefix)
	if ( tmp<C_TICKET_DIGIT ) then 
		ticket_numero=string(C_TICKET_DIGIT-tmp,"0") & ticket_num
	else
		ticket_numero=ticket_num	
	end if
	select case ticket_prefix
		case  "CRQ","INC","PBI"
			ticket_s= ticket_prefix & ticket_numero
			ticket_u=ticket_prefix & ticket_num
		case else
			ticket_s=empty
	end select
	fixTicket=ticket_s
end function

Function StripAlphaChars(regExp,ByVal pstrSource)
	Dim m_strOut
	m_strOut=Trim(pstrSource & "")
	regExp.Pattern="\D+0*" 'Matches any character that is not a digit character (0-9).
	regExp.Global=True
	regExp.IgnoreCase=True
	'm_objReg.MultiLine=True
	m_strOut=regExp.Replace(m_strOut, "")
	StripAlphaChars=m_strOut	
End Function

function validateAddToGraph( glf,byVal unsafe_query )
	dim arrResults,tmp,safe_query,regExp,match
	set regExp = new RegExp
	'here we beter not know how many digit in ticket ... better behavior if too much
	set arrResults=regexMatch(regExp,unsafe_query,"(\b#?[A-Z]{0,4}[0-9]+\b)")
	'In your pattern the answer is the first group, so all you need is'
	For each match in arrResults
		tmp=fixTicket(regExp,match.Submatches(0))
		glf.addEntryPoint(tmp)
		safe_query=safe_query&" "&tmp 
	Next
	validateAddToGraph=trim(safe_query)
end function

function validateEnv(unsafe_env)
	dim tmp
	tmp = Ucase(unsafe_env)
	select case tmp 
		case "P","S","K"
			validateEnv=tmp
		case else 
			validateEnv="N"
	end select
end function

function validateWithCI( unsafe_ci )
	dim tmp
	tmp= Ucase(unsafe_ci)
	select case tmp	
		case "ON"
			validateWithCI="true"
		case else 
			validateWithCI="false"
	end select 
end function 
%>