<%
Const DBENV_TOOL_ARS="ARS"
Const DBENV_TOOL_ITSM="PROMISE"

Class DatabaseEnv
	public connectStr 'STRconn
	public schema1
	public schema2	
	private connection
	public web_server
	public app_server
	private password
	public toolName
	private allowed
	private securityQuerySql
	'public useCodes
	
	sub class_initialize()
		allowed = false
	end sub
	
	sub	class_Terminate ()
		close
	end sub 

	sub init(env )
		initEnv( env)
	end sub
	
'	sub init(options)
'		initEnv options.env 
'		'feedback options...
'		options.setServerApp me 
'	end sub 
	
	
	function getConnection 
		if allowed then
			Set getConnection = connection
		else
			security_fatalErrorMessage "NOACCESS", "Annonymous", "ITSM Promise"
		end if		
	end function
	
	sub open
		set connection = Server.CreateObject("ADODB.Connection")
		connection.open connectStr & password
		'connection.CursorLocation = adUseServer
		'connection.CommandTimeout 5
	end sub
	
	
	sub close 
		connection.close
		Set connection = nothing 
	end sub

'	function runSqlCommand( byref rs, cmd, debug  )
'		dim ASPErr, param
'		Set rs = cmd.execute()
'	end function
	
	sub securityQuery ( user )
		dim query,cnt,rs
		
		if len(user)=0 then 
			allowed=false
			exit sub
		end if
		
		set query = new QuerySQL
		query.init connection 
		query.setSQL securityQuerySql 
		query.forceBind user
		set rs = query.execute()
		'response.write sql & " " & rs(0) & "user = " & user & "<br>"
		if  Clng(rs(0)) = 0 then 
			security_fatalErrorMessage "NOACCESS", user , "ITSM Promise"
			allowed=false
		else
			allowed=true
		end if
		set query=nothing
		set rs=nothing
	end sub
	'------------------------------------------------------------------------------------------
	'below the dirty part
	private sub initEnv( env )
		toolName = DBENV_TOOL_ITSM
		'environnement specific
		Select case env
		case "N"
			' "NGDC prod reporting"
			connectStr = "Provider=MSDAORA;Data Source=***;User Id=***"
			password="****"
			schema1	= "ITSMPRD"
			schema2 = "SRC$ITSM"
			web_server = "web_server"
			app_server = "app_server"
			securityQuerySql= "SELECT count(REMEDY_LOGIN_ID) test FROM "&schema1&".CTM_PEOPLE WHERE profile_status=1 AND REMEDY_LOGIN_ID=?"
		case "P"
			'NEWPROD
			'"NGDC Remedy PROD"
			connectStr = "Provider=MSDAORA;Data Source=***;User Id=***"
			password="***"
			schema1 = "ITSMPRD"
			schema2 = "SRC$ITSM"
			web_server = "web_server"
			app_server = "app_server"
			securityQuerySql= "SELECT count(REMEDY_LOGIN_ID) test FROM "&schema1&".CTM_PEOPLE WHERE profile_status=1 AND REMEDY_LOGIN_ID=?"
		case "PP"
			connectStr = "Provider=MSDAORA;Data Source=***;User Id=***;"
			password="***"
			schema1 = "ITSMPRD"
			schema2 = "SRC$ITSM"
			web_server = "web_server"
			app_server = "app_server"
			securityQuerySql= "SELECT count(REMEDY_LOGIN_ID) test FROM "&schema1&".CTM_PEOPLE WHERE profile_status=1 AND REMEDY_LOGIN_ID=?"
		case "L"
			' "Legacy Production"
			connectStr = "Provider=MSDAORA;Data Source=***;User Id=***"
			password="***"
			schema1 = "GEN$ARS"
			schema2 = "GEN$ARS"
			web_server = "web_server"
			app_server = "app_server"
			toolName = DBENV_TOOL_ARS
			securityQuerySql= "SELECT 1 TEST FROM DUAL  "
		case "N"
			' "NGDC prod reporting"
			connectStr = "Provider=MSDAORA;Data Source=***;User Id=***"			
			password="***"
			web_server = "web_server"
			app_server = "app_server"
			securityQuerySql= "SELECT count(REMEDY_LOGIN_ID) test FROM "&schema1&".CTM_PEOPLE WHERE profile_status=1 AND REMEDY_LOGIN_ID=?"
		case "K","S"
			'"NGDC Remedy STAGING"
			'STAGING
			connectStr = "Provider=MSDAORA;Data Source=***;User Id=***"	
			password="***"
			web_server = "web_server"
			app_server = "app_server"
			securityQuerySql= "SELECT count(REMEDY_LOGIN_ID) test FROM "&schema1&".CTM_PEOPLE WHERE profile_status=1 AND REMEDY_LOGIN_ID=?"
		case "T"
			'"NGDC Remedy STAGING"
			'STAGING
			connectStr = "Provider=MSDAORA;Data Source=***;User Id=***"	
			password="***"
			schema1 = "ITSMTST"
			schema2= "SRC$ITSM"
			web_server = "web_server"
			app_server = "app_server"
			securityQuerySql= "SELECT count(REMEDY_LOGIN_ID) test FROM "&schema1&".CTM_PEOPLE WHERE profile_status=1 AND REMEDY_LOGIN_ID=?"
		case "O"
			'OLDPROD
			' "NGDC Remdy PROD old"
			connectStr = "Provider=MSDAORA;Data Source=***;User Id=***"	
			password="***"
			schema1 = "GEN$ITSM"
			schema2 = "GEN$ITSM_SPDATA"
			web_server = "web_server"
			app_server = "app_server"
			securityQuerySql= "SELECT count(REMEDY_LOGIN_ID) test FROM "&schema1&".CTM_PEOPLE WHERE profile_status=1 AND REMEDY_LOGIN_ID=?"
		end select
	end sub	
End Class

%>