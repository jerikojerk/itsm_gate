<!--#INCLUDE FILE="lib/lib_security.asp"--><!--#INCLUDE FILE="lib/PromiseWriter.class.asp"--><%


sub stats_itsm(login)
	dim connection,sql,rs, writer

	response.write "stats for "& login & vbcrlf
	sql = "select name, analysis_day, " &_
	"(select count(*) from page_histo where dt_conn between analysis_day and next_day and http_referer like '/ppn/itsm_gate%' and status='OK'and upper(login) like '"&login&"' ) your_itsm_gate_usage," &_
	"(select count(*) from page_histo where dt_conn between analysis_day and next_day and http_referer like '/ppn/itsm_gate%' and status='OK' ) all_itsm_gate_usage," &_
	"(select count(*) from page_histo where dt_conn between analysis_day and next_day and http_referer like '/promise_gate%' and status='OK'and upper(login) like '%E0176937')  your_promise_gate_usage," &_
	"(select count(*) from page_histo where dt_conn between analysis_day and next_day and http_referer like '/promise_gate%' and status='OK' ) all_promise_gate_usage " &_
	"from (select distinct to_char(ref.dt_conn,'DAY') name, trunc(ref.dt_conn) as analysis_day, trunc(ref.dt_conn)+1 as next_day from page_histo ref where ref.dt_conn > SYSDATE-120) order by analysis_day desc"

	Set connection = Server.CreateObject("ADODB.Connection")
	connection.open CONN_STR_DBK_NGDC

	set rs = connection.execute(sql)
	
	response.write rs.fields(0).name & vbtab
	response.write rs.fields(1).name & vbtab
	response.write rs.fields(2).name & vbtab
	response.write rs.fields(3).name & vbtab
	response.write rs.fields(4).name & vbtab
	response.write rs.fields(5).name & vbcrlf
	
	Do until rs.EOF 
		response.write rs.fields(0) & vbtab
		response.write rs.fields(1) & vbtab
		response.write rs.fields(2) & vbtab
		response.write rs.fields(3) & vbtab
		response.write rs.fields(4) & vbtab
		response.write rs.fields(5) & vbcrlf
		rs.MoveNext 'next
	Loop '
	
	
	rs.close
	set writer= nothing
	set connection=nothing 

end sub
 Response.ContentType = "text/plain"
stats_itsm  security_retrieveWindowsLogin() 


%>