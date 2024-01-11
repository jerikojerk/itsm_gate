<%
'******************************************************************************************
'' @SDESCRIPTION:   takes a given string and makes it JSON valid (http://json.org/)
'' @AUTHOR: Michael Rebec
'' @DESCRIPTION:    all characters which needs to be escaped are beeing replaced by their
''                  unicode representation according to the
''                  RFC4627#2.5 - http://www.ietf.org/rfc/rfc4627.txt?number=4627
'' @PARAM:          val [string]: value which should be escaped
'' @RETURN:         [string] JSON valid string
'******************************************************************************************
class JsonTool
	public function escape(val)
		dim i,l,currentDigit, ascii

		if varType(val) = 1 then 
			escape = ""
			exit function
		end if
		
		l = len( val )
		for i = 1 to l
			currentDigit = mid(val, i, 1)
			ascii = asc( currentDigit )
			if &h00 <= ascii and ascii <= &h1F then
				currentDigit = escapeSequence(ascii)
			elseif &hC280 <= ascii and ascii <= &hC2BF then
				currentDigit =  escapeSequence(ascii - &hC200)  ' "u00" +   right(padLeft(hex(ascii ), 2, 0), 2)			
			elseif &hC380 <= ascii and ascii <= &hC3BF then
				currentDigit = escapeSequence(ascii - &hC2C0 )  ' "u00" + right(padLeft(hex(ascii - &hC2C0), 2, 0), 2)
			elseif ascii = &h22 then	'cDoubleQuote
				currentDigit = escapeSequence(ascii)
			elseif ascii = &h5C then	'cRevSolidus
				currentDigit = escapeSequence(ascii)
			elseif 	ascii = &h2F then	'cSoliduscSolidus
				currentDigit = escapeSequence(ascii)
			end if
			escape = escape & currentDigit
		next
	end function
	 
	private function escapeSequence(ascii)
		escapeSequence = "\u00" & right(padLeft(hex(ascii), 2, 0), 2)
	end function 
	 
	private function padLeft(value, totalLength, paddingChar)
		padLeft = right(clone(paddingChar, totalLength) & value, totalLength)
	end function
	 
	private  function clone(byVal str, n)
		dim i
		for i = 1 to n : clone = clone & str : next
	end function
	
	
	sub recordset(rs)
		dim cell_name, rs_length,Icount
		rs_length = rs.fields.count -1
		response.write "["
		Do until rs.EOF 
			response.write "{"
			for Icount = 0 to rs_length
				cell_name = rs.fields(Icount).name
					response.write """" & escape( cell_name ) & """:"
					response.write """"& escape( rs(cell_name) ) & """"
					
					if icount < rs_length then
						response.write ","
					end if
			next 
			response.write "}"
			rs.MoveNext 'next
			if not rs.EOF then
				response.write "," 
			end if
		Loop '
		response.write "]"
	end sub
	
end class

dim JSON
set Json = new JsonTool
%>