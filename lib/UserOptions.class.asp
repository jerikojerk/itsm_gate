<%

Const UserOptions_form_tas="TMS%3ATask"
Const UserOptions_form_crq="CHG%3AInfrastructure+Change/Best+Practice+View"
'Const UserOptions_form_inc="HPD%3aHelp%20Desk"
'Const UserOptions_form_pbi="PBM%3AProblem+Investigation"
Const UserOptions_form_appro="Approval%20Central"

'Const UserOptions_server_ars= yet another server 
Const UserOptions_form_wko="CHG%3aTask"
Const UserOptions_form_rqt="CHG%3aChange"
Const UserOptions_form_inc="HPD%3aHelp%20Desk"
Const UserOptions_form_pbi="PBM%3AProblem+Investigation"
Const UserOptions_qual_wko="%27Work+Order+ID%2B%27%3D%22WKO"
Const UserOptions_qual_rqt="%27Request+ID%2B%27%3D%22RQT"
Const UserOptions_qual_inc="%27Incident+ID*%2B%27%3D%22INC"
Const UserOptions_qual_pbi="%27Problem+ID*%2B%27%3D%22PBI"
Const UserOptions_qual_end="%22"
Const UserOptions_form_req="SRM%3ARequest"
Const UserOptions_form_wo ="WOI%3AWorkOrder/Simplified+User+View"
Const UserOptions_form_tasflow="TMS%3ATaskFlowViewer/UE+Admin+View"
Const userOptions_form_ppl="CTM%3APeople/Default+User+View"
Const userOptions_form_sgp="CTM%3ASupport+Group/Default+User+View"

Const CMDB_APPLICATION="AST%3AApplication/Dialog+View/?"
Const CMDB_COMPUTERSYSTEM="AST%3AComputerSystem/Dialog+View/?"
Const CMDB_DATABASE="AST%3ADataBase/Dialog+View/?"
Const CMDB_FORM="AST%3ACluster/Dialog+View/?"


Class UserOptions
	public env
	public group
	public ticket_user
	public ticket_sql1
	public ticket_sql2
	public ticket_sql0 
	public type_ticket
	public sens_rech
	public team_name
	public isMyself
	public isAutoTeam	'a boolean to check if we have to look for the teams after connected user name.
	public isAutoTeamFull
	public isFeature	'can be either true or false => true use a feature, false can have a filter
	public featureName	'store the name of the feature
	public query_selector		'select the query in QueryBuilder (this value is NOT safe)
	public date1		'for since feature + between
	public date2		'for between feat
	public action		'allow to distinguish between result page and welcome page. 
	private allow_no_group	'if yes
	public current_user  'current user (connected/overloaded by user parameter feature, refer to SECURITY_USER to be sure.)
	public timezone
	public countTicket
	private regExp
	private uniq
	public dbEnv
	
sub Class_initialize
	action=P_NORMAL
	allow_no_group=false
	isFeature=false
	isAutoTeam=false
	isAutoTeamfull=false
	isMyself=false
	ticket_sql0=empty
	ticket_user=empty
	ticket_sql1=empty
	ticket_sql2=empty
	featureName=empty
	env=empty
	timezone="CET"
	Set regExp=New RegExp
	set uniq=Server.CreateObject("Scripting.Dictionary")
end sub


sub Class_terminate 
	Set regExp=Nothing
	Set uniq=Nothing
	set dbEnv=nothing
end sub

sub init(logon)
	current_user=ucase(logon)
	initUser ' allow to spoof user.
	initTimezone
	initAction
	initEnv
	initTypeTicket
	initGroup
	if type_ticket="PEOPLE" then
		initPeople
	else
		initSens
		analyseMultipleTickets
	end if
	if type_ticket="GUESS" then if action=P_NORMAL then action=P_WELCOME
end sub



'------------------------------------------------
sub  initAction 
	action=Ucase(Request.queryString("action")) ' action data/count appro
	if action=P_APPRO then
		allow_no_group=true	
	else 
		action=P_NORMAL
	end if
end sub 

'------------------------------------------------
sub initTimezone 
	dim tmp, arrResul, regEx
	tmp=Request.queryString("tz") ' 
    regExp.Pattern="^[A-Z0-9/]+$"
    regExp.Global=true
	regExp.IgnoreCase=true
	'if it looks safe, apply it.
	if regExp.test( tmp ) then
		timezone=tmp
	end if
end sub
	
	
'------------------------------------------------
'init: env
sub initEnv
	dim tmp
	tmp=Ucase(Request.querystring("e"))  ' (L)EGACY, (N)GDC
	select case tmp
		case "N","P","L","K", "S", "O","T"
			env=tmp
		case else 
			env="N"
			'action=P_WELCOME
	end select
	
	Set dbEnv = new DatabaseEnv
	dbEnv.init env
	dbEnv.open 
	dbEnv.securityQuery SECURITY_USER 	
end sub


'------------------------------------------------
sub initPeople
	dim has_name, match,  arrResults, cnt, t1, t2,ext,prest,tmp,query
	query =Ucase( trim(Request.querystring("query") ))' Recherche ticket
	
	set arrResults=regexMatch(query,"(\b[A-Z._-]+\b)")
	cnt=0	
	uniq.removeAll
	'manage names
	For each match in arrResults
		t1=match.Submatches(0)
		if not uniq.exists(t1)  then 
			uniq.add t1, 0
		end if
		ext=InStrRev(t1,"-EXT")
		
		if ext=0 then 
			if not uniq.exists(t1& "-EXT")  then 
				uniq.add t1 & "-EXT", 0
			end if
		end if
		
		prest=InStrRev(t1,"-PREST")
		if prest=0 then 
			if not uniq.exists(t1& "-PREST")  then 
				uniq.add t1 & "-PREST", 0
			end if
		end if
	Next

	if uniq.count > 0 then
		ticket_sql2= uniq.keys
		has_name=true
	else
		ticket_sql2=null
		has_name=false
	end if 

	'manage login & workgroup: there is a number inside (or not) but no suffix
	' this is larger than from first pattern.
	set arrResults=regexMatch( query , "(\b[A-Z][0-9A-Z._-]+\b)|\b""([A-Z][ 0-9A-Z._-]+)""\b"  )
	uniq.removeAll
	cnt =0
	For each match in arrResults
		if len(match.Submatches(0)) and not uniq.exists( match.Submatches(0))  then
			uniq.add match.Submatches(0), match.Submatches(0)
		end if
		if len(match.Submatches(1)) and not uniq.exists( match.Submatches(1))  then
			uniq.add match.Submatches(1), """"&match.Submatches(1)&""""
		end if
	next 
	
	if uniq.count > 0 then
		ticket_sql1= uniq.keys 
		ticket_user= join( uniq.Items, " ")
		'response.write "team:"&ticket_user
	elseif has_name then
		ticket_sql1= null
		ticket_user=join( ticket_sql2, " ")
		'response.write "name:"&ticket_user
	else 
		ticket_sql1=null
		ticket_user=empty
	end if
	
	set arrResults=nothing
end sub

'----------------------------------------------
private function initGroupLegacy(tmp)
	select case tmp & "|" & type_ticket
	case "ORA-L3|WKO"
		initGroupLegacy="WKO-FR-IN03-ORACLE,SH-WWW-IN3-DATABASE_ORACLE"
		'lib_group=LIB_GRP_ORA
		group="ORA-L3"
	case "ORA-L3|INC", "ORA-L3|PBI"
		initGroupLegacy="INC-FR-IN03-ORACLE,SH-WW-IN3-DATABASE_ORACLE"
		'lib_group=LIB_GRP_ORA
		group="ORA-L3"
	case "MSSQL-L3|WKO"
		initGroupLegacy="WKO-FR-IN03-MSSQL,SH-WWW-IN3-DATABASE_SQL"
		'lib_group=LIB_GRP_MSSQL
		group="ORA-L3"
	case "MSSQL-L3|INC", "MSSQL-L3|PBI"
		initGroupLegacy="INC-FR-IN03-MSSQL,SH-WW-IN3-DATABASE_SQL"
		'lib_group=LIB_GRP_MSSQL
		group="MSSQL-L3"
	case "UNIX-L3|WKO"
		initGroupLegacy="WKO-FR-IN03-UNIX,SH-WWW-IN3-UNIX"
		'lib_group=LIB_GRP_UNIX
		group="UNIX-L3"
	case "UNIX-L3|INC", "UNIX-L3|PBI"
		initGroupLegacy="INC-FR-IN03-UNIX,SH-WW-IN3-UNIX"
		'lib_group=LIB_GRP_UNIX
		group="UNIX-L3"
	case "ETL-L3|WKO"
		initGroupLegacy="SH-WWW-IN3-EAI_ETL"
		'lib_group=LIB_GRP_ETL
		group="ETL-L3"
	case "ETL-L3|INC", "ETL-L3|PBI"
		initGroupLegacy="SH-WW-IN3-EAI_ETL"
		'lib_group=LIB_GRP_ETL
		group="ETL-L3"
	case "SAP-L3|WKO"
		initGroupLegacy="SH-WWW-IN3-SAP"
		'lib_group=LIB_GRP_ETL
		group="ETL-L3"
	case "SAP-L3|INC", "SAP-L3|PBI"
		initGroupLegacy="SH-WW-IN3-SAP"
		'lib_group=LIB_GRP_ETL
		group="SAP-L3"
	case else
		'lib_group=empty
		group="auto"
		isAutoTeam=true
	end select
end function
'------------------------------------------------
' init: teamList + lib_group +PAGE_DISPLAYED + outil
sub initGroup 	
	dim tmp,team,buf
	tmp=Ucase(trim(Request.querystring("g")))  ' group ARS ou PROMISE
	
	select case env
	'### LEGACY ###
	case "L"
		team=initGroupLegacy(tmp)
	'### NGDC ###
	
	case else 'case "N"
		buf=len(tmp)
		if tmp="MYSELF" then 
			isMyself=true
			group=tmp
		elseif tmp="AUTO" or buf=0 then 
			isAutoTeam=true
			isAutoTeamFull=false
			group="AUTO"
		elseif tmp="ALL" then
			isAutoTeam=true
			isAutoTeamFull=true
			group="ALL"
		elseif buf<10 then 
			if GetInfosGroupe(tmp,team) then
				group=tmp
			else
				team=tmp
			end if
		else 'try with the user's value
			team=tmp
			group=tmp
			'lib_group=empty
		end if
	end select
	
	if len(group)=0  then
		if not allow_no_group then 
			action=P_WELCOME
		end if
	end if
	'response.write "team " & team
	team_name=split(team,",")

end	sub

'------------------------------------------------
' init: sens_rech
sub initSens
	dim tmp
	tmp=Lcase(trim(Request.querystring("s"))) ' (m)anaged, (s)ubmited, (a)ssigned
	'gestion (s)ens recherche
	' a=assigned m= managed s=submitted,
	select case tmp
		case SENS_ASSIGNED,SENS_MANAGED,SENS_SUBMITED, SENS_COORDINATE
			sens_rech=tmp
		case else 
			sens_rech=SENS_ASSIGNED
	end select 
end sub

'------------------------------------------------
sub initTypeTicket 
	dim tmp, tab
	tmp =	Ucase(trim(Request.querystring("t")))  ' WKO, INC, PBI, TAS, INC, PBI, CRQ
	
	if len(tmp)=0 then
		type_ticket="GUESS"
		exit sub
	end if
	tab=split(tmp,"-",2)
	
	select case tab(0)
		case "TAS","INC","PBI","CRQ","REQ","WKO","WO"
			query_selector=tmp
			type_ticket=tab(0)
'		case "AP"
'			query_selector=tmp
'			type_ticket="CRQ"
		case "PEOPLE","CI"
			allow_no_group=true
			query_selector=tmp
			type_ticket=tmp
		case else
			type_ticket="GUESS"
	end select
end sub


sub setDefaultType
	'we will disabled the answer on non exitant ticket.
	type_ticket=""
	query_selector="INC"
end sub
'------------------------------------------------
sub initUser()
	dim tmp, arrResults
	tmp=Ucase(trim(Request.querystring("user")))
	if len(tmp)> 0 then 
		set arrResults=regexMatch(tmp,"([A-Z0-9_.-]+)")
		'In your pattern the answer is the first group, so all you need is'
		if arrResults.Count>0 then
			current_user=arrResults(0).Submatches(0)
		end if
	end if
end sub


'------------------------------------------------
sub analyseMultipleTickets(  )
	dim tmp, query
	
	query=Ucase(trim(Request.querystring("query") ))' Recherche ticket
	'for promige gate backward compatibility
	'default value...
	date1=date
	'defaults
	select case query
		'mots clés
		case "ALL_SINCE","FRESH_CLOSED"
			tmp=Cint("0"&StripAlphaChars(Request.querystring("since")))
			if tmp>0 then
				date1=DateAdd("m",-tmp,date1)
			else
				date1=DateAdd("m",-3,date1)			
			end if
			ticket_sql1=query
			ticket_user=query
			isFeature=true
			featureName=query
'		case "BETWEEN"
'			tmp=StripAlphaChars(Request.querystring("dateStart"))
'			tmp=StripAlphaChars(Request.querystring("dateStop"))
'			date1= cdate("10/22/2013" )
'			date2= cdate("10/23/2013" )	
'			isFeature=true
'			allow_no_group=false
'			featureName=query
		case "REVIEW","NO_TASK","PENDING","P1","AMTF","NO_DB","NO_SERVER","NO_CI","NO_APP","SLOW","OLD","IMPLEMENTATION","DONE","CHECK_TEMPLATE","FROM_TOOL"
			ticket_sql1=query
			ticket_user=query
			isFeature=true
			featureName=query
		' to tell we thinked about it.
		case else
			analyseMultipleTicketsNoMagic(query)
	end select
end sub 'analyseMultipleTickets	

private sub analyseMultipleTicketsNoMagic(query)
	Dim  t1, t2, match,  arrResults, tmp
	dim secondary

	set arrResults=regexMatch(query,"@([\(\)%*A-Z0-9_.+-]+)|@\""([ \(\)%*A-Z0-9@_.+-]+)\""")
	'In your pattern the answer is the first group, so all you need is'
	uniq.removeAll
	For each match in arrResults
		tmp=match.Submatches(0)
		if len(tmp) and not uniq.exists(tmp) then
			uniq.add tmp,tmp
		end if
		tmp=match.Submatches(1)
		if len(tmp) and not uniq.exists(tmp) then
			uniq.add tmp,""""&tmp&""""
			
		end if
	Next

	if uniq.count then
		action=P_NORMAL
		ticket_sql2= uniq.keys
		ticket_user="@"&join(uniq.Items, " @")
		allow_no_group=true	
	else
		set secondary=Server.CreateObject("Scripting.Dictionary")
		'here we beter not know how many digit in ticket ... better behavior if too much
		set arrResults=regexMatch(query,"\b((?:[A-Z]{2,4}[0-9]+)|(:?[0-9]{3,99}))\b")
		'In your pattern the answer is the first group, so all you need is'
		
		uniq.removeAll
		For each match in arrResults
			t1=match.Submatches(0)
			tmp=analyse1Ticket(type_ticket,t1,t2) 
			if tmp then 
				if not uniq.exists(t2) then
					uniq.add t2,t2
				end if
			else 
				if not secondary.exists(t2) then 
					secondary.add t2,t2
				end if
			end if 
		Next
		
		tmp = uniq.count+secondary.count
		if tmp then 
			ticket_user=trim(Join(uniq.Items," ")&" "&Join(secondary.Items))
			action=P_NORMAL
			if secondary.count then ticket_sql0=secondary.keys
			if uniq.count then ticket_sql1=uniq.keys
			allow_no_group=true
			countTicket=tmp			
'			response.write "{"&ticket_sql0(0)&","&ticket_sql0(0)&"}"
			
		end if
		set secondary=nothing
	end if
	set arrResults=nothing 
end sub


Private  function analyse1Ticket( byref default_type, byref ticket_u, byref ticket_s )
	dim ticket_num, ticket_numero, tmp, ticket_prefix  
	ticket_prefix=left(ticket_u,3)
	tmp=left(ticket_prefix,2)
	if tmp = "WO" then
		ticket_prefix="WO"
	end if
	'completion avec n�n° bas�e sur onglet actif
	ticket_num=StripAlphaChars( ticket_u )
	ticket_u=ticket_num ' now ticket is safe !
	tmp=len(ticket_num)+len(ticket_prefix)
	if ( tmp<C_TICKET_DIGIT ) then 
		ticket_numero=string(C_TICKET_DIGIT-tmp,"0") & ticket_num
	else
		ticket_numero=ticket_num	
	end if
	
	select case ticket_prefix
		case  "TAS","CRQ","INC","WO","PBI","RQT","WKO","REQ"
			if default_type="GUESS" then
				default_type=ticket_prefix
			end if
			ticket_s=ticket_prefix & ticket_numero
			ticket_u=ticket_prefix & ticket_num
			if default_type=ticket_prefix then
				analyse1Ticket=true
			else
				analyse1Ticket=false
			end if 
		case else
			if default_type="GUESS" then 
				default_type="INC"
			end if
			ticket_s=default_type & ticket_numero
			analyse1Ticket=true
	end select

end function


function GetArsWebUrl (id_disc, the_type)
    dim curform, curqual, numero
	'on recupere le type de ticket si la longueur de l'id est coherente
	Select case the_type
	case "WKO"
		curform=UserOptions_form_wko
		curqual=UserOptions_qual_wko
	case "RQT"
		curform=UserOptions_form_rqt
		curqual=UserOptions_qual_rqt
	case "INC"
		curform=UserOptions_form_inc
		curqual=UserOptions_qual_inc
	case "PBI"
		curform=UserOptions_form_pbi
		curqual=UserOptions_qual_pbi
	case else
		GetArsWebUrl="#"
		exit function
	end select
	'on enleve le prefixe type ticket
	numero=mid(id_disc,4)
	'on complete les 0 pour 12 digits si le n° est incomplet
	numero=string(12-len(numero),"0") & numero
	GetArsWebUrl="http://" & dbEnv.web_server & "/arsys/servlet/ViewFormServlet?form=" & curform & "&amp;server=" & dbEnv.app_server & "&amp;qual=" & curqual & numero & UserOptions_qual_end
end function

function GetPromiseWebUrl (byval eid, tickettype)
    dim curform, formtype
	'on recupere le type de ticket si la longueur de l'id est coherente
	formtype=tickettype
	Select case tickettype
	case "TAS"
		curform=UserOptions_form_tas
	case "CRQ"
		curform=UserOptions_form_crq
	case "INC"
		curform=UserOptions_form_inc
	case "PBI" 'PBI URL commence par 000 
		curform=UserOptions_form_pbi
	case "REQ"
		curform=UserOptions_form_req
	case "REQ-"
		GetPromiseWebUrl="https://" & dbEnv.web_server &"/arsys/forms/"&dbEnv.app_server&"/SRS%3ARequestDetails/SRS+User+View/?mode=display&amp;F1000000829="&eid&"&amp;F302832400=LaunchedViaURL"
		exit function
	case "WO0"
		curform=UserOptions_form_wo
		formtype="WO"
	case "PPL"
		curform=UserOptions_form_ppl
		formtype="PEOPLE"
	case "SGP"
		curform=UserOptions_form_sgp
		formtype="PEOPLE"		
	case else
		eid=empty
	end select
	'old way of making  path
    'GetPromiseWebUrl="https://" & web_server &"/arsys/servlet/ViewFormServlet?form=" & curform & "&amp;server=" & app_server & "&amp;eid=" & id_disc
	'new way, remove 1 http redirect.
	if len(eid) then
		GetPromiseWebUrl="https://" &dbEnv.web_server &"/arsys/forms/"&dbEnv.app_server&"/"&curform&"/?eid=" & eid
	else
		GetPromiseWebUrl=formtype
	end if
end function

'******************** HELPERS 
Private Function StripAlphaChars(ByVal pstrSource)
	Dim m_strOut
	m_strOut=Trim(pstrSource & "")
	regExp.Pattern="\D+0*" 'Matches any character that is not a digit character (0-9).
	regExp.Global=True
	regExp.IgnoreCase=True
	'm_objReg.MultiLine=True
	m_strOut=regExp.Replace(m_strOut, "")
	StripAlphaChars=m_strOut
	
End Function

'A handy function i keep lying around for RegEx matches'
	Private Function regexMatch(strTarget, strPattern)
		regExp.Pattern=strPattern
		regExp.Global=true
		regExp.IgnoreCase=True
		Set regexMatch=regExp.Execute(strTarget)
	End Function

end Class


%>