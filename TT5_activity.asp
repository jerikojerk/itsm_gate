<!--#INCLUDE FILE="lib/lib_security.asp"--><!--#INCLUDE FILE="lib/DatabaseEnv.class.asp"--><!--#INCLUDE FILE="lib/QuerySQL.class.asp"--><%
Const ANTI_CACHE_SEED=14
Const NUMBER_MONTH=30
Const NUMBER_WEEK=75 
Const LIST_CRQ_STATUS="0,'Draft',1,'R. For Authorization',2,'R. For Change',3,'Planning In Pr.',4,'Sch. For Review',5,'Sch. For Approval',6,'Scheduled',7,'Implementation In Pr.',8,'Pending',9,'Rejected',10,'Completed',11,'Closed',12,'Cancelled'"
Const LIST_CRQ_REASON="1000,'No Longer Required',2000,'Funding Not Available',3000,'To Be Re-Scheduled',4000,'Resources Not Available',5000,'Successful',6000,'Successful with Issues',7000,'Unsuccessful',8000,'Backed Out',9000,'Final Review Complete',10000,'Final Review Required',11000,'Additional Coding Required',12000,'Insufficient Task Data',14000,'In Rollout',19000,'In Build',24000,'Task Review',25000,'Miscellaneous',26000,'Future Enhancement',27000,'Manager Intervention',28000,'Accepted',29000,'Assigned'"
Const LIST_CRQ_TIMING="1000,'Emergency',2000,'Expedited',3000,'Latent',4000,'Normal',5000,'No Impact',6000,'Standard','?'"
Const LIST_TAS_STATUS="1000,'Staged',2000,'Assigned',3000,'Pending',4000,'Work in Progress',5000,'Waiting',6000,'Closed',7000,'Bypassed'"
Const LIST_TAS_REASON="1000,'Success',2000,'FAIL',3000,'Cancelled',4000,'Assignment',5000,'St. in Progress',6000,'St. Complete',9000,'Error'"


function compare_ts(col_data,operator,dateString) 
	compare_ts=""&col_data&operator&" (("&dateString&"-to_date('19700101 000000','YYYYMMDD HH24MISS'))*86400)"
end function

function makeTimeStamp(dateString)
	makeTimeStamp="(("&dateString&"-to_date('19700101 000000','YYYYMMDD HH24MISS'))*86400)"
end function

function makeTimeStampToDay()
	makeTimeStampToDay="((Trunc(SYSDATE)+1-to_date('19700101 000000','YYYYMMDD HH24MISS'))*86400)"
end function

'------------------------------------------------
function GetTime(nom_col)
	GetTime="to_char((timestamp '1970-01-01 00:00:00 GMT'+numtodsinterval("&nom_col&",'SECOND')) at time zone SESSIONTIMEZONE,'YYYY-MM-DD HH24:MI')"
end function

function GetTimeFull(nom_col)
	GetTimeFull="to_char((timestamp '1970-01-01 00:00:00 GMT'+numtodsinterval("&nom_col&",'SECOND')) at time zone SESSIONTIMEZONE,'YYYY-MM-DD HH24:MI:SS')"
end function


sub doHeaders(rs)
	dim imax,icount
	imax=RS.fields.count -1
	dim fieldname
	' a dupliquer en fin de tableau
	response.write "<thead><tr>"
	For Icount=0 to imax
		response.write "<th>"&RS.fields(Icount).name&"</th>"
	next
	response.write "</tr></thead>"&vbcrlf
end sub


sub doData(rs)
	dim imax,icount
	imax=RS.fields.count -1
	response.write "<tbody>"
	Do until rs.EOF 
		response.write "<tr>"
		for icount=0 to imax 
			response.write "<td>"&rs.fields(icount)&"</td>"
		next 
		
		response.write "</tr>"&vbcrlf
		rs.MoveNext 'next
	Loop 
	response.write "</tbody>"
end sub



sub makeQuery (connection, sql,teams, classes, title )
	dim it, rs, command, param
	Set command = Server.CreateObject("ADODB.Command")
	command.ActiveConnection = connection
	command.CommandTimeout=120
	command.CommandText=sql
	command.Prepared = True
	command.CommandType = adCmdText
	Set param=command.CreateParameter("team",adChar,adParamInput,48,"")
	command.parameters.append param
	
	%>
<!--<div class="box">
<h2><%=title%></h2> -->
	<%
'	for it=0 to ubound(teams)
'		command("team")=teams(it) 
		command("team")=team
%>
		<div class="subbox" >
		<h3><%=team&", "&title %></h3>
		<div class="<%=classes%>" style="display:none">
			<button class="showSQL">Show query</button>
			<button class="showTable">Show table</button>
			<div class="sqlContainer">
				<code style="display:none"><%=sql%></code>
			</div>
			<div class="dataContainer">
			<table style="display:none">
<%
		'response.write sql
		set rs=command.execute()
		doHeaders(rs)
		doData(rs)
		rs.close
%>
			</table>
			</div>
		</div>
	</div>
<%
	'Next
%>
<!--	</div>--><!-- box -->
<%
end sub


sub makeReport 
	dim dbEnv,connection,team
	set dbEnv=new DatabaseEnv
	dbEnv.init("N")
	dbEnv.open 
	dbEnv.securityQuery SECURITY_USER
	connection = dbEnv.getConnection
%>
<h2>Change count</h2>
<%
', avg() avg_, stddev() sd_ 
'obsolete query
sql = "select template, closure_month,count(*) count_points, round(avg(end_to_end_DURATION)/86400,3) AVG_END_TO_END_DURATION, round(stddev(end_to_end_DURATION)/86400,3) SD_END_TO_END_DURATION, round(avg(pre_duration)/86400,3) avg_PRE_DURATION, round(stddev(pre_duration)/86400,3) sd_pre_duration, round(avg(actual_duration)/86400,3) avg_actual_duration, round(avg(MAIN_DURATION)/86400,3) avg_MAIN_DURATION, round(stddev(MAIN_DURATION)/86400,3) sd_MAIN_DURATION, round(avg(POST_DURATION)/86400,3) avg_POST_DURATION, round(stddev(POST_DURATION)/86400,3) sd_POST_DURATION FROM "&_
	"( select CHG.Z1D_TEMPLATE_NAME TEMPLATE, to_char((timestamp '1970-01-01 00:00:00 GMT'+numtodsinterval(CHG.CLOSED_DATE,'SECOND')) at time zone 'CET','YYYY-MM-MON') CLOSURE_MONTH, "&_
	" CHG.CLOSED_DATE-CHG.SUBMIT_DATE END_TO_END_DURATION, CHG.SCHEDULED_DATE-CHG.RFC_DATE PRE_DURATION, CHG.ACTUAL_END_DATE-CHG.ACTUAL_START_DATE ACTUAL_DURATION, COMPLETED_DATE-CHG.RFC_DATE MAIN_DURATION, CHG.CLOSED_DATE-CHG.COMPLETED_DATE POST_DURATION "&_
	"FROM "&dbEnv.schema1&".CHG_INFRASTRUCTURE_CHANGE CHG "&_
	"WHERE CHANGE_REQUEST_STATUS=11 AND CHG.SUPPORT_GROUP_NAME=? and CHG.Z1D_TEMPLATE_NAME like 'WW%TT5%'  AND " & compare_ts( "CHG.CLOSED_DATE",">","to_date('20130901 000000','YYYYMMDD HH24MISS')") &_
") x GROUP BY template,closure_month order by 1,2,3"
'''''''''''''''''''''''''''''''''''''''''''''''''''''''

sql = "SELECT REGION, STATUS, AGE, count(*) COUNT from ("&_
	"SELECT REGION, STATUS X_STATUS,decode(STATUS,"&LIST_CRQ_STATUS&",STATUS) STATUS, CASE WHEN AGE<4 THEN AGE WHEN AGE<8 THEN 4 WHEN AGE<13 THEN 8 WHEN AGE<17 THEN 13 WHEN AGE<21 THEN 17 WHEN AGE<41 THEN 21 ELSE 41 END AGE FROM ("&_
	"SELECT CASE WHEN nvl(rr.region,CHG.LOCATION_COMPANY) like '%EMEA%' THEN 'EMEA' WHEN CHG.REGION like '%EMEA%' THEN 'EMEA' WHEN nvl(rr.region,CHG.LOCATION_COMPANY) like '%AMER%' THEN 'AMER' WHEN CHG.REGION like '%AMER%' THEN 'AMER' WHEN nvl(rr.region,CHG.LOCATION_COMPANY) like '%APAC%' THEN 'APAC' WHEN CHG.REGION like '%APAC%' THEN 'APAC' ELSE 'NO RSD' END REGION, CHG.CHANGE_REQUEST_STATUS status, "&_
	"FLOOR(("&makeTimeStampToDay()&"-COALESCE(CHG.COMPLETED_DATE,CHG.SCHEDULED_DATE,CHG.SFA_DATE, CHG.SFR_DATE,RFC_DATE,RFA_DATE,CHG.SUBMIT_DATE))/604800) AGE "&_
	"FROM "&dbEnv.schema1&".CHG_INFRASTRUCTURE_CHANGE CHG LEFT JOIN "&dbEnv.schema2&".REF_REGION rr ON (chg.REGION=rr.country) WHERE CHG.CHANGE_REQUEST_STATUS not in (11,12) AND CHG.SUPPORT_GROUP_NAME=? "&_
")) GROUP BY REGION,STATUS, X_STATUS, AGE ORDER BY REGION, X_STATUS, AGE"
makeQuery connection, sql, team, "graphMe3", "Current Number of open change by RSD, status"


sql = "SELECT REGION, decode(STATUS,"&LIST_CRQ_STATUS&",STATUS) STATUS, decode(STATUS_REASON,"&LIST_CRQ_REASON&",STATUS_REASON) STATUS_REASON, COUNT from ("&_
	"SELECT REGION, STATUS, STATUS_REASON, count(*) COUNT FROM ( "&_
	"SELECT CASE WHEN nvl(rr.region,CHG.LOCATION_COMPANY) like '%EMEA%' THEN 'EMEA' WHEN CHG.REGION like '%EMEA%' THEN 'EMEA' WHEN nvl(rr.region,CHG.LOCATION_COMPANY) like '%AMER%' THEN 'AMER' WHEN CHG.REGION like '%AMER%' THEN 'AMER' WHEN nvl(rr.region,CHG.LOCATION_COMPANY) like '%APAC%' THEN 'APAC' WHEN CHG.REGION like '%APAC%' THEN 'APAC' ELSE 'NO RSD' END REGION,CHG.CHANGE_REQUEST_STATUS STATUS, CHG.STATUS_REASON FROM "&dbEnv.schema1&".CHG_INFRASTRUCTURE_CHANGE CHG LEFT JOIN "&dbEnv.schema2&".REF_REGION rr ON (chg.REGION=rr.country) WHERE CHG.CHANGE_REQUEST_STATUS in (11,12) AND CHG.SUPPORT_GROUP_NAME=? "&_
") GROUP BY REGION,STATUS, STATUS_REASON  ORDER BY REGION, STATUS, STATUS_REASON )"
makeQuery connection, sql, team, "graphMe3b", "Current Number of closed change by RSD, status, status reason"

%>
</div>
<div class="box">
<h2>Changes sumitted</h2>
<%

sql = " SELECT ad.dbegin, NVL(MANAGER, 0) MANAGER, NVL (total, 0) TOTAL, ad.dbegin || ' to ' || ad.dend interval FROM (SELECT TO_CHAR (DR, 'YYYY-MM') dw, TO_CHAR (DR, 'YYYY-MM-DD') dbegin, TO_CHAR (LAST_DAY (DR), 'YYYY-MM-DD') dend FROM ( SELECT ADD_MONTHS (TRUNC (SYSDATE, 'MM'), LEVEL - "&NUMBER_MONTH&") AS dr FROM DUAL CONNECT BY LEVEL <= "&NUMBER_MONTH&")) ad LEFT JOIN ( SELECT SUBMIT_MONTH, SUM (MANAGER) MANAGER, COUNT (*) total FROM (SELECT TO_CHAR ( ( TIMESTAMP '1970-01-01 00:00:00 GMT' + NUMTODSINTERVAL (CHG.SUBMIT_DATE, 'SECOND')) AT TIME ZONE 'CET', 'YYYY-MM') SUBMIT_MONTH, CASE WHEN CHG.SUPPORT_GROUP_NAME = ? THEN 1 ELSE 0 END MANAGER FROM "&dbEnv.schema1&".CHG_INFRASTRUCTURE_CHANGE CHG WHERE CHG.CHANGE_REQUEST_STATUS > 2 AND CHG.SUBMIT_DATE > ( ( ADD_MONTHS ( TRUNC (SYSDATE, 'MM'), 1 - "&NUMBER_MONTH&") - TO_DATE ('19700101 000000', 'YYYYMMDD HH24MISS')) * 86400)) GROUP BY SUBMIT_MONTH) dt ON ad.dw = dt.SUBMIT_MONTH ORDER BY 1"
'makeQuery connection, sql, team, "graphMe6", "Weigth of this team in global change management - ALL RSD"

'MONTH ALL RSD 

sql = "select ad.dbegin, nvl(dra,0) ""Draft - unapproved"", nvl(pip,0) ""Planning in progress"", nvl(sch,0) ""Scheduled for Review/approval"", nvl(iip,0) ""Scheduled, Implementation"", nvl(pen,0) ""Pending"", nvl(rej,0) ""Rejected"", nvl(com,0) ""Completed"", nvl(clo,0) ""Closed"", nvl(can,0) ""Cancelled"", nvl(INI,0) ""INIT"", nvl(EMER,0) ""Emergency"",nvl(AMTF,0) AMTF,  nvl(total,0) ""Total"",ad.dbegin||' to '||ad.dend interval from ("&_
	"select to_char(DR,'YYYY-MM') dw,to_char(DR,'YYYY-MM-DD') dbegin, to_char(LAST_DAY(DR),'YYYY-MM-DD') dend FROM(SELECT ADD_MONTHS(trunc(SYSDATE,'MM'),LEVEL-"&NUMBER_MONTH&") AS dr FROM DUAL CONNECT BY LEVEL<="&NUMBER_MONTH&")) ad LEFT JOIN ("&_
"select SUBMIT_WEEK, sum(dra)+sum(rfa)+sum(rfc) dra, sum(PIP) pip, sum(SFR)+sum(SFA) sch, sum(SCH)+sum(IIP) iip,sum(PEN) pen, sum(REJ) rej, sum(COM) com, sum(CLO) clo, sum(CAN) can, sum(INIT) ini, sum(EMER) EMER, sum(AMTF) AMTF, count(*) total from ("&_
	"SELECT to_char((timestamp '1970-01-01 00:00:00 GMT'+numtodsinterval(CHG.SUBMIT_DATE,'SECOND')) at time zone 'CET','YYYY-MM') SUBMIT_WEEK,"&_
	"CASE WHEN CHG.CHANGE_REQUEST_STATUS=0 then 1 else 0 end dra,"&_
	"CASE WHEN CHG.CHANGE_REQUEST_STATUS=1 then 1 else 0 end RFA,"&_
	"CASE WHEN CHG.CHANGE_REQUEST_STATUS=2 then 1 else 0 end RFC,"&_
	"CASE WHEN CHG.CHANGE_REQUEST_STATUS=3 then 1 else 0 end PIP,"&_
	"CASE WHEN CHG.CHANGE_REQUEST_STATUS=4 then 1 else 0 end SFR,"&_
	"CASE WHEN CHG.CHANGE_REQUEST_STATUS=5 then 1 else 0 end SFA,"&_
	"CASE WHEN CHG.CHANGE_REQUEST_STATUS=6 then 1 else 0 end SCH,"&_
	"CASE WHEN CHG.CHANGE_REQUEST_STATUS=7 then 1 else 0 end IIP,"&_
	"CASE WHEN CHG.CHANGE_REQUEST_STATUS=8 then 1 else 0 end PEN,"&_
	"CASE WHEN CHG.CHANGE_REQUEST_STATUS=9 then 1 else 0 end REJ,"&_
	"CASE WHEN CHG.CHANGE_REQUEST_STATUS=10 then 1 else 0 end COM,"&_
	"CASE WHEN CHG.CHANGE_REQUEST_STATUS=11 then 1 else 0 end CLO,"&_
	"CASE WHEN CHG.CHANGE_REQUEST_STATUS=12 then 1 else 0 end CAN,"&_
	"CASE WHEN CHG.SUBMITTER = 'Remedy Application Service' AND CHG.ASGRP='CM-WW-OP2-CHANGE_COORDINATION' then 1 else 0 end INIT,"&_
	"CASE WHEN CHG.change_timing=1000 then 1 else 0 end EMER,"&_
	"CASE WHEN upper(CHG.DESCRIPTION) like '%AMTF%' then 1 else 0 end AMTF FROM "&dbEnv.schema1&".CHG_INFRASTRUCTURE_CHANGE CHG WHERE CHG.SUPPORT_GROUP_NAME=? AND "& compare_ts("CHG.SUBMIT_DATE",">","ADD_MONTHS(Trunc(SYSDATE,'MM'),1-"&NUMBER_MONTH&")") &_
") GROUP BY submit_week ) dt on ad.dw=dt.submit_week order by 1"
makeQuery connection, sql, team, "graphMe1", "Change status based on submit date, grouped by submit month, all RSD"

'WEEK ALL RSD

sql = "select ad.dbegin, nvl(dra,0) ""Draft - unapproved"", nvl(pip,0) ""Planning in progress"", nvl(sch,0) ""Scheduled for Review/approval"", nvl(iip,0) ""Scheduled, Implementation"", nvl(pen,0) ""Pending"", nvl(rej,0) ""Rejected"", nvl(com,0) ""Completed"", nvl(clo,0) ""Closed"", nvl(can,0) ""Cancelled"", nvl(INI,0) ""INIT"", nvl(EMER,0) ""Emergency"",nvl(AMTF,0) AMTF, nvl(total,0) ""Total"",ad.dbegin||' to '||ad.dend interval from ("&_
	"select to_char(DR,'IYYY-IW') dw,to_char(DR,'YYYY-MM-DD') dbegin,to_char(DR+6,'YYYY-MM-DD') dend FROM(SELECT Trunc(SYSDATE+(7*(LEVEL-"&NUMBER_WEEK&")),'IW') AS dr FROM DUAL CONNECT BY LEVEL<="&NUMBER_WEEK&")) ad LEFT JOIN ("&_
"select SUBMIT_WEEK, sum(dra)+sum(rfa)+sum(rfc) dra, sum(PIP) pip, sum(SFR)+sum(SFA) sch, sum(SCH)+sum(IIP) iip,sum(PEN) pen, sum(REJ) rej, sum(COM) com, sum(CLO) clo, sum(CAN) can, sum(INIT) ini, sum(EMER) EMER,sum(AMTF) AMTF, count(*) total from ("&_
	"SELECT to_char((timestamp '1970-01-01 00:00:00 GMT'+numtodsinterval(CHG.SUBMIT_DATE,'SECOND')) at time zone 'CET','YYYY-IW') SUBMIT_WEEK,"&_
	"CASE WHEN CHG.CHANGE_REQUEST_STATUS=0 then 1 else 0 end dra,"&_
	"CASE WHEN CHG.CHANGE_REQUEST_STATUS=1 then 1 else 0 end RFA,"&_
	"CASE WHEN CHG.CHANGE_REQUEST_STATUS=2 then 1 else 0 end RFC,"&_
	"CASE WHEN CHG.CHANGE_REQUEST_STATUS=3 then 1 else 0 end PIP,"&_
	"CASE WHEN CHG.CHANGE_REQUEST_STATUS=4 then 1 else 0 end SFR,"&_
	"CASE WHEN CHG.CHANGE_REQUEST_STATUS=5 then 1 else 0 end SFA,"&_
	"CASE WHEN CHG.CHANGE_REQUEST_STATUS=6 then 1 else 0 end SCH,"&_
	"CASE WHEN CHG.CHANGE_REQUEST_STATUS=7 then 1 else 0 end IIP,"&_
	"CASE WHEN CHG.CHANGE_REQUEST_STATUS=8 then 1 else 0 end PEN,"&_
	"CASE WHEN CHG.CHANGE_REQUEST_STATUS=9 then 1 else 0 end REJ,"&_
	"CASE WHEN CHG.CHANGE_REQUEST_STATUS=10 then 1 else 0 end COM,"&_
	"CASE WHEN CHG.CHANGE_REQUEST_STATUS=11 then 1 else 0 end CLO,CASE WHEN CHG.CHANGE_REQUEST_STATUS=12 then 1 else 0 end CAN,"&_
	"CASE WHEN CHG.SUBMITTER = 'Remedy Application Service' AND CHG.ASGRP='CM-WW-OP2-CHANGE_COORDINATION' then 1 else 0 end INIT,"&_
	"CASE WHEN CHG.change_timing=1000 then 1 else 0 end EMER, CASE WHEN upper(CHG.DESCRIPTION) like '%AMTF%' then 1 else 0 end AMTF FROM "&dbEnv.schema1&".CHG_INFRASTRUCTURE_CHANGE CHG WHERE CHG.SUPPORT_GROUP_NAME=? AND "& compare_ts("CHG.SUBMIT_DATE",">","Trunc(SYSDATE+(7*(1-"&NUMBER_WEEK&")),'IW')") &_
") GROUP BY submit_week ) dt on ad.dw=dt.submit_week order by 1"

makeQuery connection, sql, team, "graphMe1", "Change status based on submit date, grouped by submit week, all RSD "


'MONTH EMEA 

sql = "select ad.dbegin, nvl(dra,0) ""Draft - unapproved"", nvl(pip,0) ""Planning in progress"", nvl(sch,0) ""Scheduled for Review/approval"", nvl(iip,0) ""Scheduled, Implementation"", nvl(pen,0) ""Pending"", nvl(rej,0) ""Rejected"", nvl(com,0) ""Completed"", nvl(clo,0) ""Closed"", nvl(can,0) ""Cancelled"", nvl(INI,0) ""INIT"", nvl(EMER,0) ""Emergency"",nvl(AMTF,0) AMTF,  nvl(total,0) ""Total"",ad.dbegin||' to '||ad.dend interval from ("&_
	"select to_char(DR,'YYYY-MM') dw,to_char(DR,'YYYY-MM-DD') dbegin, to_char(LAST_DAY(DR),'YYYY-MM-DD') dend FROM(SELECT ADD_MONTHS(trunc(SYSDATE,'MM'),LEVEL-"&NUMBER_MONTH&") AS dr FROM DUAL CONNECT BY LEVEL<="&NUMBER_MONTH&")) ad LEFT JOIN ("&_
"select SUBMIT_WEEK, sum(dra)+sum(rfa)+sum(rfc) dra, sum(PIP) pip, sum(SFR)+sum(SFA) sch, sum(SCH)+sum(IIP) iip,sum(PEN) pen, sum(REJ) rej, sum(COM) com, sum(CLO) clo, sum(CAN) can, sum(INIT) ini, sum(EMER) EMER, sum(AMTF) AMTF, count(*) total from ("&_
	"SELECT to_char((timestamp '1970-01-01 00:00:00 GMT'+numtodsinterval(CHG.SUBMIT_DATE,'SECOND')) at time zone 'CET','IYYY-MM') SUBMIT_WEEK,"&_
	"CASE WHEN CHG.CHANGE_REQUEST_STATUS=0 then 1 else 0 end dra,"&_
	"CASE WHEN CHG.CHANGE_REQUEST_STATUS=1 then 1 else 0 end RFA,"&_
	"CASE WHEN CHG.CHANGE_REQUEST_STATUS=2 then 1 else 0 end RFC,"&_
	"CASE WHEN CHG.CHANGE_REQUEST_STATUS=3 then 1 else 0 end PIP,"&_
	"CASE WHEN CHG.CHANGE_REQUEST_STATUS=4 then 1 else 0 end SFR,"&_
	"CASE WHEN CHG.CHANGE_REQUEST_STATUS=5 then 1 else 0 end SFA,"&_
	"CASE WHEN CHG.CHANGE_REQUEST_STATUS=6 then 1 else 0 end SCH,"&_
	"CASE WHEN CHG.CHANGE_REQUEST_STATUS=7 then 1 else 0 end IIP,"&_
	"CASE WHEN CHG.CHANGE_REQUEST_STATUS=8 then 1 else 0 end PEN,"&_
	"CASE WHEN CHG.CHANGE_REQUEST_STATUS=9 then 1 else 0 end REJ,"&_
	"CASE WHEN CHG.CHANGE_REQUEST_STATUS=10 then 1 else 0 end COM,"&_
	"CASE WHEN CHG.CHANGE_REQUEST_STATUS=11 then 1 else 0 end CLO,"&_
	"CASE WHEN CHG.CHANGE_REQUEST_STATUS=12 then 1 else 0 end CAN,"&_
	"CASE WHEN CHG.SUBMITTER = 'Remedy Application Service' AND CHG.ASGRP='CM-WW-OP2-CHANGE_COORDINATION' then 1 else 0 end INIT,"&_
	"CASE WHEN CHG.change_timing=1000 then 1 else 0 end EMER, CASE WHEN upper(CHG.DESCRIPTION) like '%AMTF%' then 1 else 0 end AMTF FROM "&dbEnv.schema1&".CHG_INFRASTRUCTURE_CHANGE CHG LEFT JOIN "&dbEnv.schema2&".REF_REGION rr ON (chg.REGION=rr.country) WHERE CHG.SUPPORT_GROUP_NAME=? AND "& compare_ts("CHG.SUBMIT_DATE",">","ADD_MONTHS(Trunc(SYSDATE,'MM'),1-"&NUMBER_MONTH&")") &" AND (nvl(rr.region,CHG.LOCATION_COMPANY) like '%EMEA%' OR CHG.REGION like '%EMEA%')"&_
") GROUP BY submit_week ) dt on ad.dw=dt.submit_week order by 1" 
makeQuery connection, sql, team, "graphMe1", "Change status based on submit date, grouped by submit month - RSD EMEA only "




sql = "select ad.dw, nvl(dra,0) ""Draft - unapproved"", nvl(pip,0) ""Planning in progress"", nvl(sch,0) ""Scheduled for Review/approval"", nvl(iip,0) ""Scheduled, Implementation"", nvl(pen,0) ""Pending"", nvl(rej,0) ""Rejected"", nvl(com,0) ""Completed"", nvl(clo,0) ""Closed"", nvl(can,0) ""Cancelled"", nvl(INI,0) ""INIT"", nvl(EMER,0) ""Emergency"",nvl(AMTF,0) AMTF, nvl(total,0) ""Total"",ad.dbegin||' to '||ad.dend interval from ("&_
	"select to_char(DR,'IYYY-IW') dw,to_char(DR,'YYYY-MM-DD') dbegin,to_char(DR+6,'YYYY-MM-DD') dend FROM(SELECT Trunc(SYSDATE+(7*(LEVEL-"&NUMBER_WEEK&")),'IW') AS dr FROM DUAL CONNECT BY LEVEL <="&NUMBER_WEEK&")) ad LEFT JOIN ("&_
"select SUBMIT_WEEK, sum(dra)+sum(rfa)+sum(rfc) dra, sum(PIP) pip, sum(SFR)+sum(SFA) sch, sum(SCH)+sum(IIP) iip,sum(PEN) pen, sum(REJ) rej, sum(COM) com, sum(CLO) clo, sum(CAN) can, sum(INIT) ini, sum(EMER) EMER,sum(AMTF) AMTF, count(*) total from ("&_
	"SELECT to_char((timestamp '1970-01-01 00:00:00 GMT'+numtodsinterval(CHG.SUBMIT_DATE,'SECOND')) at time zone 'CET','IYYY-IW') SUBMIT_WEEK,"&_
	"CASE WHEN CHG.CHANGE_REQUEST_STATUS=0 then 1 else 0 end dra,"&_
	"CASE WHEN CHG.CHANGE_REQUEST_STATUS=1 then 1 else 0 end RFA,"&_
	"CASE WHEN CHG.CHANGE_REQUEST_STATUS=2 then 1 else 0 end RFC,"&_
	"CASE WHEN CHG.CHANGE_REQUEST_STATUS=3 then 1 else 0 end PIP,"&_
	"CASE WHEN CHG.CHANGE_REQUEST_STATUS=4 then 1 else 0 end SFR,"&_
	"CASE WHEN CHG.CHANGE_REQUEST_STATUS=5 then 1 else 0 end SFA,"&_
	"CASE WHEN CHG.CHANGE_REQUEST_STATUS=6 then 1 else 0 end SCH,"&_
	"CASE WHEN CHG.CHANGE_REQUEST_STATUS=7 then 1 else 0 end IIP,"&_
	"CASE WHEN CHG.CHANGE_REQUEST_STATUS=8 then 1 else 0 end PEN,"&_
	"CASE WHEN CHG.CHANGE_REQUEST_STATUS=9 then 1 else 0 end REJ,"&_
	"CASE WHEN CHG.CHANGE_REQUEST_STATUS=10 then 1 else 0 end COM,"&_
	"CASE WHEN CHG.CHANGE_REQUEST_STATUS=11 then 1 else 0 end CLO,"&_
	"CASE WHEN CHG.CHANGE_REQUEST_STATUS=12 then 1 else 0 end CAN,"&_
	"CASE WHEN CHG.SUBMITTER = 'Remedy Application Service' AND CHG.ASGRP='CM-WW-OP2-CHANGE_COORDINATION' then 1 else 0 end INIT,"&_
	"CASE WHEN CHG.change_timing=1000 then 1 else 0 end EMER, CASE WHEN upper(CHG.DESCRIPTION) like '%AMTF%' then 1 else 0 end AMTF FROM "&dbEnv.schema1&".CHG_INFRASTRUCTURE_CHANGE CHG LEFT JOIN "&dbEnv.schema2&".REF_REGION rr ON (chg.REGION=rr.country) WHERE CHG.SUPPORT_GROUP_NAME=? AND "& compare_ts("CHG.SUBMIT_DATE",">","Trunc(SYSDATE+(7*(1-"&NUMBER_WEEK&")),'IW')") &" AND (nvl(rr.region,CHG.LOCATION_COMPANY) like '%EMEA%' OR CHG.REGION like '%EMEA%')"&_
") GROUP BY submit_week ) dt on ad.dw=dt.submit_week order by 1" 
makeQuery connection, sql, team, "graphMe1", "Change status based on submit date, grouped by submit week - RSD EMEA only "

%>
</div>
<div class="box">
<h2>Changes closed or cancelled</h2>
<%
sql = "select ad.dw, nvl(clo,0) ""Closed"", nvl(can,0) ""Cancelled"", nvl(INI,0) ""INIT"", nvl(EMER,0) ""Emergency"",nvl(AMTF,0) AMTF, nvl(total,0) ""Total"",ad.dbegin||' to '||ad.dend interval from ("&_
	"select to_char(DR,'IYYY-IW') dw,to_char(DR,'YYYY-MM-DD') dbegin,to_char(DR+6,'YYYY-MM-DD') dend FROM(SELECT Trunc(SYSDATE+(7*(LEVEL-"&NUMBER_WEEK&")),'IW') AS dr FROM DUAL CONNECT BY LEVEL <="&NUMBER_WEEK&")) ad LEFT JOIN ("&_
"select MOD_WEEK, sum(CLO) clo, sum(CAN) can, sum(INIT) ini, sum(EMER) EMER,sum(AMTF) AMTF, count(*) total from ("&_
	"SELECT to_char((timestamp '1970-01-01 00:00:00 GMT'+numtodsinterval(CHG.LAST_MODIFIED_DATE,'SECOND')) at time zone 'CET','IYYY-IW') MOD_WEEK,"&_
	"CASE WHEN CHG.CHANGE_REQUEST_STATUS=11 then 1 else 0 end CLO,"&_
	"CASE WHEN CHG.CHANGE_REQUEST_STATUS=12 then 1 else 0 end CAN,"&_
	"CASE WHEN CHG.SUBMITTER = 'Remedy Application Service' AND CHG.ASGRP='CM-WW-OP2-CHANGE_COORDINATION' then 1 else 0 end INIT,"&_
	"CASE WHEN CHG.change_timing=1000 then 1 else 0 end EMER,"&_
	"CASE WHEN upper(CHG.DESCRIPTION) like '%AMTF%' then 1 else 0 end AMTF FROM "&dbEnv.schema1&".CHG_INFRASTRUCTURE_CHANGE CHG WHERE CHG.CHANGE_REQUEST_STATUS in (11,12) AND CHG.SUPPORT_GROUP_NAME=? AND "& compare_ts("CHG.LAST_MODIFIED_DATE",">","Trunc(SYSDATE+(7*(1-"&NUMBER_WEEK&")),'IW')") &_
") GROUP BY MOD_WEEK) dt on ad.dw=dt.MOD_WEEK order by 1" 
makeQuery connection, sql, team, "graphMe2", "Closure and cancellation statistics based on last modified date - All RSD "


sql = "select ad.dw, nvl(clo,0) ""Closed"", nvl(can,0) ""Cancelled"", nvl(INI,0) ""INIT"", nvl(EMER,0) ""Emergency"",nvl(AMTF,0) AMTF, nvl(total,0) ""Total"",ad.dbegin||' to '||ad.dend interval from ("&_
	"select to_char(DR,'IYYY-IW') dw,to_char(DR,'YYYY-MM-DD') dbegin,to_char(DR+6,'YYYY-MM-DD') dend FROM(SELECT Trunc(SYSDATE+(7*(LEVEL-"&NUMBER_WEEK&")),'IW') AS dr FROM DUAL CONNECT BY LEVEL <="&NUMBER_WEEK&")) ad LEFT JOIN ("&_
"select MOD_WEEK, sum(CLO) clo, sum(CAN) can, sum(INIT) ini, sum(EMER) EMER,sum(AMTF) AMTF, count(*) total from ("&_
	"SELECT to_char((timestamp '1970-01-01 00:00:00 GMT'+numtodsinterval(CHG.LAST_MODIFIED_DATE,'SECOND')) at time zone 'CET','IYYY-IW') MOD_WEEK,"&_
	"CASE WHEN CHG.CHANGE_REQUEST_STATUS=11 then 1 else 0 end CLO,"&_
	"CASE WHEN CHG.CHANGE_REQUEST_STATUS=12 then 1 else 0 end CAN,"&_
	"CASE WHEN CHG.SUBMITTER='Remedy Application Service' AND CHG.ASGRP='CM-WW-OP2-CHANGE_COORDINATION' then 1 else 0 end INIT,"&_
	"CASE WHEN CHG.change_timing=1000 then 1 else 0 end EMER, CASE WHEN upper(CHG.DESCRIPTION) like '%AMTF%' then 1 else 0 end AMTF FROM "&dbEnv.schema1&".CHG_INFRASTRUCTURE_CHANGE CHG LEFT JOIN "&dbEnv.schema2&".REF_REGION rr ON (chg.REGION=rr.country) WHERE CHG.CHANGE_REQUEST_STATUS in (11,12) AND CHG.SUPPORT_GROUP_NAME=? AND "& compare_ts("CHG.LAST_MODIFIED_DATE",">","Trunc(SYSDATE+(7*(1-"&NUMBER_WEEK&")),'IW')") &" AND (nvl(rr.region,CHG.LOCATION_COMPANY) like '%EMEA%' OR CHG.REGION like '%EMEA%')"&_
") GROUP BY MOD_WEEK) dt on ad.dw=dt.MOD_WEEK order by 1" 
makeQuery connection, sql, team, "graphMe2", "Closure and cancellation statistics based on last modified date - RSD EMEA only"	


%>
</div>
<div class="box">
<h2>INIT OVERVIEW</h2>
<%
sql = "select ad.dw, nvl(INI_S,0) INIT_GOOD, nvl(INI_R,0) INIT_REGULAR, nvl(INI_B,0) INIT_BAD, nvl(INI_N,0) NON_INIT, nvl(INI_N+INI_B,0) MANAGED, nvl(total,0) TOTAL,ad.dbegin||' to '||ad.dend interval from ("&_
	"select to_char(DR,'IYYY-IW') dw,to_char(DR,'YYYY-MM-DD') dbegin, to_char(DR+6,'YYYY-MM-DD') dend FROM(SELECT Trunc(SYSDATE+(7*(LEVEL-"&NUMBER_WEEK&")),'IW') AS dr FROM DUAL CONNECT BY LEVEL <="&NUMBER_WEEK&")) ad LEFT JOIN ("&_
"select MOD_WEEK, sum(INI_R) INI_R, sum(INI_S) INI_S, sum(INI_B) INI_B, sum(INI_N) INI_N, count(*) total from ("&_
	"SELECT to_char((timestamp '1970-01-01 00:00:00 GMT'+numtodsinterval(CHG.SUBMIT_DATE,'SECOND')) at time zone 'CET','IYYY-IW') MOD_WEEK,"&_
	"CASE WHEN CHG.SUBMITTER='Remedy Application Service' AND CHG.ASGRP='CM-WW-OP2-CHANGE_COORDINATION' AND CHG.CHANGE_TIMING=6000 then 1 else 0 end INI_S,"&_
	"CASE WHEN CHG.SUBMITTER='Remedy Application Service' AND CHG.ASGRP='CM-WW-OP2-CHANGE_COORDINATION' AND CHG.CHANGE_TIMING<>6000 then 1 else 0 end INI_R,"&_
	"CASE WHEN CHG.SUBMITTER<>'Remedy Application Service' then 1 else 0 end INI_N,"&_
	"CASE WHEN CHG.SUBMITTER='Remedy Application Service' AND CHG.ASGRP<>'CM-WW-OP2-CHANGE_COORDINATION' then 1 else 0 end INI_B FROM "&dbEnv.schema1&".CHG_INFRASTRUCTURE_CHANGE CHG WHERE CHG.SUPPORT_GROUP_NAME=? AND "& compare_ts("CHG.SUBMIT_DATE",">","Trunc(SYSDATE+(7*(1-"&NUMBER_WEEK&")),'IW')") &_
") GROUP BY MOD_WEEK) dt on ad.dw=dt.MOD_WEEK order by 1" 
makeQuery connection, sql, team, "graphMe4", "Badly configured service request+escalated service request - ALL RSD"

sql = "select ad.dw, nvl(INI_S,0) INIT_GOOD, nvl(INI_R,0) INIT_REGULAR, nvl(INI_B,0) INIT_BAD, nvl(INI_N,0) NON_INIT, nvl(INI_N+INI_B,0) MANAGED, nvl(total,0) TOTAL,ad.dbegin||' to '||ad.dend interval from ("&_
	"select to_char(DR,'IYYY-IW') dw,to_char(DR,'YYYY-MM-DD') dbegin, to_char(DR+6,'YYYY-MM-DD') dend FROM(SELECT Trunc(SYSDATE+(7*(LEVEL-"&NUMBER_WEEK&")),'IW') AS dr FROM DUAL CONNECT BY LEVEL <="&NUMBER_WEEK&")) ad LEFT JOIN ("&_
"select MOD_WEEK, sum(INI_R) INI_R, sum(INI_S) INI_S, sum(INI_B) INI_B, sum(INI_N) INI_N, count(*) total from ("&_
	"SELECT to_char((timestamp '1970-01-01 00:00:00 GMT'+numtodsinterval(CHG.SUBMIT_DATE,'SECOND')) at time zone 'CET','IYYY-IW') MOD_WEEK,"&_
	"CASE WHEN CHG.SUBMITTER='Remedy Application Service' AND CHG.ASGRP='CM-WW-OP2-CHANGE_COORDINATION' AND CHG.CHANGE_TIMING=6000 then 1 else 0 end INI_S,"&_
	"CASE WHEN CHG.SUBMITTER='Remedy Application Service' AND CHG.ASGRP='CM-WW-OP2-CHANGE_COORDINATION' AND CHG.CHANGE_TIMING<>6000 then 1 else 0 end INI_R,"&_
	"CASE WHEN CHG.SUBMITTER<>'Remedy Application Service' then 1 else 0 end INI_N,"&_
	"CASE WHEN CHG.SUBMITTER='Remedy Application Service' AND CHG.ASGRP<>'CM-WW-OP2-CHANGE_COORDINATION' then 1 else 0 end INI_B FROM "&dbEnv.schema1&".CHG_INFRASTRUCTURE_CHANGE CHG LEFT JOIN "&dbEnv.schema2&".REF_REGION rr ON (chg.REGION=rr.country) WHERE(nvl(rr.region,CHG.LOCATION_COMPANY) like '%EMEA%' OR CHG.REGION like '%EMEA%') AND CHG.SUPPORT_GROUP_NAME=? AND "& compare_ts("CHG.SUBMIT_DATE",">","Trunc(SYSDATE+(7*(1-"&NUMBER_WEEK&")),'IW')") &_
") GROUP BY MOD_WEEK) dt on ad.dw=dt.MOD_WEEK order by 1" 
makeQuery connection, sql, team, "graphMe4", "Badly configured service request+escalated service request - EMEA ONLY"


%>
</div>
<div class="box">
<h2>TASKS OVERVIEW</h2>
<%
Response.Flush 
sql = "select ad.dw, nvl(T_SUCCESS,0) T_SUCCESS, nvl(T_FAIL,0) T_FAIL, nvl(T_CANCEL,0) T_CANCEL, nvl(T_BYPASS,0) T_BYPASS, NVL (T_OTHER, 0) T_OTHER, nvl(total,0) TOTAL,ad.dbegin||' to '||ad.dend interval from ("&_
	"select to_char(DR,'IYYY-IW') dw,to_char(DR,'YYYY-MM-DD') dbegin, to_char(DR+6,'YYYY-MM-DD') dend FROM(SELECT Trunc(SYSDATE+(7*(LEVEL-"&NUMBER_WEEK&")),'IW') AS dr FROM DUAL CONNECT BY LEVEL <="&NUMBER_WEEK&")) ad LEFT JOIN ("&_
"select MOD_WEEK, sum(T_SUCCESS) T_SUCCESS, sum(T_FAIL) T_FAIL, sum(T_CANCEL) T_CANCEL, sum(T_BYPASS) T_BYPASS, SUM (T_OTHER) T_OTHER, count(*) total from ("&_
	"select to_char((timestamp '1970-01-01 00:00:00 GMT'+numtodsinterval(TSK.MODIFIED_DATE,'SECOND')) at time zone 'CET','IYYY-IW') MOD_WEEK, "&_
	"CASE WHEN TSK.status=6000 and TSK.STATUSREASONSELECTION=1000 THEN 1 ELSE 0 END T_SUCCESS,"&_
	"CASE WHEN TSK.status=6000 and TSK.STATUSREASONSELECTION=2000 THEN 1 ELSE 0 END T_FAIL,"&_
	"CASE WHEN TSK.status=6000 and TSK.STATUSREASONSELECTION=3000 THEN 1 ELSE 0 END T_CANCEL,"&_
	"CASE WHEN TSK.status=6000 and TSK.STATUSREASONSELECTION>3000 THEN 1 ELSE 0 END T_OTHER,"&_
	"CASE WHEN TSK.status=7000 THEN 1 ELSE 0 END T_BYPASS "&_
	"FROM "&dbEnv.schema1&".TMS_Task TSK "&_
	"WHERE TSK.status in (7000,6000) AND TSK.ASSIGNEE_GROUP=? AND "& compare_ts("TSK.MODIFIED_DATE",">","Trunc(SYSDATE+(7*(1-"&NUMBER_WEEK&")),'IW')") &_ 
") GROUP BY MOD_WEEK) dt on ad.dw=dt.MOD_WEEK order by 1" 

makeQuery connection, sql, team, "graphMe5", "Closed tasks assigned per week - all RSD"

sql = "SELECT REGION, STATUS, SUB_STATUS, AGE, count(*) COUNT from ("&_
	"SELECT REGION, STATUS,X_CHANGE_REQUEST_STATUS, CASE WHEN AGE<4 THEN AGE WHEN AGE<8 THEN 4 WHEN AGE<13 THEN 8 WHEN AGE<17 THEN 13 WHEN AGE<21 THEN 17 WHEN AGE<41 THEN 21 ELSE 41 END AGE FROM ("&_
	"SELECT ,CHANGE_REQUEST_STATUS  X_CHANGE_REQUEST_STATUS, CHG.CHANGE_REQUEST_STATUS STATUS, "&_
	"FLOOR(("&makeTimeStampToDay()&"-COALESCE(CHG.COMPLETED_DATE,CHG.SCHEDULED_DATE,CHG.SFA_DATE, CHG.SFR_DATE,RFC_DATE,RFA_DATE,CHG.SUBMIT_DATE))/604800) AGE "&_
	"FROM "&dbEnv.schema1&".CHG_INFRASTRUCTURE_CHANGE CHG LEFT JOIN "&dbEnv.schema2&".REF_REGION rr ON (chg.REGION=rr.country) WHERE CHG.CHANGE_REQUEST_STATUS not in (11,12) AND CHG.SUPPORT_GROUP_NAME=? "&_
")) GROUP BY REGION,X_CHANGE_REQUEST_STATUS,STATUS, AGE ORDER BY REGION, X_CHANGE_REQUEST_STATUS, AGE"
'makeQuery connection, sql, team, "graphMe3", "Current Number of open change by RSD, status"


sql=" SELECT REGION, DECODE (status, "&LIST_TAS_STATUS&", status) STATUS, DECODE (STATUSREASONSELECTION, "&LIST_TAS_REASON&", STATUSREASONSELECTION) SUB_STATUS,AGE, COUNT FROM (SELECT REGION, STATUS, STATUSREASONSELECTION,AGE, SUM (COUNT) COUNT FROM(SELECT CASE WHEN NVL (rr.region, X.LOCATION_COMPANY) LIKE '%EMEA%' THEN 'EMEA' WHEN X.REGION LIKE '%EMEA%' THEN 'EMEA' WHEN NVL (rr.region, x.LOCATION_COMPANY) LIKE '%AMER%' THEN 'AMER' WHEN x.REGION LIKE '%AMER%' THEN 'AMER' WHEN NVL (rr.region, x.LOCATION_COMPANY) LIKE '%APAC%' THEN 'APAC' WHEN x.REGION LIKE '%APAC%' THEN 'APAC' ELSE 'NO RSD' END REGION, STATUS, STATUSREASONSELECTION, CASE WHEN AGE<4 THEN AGE WHEN AGE<8 THEN 4 WHEN AGE<13 THEN 8 WHEN AGE<17 THEN 13 WHEN AGE<21 THEN 17 WHEN AGE<41 THEN 21 ELSE 41 END AGE, COUNT FROM ( SELECT LOCATION_COMPANY, REGION, STATUS, STATUSREASONSELECTION, AGE, COUNT (*) COUNT FROM (SELECT CHG.LOCATION_COMPANY, CHG.REGION, TSK.STATUS, TSK.STATUSREASONSELECTION, FLOOR ( ( "&makeTimeStampToDay()&" - NVL ( GREATEST ( TSK.ACTIVATE_TIME, TSK.SCHEDULED_START_DATE), MODIFIED_DATE)) / 604800) AGE FROM "&dbEnv.schema1&".CHG_Infrastructure_Change CHG INNER JOIN "&dbEnv.schema1&".TMS_Task TSK ON (TSK.ROOTREQUESTID = CHG.INFRASTRUCTURE_CHANGE_ID) WHERE CHG.CHANGE_REQUEST_STATUS IN (6, 7) AND TSK.status <> 6000 AND CHG.ASGRP = ?) Z GROUP BY LOCATION_COMPANY, REGION, STATUS, STATUSREASONSELECTION, AGE) X LEFT JOIN "&dbEnv.schema2&".REF_REGION rr ON (X.REGION = rr.country)) GROUP BY REGION, STATUS, STATUSREASONSELECTION, AGE ) ORDER BY REGION,STATUS, STATUSREASONSELECTION, AGE" 

makeQuery connection, sql, team, "graphMe3c", " change coordinator of tasks - all RSD"

sql=" SELECT REGION, DECODE(status, "&LIST_TAS_STATUS&", status) STATUS, DECODE (STATUSREASONSELECTION, "&LIST_TAS_REASON&", STATUSREASONSELECTION) SUB_STATUS,AGE, COUNT FROM (SELECT REGION, STATUS, STATUSREASONSELECTION,AGE, SUM (COUNT) COUNT FROM (SELECT CASE WHEN NVL (rr.region, X.LOCATION_COMPANY) LIKE '%EMEA%' THEN 'EMEA' WHEN X.REGION LIKE '%EMEA%' THEN 'EMEA' WHEN NVL (rr.region, x.LOCATION_COMPANY) LIKE '%AMER%' THEN 'AMER' WHEN x.REGION LIKE '%AMER%' THEN 'AMER' WHEN NVL (rr.region, x.LOCATION_COMPANY) LIKE '%APAC%' THEN 'APAC' WHEN x.REGION LIKE '%APAC%' THEN 'APAC' ELSE 'NO RSD' END REGION, STATUS, STATUSREASONSELECTION, CASE WHEN AGE<4 THEN AGE WHEN AGE<8 THEN 4 WHEN AGE<13 THEN 8 WHEN AGE<17 THEN 13 WHEN AGE<21 THEN 17 WHEN AGE<41 THEN 21 ELSE 41 END AGE, COUNT FROM ( SELECT LOCATION_COMPANY, REGION, STATUS, STATUSREASONSELECTION, AGE, COUNT (*) COUNT FROM (SELECT CHG.LOCATION_COMPANY, CHG.REGION, TSK.STATUS, TSK.STATUSREASONSELECTION, FLOOR ( ( "&makeTimeStampToDay()&" - NVL ( GREATEST ( TSK.ACTIVATE_TIME, TSK.SCHEDULED_START_DATE), MODIFIED_DATE)) / 604800) AGE FROM "&dbEnv.schema1&".CHG_Infrastructure_Change CHG INNER JOIN "&dbEnv.schema1&".TMS_Task TSK ON (TSK.ROOTREQUESTID = CHG.INFRASTRUCTURE_CHANGE_ID) WHERE CHG.CHANGE_REQUEST_STATUS IN (6, 7) AND TSK.status <> 6000 AND CHG.SUPPORT_GROUP_NAME = ?) Z GROUP BY LOCATION_COMPANY, REGION, STATUS, STATUSREASONSELECTION, AGE) X LEFT JOIN "&dbEnv.schema2&".REF_REGION rr ON (X.REGION = rr.country) ) GROUP BY REGION, STATUS, STATUSREASONSELECTION, AGE ) ORDER BY REGION,STATUS, STATUSREASONSELECTION, AGE" 

makeQuery connection, sql, team, "graphMe3c", " change mananger of tasks - all RSD"
end sub	

'if VERBOSE then response.write "</font>"






response.AddHeader "x-ua-compatible", "ie=edge"

security_identify_dba false






%><!DOCTYPE html>
<html xmlns:xlink="http://www.w3.org/1999/xlink" >
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
<title>TT5 statistics</title>
<link href="favicon.ico" rel="shortcut icon" />
<link rel="stylesheet" type="text/css" media="screen" href="js/ui/jquery-ui.css" /> 
<link rel="stylesheet" type="text/css" media="print" href="print.css" /> 
<link rel="stylesheet" type="text/css" media="screen" href="itsm_gate.<%=ANTI_CACHE_SEED%>.css" />
<link rel="stylesheet" type="text/css" media="screen" href="js/columnFilter.css" />
<script type="text/javascript" src="js/jquery-1.11.1.min.js"></script>
<script type="text/javascript" src="js/columnFilter.js"></script>
<script type="text/javascript" src="js/columnFilterExport.js"></script>
<script type="text/javascript" src="js/sort/jquery.tablesorter.min.js"></script>
<script type="text/javascript" src="js/ui/jquery-ui-1.10.4.custom.min.js"></script>
<script type="text/javascript" src="js/d3/d3.min.3.4.8.js"></script>
<script type="text/javascript" src="js/graphers-reporting.14.js"></script>
<link rel="search" href="opensearch/change.xml" type="application/opensearchdescription+xml" title="Change search" />
<link rel="search" href="opensearch/incident.xml" type="application/opensearchdescription+xml" title="Incident search" />
<link rel="search" href="opensearch/problem.xml" type="application/opensearchdescription+xml" title="Problem search" />
<link rel="search" href="opensearch/people.xml" type="application/opensearchdescription+xml" title="People search" />
<style type="text/css">
table,td,tr,th {border-collapse:collapse;border:1px black solid}
.line {fill:none}
.yourTeam {stroke-dasharray:none}
.managed,.init {stroke:black;stroke-width: 1px; color:back;} 
.emergency,.escalated{stroke:red;stroke-width:1px;color:red;}  
.amtf {stroke:#FF33CC;stroke-width:1px;color:#FF33CC;}  
.managed{stroke:#D2691E;color:#D2691E;}  
.non_init {stroke:orange;stroke-dasharray:6 3;color:orange}
.delegated{stroke:olive;color:olive}
.delegatedNS{stroke:green;color:green}
.total {stroke:gray;stroke-dasharray:2 2;color:orange}
.box {background-color:#e6ffcc}
.subbox {background-color:white}
.subbox, .box {border: 1px solid gray;border-radius: 9px;margin: 10px 5px;padding: 3pt;}
h2, h3 {cursor:pointer;}
.popup {background-color:white}
.popup .dataContainer {overflow:scroll;};
.sun_main {float: left;width: 700px;}
.sun_sidebar {float: right;width: 230px;}
.sun_sequence {width: 700px;height: 70px;}
.sun_legend {padding: 10px 0 0 3px;}
.sun_sequence text, .sun_legend text {font-weight: 600;fill: #fff;}
.sun_chart {position: relative;}
.sun_chart path {stroke: #fff;}
.sun_explanation {position: absolute;top: 12px;left: 524px;width: 140px;text-align: center;color: #666;}
.sun_percentage {font-size: 2.5em;}
#teamForm {width:400px;height:4em;position:absolute;right:0;top:0}
</style>
</head>
<body>
<!--[if lt IE 9]>
<p style="font-size:30pt;color:red"> Your browser is too old and may not draw the page. Get a better browser. Sorry for that...</p>
<![endif]-->
<div id="top"></div>
<form id="teamForm" method="get" action="?">
	<fieldset><legend>Select the team</legend>
	<select name="team" class="team">
		<option>SH-WW-IN3-DATABASE_ORACLE</option>
		<option>SH-WW-IN3-DATABASE_SQL</option>
		<option>SH-WW-IN3-DATABASE_OTHER</option>
		<option>SH-WW-IN3-EAI_ETL</option>
		<option>SH-WW-IN3-EAI</option>
		<option>SH-WW-IN3-UNIX</option>
		<option>SH-WW-IN3-WINDOWS</option>
	</select><input type="submit" value="report!" />
	</fieldset>
</form>
<!--
<p style="background-color:yellow;font-size:30pt">Dear user... i'm trying to fix something in this page....</p>
-->
<h1>TT5 statistics</h1>
<p>Because first week of a year rarely started a monday, weekly and monthly grouping can lead to different annual count.</p>
<div class="box">
<%

team=trim(Ucase(Request.queryString("team")))

if len(team)<6 then
	response.write "Please select a team"
else	
%>
<script type="text/javascript">
	$('#teamForm select.team').val('<% =team %>');
</script>
<%
	makeReport 
end if

%>
</div>

</body>
</html>