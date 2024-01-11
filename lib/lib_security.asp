<%

'******************** CONSTANTES ***********************************************

Const MSG_CONTACT = "Please contact PE"
Const MAIL_CONTACT = "pierre-emmanuel.perillon@sanofi.com"
'---
Const TECH1 = "***"
Const TECH2 = "***"
Const TECH3 = "***"
Const DBNAME_DBK = "O1P00045"
Const DBUSER_DBK = "DBK"
Const DBUSER_DWP = "DWP"

Const DS_STR_DBK = "Data Source=***;"
Const DS_STR_DBK_NGDC = "Data Source=***;"
'Const DS_STR_DBK_NGDC = "Data Source=***;"
Const DS_STR_DBK_NGDC2 = "Data Source=***;"

Dim  CONN_STR_DBK, CONN_STR_DBK_NGDC, CONN_STR_DBK_NGDC2, CONN_STR_DWP
CONN_STR_DBK = "Provider=MSDAORA;" & DS_STR_DBK & "User Id=DBK;Password=DBK3"

CONN_STR_DBK_NGDC = "Provider=MSDAORA;" & DS_STR_DBK_NGDC & "User Id=DBK;Password="&TECH3
CONN_STR_DWP = "Provider=MSDAORA;" & DS_STR_DBK_NGDC & "User Id=DWP;Password=***"

Const AUTHORIZED_USERS = "***1 ***2 ***3 "

Dim SECURITY_USER, SECURITY_GROUP

'******************** FONCTIONS ************************************************

sub security_fatalErrorMessage(msg, auth_user, dwp_app )
	dim mail
	 mail= "<a href=""mailto:"&MAIL_CONTACT&"?subject=Access request to DBA " &dwp_app &" for account " & auth_user & """>"&MSG_CONTACT&"</a>"
	select case msg
	case "EMPTY"
        response.write "The server did not identify you!<br/>"
	case "CONN"
        response.write "<font face=verdana size=2 color=blue>"
        response.write "Error when connecting to " & Db_name & " database<br><br>"
        response.write err.description & "<br><br>"
        select case left(err.description,9)
			case "ORA-12541"
				response.write "=> Database " & Db_name & " unreachable"
				response.write MSG_CONTACT & " or contact your service desk to create an incident. "
			case "ORA-00257"
				response.write "=> Archive logs filesystem full for <b>" & Db_name & "</b>"
				response.write MSG_CONTACT & " or contact your service desk to create an incident. "
			end select
        response.write "</font>"
	case "NOACCESS"
	    response.write "You cannot access this page with your account " & auth_user & ".<br>"
        response.write  " to get access " & MAIL_CONTACT & ", " & mail
    case "NOAVAIL"
		response.write "<font face=""verdana"" size=""3"" color=""blue""><b>"
		response.write "Your application is unavailable for maintenance reason<br/>"
		response.write "Sorry for the inconvenience."
		response.write "</b></font>"
	case else
		response.write "unexpected fatal error..."
	end select 
	response.end
end sub


sub security_identify_visitor_promise ( trace )
	'no op
	' user will be identified when connected to promise
	SECURITY_USER = security_truncLogin( security_retrieveWindowsLogin() )
end sub


sub security_identify_dba( trace )
	SECURITY_USER = security_truncLogin( security_retrieveWindowsLogin() )
	
	if inStr(AUTHORIZED_USERS,SECURITY_USER) = 0 then
		
		security_trace_visitor  false, null 
		response.redirect "/promise_gate_index.asp?msg=wig"
		response.end 
	else
		if trace then 
			security_trace_visitor true, null 	
		end if
	end if
end sub


function security_retrieveWindowsLogin()
	dim user
	user = Ucase(Request.ServerVariables("auth_user"))
	if len( user ) = 0 then 
		security_retrieveWindowsLogin = ""	
	else
		security_retrieveWindowsLogin = user
	end if
end function


function security_truncLogin( x )
	dim tmp
	tmp = inStr( x, "\" )
	if tmp = 0 then
		security_truncLogin = x
	else
		security_truncLogin = mid( x, tmp+1 )
	end if
end function 


sub security_identify_visitor ( trace )
    dim Db_name, Db_user, Db_ConnString,dwp_app 
    dim Conn_logon, RS_logon, SQL_logon
    dim auth_user, short_user, MAIL_CONTACT

    Db_name = DBNAME_DBK
    Db_user	= 	DBUSER_DBK
    Db_ConnString = CONN_STR_DBK_NGDC

    'verif du compte DBK du user connecté
	auth_user = security_retrieveWindowsLogin()
	short_user = security_truncLogin( auth_user )
    if len( auth_user ) = 0  then
		security_fatalErrorMessage "EMPTY", auth_user,dwp_app
    end if
	
	'
	SQL_logon = "SELECT U.ID_USER, U.NOM_ABREGE, U.TRIGRAMME, U.GROUPE, coalesce(U.LOGIN_TRUNC, U.LOGIN2_TRUNC) LOGIN, EQUIPE FROM V_DWP_USERS U WHERE U.PRESENT = 'O' AND ( U.LOGIN =  " & security_txt_sql_ora(auth_user) & " OR  U.LOGIN_TRUNC = " & security_txt_sql_ora(AUTH_USER) & " OR U.LOGIN2_TRUNC = " & security_txt_sql_ora(short_user) & ") "
	
    'recuperation du login windows
	 if instr(Request.ServerVariables("SCRIPT_NAME"), "/itsm_gate") > 0 then
        SQL_logon =SQL_logon &  " AND U.PROMISE_GATE = 'O'"
		dwp_app = "ITSM Gate"
	elseif instr(Request.ServerVariables("SCRIPT_NAME"), "/promise_gate") > 0 then
        SQL_cond = SQL_logon &" AND U.PROMISE_GATE = 'O'"
		dwp_app = "Promise Gate"
    elseif instr(Request.ServerVariables("SCRIPT_NAME"), "/provisioning") > 0 then
        SQL_logon =SQL_logon & " AND U.PROV = 'O'"
		dwp_app = "Provisioning tool"
	elseif instr(Request.ServerVariables("SCRIPT_NAME"), "/oamt") > 0 then
        SQL_logon =SQL_logon & " AND U.OAMT = 'O'"
		dwp_app = "OAMT"
    elseif instr(Request.ServerVariables("SCRIPT_NAME"), "/oct") > 0 then
        SQL_logon = SQL_logon & " AND U.SDC_ORA_NGDC = 'O'"
		dwp_app = "Oracle change tracking"
	elseif (instr(SCRIPT_NAME, "/activity") > 0) then
        DWP_APP = "Activity schedule"
		SQL_logon = "SELECT U.ID_USER, U.NOM_ABREGE, U.TRIGRAMME, CASE WHEN U.CRA_ADM = 'O' THEN 'ADM' WHEN U.CRA_GEST = 'O' THEN 'GEST' WHEN U.CRA_USER = 'O' THEN 'USER' ELSE NULL END GROUPE, coalesce(U.LOGIN_TRUNC, U.LOGIN2_TRUNC) LOGIN FROM V_CRA_USERS U WHERE U.PRESENT = 'O' AND (U.LOGIN_TRUNC = " & security_txt_sql_ora(ucase(short_user)) & " OR U.LOGIN2_TRUNC = " & security_txt_sql_ora(ucase(short_user)) & ")  AND (U.CRA_USER = 'O' OR U.CRA_ADM = 'O' OR U.CRA_GEST = 'O') "
        Db_user = DBUSER_DWP
        Db_ConnString = CONN_STR_DWP
	else 
		SQL_cond = " AND 1=0 "
		dwp_app =" unidentified "
    end if
	
	'init connexion
    on error resume next
    Set Conn_logon = Server.CreateObject("ADODB.Connection")
    Set RS_logon = Server.CreateObject("ADODB.Recordset")

    'connexion principale à la base pour l'authentification avec gestion d'erreur pour les utilisateurs
    Conn_logon.open Db_ConnString
    if err.number <> 0 then
		security_fatalErrorMessage "CONN",auth_user,dwp_app
    end if
    on error goto 0

	'response.write SQL_logon 

	
    Set RS_logon = Conn_logon.Execute(SQL_logon) 

    if RS_logon.EOF then
		if trace Then
			security_trace_visitor false, conn_logon
		end if
		security_fatalErrorMessage "NOACCESS",auth_user, dwp_app
	end if
    'connexion reussie

	SECURITY_USER = RS_logon("LOGIN")
	SECURITY_GROUP= RS_logon("GROUPE")

	
	if trace Then
		'maj historique
		security_trace_visitor true, conn_logon 
	end if

    'close connexion
    RS_logon.close
    Conn_logon.close
	
	set rs_logon = nothing
	set conn_logon = nothing
end sub

function security_txt_sql_ora ( x )
	security_txt_sql_ora = "'"& x & "'"
end function


function security_trace_visitor( status, connection )
	dim sql, wasNull, statusSTR

'    on error resume next    
	if isNull(connection)  then
		Set connection = Server.CreateObject("ADODB.Connection")
		connection.open CONN_STR_DBK_NGDC
		wasNull = true
	else
		wasNull = false
	end if 
	
	if status then 
		statusSTR = "'OK'"
	else
		statusSTR = "'KO'"
	end if
	'to check this: select * from page_histo where dt_conn > (sysdate - 1) and http_referer like '%itsm%' order by dt_conn desc;
	
	sql = "INSERT INTO PAGE_HISTO (LOGIN, SERVER_NAME, IP_ADDRESS, STATUS, HTTP_REFERER) VALUES (" & security_txt_sql_ora(security_retrieveWindowsLogin()) & "," & security_txt_sql_ora(Request.ServerVariables("SERVER_NAME")) & "," & security_txt_sql_ora(Request.ServerVariables("REMOTE_ADDR")) & ","&statusSTR&",'/ppn/itsm_gate/index.asp')"
	
	connection.Execute(sql)

	if wasNull then
		connection.close
		set connection = nothing
	end if
	
end function 


sub security_not_found
response.Status="404 Not found"
'it is not me, i promise i had to do this :( 
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">
<HTML><HEAD><TITLE>The page cannot be found</TITLE>
<META HTTP-EQUIV="Content-Type" Content="text/html; charset=Windows-1252">
<STYLE type="text/css">
  BODY { font: 8pt/12pt verdana }
  H1 { font: 13pt/15pt verdana }
  H2 { font: 8pt/12pt verdana }
  A:link { color: red }
  A:visited { color: maroon }
</STYLE>
</HEAD><BODY><TABLE width=500 border=0 cellspacing=10><TR><TD>

<h1>The page cannot be found</h1>
The page you are looking for might have been removed, had its name changed, or is temporarily unavailable.
<hr>
<p>Please try the following:</p>
<ul>
<li>Make sure that the Web site address displayed in the address bar of your browser is spelled and formatted correctly.</li>
<li>If you reached this page by clicking a link, contact
 the Web site administrator to alert them that the link is incorrectly formatted.
</li>
<li>Click the <a href="javascript:history.back(1)">Back</a> button to try another link.</li>
</ul>
<h2>HTTP Error 404 - File or directory not found.<br>Internet Information Services (IIS)</h2>
<hr>
<p>Technical Information (for support personnel)</p>
<ul>
<li>Go to <a href="http://go.microsoft.com/fwlink/?linkid=8180">Microsoft Product Support Services</a> and perform a title search for the words <b>HTTP</b> and <b>404</b>.</li>
<li>Open <b>IIS Help</b>, which is accessible in IIS Manager (inetmgr),
 and search for topics titled <b>Web Site Setup</b>, <b>Common Administrative Tasks</b>, and <b>About Custom Error Messages</b>.</li>
</ul>

</TD></TR></TABLE></BODY></HTML>
<%
end sub


%>