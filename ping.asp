<!--#INCLUDE FILE="lib/lib_security.asp"--><%
security_identify_dba true
Response.ContentType = "text/javascript"
response.write "var user_traking=true;" 
%>