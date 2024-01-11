<%
'*** CONSTANTES ADOVBS ***

'*** Conn.Execute SQL, CursorTypeEnum, LockTypeEnum ***

'---- CursorTypeEnum Values ----
Const adOpenForwardOnly = 0
Const adOpenKeyset = 1
Const adOpenDynamic = 2
Const adOpenStatic = 3

'---- LockTypeEnum Values ----
Const adLockReadOnly = 1
Const adLockPessimistic = 2
Const adLockOptimistic = 3
Const adLockBatchOptimistic = 4

'---- CursorLocationEnum Values ----
'OBSOLETE (appears only for backward compatibility). Does not use cursor services
Const adUseNone = 1
'Default. Uses a server-side cursor
Const adUseServer = 2
'Uses a client-side cursor supplied by a local cursor library. For backward compatibility, the synonym adUseClientBatch is also supported
Const adUseClient = 3

'---- CommandTypeEnum Values ----
Const adCmdUnknown = &H0008
Const adCmdText = &H0001
Const adCmdTable = &H0002
Const adCmdStoredProc = &H0004
Const adCmdFile = &H0100
Const adCmdTableDirect = &H0200

'------ const ADO Type DataTypeEnum Values
Const adDouble = 5 'A double-precision floating-point value.
Const adChar = 129 'A string value.
Const adNumeric = 131 'An exact numeric value with a fixed precision and scale.
Const adDBTimeStamp = 135 'A date/time stamp (yyyymmddhhmmss plus a fraction in billionths).
Const adVarChar = 200 'A string value (Parameter object only).

' added by ppn
Const adParamInput = 1
Const adParamOutput = 2
Const adParamInputOutput= 3
Const adParamReturnValue = 4


Const adEmpty = 0 'No value
Const adSmallInt = 2 'A 2-byte signed integer.
Const adInteger = 3 'A 4-byte signed integer.
Const adSingle = 4 'A single-precision floating-point value.
Const adCurrency = 6 'A currency value
Const adDate = 7 'The number of days since December 30, 1899 + the fraction of a day.
Const adBSTR = 8 'A null-terminated character string.
Const adIDispatch = 9 'A pointer to an IDispatch interface on a COM object. Note: Currently not supported by ADO.
Const adError = 10 'A 32-bit error code
Const adBoolean = 11 'A boolean value.
Const adVariant = 12 'An Automation Variant. Note: Currently not supported by ADO.
Const adIUnknown = 13 'A pointer to an IUnknown interface on a COM object. Note: Currently not supported by ADO.
Const adDecimal = 14 'An exact numeric value with a fixed precision and scale.
Const adTinyInt = 16 'A 1-byte signed integer.
Const adUnsignedTinyInt = 17 'A 1-byte unsigned integer.
Const adUnsignedSmallInt = 18 'A 2-byte unsigned integer.
Const adUnsignedInt = 19 'A 4-byte unsigned integer.
Const adBigInt = 20 'An 8-byte signed integer.
Const adUnsignedBigInt = 21 'An 8-byte unsigned integer.
Const adFileTime = 64 'The number of 100-nanosecond intervals since January 1,1601
Const adGUID = 72 'A globally unique identifier (GUID)
Const adBinary = 128 'A binary value.
Const adWChar = 130 'A null-terminated Unicode character string.
Const adUserDefined = 132 'A user-defined variable.
Const adDBDate = 133 'A date value (yyyymmdd).
Const adDBTime = 134 'A time value (hhmmss).
Const adChapter = 136 'A 4-byte chapter value that identifies rows in a child rowset
Const adPropVariant = 138 'An Automation PROPVARIANT.
Const adVarNumeric = 139 'A numeric value (Parameter object only).
Const adLongVarChar = 201 'A long string value.
Const adVarWChar = 202 'A null-terminated Unicode character string.
Const adLongVarWChar = 203 'A long null-terminated Unicode string value.
Const adVarBinary = 204 'A binary value (Parameter object only).
Const adLongVarBinary = 205 'A long binary value.


class QuerySQL
	public sql
	public allowNull
	private parameters
	private command
	private bindedCount
	private used
	private connection
	private regEx
	public affectedRow
	
	'------------------------------------------------
	private sub class_initialize()
		Set parameters = Server.CreateObject("Scripting.Dictionary")
		bindedCount = 0
		allowNull = false
		Set regEx = New RegExp
		regEx.Pattern = "{{[A-Z0-9_]+}}"
		regEx.Global = true
	end sub

	'------------------------------------------------
	private sub class_terminate()
		Set parameters = nothing
		Set command = Nothing
		Set regEx = Nothing
	end sub 

	
	'------------------------------------------------
	private function bindQuery()
		dim arrResults, match, foobar
		Set arrResults = regEx.Execute(sql)
		foobar=0
		For each match in arrResults
			foobar = foobar+1
			addParameter match,foobar
		Next 
		
		if foobar > 0 then
			command.CommandText = regEx.replace( sql, "?")
			command.Prepared = True
		else
			command.CommandText = sql 
			command.Prepared = false
		end if
		command.CommandType = adCmdText
	end function 
	
	'------------------------------------------------
	private function getParameter(placeholder)
		dim name
		name = mid(placeholder,3,len(placeholder)-4)
		getParameter = parameters(name)
	end function 
	
	'------------------------------------------------
	private function addParameter( placeholder, foobar	)
		dim  value, tmp
		value = getParameter( placeholder )
		tmp = varType( value )
		if tmp = 2 then  '2 = integer, 8 = string
			addParamInt foobar, value 
		else		
			addParamString foobar, value 
		end if
	end function 

	'------------------------------------------------
	private sub addParamInt( name, value )
		addParamGeneric name, value,  adInteger, 0 
	end sub

	'------------------------------------------------
	private sub addParamString( name, value )
		addParamGeneric name, value,  adChar, len(value) +1
	end sub

	'------------------------------------------------
	private sub addParamGeneric( name, value, typeParam, typeSize  )'
		dim tmp
		Set tmp = command.CreateParameter(name, typeParam, adParamInput, typeSize, value)
		command.parameters.append tmp
		set tmp= nothing
		bindedCount = bindedCount +1 
	end sub 

	'------------------------------------------------
	function datetime_sql_ora(dt)
		dim tmp
		tmp =  month(dt)
		datetime_sql_ora =   year(dt) & iif( len(tmp)=1 , Cstr("0" & tmp), tmp )
		tmp =day(dt)
		datetime_sql_ora =  datetime_sql_ora & iif( len(tmp)=1 , Cstr("0" & tmp), tmp ) & " "
		tmp =hour(dt)
		datetime_sql_ora =  datetime_sql_ora & iif( len(tmp)=1 , Cstr("0" & tmp), tmp )
		tmp = minute(dt)
		datetime_sql_ora =  datetime_sql_ora & iif( len(tmp)=1 , Cstr("0" & tmp), tmp )
		tmp=second(dt)
		datetime_sql_ora =  datetime_sql_ora & iif( len(tmp)=1 , Cstr("0" & tmp), tmp )
	end function
	
	'------------------------------------------------
	function date_sql_ora(dt)
		dim tmp
		tmp =  month(dt)
		date_sql_ora =   year(dt) & iif( len(tmp)=1 , Cstr("0" & tmp), tmp )
		tmp =day(dt)
		date_sql_ora =  date_sql_ora & iif( len(tmp)=1 , Cstr("0" & tmp), tmp ) 
	end function

	'------------------------------------------------	
	function date_us (dt )
		date_us=month(dt)&"/"&day(dt)&"/"&year(dt)
	end function
	
	'------------------------------------------------	
	function execute()
		On Error Goto 0 ' Reset error handling.
		bindQuery()
		On error resume next
		set execute = command.execute( affectedRow)
		
		If Err.Number <> 0 Then
			' Error Occurred / Trap it
			' Code to cope with the error here
			printDebugQuery Err.Number, Err.description
			Response.write "</body></html> "
			response.end
			execute = Nothing
		End If
		On Error Goto 0 ' Reset error handling.
	end function 

	'------------------------------------------------	
	sub forceBind( stringValue )
		addParamString "autoparam"&bindedCount, stringValue 
	end sub

	'------------------------------------------------		
	sub haveNewCommand()
		parameters.removeAll
		Set command = nothing 
		Set command = Server.CreateObject("ADODB.Command")
		command.ActiveConnection = connection
		command.CommandTimeout=120
		bindedCount = 0
	end sub

	'------------------------------------------------	
	sub init( cnx )
		set connection = cnx 
		haveNewCommand 
	end sub 

	'------------------------------------------------	
	function run( byref throwedErr, byref throwedMessage )
		bindQuery()
		On error resume next
		set run = command.execute(  affectedRow) 
		throwedErr = Err.Number		
		'13 look after row insert.
		If throwedErr <> 0 and throwedErr <> 13 Then
			'printDebugQuery  throwedErr, throwedMessage 
			throwedMessage = Err.Description 
		else
			throwedMessage = Err.Description 
		End If
		On Error Goto 0 ' Reset error handling.
	end function 

	
	'------------------------------------------------	
	sub setSql( query )
		sql = query
	end sub 

	'------------------------------------------------
	function protect( name, value )
		if varType( value ) = 1 then
			protect = "NULL"
		else
			name= Ucase(name)
			if not parameters.exists( name ) then
				parameters.add name, value
			else
				parameters.item(name)=value
			end if
			protect = "{{" & name & "}}"
		end if
	end function

	'------------------------------------------------
	function protectDate( name, value )
		if varType( value ) <> 7  then
				protectDate = "NULL"
			else
				name= Ucase(name)
				if not parameters.exists( name ) then
					parameters.add name,datetime_sql_ora(value)
				else
					parameters.item(name)=datetime_sql_ora(value) 
				end if
				protectDate="TO_DATE({{"&name&"}},'YYYYMMDD HH24MISS')"
		end if
	end function
	
	'------------------------------------------------
	function protectArray(name, values )
		dim item, count, tmp()
		count = Ubound( values )
		redim tmp( count )
		
		for  item = 0 to count
			tmp(item) = protect( name&item,values(item) )
		next
		protectArray = join( tmp, "," )
	end function


	'------------------------------------------------	
	sub printDebugQuery ( code, message )
			dim objErr
			Response.write "<div style=""color:red;background:ivory;padding:25px""><pre><h2>Error Occured</h2>"& vbCrlf
			Response.write "Err code = " &  code & vbcrlf
			Response.write "Err desc = " &  message & vbcrlf
			Response.write "</pre>SQL string <br/> "
			response.Write "<textarea cols=""130"" rows=""10"">" & command.CommandText & vbCrlf & "</textarea>"& vbCrlf
'			response.Write "<textarea cols=""130"" rows=""10"">" & bindQueryDebug()  & vbCrlf & "</textarea>" & vbCrlf	
			response.Write "<textarea cols=""130"" rows=""10"">" & sql & vbCrlf & vbCrlf 
			for each item in parameters.keys
				response.write "{{"&item & "}} => " & parameters( item )  & vbCrlf 
			next
			Response.write "</textarea>" & vbCrlf
			response.write "<p><strong>"&bindedCount&"<strong> parameters binded<p>"& vbCrlf
			Response.write "</div> "
	end sub

	sub updateParametrizedValue( paramIndex, newValue )
		command(paramIndex)=newValue
	end sub

end class 
%>