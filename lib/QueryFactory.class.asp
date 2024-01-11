<%
const QueryFactory_MaxLob=3000
const QueryFactory_NoResult=" AND (1=0) "
Const QueryFactory_INIT_USER="Remedy Application Service"
Const QueryFactory_MONITORING="IBRSD_INTERFACE"
Const LIST_TAS_STATUS="1000,'Staged',2000,'Assigned',3000,'Pending',4000,'Work in Progress',5000,'Waiting',6000,'Closed',7000,'Bypassed'"
Const LIST_TAS_REASON="1000,'Success',2000,'FAIL',3000,'Cancelled',4000,'Assignment',5000,'Staging in Progress',6000,'Staging Complete',9000,'Error'"
Const LIST_INC_STATUS="0,'New',1,'Assigned',2,'Work in Progress',3,'Pending',4,'Resolved',5, 'Closed',6,'Cancelled'"
Const LIST_PBI_STATUS="0,'Draft',1,'Under review',2,'Request for Authorization',3,'Assigned',4,'Under investigation',5,'Pending',6,'Completed',8,'Closed',9,'Cancelled',10,'Rejected'"
Const LIST_WO_STATUS="0,'Assigned',1,'Pending',2,'Waiting Approval',3,'Plannnig',4,'In Progress',5,'Completed',6,'Rejected',7,'Cancelled',8,'Closed'"
Const LIST_APPROVAL="0,'Pending',1,'Approved',2,'Rejected',3,'Hold',4,'More Information',5,'Cancelled',6,'Error',7,'Closed'"
Const LIST_PRIORITY="0,'1-Critical',1,'2-High',2,'3-Medium',3,'4-Low','?'"
Const LIST_GXP="1000,'not GxP',2000,'GxP 1',3000,'GxP 2',4000,'GxP 3','?'"
Const LIST_CWL_TYPE="3000,'Business Justification',4000,'Requierements',6000,'Change Assessment',8000,'Risk Assessment',9000,'Service Impact Assessment',11000,'Backout Plan',14000,'Install Plan',16000,'Test plan',20000,'Test Results - Details',22000,'Cancellation information',29000,'General Information'"
Const LIST_WLG_TYPE="2000,'Customer communication',8000,'General Information',15000,'Working Log',18000,'BMC Impact Manager Update',19000,'Escalation'"
Const LIST_PPL_STATUS="0,'Profile Proposed',1,'Profile Enabled',2,'Profile Offline',3,'Profile Obsolete',4,'Profile Archive',5,'Profile Delete'"
Const LIST_CRQ_TIMING="1000,'Emergency',2000,'Expedited',3000,'Latent',4000,'Normal',5000,'No Impact',6000,'Standard','?'"
Const LIST_CRQ_IMPACT="1000,'1:Extensive/Widespread',2000,'2:Significant/Large',3000,'3:Moderate/Limited',4000,'4:Minor/Localized','?'"
Const LIST_CRQ_URGENCY="1000,'1:Critical',2000,'2:Hight',3000,'3:Medium',4000,'4:Low','?'"
Const LIST_CRQ_STATUS="0,'Draft',1,'Request For Authorization',2,'Request For Change',3,'Planning In Progress',4,'Scheduled For Review',5,'Scheduled For Approval',6,'Scheduled',7,'Implementation In Progress',8,'Pending',9,'Rejected',10,'Completed',11,'Closed',12,'Cancelled'"
'Const LIST_CRQ_STATUS_PLUS= LIST_CRQ_STATUS
Const LIST_CRQ_STATUS_PLUS="0,'Draft',1,'Request For Authorization',2,'Request For Change',3,'Planning In Progress',4,'Scheduled For Review',5,'Scheduled For Approval',6,'Scheduled',7,'Implementation In Progress',8,'Pending/'||Decode(CHG.CHANGE_REQUEST_PREV_STATUS,0,'Draft',1,'Request For Authorization',2,'Request For Change',3,'Planning In Progress',4,'Scheduled For Review',5,'Scheduled For Approval',6,'Scheduled',7,'Implementation In Progress',9,'Rejected',10,'Completed'),9,'Rejected',10,'Completed',11,'Closed',12,'Cancelled'"
Const LIST_CRQ_REASON="1000,'No Longer Required',2000,'Funding Not Available',3000,'To Be Re-Scheduled',4000,'Resources Not Available',5000,'Successful',6000,'Successful with Issues',7000,'Unsuccessful',8000,'Backed Out',9000,'Final Review Complete',10000,'Final Review Required',11000,'Additional Coding Required',12000,'Insufficient Task Data',14000,'In Rollout',19000,'In Build',22000,'Vendor Purchase',23000,'Support Group Communication',24000,'Task Review',25000,'Miscellaneous',26000,'Future Enhancement',27000,'Manager Intervention',28000,'Accepted',29000,'Assigned'"
Const LIST_PEOPLE_ROLE="1000, 'ALL',5000,'Uses',6000,'Used by',7000,'Owns',8000, 'Owned by',9000,'Supports',10000,'Supported by',38000,'Manages',39000,'Managed by',52000,'Member of',76000,'Approved by',100000,'Specific role' "
Const LIST_AST_STATUS="0,'Ordered',1,'Received',2,'Being Assembled',3,'Deployed',4,'In Repair',5,'Down',6,'End of Life',7,'Transferred',8,'Delete',9,'In Inventory',10,'On Loan',11,'Disposed',12,'Reserved',13,'Return to Vendor' "

class QueryFactory

	private query
	private sql
	private timezone 
	private few_tickets
	private currentUser
	private currentTeamName
	'private currentTeamCode
	private field_id
	private caption
	private schema1
	private schema2
	public isInvalidSelector
	private WhereLimiter
	'private useCode 
	'------------------------------------------------

	private sub class_initialize()
		timezone="GMT"
		few_tickets=20
		isInvalidSelector=false
		WhereLimiter=" WHERE (rownum<="&C_MAX_ROW&") "
	end sub

	'------------------------------------------------
	' scalable compare ts.
	private function compare_ts(col_data,operator,dateString) 
		compare_ts="("&col_data&operator&" ("&dateString&"-to_date('19700101 000000','YYYYMMDD HH24MISS'))*86400)"
	end function 

	'------------------------------------------------
	private function GetTime(nom_col)
		GetTime="to_char((timestamp '1970-01-01 00:00:00 GMT'+numtodsinterval("&nom_col&",'SECOND')) at time zone SESSIONTIMEZONE,'YYYY-MM-DD HH24:MI')"
	end function

	private function GetTimeFull(nom_col)
		GetTimeFull="to_char((timestamp '1970-01-01 00:00:00 GMT'+numtodsinterval("&nom_col&",'SECOND')) at time zone SESSIONTIMEZONE,'YYYY-MM-DD HH24:MI:SS')"
	end function
	
	private function GetDateArs(nom_col)
		GetDateArs="to_char((timestamp '1970-01-01 00:00:00 GMT'+numtodsinterval("&nom_col&",'SECOND')) at time zone SESSIONTIMEZONE,'YYYY-MM-DD')"
	end function
	
	private function GetIntervalFormat( value )
		GetIntervalFormat="extract( day from NUMTODSINTERVAL( "&value&",'second' ) )||' day(s) '||extract( hour from NUMTODSINTERVAL( "&value&",'second' ) )||'h'||extract( minute from NUMTODSINTERVAL( "&value&",'second' ) )||'m'||extract( second from NUMTODSINTERVAL( "&value&",'second' ))||'s'"	
	end function 
	
	private function GetFileAttachmentName(nom_col)
		GetFileAttachmentName=" regexp_substr("& nom_col&"||';','[0-9]+;[0-9]+;(.*)$',1,1,'',1)" 
	end function 
	
	private function hasFileAttachment(nom_col)
		hasFileAttachment=" CASE when length ("&nom_col&")>2 then 1 else 0 end "
	end function 
	
	sub forceQuery(sql)
		query.setSql(sql)
	end sub
	
	sub forceBind(stringValue)
		query.setSql(stringValue)
	end sub
	
	function init(options,byref idstr, byref captionstr ) 
		dim sql_prologue
		schema1=options.dbEnv.schema1
		schema2=options.dbEnv.schema2
		'useCode=options.dbEnv.useCodes
		
		set query=new QuerySQL
		query.init options.dbEnv.getConnection()
		setSessionTimezone options.timezone
		
		currentUser=query.protect("USER", options.current_user)
		if options.isMyself then 
			currentTeamName=""
		elseif options.isAutoTeam then
			if options.isAutoTeamFull then 
				setCurrentTeamName
			else
				setCurrentTeamNameDefault
			end if
		elseif options.isMyself then
			'for myself, currentTeamName is uselesss
			currentTeamName="'foobar'"
		else
			currentTeamName=query.protectArray("TEAM",options.team_name)
		end if
		
		' create the query
		if options.env="L" then
			builderLegacy options
		else
			builderNgdc options
		end if
		'SetQueryOrDebugIt(query)
		'query.setSQL(sql_prologue&sql)
		query.setSQL(sql)
		set init=query
		idstr=field_id
		captionstr=caption
	end function 
	
	private sub setCurrentTeamName()
		currentTeamName="SELECT G.SUPPORT_GROUP_NAME FROM "&schema1&".CTM_PEOPLE P INNER JOIN "&schema1&".CTM_SUPPORT_GROUP_ASSOCIATION X ON (P.PERSON_ID=X.PERSON_ID) INNER JOIN "&schema1&".CTM_SUPPORT_GROUP G ON (G.SUPPORT_GROUP_ID=X.SUPPORT_GROUP_ID) WHERE P.REMEDY_LOGIN_ID="&currentUser&" "
	end sub
	
	private sub setCurrentTeamNameDefault()
		currentTeamName="SELECT G.SUPPORT_GROUP_NAME FROM "&schema1&".CTM_PEOPLE P INNER JOIN "&schema1&".CTM_SUPPORT_GROUP_ASSOCIATION X ON (P.PERSON_ID=X.PERSON_ID) INNER JOIN "&schema1&".CTM_SUPPORT_GROUP G ON (G.SUPPORT_GROUP_ID=X.SUPPORT_GROUP_ID) WHERE X.DEFAULT_X=0 AND P.REMEDY_LOGIN_ID="&currentUser&" " 
	end sub
	
	private sub setSessionTimezone(tz)
		timezone=tz
		query.setSql("alter session set time_zone='"&tz&"'" ) 
		query.execute()
	end sub
	
	private function checkChangeFiles(schema)
		checkChangeFiles="(select listAgg("&GetFileAttachmentName("CWL.Z2AF_WORK_LOG01")&"||' '||"&GetFileAttachmentName("CWL.Z2AF_WORK_LOG02")&"||' '||"&GetFileAttachmentName("CWL.Z2AF_WORK_LOG03")&",' ') within group (order by CWL.WORK_LOG_ID) from "&schema&".CHG_WORKLOG CWL where CHG.INFRASTRUCTURE_CHANGE_ID=CWL.INFRASTRUCTURE_CHANGE_ID group by CWL.INFRASTRUCTURE_CHANGE_ID) CHANGE_FILES,"&_ 
		"(select ListAgg("&GetFileAttachmentName("TSK.Z2AF_ATTACHMENT1")&"||' '||"&GetFileAttachmentName("TSK.Z2AF_ATTACHMENT2")&"||' '||"&GetFileAttachmentName("TSK.Z2AF_ATTACHMENT3")&",' ') within group (order by TSK.ROOTREQUESTID) from "&schema&".TMS_Task TSK where CHG.INFRASTRUCTURE_CHANGE_ID=TSK.ROOTREQUESTID group by TSK.ROOTREQUESTID) X_TASK_FILES, "&_ 
		"(select ListAgg("&GetFileAttachmentName("TWI.Z2AF_ATTACHMENT1")&" ||' '|| "&GetFileAttachmentName("TWI.Z2AF_ATTACHMENT2")&"||' '||"&GetFileAttachmentName("TWI.Z2AF_ATTACHMENT3")&",' ') within group (order by TWI.WORK_INFO_ID) FROM "&schema&".TMS_Task TSK LEFT OUTER JOIN "&schema&".TMS_WORKINFO TWI ON (TWI.TASKORTASKGROUPID=TSK.TASK_ID) where CHG.INFRASTRUCTURE_CHANGE_ID=TSK.ROOTREQUESTID group by TSK.ROOTREQUESTID) X_TASK_WORKINFO_FILES, "
	end function
	
private function generateSelectNotFound( x, y )
	sql="SELECT 'Query to build not recognized with this " &x &"/"&y&" .' Message FROM DUAL"
	field_id="MESSAGE"
	isInvalidSelector=true
end function


'private function onlyWithCodes(byVal tmp)
'	if useCode then 
		'response.write "using code"
'		onlyWithCodes=tmp
'	else
		'response.write "not using code"
'		onlyWithCodes=empty
'	end if
'end function


private function SetQueryOrDebugIt(query)
	if Request.querystring("debugQuery")="y"  then 
		dim tmp, foo, bar
		tmp ="itsm"&DateDiff("s", "01/01/1970 00:00:00", now)
		query.setSQL("EXPLAIN PLAN SET STATEMENT_ID='"&tmp&"' FOR "&sql)
		query.run foo,bar
		query.printDebugQuery foo, bar 
		response.write "#"&foo &"#"&bar&"#"
		query.haveNewCommand
		sql= "SELECT x.cardinality ""Rows"",lpad('-',level-1)||x.operation||' '||x.options||' '||x.object_name ""Plan"" FROM PLAN_TABLE x CONNECT BY prior id = parent_id AND prior statement_id = statement_id START WITH id = 0 AND statement_id = '"&tmp&"' ORDER BY id"
	end if
end function

sub builderNgdc(options)
	' let's sort out high level on the default completion requiered by the querys... 
	' and not exactly the completion of the object showned ( ie: CRQ if Change Work log)
	
	select case options.type_ticket
		case "CRQ"
			builderNgdcCRQ options 
		case "INC"
			builderNgdcINC options 
		case "TAS"
			builderNgdcTAS options
		case "REQ"
			builderNgdcREQ options
		case "PBI"
			builderNgdcPBI options
		case else
			builderNgdcOTHER options 
	end select
end sub

'private function mainViewerChange(sens)
'	select case sens
'		case SENS_COORDINATE
'			mainViewerChange="'C: '||CHG.ASLOGID"
'		case SENS_SUBMITED
'			mainViewerChange="'S: '||chg.submitter"
'		case else 
'			mainViewerChange="'M: '||CHG.cab_manager_login"
'	end select 
'end function

'lower are here for promise_gate compatibility
private function pointOfViewChange(sens, isMyself )	
		select case sens
		case SENS_COORDINATE
			if isMyself then
				pointOfViewChange="CHG.ASGRPID=REF.SUPPORT_GROUP_ID AND CHG.ASGRP=REF.SUPPORT_GROUP_NAME AND CHG.ASLOGID="&currentUser&" AND lower(CHG.ASLOGID)=lower("&currentUser&")"
			else
				pointOfViewChange="CHG.ASGRPID=REF.SUPPORT_GROUP_ID AND CHG.ASGRP=REF.SUPPORT_GROUP_NAME AND REF.SUPPORT_GROUP_NAME in ("&currentTeamName&")"
			end if
		case SENS_MANAGED
			if isMyself then
				pointOfViewChange="CHG.SUPPORT_GROUP_ID=REF.SUPPORT_GROUP_ID AND CHG.SUPPORT_GROUP_NAME=REF.SUPPORT_GROUP_NAME AND CHG.CAB_MANAGER_LOGIN="&currentUser&" AND lower(CHG.CAB_MANAGER_LOGIN)=lower("&currentUser&")"
			else
				pointOfViewChange="CHG.SUPPORT_GROUP_ID=REF.SUPPORT_GROUP_ID AND CHG.SUPPORT_GROUP_NAME=REF.SUPPORT_GROUP_NAME AND REF.SUPPORT_GROUP_NAME in ("&currentTeamName&")"
			end if
		case SENS_ASSIGNED
			if isMyself then 
				pointOfViewChange="CHG.ASGRPID=REF.SUPPORT_GROUP_ID AND CHG.ASGRP=REF.SUPPORT_GROUP_NAME AND ((CHG.ASLOGID="&currentUser&" AND lower(CHG.ASLOGID)="&currentUser&") OR (CHG.CAB_MANAGER_LOGIN="&currentUser&" AND lower(CHG.CAB_MANAGER_LOGIN)=lower("&currentUser&")))"
			else 
				pointOfViewChange="((CHG.ASGRPID=REF.SUPPORT_GROUP_ID AND CHG.ASGRP=REF.SUPPORT_GROUP_NAME AND REF.SUPPORT_GROUP_NAME in ("&currentTeamName&")) OR (CHG.SUPPORT_GROUP_ID=REF.SUPPORT_GROUP_ID AND CHG.SUPPORT_GROUP_NAME=REF.SUPPORT_GROUP_NAME AND REF.SUPPORT_GROUP_NAME in ("&currentTeamName&")))"
			end if
		case else 'submited
			'team_sql="(CHG.SUPPORT_GROUP_NAME2 in ("&currentTeamName&"))"&onlyWithCodes("AND CHG.SUPPORT_GROUP_ID_2 in ("&currentTeamCode&")" )
			if isMyself then
				pointOfViewChange="CHG.SUPPORT_GROUP_ID_2=REF.SUPPORT_GROUP_ID AND CHG.SUPPORT_GROUP_NAME2=REF.SUPPORT_GROUP_NAME AND ((CHG.SUBMITTER="&currentUser&" AND lower(CHG.SUBMITTER)=lower("&currentUser&")) OR (CHG.REQUESTOR_ID="&currentUser&" AND lower(CHG.REQUESTOR_ID)=lower("&currentUser&")))"
			else
				pointOfViewChange="CHG.SUPPORT_GROUP_ID_2=REF.SUPPORT_GROUP_ID AND CHG.SUPPORT_GROUP_NAME2=REF.SUPPORT_GROUP_NAME AND REF.SUPPORT_GROUP_NAME in ("&currentTeamName&")"
			end if 
		end select
end function

'lower() are here for promise_gate compatibility
private function pointOfViewIncident(sens,isMyself)
	if sens=SENS_SUBMITED then
		if isMyself then
			pointOfViewIncident="INC.OWNER_GROUP=REF.SUPPORT_GROUP_NAME AND INC.OWNER_GROUP_ID=REF.SUPPORT_GROUP_ID AND INC.SUBMITTER="&currentUser&" AND lower(INC.SUBMITTER)=lower("&currentUser&")"
		else 
			pointOfViewIncident="INC.OWNER_GROUP=REF.SUPPORT_GROUP_NAME AND INC.OWNER_GROUP_ID=REF.SUPPORT_GROUP_ID AND REF.SUPPORT_GROUP_NAME in ("&currentTeamName&")"
		end if
	else
		if isMyself then 
			pointOfViewIncident="INC.ASSIGNED_GROUP=REF.SUPPORT_GROUP_NAME AND INC.ASSIGNED_GROUP_ID=REF.SUPPORT_GROUP_ID AND INC.ASSIGNEE_LOGIN_ID="&currentUser&" AND lower(INC.ASSIGNEE_LOGIN_ID)=lower("&currentUser&")"
		else 
			pointOfViewIncident="INC.ASSIGNED_GROUP=REF.SUPPORT_GROUP_NAME AND INC.ASSIGNED_GROUP_ID=REF.SUPPORT_GROUP_ID AND INC.ASSIGNED_GROUP in ("&currentTeamName&")"
		end if
	end if 
end function 

'lower() are here for promise_gate compatibility
private function pointOfViewProblem(sens,isMyself)
	select case sens
	 case SENS_SUBMITED
		if isMyself then 
			pointOfViewProblem="PB.SUPPORT_GROUP_NAME_REQUESTER=REF.SUPPORT_GROUP_NAME AND PB.SUPPORT_GROUP_ID_REQUESTOR=REF.SUPPORT_GROUP_ID AND pb.SUBMITTER="&currentUser&" AND lower(pb.SUBMITTER)=lower("&currentUser&")"
		else
			pointOfViewProblem="PB.SUPPORT_GROUP_NAME_REQUESTER=REF.SUPPORT_GROUP_NAME AND PB.SUPPORT_GROUP_ID_REQUESTOR=REF.SUPPORT_GROUP_ID AND REF.SUPPORT_GROUP_NAME IN ("&currentTeamName&")"
		end if
	 case SENS_MANAGED
		if isMyself then 
			pointOfViewProblem="pb.ASSIGNED_GROUP_PBLM_MGR=REF.SUPPORT_GROUP_NAME AND PB.SUPPORT_GROUP_ID_PBM_MGR=REF.SUPPORT_GROUP_ID AND pb.PROBLEM_MANAGER_LOGIN="&currentUser&" AND lower(pb.PROBLEM_MANAGER_LOGIN)=lower("&currentUser&")"
		else
			pointOfViewProblem="pb.ASSIGNED_GROUP_PBLM_MGR=REF.SUPPORT_GROUP_NAME AND PB.SUPPORT_GROUP_ID_PBM_MGR=REF.SUPPORT_GROUP_ID AND REF.SUPPORT_GROUP_NAME IN ("&currentTeamName&")"		
		end if
	 case SENS_COORDINATE
		if isMyself then 
			pointOfViewProblem="PB.ASSIGNED_GROUP=REF.SUPPORT_GROUP_NAME AND PB.ASSIGNED_GROUP_ID=REF.SUPPORT_GROUP_ID AND pb.ASSIGNEE_LOGIN_ID="&currentUser&" AND lower(pb.ASSIGNEE_LOGIN_ID)=lower("&currentUser&")"
		else 
			pointOfViewProblem="PB.ASSIGNED_GROUP=REF.SUPPORT_GROUP_NAME AND PB.ASSIGNED_GROUP_ID=REF.SUPPORT_GROUP_ID AND REF.SUPPORT_GROUP_NAME IN ("&currentTeamName&")"
		end if 
	case else'case SENS_ASSIGNED
		if isMyself then 
			pointOfViewProblem="pb.ASSIGNED_GROUP_PBLM_MGR=REF.SUPPORT_GROUP_NAME AND REF.SUPPORT_GROUP_ID=PB.SUPPORT_GROUP_ID_PBM_MGR AND ((pb.PROBLEM_MANAGER_LOGIN="&currentUser&" AND lower(pb.PROBLEM_MANAGER_LOGIN)=lower("&currentUser&")) or (pb.ASSIGNEE_LOGIN_ID="&currentUser&" AND lower(pb.ASSIGNEE_LOGIN_ID)=lower("&currentUser&")))"
		else
			pointOfViewProblem="((pb.ASSIGNED_GROUP_PBLM_MGR=REF.SUPPORT_GROUP_NAME AND PB.SUPPORT_GROUP_ID_PBM_MGR=REF.SUPPORT_GROUP_ID AND REF.SUPPORT_GROUP_NAME IN ("&currentTeamName&")) or (PB.ASSIGNED_GROUP=REF.SUPPORT_GROUP_NAME AND PB.ASSIGNED_GROUP_ID=REF.SUPPORT_GROUP_ID AND REF.SUPPORT_GROUP_NAME IN ("&currentTeamName&")))"
		end if
	end select
end function

'lower() are here for promise_gate compatibility
private function pointOfViewWorkOrder(sens,isMyself)
	select case sens 
	case SENS_MANAGED
		if isMyself then 
			pointOfViewWorkOrder="WO.SUPPORT_GROUP_NAME=REF.SUPPORT_GROUP_NAME AND WO.SUPPORT_GROUP_ID=REF.SUPPORT_GROUP_ID AND WO.CAB_MANAGER_LOGIN="&currentUser
		else 
			pointOfViewWorkOrder="WO.SUPPORT_GROUP_NAME=REF.SUPPORT_GROUP_NAME AND WO.SUPPORT_GROUP_ID=REF.SUPPORT_GROUP_ID AND REF.SUPPORT_GROUP_NAME in ("&currentTeamName&")"
		end if 
	case SENS_COORDINATE
		if isMyself then 
			pointOfViewWorkOrder="WO.ASGRP=REF.SUPPORT_GROUP_NAME AND WO.ASGRPID=REF.SUPPORT_GROUP_ID AND WO.ASLOGID="&currentUser
		else 
			pointOfViewWorkOrder="WO.ASGRP=REF.SUPPORT_GROUP_NAME AND WO.ASGRPID=REF.SUPPORT_GROUP_ID AND REF.SUPPORT_GROUP_NAME in ("&currentTeamName&")"
		end if 
	case SENS_ASSIGNED
		if isMyself then
			pointOfViewWorkOrder="((WO.SUPPORT_GROUP_NAME=REF.SUPPORT_GROUP_NAME AND WO.SUPPORT_GROUP_ID=REF.SUPPORT_GROUP_ID AND WO.CAB_MANAGER_LOGIN="&currentUser&") or (WO.ASGRP=REF.SUPPORT_GROUP_NAME AND WO.ASGRPID=REF.SUPPORT_GROUP_ID AND WO.ASLOGID="&currentUser&"))"
		else
			pointOfViewWorkOrder="((WO.SUPPORT_GROUP_NAME=REF.SUPPORT_GROUP_NAME AND WO.SUPPORT_GROUP_ID=REF.SUPPORT_GROUP_ID AND REF.SUPPORT_GROUP_NAME in ("&currentTeamName&")) or (WO.ASGRP=REF.SUPPORT_GROUP_NAME AND WO.ASGRPID=REF.SUPPORT_GROUP_ID AND REF.SUPPORT_GROUP_NAME in ("&currentTeamName&")))"
		end if
	case else 
		if isMyself then
			pointOfViewWorkOrder="WO.SUPPORT_GROUP_NAME2=REF.SUPPORT_GROUP_NAME AND WO.SUPPORT_GROUP_ID_2=REF.SUPPORT_GROUP_ID AND WO.SUBMITTER="&currentUser
		else 
			pointOfViewWorkOrder="WO.SUPPORT_GROUP_NAME2=REF.SUPPORT_GROUP_NAME AND WO.SUPPORT_GROUP_ID_2=REF.SUPPORT_GROUP_ID AND REF.SUPPORT_GROUP_NAME in ("&currentTeamName&")"
		end if
	end select 
end function

'lower() are here for promise_gate compatibility
private function pointOfViewTask(sens,isMyself)
	select case sens 
	case SENS_SUBMITED
		if isMyself then
			pointOfViewTask="TSK.SUPPORT_GROUP_NAME=REF.SUPPORT_GROUP_NAME  AND TSK.LOOKUPKEYWORD='TMSTASK' AND (tsk.SUBMITTER="&currentUser&" OR tsk.REQUESTOR_ID="&currentUser&")"
		else
			pointOfViewTask="TSK.SUPPORT_GROUP_NAME=REF.SUPPORT_GROUP_NAME AND TSK.ASSIGNEE_GROUP_ID=REF.SUPPORT_GROUP_ID AND REF.SUPPORT_GROUP_NAME in ("&currentTeamName&")"
		end if 
	case else
		if isMyself then 
			pointOfViewTask="TSK.ASSIGNEE_GROUP=REF.SUPPORT_GROUP_NAME AND TSK.ASSIGNEE_GROUP_ID=REF.SUPPORT_GROUP_ID AND TSK.LOOKUPKEYWORD='TMSTASK' AND tsk.ASSIGNED_TO="&currentUser
		else
			pointOfViewTask="TSK.ASSIGNEE_GROUP=REF.SUPPORT_GROUP_NAME AND TSK.LOOKUPKEYWORD='TMSTASK' AND TSK.ASSIGNEE_GROUP_ID=REF.SUPPORT_GROUP_ID AND REF.SUPPORT_GROUP_NAME in ("&currentTeamName&")"
		end if
	end select 
end function


private function pointOfViewChangeTemplate(sens,withTasks)
	select case sens
		case SENS_MANAGED
			pointOfViewChangeTemplate=" ct.SUPPORT_GROUP_NAME IN ("&currentTeamName&")"
		case SENS_COORDINATE
			pointOfViewChangeTemplate=" ct.ASGRP in ("&currentTeamName&")"
		case SENS_ASSIGNED
			if withTasks then
				pointOfViewChangeTemplate=" ttt.ASSIGNEE_GROUP IN ("&currentTeamName&") "
			else
				pointOfViewChangeTemplate=" (ct.ASGRP in ("&currentTeamName&") OR ct.SUPPORT_GROUP_NAME IN ("&currentTeamName&"))"
			end if
		case else 'submited
			pointOfViewChangeTemplate=" ct.authoring_group IN ("&currentTeamName&") "
	end select
end function

'###############################################################################
'# NGDC #
'###############################################################################

 

private sub builderNgdcCRQ(options)
	dim team_sql,place1,place2
	dim sqlSELECT,sqlFROM,sqlWHERE
	select case options.query_selector 
	case "CRQ"
	
	team_sql=pointOfViewChange(options.sens_rech,options.isMyself)
	sqlFROM="[1].CHG_Infrastructure_Change CHG LEFT JOIN [1].CTM_PEOPLE p1 ON (CHG.ASLOGID=p1.REMEDY_LOGIN_ID) LEFT JOIN [1].CTM_PEOPLE p2 ON (CHG.SUBMITTER=p2.REMEDY_LOGIN_ID) LEFT JOIN [1].CTM_PEOPLE p4 ON (CHG.cab_manager_login=p4.REMEDY_LOGIN_ID) LEFT JOIN "&schema2&".REF_REGION rr ON (chg.REGION=rr.country)"
	If options.isFeature then
			select case options.featureName
			case "AMTF"
				sqlFROM="[1].CTM_SUPPORT_GROUP REF,"&sqlFROM
				sqlWHERE=" AND CHG.CHANGE_REQUEST_STATUS not in (0,9,11,12) AND upper(CHG.DESCRIPTION) like '%AMTF%' AND "&team_sql
			case "CHECK_TEMPLATE" 
				sqlFROM=sqlFROM&" INNER JOIN [1].chg_template CT ON (CT.CHG_TEMPLATE_ID=CHG.CHG_TEMPLATE_ID_PREVIOUS)"
				sqlWHERE=" AND CHG.CHANGE_REQUEST_STATUS not in (0,9,11,12) AND (ct.asgrp<>CHG.ASGRP OR ct.asgrpid <>CHG.ASGRPID OR ct.SUPPORT_GROUP_NAME<>CHG.SUPPORT_GROUP_NAME or ct.support_group_id<>CHG.support_group_id) AND (CT.ASGRP in ("&currentTeamName&") or CT.SUPPORT_GROUP_NAME in ("&currentTeamName&")) "
				place1=" ct.asgrp TEMPLATE_COORD_GROUP,"
				place2=" ct.SUPPORT_GROUP_NAME TEMPLATE_MANAGER_GROUP,"
			case "FROM_TOOL"
				sqlFROM="[1].CTM_SUPPORT_GROUP REF,"&sqlFROM
				sqlWHERE=" AND CHG.CHANGE_REQUEST_STATUS not in (11,12) AND CHG.SUBMITTER ="&query.protect("INIT",QueryFactory_INIT_USER)&" AND "&team_sql
			case "REVIEW"
				sqlFROM="[1].CTM_SUPPORT_GROUP REF,"&sqlFROM
				if options.sens_rech = SENS_MANAGED then 
					sqlWHERE=" AND ("&pointOfViewChange(SENS_MANAGED,options.isMyself)&" AND CHG.CHANGE_REQUEST_STATUS in (4,5,8,9))"
				elseif options.sens_rech = SENS_ASSIGNED then 
					sqlWHERE=" AND (("&pointOfViewChange(SENS_COORDINATE,options.isMyself)&" AND CHG.CHANGE_REQUEST_STATUS IN (3,4,6,8,9)) OR ("&pointOfViewChange(SENS_MANAGED,options.isMyself)&" AND CHG.CHANGE_REQUEST_STATUS in (4,5,6)))"
				elseif options.sens_rech = SENS_SUBMITED then 
					sqlWHERE=" AND CHG.CHANGE_REQUEST_STATUS NOT IN (7,11,12) AND "&team_sql
				else
					sqlWHERE=" AND CHG.CHANGE_REQUEST_STATUS IN (3,4,5,6,8,9) AND "&team_sql
				end if
				place2=place1 
				place1=checkChangeFiles(schema1)
			case "PENDING"
				sqlFROM="[1].CTM_SUPPORT_GROUP REF,"&sqlFROM
				sqlWHERE=" AND CHG.CHANGE_REQUEST_STATUS IN (0,1,2,8,9) AND "&team_sql
				place2=place1
				place1=checkChangeFiles(schema1)
			case "IMPLEMENTATION"
				sqlFROM="[1].CTM_SUPPORT_GROUP REF,"&sqlFROM
				sqlWHERE=" AND CHG.CHANGE_REQUEST_STATUS in (6,7) AND "&team_sql
				sqlFROM=sqlFROM&replace(" LEFT OUTER JOIN (SELECT TSK.TASK_ID,TSK.TASKNAME, TSK.ACTIVATE_TIME,TSK.MODIFIED_DATE,TSK.STATUS, TSK.STATUSREASONSELECTION,TSK.ROOTREQUESTID FROM [1].TMS_Task TSK WHERE TSK.status NOT IN (1000,6000,7000)) T ON (T.ROOTREQUESTID=CHG.INFRASTRUCTURE_CHANGE_ID)","[1]", schema1)
				place2=""
				place1=" decode(T.status,"&LIST_TAS_STATUS&",T.status)||nvl2(T.STATUSREASONSELECTION,' ('||decode (T.STATUSREASONSELECTION,"&LIST_TAS_REASON&",T.STATUSREASONSELECTION)||')','') X_CHILD_STATUS,T.TASK_ID X_CHILD_CODE,T.TASK_ID CHILD_ID,T.TASKNAME,"&GetTime("T.MODIFIED_DATE")&" TASK_LAST_MODIFIED_DATE,"&GetTime("T.ACTIVATE_TIME")&" TASK_ACTIVATE_TIME,"
			case "DONE"
				sqlFROM="[1].CTM_SUPPORT_GROUP REF,"&sqlFROM
				sqlWHERE=" AND CHG.CHANGE_REQUEST_STATUS in (10) AND "&team_sql
			case "FRESH_CLOSED"
				sqlFROM="[1].CTM_SUPPORT_GROUP REF,"&sqlFROM
				sqlWHERE=" AND CHG.CHANGE_REQUEST_STATUS in (11,12) AND ("&compare_ts( "CHG.CLOSED_DATE"," > ",query.protectDate("SINCE", options.date1))&" ) AND "&team_sql
			case "NO_TASK"
				sqlFROM=sqlFROM&" LEFT OUTER JOIN [1].TMS_Task TSK ON CHG.INFRASTRUCTURE_CHANGE_ID=TSK.ROOTREQUESTID,[1].CTM_SUPPORT_GROUP REF"
				sqlWHERE=" AND (TSK.ROOTREQUESTID IS NULL) AND (CHG.CHANGE_REQUEST_STATUS not in (0,9,10,11,12)) AND "&team_sql
			case "P1"
				sqlFROM="[1].CTM_SUPPORT_GROUP REF,"&sqlFROM
				sqlWHERE=" AND (CHG.PRIORITY=0 OR CHG.change_timing=1000) AND CHG.CHANGE_REQUEST_STATUS not in (9,11,12) AND "&team_sql
			case "NO_DB"
				sqlFROM="[1].CTM_SUPPORT_GROUP REF,"&sqlFROM
				sqlWHERE=" AND CHG.CHANGE_REQUEST_STATUS not in (0,9,11,12) AND NOT EXISTS(select associations_id from "&schema1&".chg_associations ASSO where ASSO.request_id02=CHG.INFRASTRUCTURE_CHANGE_ID AND ASSO.request_type01=6000 AND Lookup_keyword="&query.protect("LOOKPUP","BMC_DATABASE")&") AND "&team_sql
			case "NO_SERVER"
				sqlFROM="[1].CTM_SUPPORT_GROUP REF,"&sqlFROM
				sqlWHERE=" AND CHG.CHANGE_REQUEST_STATUS not in (0,9,11,12) AND NOT EXISTS(select associations_id from "&schema1&".chg_associations ASSO where ASSO.request_id02=CHG.INFRASTRUCTURE_CHANGE_ID AND ASSO.request_type01=6000 AND Lookup_keyword="&query.protect("LOOKPUP","BMC_COMPUTERSYSTEM")&") AND "&team_sql
			case "NO_APP"
				sqlFROM="[1].CTM_SUPPORT_GROUP REF,"&sqlFROM
				sqlWHERE=" AND CHG.CHANGE_REQUEST_STATUS not in (0,9,11,12) AND NOT EXISTS(select associations_id from "&schema1&".chg_associations ASSO where ASSO.request_id02=CHG.INFRASTRUCTURE_CHANGE_ID AND ASSO.request_type01=6000 AND Lookup_keyword="&query.protect("LOOKPUP","BMC_APPLICATION")& ") AND "&team_sql
			case "NO_CI"
				sqlFROM="[1].CTM_SUPPORT_GROUP REF,"&sqlFROM
				sqlWHERE=" AND CHG.CHANGE_REQUEST_STATUS not in (0,9,11,12) AND NOT EXISTS(select associations_id from "&schema1&".chg_associations ASSO where ASSO.request_id02=CHG.INFRASTRUCTURE_CHANGE_ID AND ASSO.request_type01=6000 AND Lookup_keyword <> "&query.protect("LOOKPUP","BMC_BUSINESSSERVICE")&") AND "&team_sql
			case "ALL_SINCE"
				sqlFROM="[1].CTM_SUPPORT_GROUP REF,"&sqlFROM
				sqlWHERE=" AND ("&compare_ts( "CHG.last_modified_date"," > ",query.protectDate("SINCE", options.date1))&" ) AND "&team_sql

			case "BETWEEN"
				sqlFROM="[1].CTM_SUPPORT_GROUP REF,"&sqlFROM
				sqlWHERE=" AND ("&compare_ts( "CHG.SCHEDULED_START_DATE"," > ",query.protectDate("S2", options.date2))&_
				" AND "&compare_ts("CHG.SCHEDULED_END_DATE"," < ",query.protectDate("S1", options.date1))&") AND CHG.SCHEDULED_END_DATE-CHG.SCHEDULED_START_DATE<3*86400 AND CHG.CHANGE_REQUEST_STATUS not in (0,9,10,11,12) AND CHG.ASGRPID=REF.SUPPORT_GROUP_ID "
				case else
				sqlWHERE=QueryFactory_NoResult
			end select
		else
			'ticket_sql2 is full of CI 
			if isArray(options.ticket_sql2) then
				sqlFROM=sqlFROM&" LEFT OUTER JOIN "&schema1&".CHG_ASSOCIATIONS ASSO ON ASSO.request_id02=CHG.INFRASTRUCTURE_CHANGE_ID "
				sqlWHERE=" AND ASSO.request_type01=6000 AND ASSO.request_description01 in ("&query.protectArray("ARR2",options.ticket_sql2)&")"
			else
				'ticket_sql1 is full of tickets 				
				if options.countTicket then 
					if isArray(options.ticket_sql1) then
						if isArray(options.ticket_sql0) then
							sqlWHERE=" AND CHG.INFRASTRUCTURE_CHANGE_ID in ("&query.protectArray("ARR1",options.ticket_sql1)&") or CHG.SRID in ("&query.protectArray("ARR0", options.ticket_sql0)&") "
						else 
							sqlWHERE=" AND CHG.INFRASTRUCTURE_CHANGE_ID in ("&query.protectArray("ARR1",options.ticket_sql1)&") "
						end if
					else 
						'if isArray(options.ticket_sql1) then
							sqlWHERE=" AND CHG.SRID in ("&query.protectArray("ARR0", options.ticket_sql0)&") "
						'end if						
					end if
					if options.countTicket<few_tickets then 
						place2=checkChangeFiles(schema1)
					end if
				else
					sqlFROM="[1].CTM_SUPPORT_GROUP REF,"&sqlFROM
					sqlWHERE=" AND CHG.CHANGE_REQUEST_STATUS not in (11,12) AND "&team_sql
				end if			
			end if
		end if
		
		sqlFROM=" FROM "&replace(sqlFROM,"[1]",schema1)	
		sqlSELECT="SELECT decode(CHG.change_timing,1000,'seeme',null) X_VISIBILITY, CHG.REQUEST_ID X_CHANGE_CODE,CHG.INFRASTRUCTURE_CHANGE_ID CHANGE_ID,"&_
		"decode(CHG.CHANGE_REQUEST_STATUS,"&LIST_CRQ_STATUS_PLUS&",CHG.CHANGE_REQUEST_STATUS )||nvl2(CHG.STATUS_REASON,' ('||decode(CHG.STATUS_REASON,"&LIST_CRQ_REASON&",CHG.STATUS_REASON)||')','') STATUS," &_
		" CHG.Z1D_TEMPLATE_NAME TEMPLATE, CHG.DESCRIPTION SUMMARY,"&place1 &_ 
		"CHG.ASGRP COORD_GROUP,CHG.ASLOGID X_COORDINATOR_LOGIN, P1.CORPORATE_E_MAIL X_COORDINATOR_EMAIL, CHG.aschg coordinator,"&_
		" nvl(rr.region,CHG.LOCATION_COMPANY) REGION,CHG.REGION||' '||CHG.SITE_GROUP LOCATION, inversion_ci(CHG.INFRASTRUCTURE_CHANGE_ID) CI,"&place2&_
		"CHG.SUPPORT_GROUP_NAME MANAGER_GROUP, CHG.cab_manager_login X_manager_LOGIN, p4.CORPORATE_E_MAIL X_manager_EMAIL,p4.full_name manager,"&_
		GetTime("CHG.CHANGE_TARGET_DATE")&" TARGET_DATE,"&_
		GetTime("CHG.SCHEDULED_START_DATE")&" SCHEDULED_START_DATE,"&_ 
		GetTime("CHG.SCHEDULED_END_DATE")&" SCHEDULED_END_DATE,"&_
		"chg.submitter X_SUBMITTER_LOGIN, p2.CORPORATE_E_MAIL X_SUBMITTER_EMAIL, nvl(p2.full_name,chg.submitter) SUBMITTER, "&_
		"decode(CHG.PRIORITY,"&LIST_PRIORITY&") PRIORITY, decode(CHG.PRO_GXPRISKLEVEL,"&LIST_GXP&") GXP,"&_
		GetTime("CHG.last_modified_date")&" LAST_MODIFIED_DATE,"&_
		GetTime("CHG.submit_date")&" SUBMIT_DATE " 
		sql=sqlSELECT&sqlFROM&WhereLimiter&sqlWHERE 
		field_id="CHANGE_ID"
		
	case "CRQ-AP"
		sqlSELECT="SELECT ap.REQUEST X_CHANGE_CODE,ap.INFRASTRUCTURE_CHANGE_ID CHANGE_ID,"&_
		"decode(ap.CHANGE_REQUEST_STATUS,"&LIST_CRQ_STATUS&",ap.CHANGE_REQUEST_STATUS )||nvl2(ap.STATUS_REASON,' ('||decode(ap.STATUS_REASON,"&LIST_CRQ_REASON&",ap.STATUS_REASON)||')','') STATUS, "&_
		"nvl(rr.region,ap.LOCATION_COMPANY) REGION," &_ 		
		"ap.pro_fullname SIGNATURE,decode(ap.APPROVAL_STATUS2,"&LIST_APPROVAL&",ap.APPROVAL_STATUS2) APPRO_STATUS, ap.DESCRIPTION SUMMARY, "&_
		GetTime("ap.PRO_DATE")&" SIGNATURE_DATE, "&_
		GetTime("ap.REQUESTED_START_DATE")&" REQUEST_START_DATE,"&_
		GetTime("ap.SCHEDULED_START_DATE")&" SCHED_START_DATE,"&_
		" ap.ASLOGID X_coordinator_LOGIN, p3.CORPORATE_E_MAIL X_coordinator_EMAIL,p3.full_name coordinator,"&_
		" ap.SUPPORT_GROUP_NAME MANAGER_GROUP,ap.CAB_MANAGER_LOGIN X_manager_LOGIN, p1.CORPORATE_E_MAIL X_manager_EMAIL, p1.full_name manager,"&_
		"ap.SUBMITTER X_submitter_LOGIN, p2.CORPORATE_E_MAIL X_SUBMITTER_EMAIL, nvl(p2.full_name,ap.SUBMITTER) SUBMITTER,"&_
		" ap.APAPPROVERS X_APPROVERS,replace(dbms_lob.substr(ap.FULLNAME, "&QueryFactory_MaxLob&",1),';',chr(13)) APPROVERS, G.SUPPORT_GROUP_NAME APPROUVER_GROUP, replace(dbms_lob.substr(ap.COMMENTS, "&QueryFactory_MaxLob&",1),chr(4),chr(13)) COMMENTS,"&_
		GetTime("ap.SUBMIT_DATE")&" SUBMIT_DATE "
		sqlFROM="FROM "&schema1&".CHG_CHANGEAPDETAILSIGNATURE ap LEFT JOIN "&schema1&".CTM_PEOPLE p1 on (ap.CAB_MANAGER_LOGIN=p1.REMEDY_LOGIN_ID) LEFT JOIN "&schema1&".CTM_PEOPLE p2 on (ap.submitter=p2.REMEDY_LOGIN_ID) LEFT JOIN "&schema1&".CTM_PEOPLE p3 on (ap.ASLOGID=p3.REMEDY_LOGIN_ID) LEFT JOIN "&schema2&".REF_REGION rr on (ap.REGION=rr.country) LEFT JOIN "&schema1&".CTM_SUPPORT_GROUP G ON (G.SUPPORT_GROUP_ID=substr(ORIGINAL_APPROVERS,1,15)) "
		If isArray(options.ticket_sql1) then
			sqlWHERE=" AND ap.INFRASTRUCTURE_CHANGE_ID in ("&query.protectArray("ARR1",options.ticket_sql1)&")"
		else
			sqlWHERE=" AND ap.APPROVAL_STATUS2 in (0,3,4) and ap.CHANGE_REQUEST_STATUS not in (9,10,11,12) AND ap.APAPPROVERS like "&query.protect( "CHAIRMAN", "%" & options.current_user&"%") ' and ap.APPLICATION='CHG:Infrastructure Change'
		end if
		sql=sqlSELECT&sqlFROM&WhereLimiter&sqlWHERE
		field_id="CHANGE_ID"
		
	case "CRQ-CWL"
		sqlSELECT="select CWL.WORK_LOG_ID WORKLOG_ID," &_
		GetTime("CWL.SUBMIT_DATE")&" SUBMIT_DATE, decode(CWL.WORK_LOG_TYPE,"&LIST_CWL_TYPE&",CWL.WORK_LOG_TYPE) TYPE,"&_
		"p2.CORPORATE_E_MAIL X_SUBMITTER_EMAIL,CWL.WORK_LOG_SUBMITTER X_SUBMITTER_LOGIN, nvl(p2.full_name,CWL.WORK_LOG_SUBMITTER) SUBMITTER," &_
		GetFileAttachmentName("CWL.Z2AF_WORK_LOG01")&"||' '||"&GetFileAttachmentName("CWL.Z2AF_WORK_LOG02")&"||' '||"&GetFileAttachmentName("CWL.Z2AF_WORK_LOG03")&" ATTACHMENTS,"&_
		"dbms_lob.substr(CWL.DETAILED_DESCRIPTION,"&QueryFactory_MaxLob&",1) DETAILS, dbms_lob.substr(CWL.DESCRIPTION,"&QueryFactory_MaxLob&",1) SUMMARY "
		sqlFROM=replace("FROM [1].CHG_WORKLOG CWL LEFT JOIN [1].CTM_PEOPLE p2 ON (CWL.WORK_LOG_SUBMITTER=p2.REMEDY_LOGIN_ID)","[1]",schema1) 
		If isArray(options.ticket_sql1) then
			sqlWHERE=" and CWL.INFRASTRUCTURE_CHANGE_ID in ("&query.protectArray("ARR1",options.ticket_sql1)&") order by CWL.WORK_LOG_ID"
		else
			sqlWHERE=QueryFactory_NoResult
		end if
		sql=sqlSELECT&sqlFROM&WhereLimiter&sqlWHERE
		field_id="WORKLOG_ID"
		
	case "CRQ-LOG"
		dim sqlSELECT1, sqlFROM1,sqlSELECT2,sqlFROM2
		sqlSELECT1="SELECT '(audit) '||AL.REQUEST_ID ID,CHG.REQUEST_ID X_CHANGE_CODE, CHG.INFRASTRUCTURE_CHANGE_ID CHANGE_ID, "&GetTimeFull("AL.Audit_date")&" AUDIT_DATE, p2.CORPORATE_E_MAIL X_SUBMITTER_EMAIL,AL.SUBMITTER X_SUBMITTER_LOGIN, nvl(p2.full_name,AL.USER_X) SUBMITTER, dbms_lob.substr(AL.LOG,"&QueryFactory_MaxLob&",1) LOG "
		sqlFROM1=replace(" FROM [1].CHG_INFRASTRUCTURE_CHANGE CHG INNER JOIN [1].CHG_CHANGEREQUEST_AUDITLOGSYST AL ON (CHG.REQUEST_ID=AL.ORIGINAL_REQUEST_ID) LEFT JOIN [1].CTM_PEOPLE p2 ON (AL.USER_X=p2.REMEDY_LOGIN_ID)","[1]",schema1) 
		'field_id="ID"
		sqlSELECT2="SELECT '(event) '||AL.REQUEST_ID ID,CHG.REQUEST_ID X_CHANGE_CODE, CHG.INFRASTRUCTURE_CHANGE_ID CHANGE_ID, "&GetTimeFull("AL.create_date")&" AUDIT_DATE, p2.CORPORATE_E_MAIL X_SUBMITTER_EMAIL, AL.SUBMITTER X_SUBMITTER_LOGIN, AL.pro_fullname SUBMITTER, dbms_lob.substr(AL.pro_eventdetail,"&QueryFactory_MaxLob&",1) LOG "
		sqlFROM2=replace(" FROM [1].CHG_INFRASTRUCTURE_CHANGE CHG INNER JOIN [1].PRO_CHG_AUDITLOG AL ON (CHG.INFRASTRUCTURE_CHANGE_ID=AL.PRO_INFRASTRUCTURECHANGEID) LEFT JOIN [1].CTM_PEOPLE p2 ON (AL.SUBMITTER=p2.REMEDY_LOGIN_ID)","[1]",schema1) 
		if isArray(options.ticket_sql1) then
			sqlWHERE=" AND CHG.INFRASTRUCTURE_CHANGE_ID in ("&query.protectArray("ARR1", options.ticket_sql1)&") "'ORDER BY AL.REQUEST_ID "
		else
			sqlWHERE=QueryFactory_NoResult
		end if
		sql=sqlSELECT1&sqlFROM1&WhereLimiter&sqlWHERE&" UNION "&sqlSELECT2&sqlFROM2&WhereLimiter&sqlWHERE
		field_id="ID"

	case "CRQ-MORE"
		'INFRASTRUCTURE_CHANGE_ID like 'CRQ000000092110'
		sqlSELECT="SELECT CHG.REQUEST_ID X_CHANGE_CODE, CHG.INFRASTRUCTURE_CHANGE_ID CHANGE_ID, CHG.REQUEST_NUMBER X_SERVICE_REQUEST_CODE, CHG.SRID SERVICE_REQUEST_ID, CHG.COPIED_FROM_ORIGINAL_ID COPIED_FROM,"&_
		" CHG.DESCRIPTION SUMMARY, dbms_lob.substr(CHG.DETAILED_DESCRIPTION,"&QueryFactory_MaxLob&",1) DETAILS,"&_
		" CHG.CUSTOMER_FIRST_NAME||' '||CHG.CUSTOMER_LAST_NAME||' <'||CHG.CUSTOMER_INTERNET_E_MAIL||'>' REQUESTED_FOR, decode(CHG.change_timing,"&LIST_CRQ_TIMING&") CHANGE_CLASS,"&_
		" 'DRAFT:'||"&GetTimeFull("CH1.DRAFT_TIME")&_
		" ||', RFA:'||"&GetTimeFull("CH1.REQUEST_FOR_AUTHORIZATION_TIME")&_
		" ||', RFC:'||"&GetTimeFull("CH1.REQUEST_FOR_CHANGE_TIME")&_
		" ||', PIP:'||"&GetTimeFull("CH1.PLANNING_IN_PROGRESS_TIME")&_
		" ||', SFR:'||"&GetTimeFull("CH1.SCHEDULED_FOR_REVIEW_TIME")&_
		" ||', SFA:'||"&GetTimeFull("CH1.SCHEDULED_FOR_APPROVAL_TIME")&_
		" ||', SCHEDULED:'||"&GetTimeFull("CH1.SCHEDULED_TIME")&_ 
		" ||', IIP:'||"&GetTimeFull("CH1.IMPLEMENTATION_IN_PROGRES_TIME")&_ 		
		" ||', COMPLETED:'||"&GetTimeFull("CH1.COMPLETED_TIME")&_ 
		" ||', REJECTED:'||"&GetTimeFull("CH1.REJECTED_TIME")&_
		" ||', PENDING:'||"&GetTimeFull("CH1.PENDING_TIME")&_
		" ||', CLOSED:'||"&GetTimeFull("CH1.CLOSED_TIME")&_	
		" CHANGE_HISTORY,"&_
		" 'Submit:'||"&GetTimeFull("CHG.SUBMIT_DATE") &_
		" ||', Target:'||"&GetTimeFull("CHG.CHANGE_TARGET_DATE")&_	
		" ||', Scheduled:'||"&GetTimeFull("CHG.SCHEDULED_DATE")&_ 
		" ||', ScheduledStart:'||"&GetTimeFull("CHG.SCHEDULED_START_DATE")&_ 
		" ||', ScheduledEnd:'||"&GetTimeFull("CHG.SCHEDULED_END_DATE")&_ 
		" ||', ActualBegin:'||"&GetTimeFull("CHG.ACTUAL_START_DATE")&_
		" ||', ActualEnd:'||"&GetTimeFull("CHG.ACTUAL_END_DATE")&_
		" ||', LastMod:'||"&GetTimeFull("CHG.LAST_MODIFIED_DATE")&_
		" ||' TimeToPlan:'||CHG.TIME_TO_PLAN"&_
		" ||', TimeToApprouve:'||CHG.TIME_TO_APPROVE MORE_HISTORY, "&_
		"(SELECT LISTAGG (decode(cap.approval_status2,"&LIST_APPROVAL&", cap.approval_status2) ||' by '||cap.pro_fullname||' '||"&GetTimeFull("cap.pro_date")&",'; ') WITHIN GROUP (ORDER BY cap.pro_date) approval FROM "&schema1&".CHG_CHANGEAPDETAILSIGNATURE cap WHERE cap.INFRASTRUCTURE_CHANGE_ID=CHG.INFRASTRUCTURE_CHANGE_ID group by cap.INFRASTRUCTURE_CHANGE_ID) approvals, " &_
		"(SELECT LISTAGG(CASE WHEN request_type01=6000 THEN ASSO.request_description01 ELSE ASSO.request_id01 END,', ') WITHIN GROUP (ORDER BY ASSO.request_type01,ASSO.request_description01) FROM "&schema1&".chg_associations ASSO WHERE ASSO.request_id02=CHG.INFRASTRUCTURE_CHANGE_ID) RELATIONSHIPS," &_
		checkChangeFiles(schema1)&_
		"nvl(S1.TASK_COUNT,0)TASK_COUNT,nvl(S1.SEQ_COUNT,0) X_SEQ_COUNT,S2.SEQ_ACTIVE SEQ_ACTIVE,nvl(S2.TASK_ACTIVE,0) X_TAS_ACTIVE,nvl2(CHG.PRODUCT_CAT_TIER_3,CHG.PRODUCT_CAT_TIER_1||' | '||CHG.PRODUCT_CAT_TIER_2||' | '||CHG.PRODUCT_CAT_TIER_3,null) PRODUCT_TIER "
		
		sqlFROM =" FROM "&schema1&".CHG_INFRASTRUCTURE_CHANGE CHG LEFT JOIN "&schema1&".SH_CHG_INFRASTRUCTURE_CHANGE CH1 ON (CH1.REQUEST_ID=CHG.REQUEST_ID) LEFT JOIN (select TSK1.ROOTREQUESTID, count(TSK1.TASK_ID) TASK_COUNT, count(distinct TSK1.SEQUENCE) SEQ_COUNT from "&schema1&".TMS_Task TSK1 group by TSK1.ROOTREQUESTID) S1 ON (S1.ROOTREQUESTID=CHG.INFRASTRUCTURE_CHANGE_ID)"&_
		" LEFT JOIN (select TSK2.ROOTREQUESTID, min(TSK2.SEQUENCE) SEQ_ACTIVE, count(TSK2.TASK_ID) TASK_ACTIVE from "&schema1&".TMS_Task TSK2 where TSK2.status in (2000,3000,4000,5000) group by TSK2.ROOTREQUESTID) S2 ON (S2.ROOTREQUESTID=CHG.INFRASTRUCTURE_CHANGE_ID AND CHANGE_REQUEST_STATUS in(6,7))"
		if isArray(options.ticket_sql1) then
			sqlWHERE=" AND CHG.INFRASTRUCTURE_CHANGE_ID in ("&query.protectArray("ARR1",options.ticket_sql1)&") "
		else
			sqlWHERE=QueryFactory_NoResult
		end if
		sql=sqlSELECT&sqlFROM&WhereLimiter&sqlWHERE
		field_id="CHANGE_ID"
		
	case "CRQ-COOK"
'"LEFT JOIN (SELECT ROOTREQUESTID,SUM(CASE WHEN BAD_START>0 THEN 1 ELSE 0 END) BAD_START, SUM(CASE WHEN BAD_END>0 THEN 1 ELSE 0 END) BAD_END FROM (SELECT T2.ROOTREQUESTID, T2.TASK_ID, SUM(CASE WHEN T2.SCHEDULED_START_DATE<T1.SCHEDULED_START_DATE THEN 1 ELSE 0 END) BAD_START, SUM(CASE WHEN (T2.SCHEDULED_END_DATE-T1.SCHEDULED_END_DATE)<300 THEN 1 ELSE 0 END) BAD_END FROM "&schema1&".tms_task t1 INNER JOIN "&schema1&".tms_task t2 ON (T1.ROOTREQUESTID=T2.ROOTREQUESTID) WHERE T1.SEQUENCE<T2.SEQUENCE AND NOT (T1.STATUS=6000 AND T1.STATUSREASONSELECTION=3000) AND NOT (T2.STATUS=6000 AND T2.STATUSREASONSELECTION=3000) GROUP BY T2.ROOTREQUESTID,T2.TASK_ID) GROUP BY ROOTREQUESTID) TSK1 ON (CHG.INFRASTRUCTURE_CHANGE_ID=TSK1.ROOTREQUESTID) "&_
'	"( select regexp_substr(ORIGINAL_APPROVERS,'SGP[0-9]+', 1, level) SGP from dual  connect by regexp_substr(ORIGINAL_APPROVERS,'SGP[0-9]+', 1, level) is not null ) ;
'		"nvl(BAD_START,0) TASKS_BAD_SCHEDULED_START,nvl(BAD_END,0) TASKS_BAD_SCHEDULED_END,"&_

		sqlSELECT="SELECT CHG.REQUEST_ID X_CHANGE_CODE, CHG.INFRASTRUCTURE_CHANGE_ID CHANGE_ID,CHG.Z1D_TEMPLATE_NAME TEMPLATE, decode(CHG.change_timing,"&LIST_CRQ_TIMING&") CHANGE_CLASS,decode(CHG.CHANGE_REQUEST_STATUS,"&LIST_CRQ_STATUS_PLUS&",CHG.CHANGE_REQUEST_STATUS)||nvl2(CHG.STATUS_REASON,' ('||decode(CHG.STATUS_REASON,"&LIST_CRQ_REASON&",CHG.STATUS_REASON)||')','') ||CASE WHEN TSK3.CNT is null THEN ' without tasks' END || CASE WHEN TSK3.WITH_FAILED>0 THEN ' with '||TSK3.WITH_FAILED||'/'||TSK3.CNT||' tasks failed' END STATUS,CHG.DESCRIPTION SUMMARY,"&_ 
		" nvl(CASE WHEN CHG.ASLOGID = CHG.CAB_MANAGER_LOGIN THEN 'One can not be coordinator and manager. ' ELSE null END || CASE WHEN (SELECT COUNT (*) bad_implementer FROM "&schema1&".tms_task t4 WHERE CHG.INFRASTRUCTURE_CHANGE_ID=T4.ROOTREQUESTID AND (T4.ASSIGNED_TO=CHG.ASLOGID OR CHG.CAB_MANAGER_LOGIN=T4.ASSIGNED_TO))>0 THEN 'Tasks are assigned to change coordinator or manager.' ELSE null END,'PASS') SEGREGATION_OF_DUTIES, CASE "&_
			"WHEN CHG.CHANGE_REQUEST_STATUS<6 THEN 'NA' "&_
			"WHEN CHG.ACTUAL_START_DATE>CH1.SCHEDULED_TIME THEN CASE WHEN TSK3.MIN_TASK_SCHED_DATE-CH1.SCHEDULED_TIME>259200 THEN 'PASS*' ELSE 'PASS' END "&_
			"WHEN MIN_TASK_ACTUAL_START_DATE is null THEN 'WARNING: not started' "&_
			"WHEN CHG.change_timing=1000 THEN 'WARNING: emergency exception' "&_
			"WHEN CHG.change_timing=6000 THEN 'WARNING: standard exception' "&_
		"ELSE 'FAIL' END AUTHORIZED_CHANGE, CASE "&_
			"WHEN TSK3.ROOTREQUESTID is null THEN 'WARNING: no task' "&_
			"WHEN TSK3.FIRST_TASK_ACTIVATE_TIME<TSK3.MAX_TASK_CREATE_DATE THEN 'WARNING: task created during implementation' "&_
			"WHEN CHG.change_timing=6000 AND (TSK3.MAX_TASK_CREATE_DATE-TSK3.MIN_TASK_CREATE_DATE)>60 THEN 'WARNING: task added to standard change' "&_
			"WHEN CHG.Z1D_TEMPLATE_NAME is not null AND (TSK3.MAX_TASK_CREATE_DATE-TSK3.MIN_TASK_CREATE_DATE)>60 THEN 'WARNING: task added to template change'"&_
			"WHEN AP1.LAST_APPROVAL<TSK3.MAX_TASK_CREATE_DATE THEN 'WARNING: TASK created after approval' "&_
		"ELSE 'PASS' END AUTHORIZED_TASK, "&_
		"CASE WHEN REL.CI>0 THEN 'PASS' ELSE 'FAIL' END RELATIONSHIPS_QUALITY,"&_
		"CASE WHEN CHG.PRO_GXPRISKLEVEL is not null AND (CHG.PRO_GXPRISKLEVEL>=REL.GXP_LVL or REL.GXP_LVL is null) THEN 'PASS' WHEN CHG.PRO_GXPRISKLEVEL=1000 AND CHG.PRO_GXPRISKLEVEL<REL.GXP_LVL THEN 'FAIL: should be GxP' WHEN CHG.PRO_GXPRISKLEVEL is null THEN 'FAIL: not set' ELSE 'WARNING: level mismatch' END GXP_QUALITY,"&_
		"CASE WHEN AP2.GXP_APP>0 THEN 'PASS' WHEN GREATEST(nvl(CHG.PRO_GXPRISKLEVEL,0),nvl(REL.GXP_LVL,0))=1000 THEN 'NOT REQUIRED' WHEN CHG.change_timing=6000 THEN 'NOT REQUIRED' ELSE 'FAIL' END GXP_QUALITY_APPROVED,"&_
		"CASE WHEN CHG.REGION is null THEN 'FAIL' WHEN CHG.LOCATION_COMPANY in ('SUPPORT FUNCTIONS','GENZYME','MERIAL') THEN 'PASS' WHEN CHG.LOCATION_COMPANY in ('INFRASTRUCTURE SERVICES') THEN 'WARNING, only global change can use INFRASTRUCTURE SERVICES' ELSE 'FAIL' END CHANGE_LOCATION_QUALITY, "&_
		"CASE WHEN length(CHG.DESCRIPTION)>10 THEN 'PASS' ELSE 'FAIL' END SUMMARY_LENGTH,"&_
		"CASE WHEN length(DBMS_LOB.SUBSTR(CHG.DETAILED_DESCRIPTION,128,1))<50 THEN 'FAIL' WHEN CHG.DESCRIPTION<>DBMS_LOB.SUBSTR(CHG.DETAILED_DESCRIPTION,128,1) THEN 'PASS' ELSE 'FAIL' END NOTES_QUALITY,"&_
			"CASE WHEN SI>0 THEN 'PASS' WHEN CHG.change_timing<>6000 THEN 'FAIL' ELSE 'NA' END SERVICE_IMPACT_LENGTH,"&_
			"CASE WHEN IP>0 THEN 'PASS' WHEN CHG.change_timing<>6000 THEN 'FAIL' ELSE 'NA' END INSTALL_PLAN_LENGTH,"&_
			"CASE WHEN TP>0 THEN 'PASS' WHEN CHG.change_timing<>6000 THEN 'FAIL' ELSE 'NA' END TEST_PLAN_LENGTH,"&_
			"CASE WHEN BP>0 THEN 'PASS' WHEN CHG.change_timing<>6000 THEN 'FAIL' ELSE 'NA' END BACKOUT_LENGTH,"&_
			"CASE WHEN CHG.SCHEDULED_START_DATE-CH1.SCHEDULED_FOR_REVIEW_TIME<172800 THEN 'Required for timing' ELSE 'NA' END BUSINESS_JUSTIFICATION,"&_ 
		"CASE WHEN CHG.CHANGE_REQUEST_STATUS in (10,11) THEN '' ELSE 'WILL ' END||CASE WHEN TR>0 THEN 'PASS' ELSE 'FAIL' END TEST_RESULT_LENGTH,"&_
		"CASE WHEN CHG.ACTUAL_START_DATE is null OR CHG.ACTUAL_END_DATE is null THEN 'NA' WHEN (CHG.ACTUAL_START_DATE-CHG.ACTUAL_END_DATE)<=259200 THEN 'YES' ELSE 'NO' END TREE_DAYS_CHANGE,"&_ 
		GetTimeFull("AP1.LAST_APPROVAL")&" LAST_APPROVAL_DATE,"&_
		GetTimeFull("CH1.SCHEDULED_TIME")&" SCHEDULED_DATE,"&_
		GetTimeFull("CHG.ACTUAL_START_DATE")&" CHANGE_ACTUAL_START_DATE,"&_
		GetTimeFull("TSK3.FIRST_TASK_ACTIVATE_TIME")& " FIRST_TASK_ACTIVATE_TIME,"&_
		GetTimeFull("MIN_TASK_ACTUAL_START_DATE")&" MIN_TASK_ACTUAL_START_DATE,"&_
		GetTimeFull("CASE WHEN CHG.ACTUAL_START_DATE>CH1.SCHEDULED_TIME THEN CHG.ACTUAL_START_DATE ELSE CH1.SCHEDULED_TIME+60 END ")&_
		" SUGGESTED_ACTUAL_START_TIME, nvl(rr.region,CHG.LOCATION_COMPANY) REGION, CHG.cab_manager_login X_manager_LOGIN, p4.CORPORATE_E_MAIL X_manager_EMAIL,p4.full_name manager "
		sqlFROM=schema1&".CHG_INFRASTRUCTURE_CHANGE CHG LEFT JOIN "&schema1&".SH_CHG_INFRASTRUCTURE_CHANGE CH1 ON (CH1.REQUEST_ID=CHG.REQUEST_ID)LEFT JOIN "&schema1&".CTM_PEOPLE p4 ON (CHG.cab_manager_login=p4.REMEDY_LOGIN_ID)  LEFT JOIN "&schema2&".REF_REGION rr ON (CHG.REGION=rr.country) "&_
		"LEFT JOIN (select C10051, Max(cap.C600001018) LAST_APPROVAL FROM "&schema1&".T171 cap GROUP BY cap.C10051) ap1 ON (ap1.C10051=CHG.REQUEST_ID) "&_
		"LEFT JOIN (select C10051,count(*) GXP_APP from (select cap.C10051  FROM "&schema1&".T171 cap LEFT JOIN "&schema1&".CTM_SUPPORT_GROUP G ON (G.SUPPORT_GROUP_ID=substr(cap.C13203,1,15)) where cap.C13191=1 AND G.SUPPORT_GROUP_NAME like 'APQ%GIS_QUALITY%') group by C10051) ap2 ON (ap2.C10051=CHG.REQUEST_ID) "&_
		"LEFT JOIN (SELECT T1.ROOTREQUESTID, Min(T1.ACTIVATE_TIME) FIRST_TASK_ACTIVATE_TIME, Min(T1.ACTUAL_START_DATE) MIN_TASK_ACTUAL_START_DATE, Max(T1.CREATE_DATE) MAX_TASK_CREATE_DATE, Min(T1.CREATE_DATE) MIN_TASK_CREATE_DATE, Min(T1.SCHEDULED_START_DATE) MIN_TASK_SCHED_DATE, sum(CASE WHEN T1.STATUSREASONSELECTION=2000 AND T1.STATUS=6000 THEN 1 ELSE 0 END) WITH_FAILED, count(T1.TASK_ID) CNT"&_
		" FROM "&schema1&".tms_task t1 WHERE not(T1.STATUS=6000 AND T1.STATUSREASONSELECTION=3000) GROUP BY T1.ROOTREQUESTID) TSK3 ON (CHG.INFRASTRUCTURE_CHANGE_ID=TSK3.ROOTREQUESTID) "&_
		"LEFT JOIN (SELECT INFRASTRUCTURE_CHANGE_ID,SUM(CASE WHEN WORK_LOG_TYPE=20000 THEN CNT ELSE 0 END) TR,SUM(CASE WHEN WORK_LOG_TYPE=16000 THEN CNT ELSE 0 END) TP,SUM(CASE WHEN WORK_LOG_TYPE=14000 THEN CNT ELSE 0 END) IP,SUM(CASE WHEN WORK_LOG_TYPE=11000 THEN CNT ELSE 0 END) BP,SUM(CASE WHEN WORK_LOG_TYPE=9000 THEN CNT ELSE 0 END) SI FROM (SELECT INFRASTRUCTURE_CHANGE_ID,WORK_LOG_TYPE,count(*) CNT FROM "&schema1&".CHG_WORKLOG WHERE (length(DBMS_LOB.SUBSTR(DETAILED_DESCRIPTION,128,1))>50 or length(Z2AF_WORK_LOG01)>3 or length(Z2AF_WORK_LOG02)>3 or length(Z2AF_WORK_LOG03)>3) AND WORK_LOG_TYPE in (20000,16000,14000,11000,9000) GROUP BY INFRASTRUCTURE_CHANGE_ID,WORK_LOG_TYPE) GROUP BY INFRASTRUCTURE_CHANGE_ID) CWL ON (CWL.INFRASTRUCTURE_CHANGE_ID=CHG.INFRASTRUCTURE_CHANGE_ID) "&_
		"LEFT JOIN (SELECT REQUEST_ID02,count(*) CI, max(PRO_GXPRISKLEVEL) GXP_LVL FROM "&schema1&".chg_associations WHERE request_type01=6000 and LOOKUP_KEYWORD<>'BMC_BUSINESSSERVICE' GROUP BY REQUEST_ID02) REL ON (REL.REQUEST_ID02=CHG.INFRASTRUCTURE_CHANGE_ID)"
		if options.isFeature then 
			team_sql=pointOfViewChange(options.sens_rech,options.isMyself)
			select case options.featureName
			case "FRESH_CLOSED"
				sqlFROM=schema1&".CTM_SUPPORT_GROUP REF,"&sqlFROM
				sqlWHERE=" AND CHG.CHANGE_REQUEST_STATUS=11 AND ("&compare_ts( "CHG.CLOSED_DATE"," > ", query.protectDate("SINCE", options.date1))&" ) AND "&team_sql
			case else
				sqlWHERE=QueryFactory_NoResult
			end select
		elseif isArray(options.ticket_sql1) then
			sqlWHERE=" AND CHG.INFRASTRUCTURE_CHANGE_ID in ( "&query.protectArray( "ARR1", options.ticket_sql1 )&") "
		else
			sqlFROM=sqlFROM&", "&schema1&".CTM_SUPPORT_GROUP REF"
			sqlWHERE=" AND CHG.CHANGE_REQUEST_STATUS=10 AND "&pointOfViewChange(options.sens_rech,options.isMyself)
		end if
		sql=sqlSELECT&" FROM "&sqlFROM&WhereLimiter&sqlWHERE
		field_id="CHANGE_ID"
		
	case "CRQ-FREESE"
		sqlSELECT ="SELECT decode(CHG.change_timing,1000,'seeme',null)  X_VISIBILITY, CHG.REQUEST_ID X_CHANGE_CODE, CHG.INFRASTRUCTURE_CHANGE_ID CHANGE_ID, CHG.DESCRIPTION SUMMARY,"&_
		" decode(CHG.CHANGE_REQUEST_STATUS,"&LIST_CRQ_STATUS_PLUS&",CHG.CHANGE_REQUEST_STATUS)||nvl2(CHG.STATUS_REASON,' (' || decode(CHG.STATUS_REASON,"&LIST_CRQ_REASON&",CHG.STATUS_REASON)||')','') STATUS,"&_
		" CHG.asgrp coord_group, p1.REMEDY_LOGIN_ID X_coordinator_LOGIN, p1.CORPORATE_E_MAIL X_coordinator_EMAIL, CHG.aschg coordinator,"&_
		" CHG.SUPPORT_GROUP_NAME MANAGER_GROUP,CHG.cab_manager_login X_manager_LOGIN, p4.CORPORATE_E_MAIL X_manager_EMAIL, p4.full_name manager,"&_
		" nvl(S1.TASK_COUNT,0) TASK_COUNT, nvl(S1.SEQ_COUNT,0) X_SEQ_COUNT, S2.LAST_CLOSED_SEQ, S2.CLOSED_TASKS  FROM " 
		sqlFROM=replace("[1].CHG_Infrastructure_Change CHG INNER JOIN "&_
		"(select TSK1.ROOTREQUESTID,count(TSK1.TASK_ID) TASK_COUNT, count(distinct TSK1.SEQUENCE) SEQ_COUNT from [1].TMS_Task TSK1 group by TSK1.ROOTREQUESTID ) S1"&_
		" ON (S1.ROOTREQUESTID=CHG.INFRASTRUCTURE_CHANGE_ID) LEFT JOIN "&_
		"(select TSK2.ROOTREQUESTID, max(TSK2.SEQUENCE) LAST_CLOSED_SEQ, count(TSK2.TASK_ID) CLOSED_TASKS from [1].TMS_Task TSK2 where TSK2.status in (6000) group by TSK2.ROOTREQUESTID)S2" &_
		" ON (S2.ROOTREQUESTID=CHG.INFRASTRUCTURE_CHANGE_ID)" &_
		" LEFT JOIN [1].CTM_PEOPLE p1 ON (CHG.ASLOGID=p1.REMEDY_LOGIN_ID)"&_
		" LEFT JOIN [1].CTM_PEOPLE p4 ON (CHG.cab_manager_login=p4.REMEDY_LOGIN_ID) " , "[1]",schema1)
		
		sqlWHERE=sqlWHERE&" and CHANGE_REQUEST_STATUS in (6,7) and not exists( SELECT TASK_ID FROM "&schema1&".TMS_Task TSK3 WHERE TSK3.ROOTREQUESTID=CHG.INFRASTRUCTURE_CHANGE_ID AND TSK3.status in (2000,3000,4000,5000))"
		'les change implem' qui n'ont pas de taches actives et qui ont des taches.
		
		if options.isFeature=false or options.featureName<>"IMPLEMENTATION" then
			sqlFROM=sqlFROM & ", "&schema1&".CTM_SUPPORT_GROUP REF "
			sqlWHERE = sqlWHERE & " AND "&pointOfViewChange(options.sens_rech,options.isMyself)
			caption=" buggy changes are searched according to your support group configuration."
		else
			caption=" buggy changes are searched for any support groups."
		end if
		sql=sqlSELECT&sqlFROM&WhereLimiter&sqlWHERE 
		field_id="CHANGE_ID"
		caption=" Those change do not have any task activated wheras they should. Use ""IMPLEMENTATION"" feature to remove the filter on support groups."
		
	case "CRQ-TEMPLATE"
		sqlSELECT ="select ct.CHG_TEMPLATE_ID,ct.template_name, ct.DESCRIPTION, decode(ct.status, 0, 'Proposed', 1, 'Enabled', 2, 'Offline', 3, 'Obsolete', 4, 'Archive', 5, 'Delete') template_status, ct.categorization_tier_1||' | '||ct.categorization_tier_2||' | '||ct.categorization_tier_3 CATEGORY, decode(ct.urgency,"&LIST_CRQ_URGENCY&")||' + '||decode(ct.impact,"&LIST_CRQ_IMPACT&")||' = '||decode(ct.PRIORITY,"&LIST_PRIORITY&") URGENCY_IMPACT_PRIORITY, decode(ct.change_timing,"&LIST_CRQ_TIMING&") CHANGE_CLASS,ct.reason_for_change, ct.asgrp||' ('||ct.asgrpid||')' COORDINATOR_GROUP,ct.SUPPORT_GROUP_NAME||' ('||ct.support_group_id||')' MANAGER_GROUP, ct.CAB_MANAGER___CHANGE_CO_ORD__  CRQ_default_manager, ttt.TEMPLATE_ID as task_template_id, ttt.taskname, ttt.ASSIGNEE_GROUP||' ('||ttt.ASSIGNEE_GROUP_ID||')' TASK_ASSIGNEE_GROUP,ttt.SUMMARY TASK_SUMMARY, tsd.sequence TASK_SEQUENCE, ttt.category TASK_CATEGORY,ttt.ESTIMATEDTOTALTIME WORKLOAD,  dbms_lob.substr(ttt.notes, "&QueryFactory_MaxLob&",1) DETAILS, ct.authoring_group ||' ('||CT.AUTHOR_GROUP_ID ||')' AUTHOR_GROUP,ct.LAST_MODIFIED_BY TEMPLATE_MODIFIED_BY, tat.LAST_MODIFIED_BY ASSOCIATION_MODIFIED_BY, ttt.LAST_MODIFIED_BY TASK_MODIFIED_BY,(select LISTAGG(ct1.CHG_TEMPLATE_ID,' ') within group (order by ct1.CHG_TEMPLATE_ID) from "&replace("[1].chg_template ct1 inner join [1].tms_associationtemplate tat1 on (tat1.parent_id=ct1.instanceid) where ct1.CHG_TEMPLATE_ID<>ct.CHG_TEMPLATE_ID and tat1.child_id = ttt.instanceid","[1]",schema1)&") SHARED_WITH_TEMPLATE_ID "
		sqlFROM= replace( "from [1].chg_template ct left join [1].tms_associationtemplate tat on (tat.parent_id=ct.instanceid) left join [1].tms_tasktemplate ttt on (tat.child_id=ttt.instanceid) left join [1].tms_summarydata tsd on (tsd.associationentryinstanceid=tat.instanceid)","[1]",schema1)
		
		if isArray(options.ticket_sql1) then
			sqlFROM=sqlFROM &" INNER JOIN (SELECT DISTINCT CHG_TEMPLATE_ID_PREVIOUS FROM "&schema1&".CHG_Infrastructure_Change CHG WHERE CHG.INFRASTRUCTURE_CHANGE_ID in ("&query.protectArray("ARR1", options.ticket_sql1)&")) l ON (ct.CHG_TEMPLATE_ID=l.CHG_TEMPLATE_ID_PREVIOUS)"
			caption=" Showing template for the change listed in search box."
		else
			caption=" Showing template for all change matching support group and view configuration. Not compatible with <em>myself</em> smart group."
			sqlWHERE=" AND "&pointOfViewChangeTemplate(options.sens_rech,true) 
		end if
		sql=sqlSELECT&sqlFROM&WhereLimiter&sqlWHERE
		field_id="CHG_TEMPLATE_ID"
	case else
		generateSelectNotFound options.type_ticket, options.query_selector 
	end select
	
end sub



private sub builderNgdcINC(options)
	dim team_sql 
	dim sqlSELECT, sqlFROM, sqlWHERE, sqlWHERE1
	
	'sqlWHERE=" WHERE (rownum<="&C_MAX_ROW&") "
	select case options.query_selector 	
	case "INC"
		team_sql=pointOfViewIncident(options.sens_rech,options.isMyself)
		sqlSELECT="SELECT INC.ENTRY_ID X_INCIDENT_CODE, INC.INCIDENT_NUMBER INCIDENT_ID, INC.DESCRIPTION, INC.ASSIGNED_GROUP ASSIGNED_GROUP,INC.ASSIGNEE_LOGIN_ID X_ASSIGNEE_LOGIN,p2.CORPORATE_E_MAIL X_ASSIGNEE_EMAIL, p2.full_name ASSIGNEE,"&_
		 "INC.hpd_ci ci,decode(INC.HPD_CI_FORMNAME,'BMC_COMPUTERSYSTEM',ACS.REGION, 'BMC_APPLICATION',AA.REGION, 'BMC_APPLICATIONSERVICE',AASER.REGION,'BMC_APPLICATIONSYSTEM',AASYS.REGION, 'BMC_DATABASE',AD.REGION,'BMC_EQUIPMENT',AE.REGION, 'BMC_PRODUCT',APROD.REGION,'BMC_CLUSTER',BCLUST.REGION,'') CI_COUNTRY,"&_
		 " decode(INC.HPD_CI_FORMNAME,'BMC_COMPUTERSYSTEM',ACS.SITE, 'BMC_APPLICATION',AA.SITE,'BMC_APPLICATIONSERVICE',AASER.SITE,'BMC_APPLICATIONSYSTEM',AASYS.SITE,'BMC_DATABASE',AD.SITE, 'BMC_EQUIPMENT',AE.SITE, 'BMC_PRODUCT',APROD.SITE,'BMC_CLUSTER',BCLUST.REGION,'?') CI_SITE,"&_
		 "decode(INC.PRIORITY,"&LIST_PRIORITY&") PRIORITY,"&_
		 "decode(INC.status,"&LIST_INC_STATUS&",INC.status) STATUS,"&_
		 GetTime("INC.LAST_MODIFIED_DATE")&" LAST_MODIFIED_DATE, "&_
		 "INC.SUBMITTER X_SUBMITTER_LOGIN, p1.CORPORATE_E_MAIL X_SUBMITTER_EMAIL, p1.full_name SUBMITTER,INC.OWNER_GROUP SUBMITTER_GROUP,"&_
		 GetTime("INC.SUBMIT_DATE")&" SUBMIT_DATE "	 
		 sqlFROM="[1].HPD_Help_Desk INC LEFT JOIN [1].CTM_PEOPLE p1 ON(INC.SUBMITTER=p1.REMEDY_LOGIN_ID) LEFT JOIN [1].CTM_PEOPLE p2 ON (INC.ASSIGNEE_LOGIN_ID=p2.REMEDY_LOGIN_ID)"&_
		" LEFT JOIN [1].AST_COMPUTERSYSTEM ACS ON (inc.HPD_CI_RECONID=ACS.RECONCILIATION_IDENTITY) LEFT JOIN [1].AST_APPLICATION AA ON (inc.HPD_CI_RECONID=AA.RECONCILIATION_IDENTITY) LEFT JOIN [1].AST_APPLICATIONSERVICE AASER ON (inc.HPD_CI_RECONID=AASER.RECONCILIATION_IDENTITY) LEFT JOIN [1].AST_APPLICATIONSYSTEM AASYS ON (inc.HPD_CI_RECONID=AASYS.RECONCILIATION_IDENTITY) LEFT JOIN [1].AST_DATABASE AD ON (inc.HPD_CI_RECONID=AD.RECONCILIATION_IDENTITY) LEFT JOIN [1].AST_EQUIPMENT AE ON (inc.HPD_CI_RECONID=AE.RECONCILIATION_IDENTITY) LEFT JOIN [1].AST_PRODUCT APROD ON (inc.HPD_CI_RECONID=APROD.RECONCILIATION_IDENTITY) LEFT JOIN [1].BMC_CORE_BMC_CLUSTER BCLUST on (inc.HPD_CI_RECONID=BCLUST.RECONCILIATIONIDENTITY)"

		if options.isFeature then 
			select case options.featureName
			case "P1"
				sqlFROM="[1].CTM_SUPPORT_GROUP REF,"&sqlFROM
				sqlWHERE=" AND (INC.PRIORITY=0) AND inc.status IN (1,2,3,4) AND "&team_sql
			case "ALL_SINCE"
				sqlFROM="[1].CTM_SUPPORT_GROUP REF,"&sqlFROM
				sqlWHERE=" AND "&compare_ts("INC.LAST_MODIFIED_DATE"," > ",query.protectDate("SINCE",options.date1))&" AND "&team_sql
			case "REVIEW"
				sqlFROM="[1].CTM_SUPPORT_GROUP REF,"&sqlFROM
				sqlWHERE=" AND INC.status="&query.protect("STATUS",1)&" AND "&team_sql
			case "IMPLEMENTATION"
				sqlFROM="[1].CTM_SUPPORT_GROUP REF,"&sqlFROM
				sqlWHERE=" AND INC.status="&query.protect("STATUS",2)&" AND "&team_sql
			case "PENDING"
				sqlFROM="[1].CTM_SUPPORT_GROUP REF,"&sqlFROM
				sqlWHERE=" AND INC.status="&query.protect("STATUS",3)&" AND "&team_sql
			case "DONE"
				sqlFROM="[1].CTM_SUPPORT_GROUP REF,"&sqlFROM
				sqlWHERE=" AND INC.status="&query.protect("STATUS",4)&" AND "&team_sql
			case "FRESH_CLOSED"
				sqlFROM="[1].CTM_SUPPORT_GROUP REF,"&sqlFROM
				sqlWHERE=" AND INC.status=5 AND "&compare_ts("INC.CLOSED_DATE"," > ",query.protectDate("SINCE", options.date1))&" AND "&team_sql
			case "FROM_TOOL"
				sqlFROM="[1].CTM_SUPPORT_GROUP REF,"&sqlFROM
				sqlWHERE=" AND INC.status not in(5,6) AND INC.SUBMITTER="&query.protect("TOOL",QueryFactory_MONITORING)&" AND "&pointOfViewIncident(SENS_ASSIGNED,options.isMyself)
				options.sens_rech=SENS_ASSIGNED
			case else
				sqlWHERE=QueryFactory_NoResult
			end select
		 else
			if isArray(options.ticket_sql2) then 
				sqlWHERE=" AND INC.hpd_ci in ("&query.protectArray( "ARR2", options.ticket_sql2)&")"
			elseif isArray(options.ticket_sql1) then 
				sqlWHERE=" AND (inc.INCIDENT_NUMBER in ("&query.protectArray("ARR1",options.ticket_sql1)&"))"
			else
				sqlFROM="[1].CTM_SUPPORT_GROUP REF,"&sqlFROM
				sqlWHERE=" AND inc.status IN (1,2,3) AND "&team_sql
			end if 
		end if
		sqlFROM="FROM "&replace(sqlFROM,"[1]",schema1)
		sql="SELECT TBL.X_INCIDENT_CODE, TBL.INCIDENT_ID, TBL.DESCRIPTION SUMMARY,TBL.CI, TBL.ASSIGNED_GROUP, TBL.X_ASSIGNEE_LOGIN, TBL.X_ASSIGNEE_EMAIL, TBL.ASSIGNEE," &_ 
		" rr.region REGION, tbl.CI_COUNTRY||NVL2(tbl.CI_SITE,' '|| tbl.CI_SITE,'') CI_LOCATION, "&_
		"TBL.PRIORITY,TBL.STATUS,TBL.SUBMITTER_GROUP,TBL.X_SUBMITTER_LOGIN, TBL.X_SUBMITTER_EMAIL,TBL.SUBMITTER,"&_
		 "TBL.LAST_MODIFIED_DATE, TBL.SUBMIT_DATE FROM ("&_
		sqlSELECT&sqlFROM&WhereLimiter&sqlWHERE&") tbl LEFT JOIN "&schema2&".REF_REGION rr ON (tbl.CI_COUNTRY=rr.country)"
		field_id="INCIDENT_ID"
	
	case "INC-MORE"
		sqlSELECT="SELECT INC.ENTRY_ID X_INCIDENT_CODE, INC.INCIDENT_NUMBER INCIDENT_ID, dbms_lob.substr(INC.DETAILED_DECRIPTION,"&QueryFactory_MaxLob&",1) DETAILS, dbms_lob.substr(INC.RESOLUTION,"&QueryFactory_MaxLob&",1) RESOLUTION, (select LISTAGG(case when ASSO.REQUEST_TYPE01=6000 THEN ASSO.request_description01 ELSE ASSO.request_id01 END,', ') WITHIN GROUP (ORDER BY ASSO.request_type01,ASSO.request_description01) from "&schema1&".hpd_associations ASSO where ASSO.request_id02=INC.INCIDENT_NUMBER ) RELATIONSHIPS"
		sqlFROM=" FROM "&replace("[1].HPD_Help_Desk INC LEFT JOIN [1].CTM_PEOPLE p1 ON(INC.SUBMITTER=p1.REMEDY_LOGIN_ID) ","[1]",schema1)
		if isArray(options.ticket_sql1) then 
			sqlWHERE=" AND (inc.INCIDENT_NUMBER in ("&query.protectArray("ARR1",options.ticket_sql1)&"))"
		else
			sqlWHERE=sqlWHERE&QueryFactory_NoResult
		end if 
		sql=sqlSELECT&sqlFROM&WhereLimiter&sqlWHERE
		field_id="INCIDENT_ID"
	
	case "INC-WLG"
		sqlSELECT="select WLG.WORK_LOG_ID WORKLOG_ID, WLG.INCIDENT_ENTRY_ID X_INCIDENT_CODE, WLG.INCIDENT_NUMBER INCIDENT_ID, "&_
		"decode(WLG.WORK_LOG_TYPE,"&LIST_WLG_TYPE&",WLG.WORK_LOG_TYPE ) TYPE,"&_
		GetFileAttachmentName("WLG.Z2AF_WORK_LOG01") &" ||' '||"&GetFileAttachmentName( "WLG.Z2AF_WORK_LOG02")&"||' '||"&GetFileAttachmentName("WLG.Z2AF_WORK_LOG03")&" ATTACHMENTS, " &_
		"p2.CORPORATE_E_MAIL X_SUBMITTER_EMAIL, p2.REMEDY_LOGIN_ID X_SUBMITTER_LOGIN, p2.full_name SUBMITTER, " &_
		GetTime("WLG.SUBMIT_DATE")&" SUBMIT_DATE, WLG.DESCRIPTION SUMMARY, dbms_lob.substr( WLG.DETAILED_DESCRIPTION,"&QueryFactory_MaxLob&",1) DETAILS "
	'	GetTime("WLG.WORK_LOG_DATE")&" WORKLOG_DATE"	
		sqlFROM=replace("FROM [1].HPD_WORKLOG WLG LEFT JOIN [1].CTM_PEOPLE p2 ON (WLG.SUBMITTER=p2.REMEDY_LOGIN_ID)","[1]",schema1) 

	'	team_sql="(CHG.ASGRP in ("&currentTeamName&") or CHG.SUPPORT_GROUP_NAME in ("&currentTeamName&")) "
		If isArray(options.ticket_sql1) then
			sqlWHERE=" and WLG.INCIDENT_NUMBER in ("&query.protectArray("ARR1",options.ticket_sql1)&") order by WLG.WORK_LOG_ID"
		else
			sqlWHERE=QueryFactory_NoResult
		end if	
		sql=sqlSELECT&sqlFROM&WhereLimiter&sqlWHERE
		field_id="INCIDENT_ID"
		
	case "INC-LOG" 
		If isArray(options.ticket_sql1) then ' ORDER BY HDA.LAST_MODIFIED_DATE DESC
			team_sql=query.protectArray("ARR1",options.ticket_sql1)
			sqlWHERE=" AND INC.INCIDENT_NUMBER in ("&team_sql&") "			
		else
			sqlWHERE=QueryFactory_NoResult
		end if
		
		sqlSELECT = "select AL.REQUEST_ID INCIDENT_LOG_ID, INC.ENTRY_ID X_INCIDENT_CODE, INC.INCIDENT_NUMBER INCIDENT_ID,"&GetTimeFull("AL.Audit_date")&" AUDIT_DATE,p2.CORPORATE_E_MAIL X_SUBMITTER_EMAIL,AL.SUBMITTER X_SUBMITTER_LOGIN, nvl(p2.full_name,AL.USER_X) SUBMITTER, dbms_lob.substr(AL.LOG,"&QueryFactory_MaxLob&",1) LOG "
		sqlFROM=" FROM "&replace("[1].HPD_HELP_DESK INC  INNER JOIN [1].HPD_HELPDESK_AUDITLOGSYSTEM AL ON (INC.ENTRY_ID=AL.ORIGINAL_REQUEST_ID) LEFT JOIN [1].CTM_PEOPLE p2 ON (AL.USER_X=p2.REMEDY_LOGIN_ID)","[1]", schema1) 
		sql=sqlSELECT&sqlFROM&WhereLimiter&sqlWHERE
		field_id="INCIDENT_ID"
		
	case "INC-HDA"
		'this is correct but dangerous..
		If isArray(options.ticket_sql1) then ' ORDER BY HDA.LAST_MODIFIED_DATE DESC
			team_sql=query.protectArray("ARR1",options.ticket_sql1)
			sqlFROM=WhereLimiter&" AND INC.INCIDENT_NUMBER in ("&team_sql&") "
			sqlWHERE=WhereLimiter&" AND HDA.INCIDENT_NUMBER in ("&team_sql&") "
			
		else
			sqlFROM=WhereLimiter&QueryFactory_NoResult
			sqlWHERE=WhereLimiter&QueryFactory_NoResult
		end if
		
		sql="select HDA.HPD_ASSIGNMENT_LOG_ID OWNERSHIP_ID, HDA.INCIDENT_ENTRY_ID X_INCIDENT_CODE, HDA.INCIDENT_NUMBER INCIDENT_ID,"&_
		"HDA.ASSIGNED_SUPPORT_COMPANY, HDA.ASSIGNED_SUPPORT_ORGANIZATION, HDA.ASSIGNED_GROUP, "&_
		"p2.CORPORATE_E_MAIL X_ASSIGNEE_EMAIL, p2.REMEDY_LOGIN_ID X_ASSIGNEE_LOGIN, HDA.ASSIGNEE," &_
		"NUMBER_OF_TRANSFERS, HDA.BUSINESS_HOURS_DURATION, " &_
		"HDA.SUBMITTER LATEST_EDITOR,"&GetTime("HDA.LAST_MODIFIED_DATE")&" END_OF_LATEST_ASSIGNMENT_DATE FROM " &_
		replace("[1].HPD_HELP_DESK_ASSIGNMENT_LOG HDA LEFT JOIN [1].CTM_PEOPLE p2 ON (HDA.ASSIGNEE_LOGIN_ID=p2.REMEDY_LOGIN_ID)","[1]",schema1 )&sqlWHERE&" UNION ALL " &_
		" select null, INC.ENTRY_ID, INC.INCIDENT_NUMBER,"&_
		"INC.ASSIGNED_SUPPORT_COMPANY, INC.ASSIGNED_SUPPORT_ORGANIZATION, INC.ASSIGNED_GROUP, " &_
		"p1.CORPORATE_E_MAIL X_ASSIGNEE_EMAIL, p1.REMEDY_LOGIN_ID X_ASSIGNEE_LOGIN, INC.ASSIGNEE,"&_
		"null,'Current Assignement', INC.LAST_MODIFIED_BY, "&GetTime("LAST__ASSIGNED_DATE")&" FROM "&replace("[1].HPD_HELP_DESK INC LEFT JOIN [1].CTM_PEOPLE p1 ON (INC.ASSIGNEE_LOGIN_ID=p1.REMEDY_LOGIN_ID) ","[1]", schema1)&sqlFROM 
		field_id="INCIDENT_ID"
	case else
		generateSelectNotFound options.type_ticket, options.query_selector 
	end select
end sub

private sub	builderNgdcTAS(options)
	dim sqlSELECT1,sqlSELECT2,sqlSELECT3,sqlFROM1,sqlFROM2,sqlFROM3,sqlWHERE1,sqlWHERE2,sqlWHERE3, placeHolder1,placeHolder2,placeHolder3, placeHolder0
	dim sqlSELECT, sqlFROM, sqlWHERE
	sqlWHERE=" WHERE (rownum<="&C_MAX_ROW&") "
	
	select case options.query_selector
	case "TAS"
		sqlFROM1=""
		sqlFROM2=""
		sqlFROM3=""
		placeHolder0=" "
		If options.isFeature then
			select case options.featureName
			case "IMPLEMENTATION"
				sqlFROM1="[1].CTM_SUPPORT_GROUP REF,"
				sqlWHERE1=" AND CHG.CHANGE_REQUEST_STATUS in (6,7) AND TSK.status in (2000,3000,4000,5000) AND "&pointOfViewChange(options.sens_rech,options.isMyself)
				sqlWHERE2=QueryFactory_NoResult	
				sqlWHERE3=sqlWHERE2
			case "PENDING"
				sqlFROM1="[1].CTM_SUPPORT_GROUP REF,"
				sqlWHERE1=" AND (TSK.STATUSREASONSELECTION not in (4000) or TSK.STATUSREASONSELECTION is NULL) AND TSK.status in (3000) AND "&pointOfViewChange(options.sens_rech,options.isMyself)
				sqlWHERE2=QueryFactory_NoResult
				sqlWHERE3=sqlWHERE2
			case "SLOW"
				sqlFROM1="[1].CTM_SUPPORT_GROUP REF,"
				sqlWHERE1=" AND TSK.LOOKUPKEYWORD='TMSTASK' AND TSK.status in (2000,3000,4000,5000) AND "&compare_ts("GREATEST(TSK.ACTIVATE_TIME,TSK.SCHEDULED_START_DATE)"," < ",query.protectDate("WEEK",dateAdd("d",-7,date)))&" AND CHG.CHANGE_REQUEST_STATUS in (6,7) AND "&pointOfViewChange(options.sens_rech,options.isMyself)
				sqlWHERE2=QueryFactory_NoResult
				sqlWHERE3=sqlWHERE2
			case "OLD"
				sqlFROM1="[1].CTM_SUPPORT_GROUP REF,"
				sqlWHERE1=" AND TSK.status in (2000,3000,4000,5000) AND "&compare_ts("GREATEST(TSK.ACTIVATE_TIME, TSK.SCHEDULED_START_DATE)"," < ",query.protectDate("WEEK",dateAdd("d", -7, date)))&" AND TSK.LOOKUPKEYWORD='TMSTASK' AND CHG.CHANGE_REQUEST_STATUS in (6,7) AND "&pointOfViewTask(options.sens_rech,options.isMyself)
				sqlWHERE2=QueryFactory_NoResult
				sqlWHERE3=sqlWHERE2
			case "ALL_SINCE"
				sqlFROM1="[1].CTM_SUPPORT_GROUP REF,"
				sqlFROM2="[1].CTM_SUPPORT_GROUP REF,"
				sqlFROM3="[1].CTM_SUPPORT_GROUP REF,"
				sqlWHERE1=" AND ("&compare_ts("TSK.MODIFIED_DATE"," > ", query.protectDate("SINCE",options.date1))&" ) AND "&pointOfViewTask(options.sens_rech,options.isMyself)
				sqlWHERE2=sqlWHERE1
				sqlWHERE3=sqlWHERE1
			case "AMTF"
				sqlFROM1="[1].CTM_SUPPORT_GROUP REF,"
				sqlWHERE1=" AND TSK.status in (2000,3000,4000,5000) AND upper(CHG.DESCRIPTION) like '%AMTF%' AND CHG.CHANGE_REQUEST_STATUS not in (9,11,12) AND "&pointOfViewTask(options.sens_rech,options.isMyself)
				sqlWHERE2=QueryFactory_NoResult
				sqlWHERE3=sqlWHERE2
'			case "BETWEEN"
'				sqlWHERE1=sqlWHERE&" AND (("&compare_ts("TSK.SCHEDULED_START_DATE"," <= ",query.protectDate("END",options.date2))&" or TSK.SCHEDULED_START_DATE is null) AND "&compare_ts("TSK.SCHEDULED_END_DATE"," >= ",query.protectDate("BEGIN",options.date1))&") AND TSK.ASSIGNEE_GROUP=REF.SUPPORT_GROUP_NAME AND TSK.ASSIGNEE_GROUP_ID=REF.SUPPORT_GROUP_ID AND REF.SUPPORT_GROUP_NAME in ("&currentTeamName&")"
'				sqlWHERE2=sqlWHERE1
'				sqlWHERE3=sqlWHERE1
			case "FRESH_CLOSED"
				sqlFROM1="[1].CTM_SUPPORT_GROUP REF,"
				sqlFROM2="[1].CTM_SUPPORT_GROUP REF,"
				sqlFROM3="[1].CTM_SUPPORT_GROUP REF,"
				sqlWHERE=" AND TSK.status=6000 AND ("&compare_ts("TSK.MODIFIED_DATE"," > ",query.protectDate("SINCE", options.date1))&") AND "
				sqlWHERE1=pointOfViewChange(options.sens_rech,options.isMyself)
				sqlWHERE2=pointOfViewProblem(options.sens_rech,options.isMyself)
				sqlWHERE3=pointOfViewWorkOrder(options.sens_rech,options.isMyself)
			case "CHECK_TEMPLATE"
				sqlFROM1="[1].CTM_SUPPORT_GROUP REF,"
				sqlWHERE1=" INNER JOIN "&schema1&".TMS_TASKTEMPLATE TTT on (TTT.INSTANCEID=TSK.TEMPLATEID) "&WhereLimiter&" AND (TSK.ASSIGNEE_GROUP<>TTT.ASSIGNEE_GROUP or TSK.ASSIGNEE_GROUP_ID <> TTT.ASSIGNEE_GROUP_ID) AND TSK.status in (2000,3000,4000,5000) AND "&pointOfViewChange(options.sens_rech,options.isMyself)
				placeHolder1="TTT.ASSIGNEE_GROUP TEMPLATE_ASSIGNEE_GROUP,"
				placeHolder2="Null,"
				placeHolder3="Null,"
				sqlWHERE2=QueryFactory_NoResult
				sqlWHERE3=sqlWHERE2
			case else
				sqlWHERE1=QueryFactory_NoResult
				sqlWHERE2=sqlWHERE1
				sqlWHERE3=sqlWHERE1
			end select
		else
			if options.countTicket then 
				if isArray(options.ticket_sql1) then 
					If isArray(options.ticket_sql0) then
						sqlWHERE1=" AND (TSK.ROOTREQUESTID in ("&query.protectArray("ARR0",options.ticket_sql0)&") OR TSK.TASK_ID in ("&query.protectArray("ARR1", options.ticket_sql1)&")) "
					else
						sqlWHERE1=" AND TSK.TASK_ID in ("&query.protectArray("ARR1", options.ticket_sql1)&") "
					end if
				else
					sqlWHERE1=" AND (TSK.ROOTREQUESTID in ("&query.protectArray("ARR0",options.ticket_sql0)&")) "
				end if
				sqlWHERE2=sqlWHERE1
				sqlWHERE3=sqlWHERE1
			else
				sqlFROM1="[1].CTM_SUPPORT_GROUP REF,"
				sqlFROM2="[1].CTM_SUPPORT_GROUP REF,"
				sqlFROM3="[1].CTM_SUPPORT_GROUP REF,"
				sqlWHERE1=" AND TSK.status in (2000,3000,4000,5000) AND "&pointOfViewTask(options.sens_rech,options.isMyself)
				sqlWHERE2=sqlWHERE1
				sqlWHERE3=sqlWHERE1
			end if
		end if
		
		'for crq
		sqlSELECT1="SELECT TSK.TASK_ID X_TASK_CODE, TSK.TASK_ID,"&_
		" decode(CHG.CHANGE_REQUEST_STATUS,"&LIST_CRQ_STATUS_PLUS&",CHG.CHANGE_REQUEST_STATUS) X_PARENT_STATUS, CHG.REQUEST_ID X_PARENT_CODE, TSK.ROOTREQUESTID PARENT_ID,"&_
		" TSK.ASSIGNEE_GROUP ASSIGNED_GROUP,tsk.ASSIGNED_TO X_ASSIGNEE_LOGIN, p3.CORPORATE_E_MAIL X_ASSIGNEE_EMAIL, TSK.ASSIGNEE,"& placeHolder1&_
		" TSK.TASKNAME, TSK.SEQUENCE, TSK.SUMMARY DESCRIPTION,"&_
		" decode(TSK.status,"&LIST_TAS_STATUS&",TSK.status)||nvl2(TSK.STATUSREASONSELECTION,' ('||decode (TSK.STATUSREASONSELECTION,"&LIST_TAS_REASON&",TSK.STATUSREASONSELECTION)||')','') STATUS, CHG.Z1D_TEMPLATE_NAME TEMPLATE, nvl(rr.region,CHG.LOCATION_COMPANY) REGION, inversion_ci(CHG.INFRASTRUCTURE_CHANGE_ID) CI,"&_
		" p0.CORPORATE_E_MAIL X_coordinator_EMAIL, CHG.ASLOGID X_COORDINATOR_LOGIN, CHG.aschg coordinator, CHG.asgrp coord_group,"&_
		" p4.CORPORATE_E_MAIL X_manager_EMAIL,CHG.cab_manager_login X_MANAGER_LOGIN, p4.full_name manager,"&_
		" p1.CORPORATE_E_MAIL X_SUBMITTER_EMAIL, TSK.SUBMITTER X_SUBMITTER_LOGIN, p1.full_name SUBMITTER,"&_
		placeHolder0&_
		GetTime("TSK.MODIFIED_DATE")&" LAST_MODIFIED_DATE,"&_
		GetTime("TSK.ACTIVATE_TIME")&" ACTIVATE_TIME,"&_
		GetTime("TSK.SCHEDULED_START_DATE")&" SCHEDULED_START_DATE,"&_
		GetTime("TSK.SCHEDULED_END_DATE")&" SCHEDULED_END_DATE"
		sqlFROM1=sqlFROM1&"[1].TMS_Task TSK INNER JOIN [1].CHG_Infrastructure_Change CHG ON (TSK.ROOTREQUESTID=CHG.INFRASTRUCTURE_CHANGE_ID) LEFT OUTER JOIN [1].CTM_PEOPLE p0 ON (CHG.ASLOGID=p0.REMEDY_LOGIN_ID) LEFT OUTER JOIN [1].CTM_PEOPLE p1 on (TSK.SUBMITTER=p1.REMEDY_LOGIN_ID) LEFT OUTER JOIN [1].CTM_PEOPLE p3 ON (TSK.ASSIGNED_TO=p3.REMEDY_LOGIN_ID) LEFT OUTER JOIN [1].CTM_PEOPLE p4 ON (CHG.cab_manager_login=p4.REMEDY_LOGIN_ID) LEFT OUTER JOIN "&schema2&".REF_REGION rr ON (chg.REGION=rr.country)"

		'for pbi 
		sqlSELECT2="SELECT TSK.TASK_ID X_TASK_CODE, TSK.TASK_ID,"&_
		"decode(PB.INVESTIGATION_STATUS,"&LIST_PBI_STATUS&",PB.INVESTIGATION_STATUS) X_PARENT_STATUS, PB.SYS_PROBLEM_INVESTIGATION_ID X_PARENT_CODE, TSK.ROOTREQUESTID PARENT_ID,"&_
		" TSK.ASSIGNEE_GROUP ASSIGNED_GROUP,tsk.ASSIGNED_TO X_ASSIGNEE_LOGIN, q3.CORPORATE_E_MAIL X_ASSIGNEE_EMAIL, TSK.ASSIGNEE,"&placeHolder2& _
		" TSK.TASKNAME, TSK.SEQUENCE, TSK.SUMMARY DESCRIPTION,"&_
		" decode(TSK.status,"&LIST_TAS_STATUS&",TSK.status)||nvl2(TSK.STATUSREASONSELECTION,' ('||decode(TSK.STATUSREASONSELECTION,"&LIST_TAS_REASON&",TSK.STATUSREASONSELECTION)||')','') STATUS, null TEMPLATE, nvl(rr.region,PB.COMPANY) REGION,inversion_ci(TSK.TASK_ID) CI,"&_
		"q0.CORPORATE_E_MAIL X_coordinator_EMAIL,PB.ASSIGNEE_LOGIN_ID X_COORDINATOR_LOGIN, q0.full_name coordinator, pb.ASSIGNED_GROUP_PBLM_MGR COORD_GROUP,"&_
		"q4.CORPORATE_E_MAIL X_manager_EMAIL,PB.PROBLEM_MANAGER_LOGIN X_MANAGER_LOGIN, q4.full_name manager,"&_
		"q1.CORPORATE_E_MAIL X_SUBMITTER_EMAIL, TSK.SUBMITTER X_SUBMITTER_LOGIN, q1.full_name SUBMITTER,"&_
		placeHolder0&_
		GetTime("TSK.MODIFIED_DATE")&" LAST_MODIFIED_DATE,"&_
		GetTime("TSK.ACTIVATE_TIME")&" ACTIVATE_TIME,"&_
		GetTime("TSK.SCHEDULED_START_DATE")&" SCHEDULED_START_DATE,"&_
		GetTime("TSK.SCHEDULED_END_DATE")&" SCHEDULED_END_DATE "
		sqlFROM2=sqlFROM2&"[1].TMS_Task TSK INNER JOIN [1].PBM_PROBLEM_INVESTIGATION PB ON (TSK.ROOTREQUESTID=PB.PROBLEM_INVESTIGATION_ID) LEFT OUTER JOIN [1].CTM_PEOPLE q0 ON (PB.ASSIGNEE_LOGIN_ID=q0.REMEDY_LOGIN_ID) LEFT OUTER JOIN [1].CTM_PEOPLE q1 on (TSK.SUBMITTER=q1.REMEDY_LOGIN_ID) LEFT OUTER JOIN [1].CTM_PEOPLE q3 ON (TSK.ASSIGNED_TO=q3.REMEDY_LOGIN_ID) LEFT OUTER JOIN [1].CTM_PEOPLE q4 ON (PB.PROBLEM_MANAGER_LOGIN=q4.REMEDY_LOGIN_ID) LEFT OUTER JOIN "&schema2&".REF_REGION rr ON (PB.REGION=rr.country)" 

		'for Work orders 
		sqlSELECT3="SELECT TSK.TASK_ID X_TASK_CODE, TSK.TASK_ID,"&_
		"decode(WO.STATUS,"&LIST_WO_STATUS&",WO.STATUS) X_PARENT_STATUS, WO.REQUEST_ID X_PARENT_CODE, TSK.ROOTREQUESTID PARENT_ID,"&_
		" TSK.ASSIGNEE_GROUP ASSIGNED_GROUP,tsk.ASSIGNED_TO X_ASSIGNEE_LOGIN, p3.CORPORATE_E_MAIL X_ASSIGNEE_EMAIL, TSK.ASSIGNEE,"&placeHolder3&_
		" TSK.TASKNAME, TSK.SEQUENCE, TSK.SUMMARY DESCRIPTION,"&_
		" decode(TSK.status,"&LIST_TAS_STATUS&",TSK.status)|| nvl2(TSK.STATUSREASONSELECTION,' ('||decode (TSK.STATUSREASONSELECTION,"&LIST_TAS_REASON&",TSK.STATUSREASONSELECTION)||')','') STATUS, WO.TEMPLATENAME TEMPLATE,nvl(rr.region,WO.LOCATION_COMPANY) REGION,null CI,"&_
		" p0.CORPORATE_E_MAIL X_coordinator_EMAIL, WO.ASLOGID X_COORDINATOR_LOGIN,  WO.aschg coordinator, WO.asgrp coord_group,"&_
		" p4.CORPORATE_E_MAIL X_manager_EMAIL, WO.cab_manager_login X_MANAGER_LOGIN, p4.full_name manager,"&_
		" p1.CORPORATE_E_MAIL X_SUBMITTER_EMAIL,TSK.SUBMITTER X_SUBMITTER_LOGIN, p1.full_name SUBMITTER,"&_
		placeHolder0&_
		GetTime("TSK.MODIFIED_DATE")&" LAST_MODIFIED_DATE,"&_
		GetTime("TSK.ACTIVATE_TIME")&" ACTIVATE_TIME,"&_
		GetTime("TSK.SCHEDULED_START_DATE")&" SCHEDULED_START_DATE,"&_
		GetTime("TSK.SCHEDULED_END_DATE")&" SCHEDULED_END_DATE"
		sqlFROM3=sqlFROM3&"[1].TMS_Task TSK INNER JOIN [1].WOI_WORKORDER WO ON (TSK.ROOTREQUESTID=WO.WORK_ORDER_ID) LEFT OUTER JOIN [1].CTM_PEOPLE p0 ON (WO.ASLOGID=p0.REMEDY_LOGIN_ID) LEFT OUTER JOIN [1].CTM_PEOPLE p1 on (TSK.SUBMITTER=p1.REMEDY_LOGIN_ID) LEFT OUTER JOIN [1].CTM_PEOPLE p3 ON (TSK.ASSIGNED_TO=p3.REMEDY_LOGIN_ID) LEFT OUTER JOIN [1].CTM_PEOPLE p4 ON (WO.cab_manager_login=p4.REMEDY_LOGIN_ID) LEFT OUTER JOIN "&schema2&".REF_REGION rr ON (WO.REGION=rr.country) " 
		
		sql=sqlSELECT1&" FROM "&replace(sqlFROM1,"[1]",schema1)&WhereLimiter&sqlWHERE1&" AND TSK.ROOTREQUESTID like 'CRQ%' UNION ALL "&_
			sqlSELECT2&" FROM "&replace(sqlFROM2,"[1]",schema1)&WhereLimiter&sqlWHERE2&" AND TSK.ROOTREQUESTID like 'PBI%' UNION ALL "&_
			sqlSELECT3&" FROM "&replace(sqlFROM3,"[1]",schema1)&WhereLimiter&sqlWHERE3&" AND TSK.ROOTREQUESTID like 'WO%'"
		field_id="TASK_ID"
	
	
	case "TAS-REMINDER"
		' SIMILAR TO IMPLEMENTATION 
		

		
		sqlWHERE1=" AND CHG.CHANGE_REQUEST_STATUS in (6,7) AND TSK.status in (2000,3000,4000,5000) AND "&pointOfViewChange(options.sens_rech,options.isMyself)&" "
		sqlWHERE2=QueryFactory_NoResult	
		'Const LIST_WO_STATUS="0,'Assigned',1,'Pending',2,'Waiting Approval',3,'Plannnig',4,'In Progress',5,'Completed',6,'Rejected',7,'Cancelled',8,'Closed'"
		sqlWHERE3=" AND WO.STATUS in (4) AND TSK.status in (2000,3000,4000,5000) AND "&pointOfViewWorkOrder(options.sens_rech,options.isMyself)
		
		'for crq
		sqlSELECT1="SELECT TSK.TASK_ID X_TASK_CODE, TSK.TASK_ID, TSK.TASKNAME,decode(TSK.status,"&LIST_TAS_STATUS&",TSK.status)||nvl2(TSK.STATUSREASONSELECTION,' ('||decode (TSK.STATUSREASONSELECTION,"&LIST_TAS_REASON&",TSK.STATUSREASONSELECTION)||')','') STATUS,"&_
		" decode(CHG.CHANGE_REQUEST_STATUS,"&LIST_CRQ_STATUS_PLUS&",CHG.CHANGE_REQUEST_STATUS) X_PARENT_STATUS, CHG.REQUEST_ID X_PARENT_CODE, TSK.ROOTREQUESTID PARENT_ID,"&_
		" TSK.ASSIGNEE_GROUP ASSIGNED_GROUP, tsk.ASSIGNED_TO ASSIGNEE_LOGIN, p3.CORPORATE_E_MAIL ASSIGNEE_EMAIL, TSK.ASSIGNEE ASSIGNEE_NAME, "&_
		" p0.CORPORATE_E_MAIL X_coordinator_EMAIL, CHG.ASLOGID X_COORDINATOR_LOGIN, p0.CORPORATE_E_MAIL COORDINATOR, CHG.ASLOGID COORDINATOR_LOGIN,"&_
		" p4.CORPORATE_E_MAIL X_manager_EMAIL,CHG.cab_manager_login X_MANAGER_LOGIN, p4.CORPORATE_E_MAIL manager,CHG.cab_manager_login MANAGER_LOGIN,"&_
		GetTime("TSK.ACTIVATE_TIME")&" ACTIVATE_TIME,"&_
		GetTime("TSK.MODIFIED_DATE")&" LAST_MODIFIED_DATE,"&_
		GetTime("TSK.SCHEDULED_START_DATE")&" SCHEDULED_START_DATE,"&_
		GetTime("TSK.SCHEDULED_END_DATE")&" SCHEDULED_END_DATE "
		sqlFROM1="[1].CTM_SUPPORT_GROUP REF,[1].TMS_Task TSK INNER JOIN [1].CHG_Infrastructure_Change CHG ON (TSK.ROOTREQUESTID=CHG.INFRASTRUCTURE_CHANGE_ID) LEFT OUTER JOIN [1].CTM_PEOPLE p0 ON (CHG.ASLOGID=p0.REMEDY_LOGIN_ID) LEFT OUTER JOIN [1].CTM_PEOPLE p1 on (TSK.SUBMITTER=p1.REMEDY_LOGIN_ID) LEFT OUTER JOIN [1].CTM_PEOPLE p3 ON (TSK.ASSIGNED_TO=p3.REMEDY_LOGIN_ID) LEFT OUTER JOIN [1].CTM_PEOPLE p4 ON (CHG.cab_manager_login=p4.REMEDY_LOGIN_ID) LEFT OUTER JOIN "&schema2&".REF_REGION rr ON (chg.REGION=rr.country)"
		
		'for pbi 
		sqlSELECT2="SELECT TSK.TASK_ID X_TASK_CODE, TSK.TASK_ID, TSK.TASKNAME,decode(TSK.status,"&LIST_TAS_STATUS&",TSK.status)||nvl2(TSK.STATUSREASONSELECTION,' ('||decode (TSK.STATUSREASONSELECTION,"&LIST_TAS_REASON&",TSK.STATUSREASONSELECTION)||')','') STATUS,"&_
		"decode(PB.INVESTIGATION_STATUS,"&LIST_PBI_STATUS&",PB.INVESTIGATION_STATUS) X_PARENT_STATUS, PB.SYS_PROBLEM_INVESTIGATION_ID X_PARENT_CODE, TSK.ROOTREQUESTID PARENT_ID, "&_
		" TSK.ASSIGNEE_GROUP ASSIGNED_GROUP, tsk.ASSIGNED_TO ASSIGNEE_LOGIN, q3.CORPORATE_E_MAIL ASSIGNEE_EMAIL, TSK.ASSIGNEE ASSIGNEE_NAME, "&_
		"q0.CORPORATE_E_MAIL X_coordinator_EMAIL,PB.ASSIGNEE_LOGIN_ID X_COORDINATOR_LOGIN, q0.CORPORATE_E_MAIL coordinator, PB.ASSIGNEE_LOGIN_ID COORDINATOR_LOGIN, "&_
		"q4.CORPORATE_E_MAIL X_manager_EMAIL,PB.PROBLEM_MANAGER_LOGIN X_MANAGER_LOGIN, q4.CORPORATE_E_MAIL manager,PB.PROBLEM_MANAGER_LOGIN MANAGER_LOGIN, "&_
		GetTime("TSK.MODIFIED_DATE")&" LAST_MODIFIED_DATE, "&_
		GetTime("TSK.ACTIVATE_TIME")&" ACTIVATE_TIME,"&_
		GetTime("TSK.SCHEDULED_START_DATE")&" SCHEDULED_START_DATE,"&_
		GetTime("TSK.SCHEDULED_END_DATE")&" SCHEDULED_END_DATE "
		sqlFROM2=sqlFROM2&"[1].TMS_Task TSK INNER JOIN [1].PBM_PROBLEM_INVESTIGATION PB ON (TSK.ROOTREQUESTID=PB.PROBLEM_INVESTIGATION_ID) LEFT OUTER JOIN [1].CTM_PEOPLE q0 ON (PB.ASSIGNEE_LOGIN_ID=q0.REMEDY_LOGIN_ID) LEFT OUTER JOIN [1].CTM_PEOPLE q1 on (TSK.SUBMITTER=q1.REMEDY_LOGIN_ID) LEFT OUTER JOIN [1].CTM_PEOPLE q3 ON (TSK.ASSIGNED_TO=q3.REMEDY_LOGIN_ID) LEFT OUTER JOIN [1].CTM_PEOPLE q4 ON (PB.PROBLEM_MANAGER_LOGIN=q4.REMEDY_LOGIN_ID) LEFT OUTER JOIN "&schema2&".REF_REGION rr ON (PB.REGION=rr.country)" 
		sqlFROM2="[1].CTM_SUPPORT_GROUP REF,[1].TMS_Task TSK INNER JOIN [1].PBM_PROBLEM_INVESTIGATION PB ON (TSK.ROOTREQUESTID=PB.PROBLEM_INVESTIGATION_ID) LEFT OUTER JOIN [1].CTM_PEOPLE q0 ON (PB.ASSIGNEE_LOGIN_ID=q0.REMEDY_LOGIN_ID) LEFT OUTER JOIN [1].CTM_PEOPLE q1 on (TSK.SUBMITTER=q1.REMEDY_LOGIN_ID) LEFT OUTER JOIN [1].CTM_PEOPLE q3 ON (TSK.ASSIGNED_TO=q3.REMEDY_LOGIN_ID) LEFT OUTER JOIN [1].CTM_PEOPLE q4 ON (PB.PROBLEM_MANAGER_LOGIN=q4.REMEDY_LOGIN_ID) LEFT OUTER JOIN "&schema2&".REF_REGION rr ON (PB.REGION=rr.country)" 

		
		'for Work orders 
		sqlSELECT3="SELECT TSK.TASK_ID X_TASK_CODE, TSK.TASK_ID, TSK.TASKNAME,decode(TSK.status,"&LIST_TAS_STATUS&",TSK.status)||nvl2(TSK.STATUSREASONSELECTION,' ('||decode (TSK.STATUSREASONSELECTION,"&LIST_TAS_REASON&",TSK.STATUSREASONSELECTION)||')','') STATUS,"&_
		"decode(WO.STATUS,"&LIST_WO_STATUS&",WO.STATUS) X_PARENT_STATUS, WO.REQUEST_ID X_PARENT_CODE, TSK.ROOTREQUESTID PARENT_ID,"&_
		" TSK.ASSIGNEE_GROUP ASSIGNED_GROUP, tsk.ASSIGNED_TO ASSIGNEE_LOGIN, p3.CORPORATE_E_MAIL ASSIGNEE_EMAIL, TSK.ASSIGNEE ASSIGNEE_NAME, "&_
		" p0.CORPORATE_E_MAIL X_coordinator_EMAIL, WO.ASLOGID X_COORDINATOR_LOGIN,  p0.CORPORATE_E_MAIL coordinator, WO.ASLOGID COORDINATOR_LOGIN,"&_
		" p4.CORPORATE_E_MAIL X_manager_EMAIL, WO.cab_manager_login X_MANAGER_LOGIN, p4.CORPORATE_E_MAIL manager, WO.cab_manager_login MANAGER_LOGIN,"&_
		GetTime("TSK.MODIFIED_DATE")&" LAST_MODIFIED_DATE,"&_
		GetTime("TSK.ACTIVATE_TIME")&" ACTIVATE_TIME,"&_
		GetTime("TSK.SCHEDULED_START_DATE")&" SCHEDULED_START_DATE,"&_
		GetTime("TSK.SCHEDULED_END_DATE")&" SCHEDULED_END_DATE "
		sqlFROM3=sqlFROM3&"[1].TMS_Task TSK INNER JOIN [1].WOI_WORKORDER WO ON (TSK.ROOTREQUESTID=WO.WORK_ORDER_ID) LEFT OUTER JOIN [1].CTM_PEOPLE p0 ON (WO.ASLOGID=p0.REMEDY_LOGIN_ID) LEFT OUTER JOIN [1].CTM_PEOPLE p1 on (TSK.SUBMITTER=p1.REMEDY_LOGIN_ID) LEFT OUTER JOIN [1].CTM_PEOPLE p3 ON (TSK.ASSIGNED_TO=p3.REMEDY_LOGIN_ID) LEFT OUTER JOIN [1].CTM_PEOPLE p4 ON (WO.cab_manager_login=p4.REMEDY_LOGIN_ID) LEFT OUTER JOIN "&schema2&".REF_REGION rr ON (WO.REGION=rr.country) " 
		
		sqlFROM3="[1].CTM_SUPPORT_GROUP REF,[1].TMS_Task TSK INNER JOIN [1].WOI_WORKORDER WO ON (TSK.ROOTREQUESTID=WO.WORK_ORDER_ID) LEFT OUTER JOIN [1].CTM_PEOPLE p0 ON (WO.ASLOGID=p0.REMEDY_LOGIN_ID) LEFT OUTER JOIN [1].CTM_PEOPLE p1 on (TSK.SUBMITTER=p1.REMEDY_LOGIN_ID) LEFT OUTER JOIN [1].CTM_PEOPLE p3 ON (TSK.ASSIGNED_TO=p3.REMEDY_LOGIN_ID) LEFT OUTER JOIN [1].CTM_PEOPLE p4 ON (WO.cab_manager_login=p4.REMEDY_LOGIN_ID) LEFT OUTER JOIN "&schema2&".REF_REGION rr ON (WO.REGION=rr.country) " 
		
		sql=sqlSELECT1&" FROM "&replace(sqlFROM1,"[1]",schema1)&WhereLimiter&sqlWHERE1&" AND TSK.ROOTREQUESTID like 'CRQ%' UNION ALL "&_
			sqlSELECT2&" FROM "&replace(sqlFROM2,"[1]",schema1)&WhereLimiter&sqlWHERE2&" AND TSK.ROOTREQUESTID like 'PBI%' UNION ALL "&_
			sqlSELECT3&" FROM "&replace(sqlFROM3,"[1]",schema1)&WhereLimiter&sqlWHERE3&" AND TSK.ROOTREQUESTID like 'WO%'"
		field_id="TASK_ID"
	

	case "TAS-LOG"
		sqlSELECT="SELECT AL.ORIGINAL_REQUEST_ID X_TASK_CODE,AL.ORIGINAL_REQUEST_ID TASK_ID, "&GetTime( "AL.Audit_date")&" AUDIT_DATE, p2.CORPORATE_E_MAIL X_SUBMITTER_EMAIL, AL.SUBMITTER X_SUBMITTER_LOGIN, p2.full_name SUBMITTER,dbms_lob.substr(AL.LOG,"&QueryFactory_MaxLob&",1) LOG, AL.SUMMARY, decode( al.action, 4, 'Create',2,'Edit',al.action ) action  "
		sqlFROM=replace("FROM [1].TMS_AUDITLOGSYSTEM AL LEFT JOIN [1].CTM_PEOPLE p2 ON (AL.USER_X=p2.REMEDY_LOGIN_ID)","[1]",schema1) 
		if isArray(options.ticket_sql1) then
			sqlWHERE=" AND  AL.ORIGINAL_REQUEST_ID in ("&query.protectArray("ARR1",options.ticket_sql1)&") ORDER BY AL.Audit_date ASC "
		else
			sqlWHERE=QueryFactory_NoResult
		end if
		sql=sqlSELECT&sqlFROM&WhereLimiter&sqlWHERE
		field_id="TASK_ID"
	
	case "TAS-MORE"
		sqlSELECT="SELECT TSK.TASK_ID X_TASK_CODE,TSK.TASK_ID, TSK.TASKNAME, TSK.SUMMARY, dbms_lob.substr(TSK.NOTES,"&QueryFactory_MaxLob&",1) DETAILS, " &_
		GetFileAttachmentName("TSK.Z2AF_ATTACHMENT1")&"||' '||"&GetFileAttachmentName("TSK.Z2AF_ATTACHMENT2")&"||' '||"&GetFileAttachmentName("TSK.Z2AF_ATTACHMENT3") &" TASK_FILES, "&_
		"(select ListAgg("&GetFileAttachmentName("TWI.Z2AF_ATTACHMENT1")&" ||' '|| "&GetFileAttachmentName("TWI.Z2AF_ATTACHMENT2")&"||' '||"&GetFileAttachmentName("TWI.Z2AF_ATTACHMENT3")&",' ') within group (order by TWI.WORK_INFO_ID) FROM "&schema1&".TMS_WORKINFO TWI WHERE TWI.TASKORTASKGROUPID=TSK.TASK_ID GROUP BY TWI.TASKORTASKGROUPID) X_TASK_WORKINFO_FILES, "&_
		" 'Submit:'||"&GetTime("TSK.CREATE_DATE") &_
		" ||', Activate:'||"&GetTime("TSK.ACTIVATE_TIME")  &_	
		" ||', Assigned:'||"&GetTime("TSK.ASSIGN_TIME")  &_
		" ||', Scheduled_start:'|| "& GetTime("TSK.SCHEDULED_START_DATE") &_
		" ||', Actual_start:'||"&GetTime("TSK.ACTUAL_START_DATE") &_
		" ||', Actual_end:'||"&GetTime("TSK.ACTUAL_END_DATE") &_
		" ||', Scheduled_end:'||"&GetTime("TSK.SCHEDULED_END_DATE")  &_ 
		" ||', LastMod:'||"&GetTime("TSK.MODIFIED_DATE")&" ALL_DATES, inversion_ci(TSK.TASK_ID) CI "	
		sqlFROM="FROM "&schema1&".TMS_Task TSK "
		if isArray(options.ticket_sql1) then
			sqlWHERE=" AND TSK.TASK_ID in ("&query.protectArray("ARR1",options.ticket_sql1)&")"
		else
			sqlWHERE=QueryFactory_NoResult
		end if 
		sql=sqlSELECT&sqlFROM&WhereLimiter&sqlWHERE
		field_id="TASK_ID"
	
	case "TAS-SCHED"
		sqlSELECT="SELECT TSK.TASK_ID X_TASK_CODE, TSK.TASK_ID, null X_PARENT_STATUS, null X_PARENT_CODE, TSK.ROOTREQUESTID PARENT_ID,  decode(TSK.status,"&LIST_TAS_STATUS&",TSK.status)||nvl2(TSK.STATUSREASONSELECTION,' ('||decode(TSK.STATUSREASONSELECTION,"&LIST_TAS_REASON&",TSK.STATUSREASONSELECTION)||')','') STATUS, "&_
		GetTime("TSK.SCHEDULED_START_DATE")&" SCHEDULED_START_DATE, "&_
		GetTime("TSK.SCHEDULED_END_DATE")&" SCHEDULED_END_DATE, TSK.SEQUENCE, TSK.TASKNAME,"&_
        "(SELECT LISTAGG(T1.TASK_ID||'#'||T1.SEQUENCE,', ') WITHIN GROUP (ORDER BY T1.SEQUENCE, T1.TASK_ID) FROM "&schema1&".tms_task T1 WHERE T1.ROOTREQUESTID = TSK.ROOTREQUESTID AND NOT(TSK.STATUS = 6000 AND TSK.STATUSREASONSELECTION = 3000) AND NOT (T1.STATUS=6000 AND T1.STATUSREASONSELECTION = 3000) AND TSK.SEQUENCE>T1.SEQUENCE AND TSK.SCHEDULED_START_DATE<T1.SCHEDULED_START_DATE) BAD_TASK_SCHEDULED_START,"&_
        "(SELECT LISTAGG(T2.TASK_ID||'#'||T2.SEQUENCE,', ') WITHIN GROUP (ORDER BY T2.SEQUENCE, T2.TASK_ID) FROM "&schema1&".tms_task T2 WHERE T2.ROOTREQUESTID=TSK.ROOTREQUESTID AND NOT(TSK.STATUS = 6000 AND TSK.STATUSREASONSELECTION = 3000) AND NOT(T2.STATUS=6000 AND T2.STATUSREASONSELECTION=3000) AND TSK.SEQUENCE>T2.SEQUENCE AND (TSK.SCHEDULED_END_DATE-T2.SCHEDULED_END_DATE)<300) BAD_TASK_SCHEDULED_END," &_
		"(SELECT CASE WHEN TSK.STATUS = 6000 AND TSK.STATUSREASONSELECTION = 3000 THEN NULL WHEN TSK.SCHEDULED_END_DATE IS NULL THEN NULL WHEN COUNT(T3.TASK_ID) = 0 THEN "&GetIntervalFormat("TSK.SCHEDULED_END_DATE - TSK.SCHEDULED_START_DATE")&" WHEN MAX (T3.SCHEDULED_END_DATE) IS NULL THEN NULL WHEN TSK.SCHEDULED_START_DATE IS NULL THEN "&GetIntervalFormat("TSK.SCHEDULED_END_DATE - MAX (T3.SCHEDULED_END_DATE)")&" ELSE "&GetIntervalFormat("TSK.SCHEDULED_END_DATE - GREATEST (TSK.SCHEDULED_START_DATE, MAX ( T3.SCHEDULED_END_DATE))")&" END X FROM "&schema1&".tms_task T3 WHERE T3.ROOTREQUESTID = TSK.ROOTREQUESTID AND NOT(TSK.STATUS = 6000 AND TSK.STATUSREASONSELECTION = 3000) AND NOT (T3.STATUS = 6000 AND T3.STATUSREASONSELECTION = 3000) AND TSK.SEQUENCE > T3.SEQUENCE) IMPLEMENT_DURATION, "&_
		GetTime("TSK.ACTIVATE_TIME")&" ACTIVATE_TIME,"&_
		GetTime("CASE WHEN TSK.SCHEDULED_START_DATE is null THEN TSK.ACTIVATE_TIME WHEN TSK.SCHEDULED_START_DATE>TSK.ACTIVATE_TIME THEN TSK.SCHEDULED_START_DATE ELSE TSK.ACTIVATE_TIME END")& " WONT_START_BEFORE_DATE, "&_
		GetTime("TSK.ACTUAL_START_DATE")&" ACTUAL_START_DATE,"&_
		GetTime("TSK.ACTUAL_END_DATE")&" ACTUAL_END_DATE,"&_
		GetTime("TSK.MODIFIED_DATE")&" LAST_MODIFIED_DATE"
		sqlFROM=" FROM "&schema1&".tms_task TSK "
		if options.countTicket then 
			if isArray(options.ticket_sql1) then
				if isArray(options.ticket_sql0) then
					sqlWHERE=" AND TSK.ROOTREQUESTID IN (SELECT DISTINCT ROOTREQUESTID FROM "&schema1&".tms_task WHERE task_id IN ("&query.protectArray("ARR1",options.ticket_sql1)&") UNION SELECT DISTINCT ROOTREQUESTID FROM "&schema1&".tms_task WHERE rootrequestid IN ("&query.protectArray("ARR0",options.ticket_sql0)&"))"
				else 
					sqlWHERE=" AND TSK.ROOTREQUESTID IN (SELECT DISTINCT ROOTREQUESTID FROM "&schema1&".tms_task WHERE task_id IN ("&query.protectArray("ARR1",options.ticket_sql1)&"))"
				end if 
			else 
				sqlWHERE=" AND TSK.ROOTREQUESTID IN (SELECT DISTINCT ROOTREQUESTID FROM "&schema1&".tms_task WHERE rootrequestid IN ("&query.protectArray("ARR0",options.ticket_sql0)&"))"
			end if 
		else
			sqlWHERE=QueryFactory_NoResult
		end if
		sql=sqlSELECT&sqlFROM&WhereLimiter&sqlWHERE
		field_id="TASK_ID"

	case "TAS-TWI"	
		sqlSELECT ="select TWI.WORK_INFO_ID WORKINFO_ID, TWI.TASKORTASKGROUPID TASK_ID, TWI.TASKORTASKGROUPID X_TASK_CODE, "&_
		"p2.CORPORATE_E_MAIL X_SUBMITTER_EMAIL, TWI.WORKINFOSUBMITTER X_SUBMITTER_LOGIN, nvl(p2.full_name,TWI.WORKINFOSUBMITTER) SUBMITTER, " &_
		GetTime("TWI.SUBMIT_DATE")&" SUBMIT_DATE, TWI.SUMMARY,dbms_lob.substr(TWI.NOTES,"&QueryFactory_MaxLob&",1) DETAILS,"&_
		GetFileAttachmentName("TWI.Z2AF_ATTACHMENT1")&"||' '||"&GetFileAttachmentName("TWI.Z2AF_ATTACHMENT2")&"||' '||"&GetFileAttachmentName("TWI.Z2AF_ATTACHMENT3") &" ATTACHMENTS "
		sqlFROM=replace("FROM [1].TMS_WORKINFO TWI LEFT JOIN [1].CTM_PEOPLE p2 ON (TWI.WORKINFOSUBMITTER=p2.REMEDY_LOGIN_ID)","[1]",schema1) 

		If isArray(options.ticket_sql1) then
			sqlWHERE=" and TWI.TASKORTASKGROUPID in ("&query.protectArray("ARR1",options.ticket_sql1)&") order by TWI.WORK_INFO_ID"
		else
			sqlWHERE=QueryFactory_NoResult
		end if
		sql=sqlSELECT&sqlFROM&WhereLimiter&sqlWHERE
		field_id="TASK_ID"
		
	case else
		generateSelectNotFound options.type_ticket, options.query_selector 
	end select
	
end sub 

'******************************************************
private sub builderNgdcREQ(options)
	dim team_sql, tmp
	dim sqlSELECT, sqlFROM, sqlWHERE
	sqlWHERE=" WHERE (rownum <= "&C_MAX_ROW&") "
	select case options.query_selector 
		case "REQ"	
		'le besoin
			'filtrage des REQ.
			'point de vue
				'+ MANAGER si je ne donne rien je veux voir les REQ ouvertes qui sont vont donner des changes chez moi 
				'+ COORDINATOR si je donne rien  je veux voir les REQ ouvertes qui vont donner des changes chez moi.
				'+ ASSIGNEE si je donne rien 
				'+ SUBMITTER, la je donne les REQ soumise par moi ou par mes groupes, possiblement détecté automatiquement.
			'le mot magique controle l'état de la REQ (ouvert /clos / ... )
			'le mot magique "from tool" permet de surfilter les demande init dans les ouvertes 
			'le reste extrait la/les REQ demandées via son numéro.
		
		
			sqlSELECT="select REQ.SYSREQUESTID X_SERVICE_REQUEST_CODE, REQ.REQUEST_NUMBER SERVICE_REQUEST_ID,  req.concate__status_statusreason STATUS, REQ.CATEGORY_1 CATEGORY, REQ.summary, REQ.Apprequestid CHILD_ID, null X_CHILD_CODE,REQ.apprequeststatus X_CHILD_STATUS,REQ.SRD_NUMBER SR_DEFINITION, REQ.internet_e_mail X_SUBMITTER_EMAIL, REQ.REQUESTED_BY_LOGIN_ID X_SUMITTER_LOGIN,nvl( REQ.full_name, REQ.first_name ||' '||REQ.last_name) SUBMITTER,REQ.REQUESTED_FOR_LOGIN_ID X_RECIPIENT_LOGIN, REQ.customer_internet_e_mail X_RECIPIENT_EMAIL, REQ.customer_full_name RECIPIENT,"&_ 
			GetTime("REQ.submit_date") &" SUBMIT_DATE,"&_
			GetTime("REQ.actual_start_date") &"ACTUAL_START_DATE,"&_
			GetTime("REQ.approval_date") &"APPROVAL_DATE,"&_
			GetTime("REQ.next_target_date") &" NEXT_TARGET_DATE,"&_
			GetTime("REQ.completion_date") &" COMPLETION_DATE,"&_
			GetTime("REQ.last_modified_date") &" LAST_MODIFIED_DATE "
			
			if options.sens_rech = SENS_SUBMITED then 
				if options.isMyself then 
					team_sql="select "&currentUser&" REMEDY_LOGIN_ID from dual"
				else 
					team_sql="select distinct P1.REMEDY_LOGIN_ID from "&replace("[1].CTM_PEOPLE P1 INNER JOIN [1].CTM_SUPPORT_GROUP_ASSOCIATION X1 ON (P1.PERSON_ID=X1.PERSON_ID) INNER JOIN [1].CTM_SUPPORT_GROUP G1 ON (G1.SUPPORT_GROUP_ID=X1.SUPPORT_GROUP_ID)","[1]",schema1)&" WHERE G1.SUPPORT_GROUP_NAME in ("&currentTeamName&")"
				end if 
				sqlFROM=schema1&".SRM_REQUEST REQ INNER JOIN ("&team_sql&") pp  ON (REQ.REQUESTED_BY_LOGIN_ID=pp.REMEDY_LOGIN_ID OR REQ.REQUESTED_FOR_LOGIN_ID=pp.REMEDY_LOGIN_ID) "
				tmp=" AND (REQ.SOURCE_KEYWORD<>'IM' or REQ.SOURCE_KEYWORD is null) AND REQ.TITLEFROMSRD <> 'Service Desk Incident' "
				caption="searching REQ by submitter "
			else 
				'here we need to bypass
				if options.isMyself then 
					setCurrentTeamName
				end if
				sqlFROM =schema1&".SRM_REQUEST REQ "
				tmp =" AND EXISTS (select * from  "&schema1&".SRM_REQUEST sr INNER JOIN "&schema1&".SRM_AOTSINPDTSRELATEDTOSRD SA ON SA.PDT_PARENTINSTANCEID  = SR.SRDINSTANCEID INNER JOIN "&schema1&".SRM_APPTEMPLATEBRIDGE_BASE SAB ON SAB.INSTANCEID = SA.AOT_INSTANCEID INNER JOIN "&schema1&".CHG_TEMPLATE CT ON SAB.TEMPLATE_NAME = CT.TEMPLATE_NAME WHERE REQ.REQUEST_NUMBER=SR.REQUEST_NUMBER AND "& pointOfViewChangeTemplate(options.sens_rech, false )&" )" 
				caption="searching capacity to generate a change associated to your support groups "
			end if
			
			
			if options.isFeature then
				select case options.featureName
				'change ou je suis assigned
				case "FROM_TOOL"
					'ça c'est pouri.
					sqlFROM=schema1&".SRM_REQUEST REQ INNER JOIN "&schema1&".CHG_Infrastructure_Change CHG ON (REQ.REQUEST_NUMBER=CHG.SRID),"&schema1&".CTM_SUPPORT_GROUP REF"
					sqlWHERE=" AND CHG.CHANGE_REQUEST_STATUS not in (11,12) and REQ.STATUS not in (8000,9000) AND CHG.SUBMITTER="&query.protect("INIT",QueryFactory_INIT_USER)&" AND "&pointOfViewChange(options.sens_rech,options.isMyself)
					caption=" Searching REQ that have generated a open INIT change."
				case "REVIEW"
					sqlWHERE=tmp&" AND REQ.STATUS in (0,3000,4000)"
					caption=caption=" with specific status "
				case "IMPLEMENTATION"
					sqlWHERE=tmp&" AND REQ.STATUS in (5000)"
					caption=caption=" with specific status "
				case "DONE"
					sqlWHERE=tmp&" AND REQ.STATUS in (6000)"'6000 =>8000 cancel(l)ed
					caption=caption=" with specific status "
				case "PENDING"
					sqlWHERE=tmp&" AND REQ.STATUS in (1000,2000,7000)"
					caption=caption=" with specific status "
				case "FRESH_CLOSED"
					sqlWHERE=tmp&" AND REQ.STATUS in (9000)"
					caption=caption=" with specific status "
				'case "ALL_SINCE"
				'	sqlWHERE=tmp&" AND REQ.STATUS in (9000)"
				case else
					sqlWHERE=QueryFactory_NoResult
					caption="Not a valid magic word"
				end select
			else
				If isArray(options.ticket_sql1) then
					sqlFROM=schema1&".SRM_REQUEST REQ "
					sqlWHERE=" AND REQ.REQUEST_NUMBER in ("&query.protectArray("ARR1",options.ticket_sql1)&") "
					caption="Searching changes by request number"
				else 
					sqlWHERE=tmp&" AND REQ.STATUS not in (6000,8000,9000)"
					caption=caption&" for all open requests"
				end if 
			end if
			sql=sqlSELECT&" from "&sqlFROM&WhereLimiter&sqlWHERE
			field_id="SERVICE_REQUEST_ID"

	case "REQ-AP"
	'http://SERVER3/_layouts/SAG.Promise/ApproveServiceRequest.aspx?SignatureId=000000000160824&auth=No
		sqlSELECT="SELECT REQ.SYSREQUESTID X_SERVICE_REQUEST_CODE,REQ.REQUEST_NUMBER SERVICE_REQUEST_ID, req.concate__status_statusreason STATUS,p0.full_name||' ('||ap.APPROVER_SIGNATURE||')' SIGNATURE, decode(ap.APPROVAL_STATUS,"&LIST_APPROVAL&",ap.APPROVAL_STATUS) APPRO_STATUS, REQ.summary, allquest.QUESTS DETAILS,null APPROVE_REQ,"&_
		"REQ.internet_e_mail X_SUBMITTER_EMAIL, REQ.REQUESTED_BY_LOGIN_ID X_SUMITTER_LOGIN,nvl( REQ.full_name, REQ.first_name ||' '||REQ.last_name) SUBMITTER,SUBMITTER_GROUP.SUPPORT_GROUP_NAME SUBMITER_GROUP,REQ.REQUESTED_FOR_LOGIN_ID X_RECIPIENT_LOGIN, REQ.customer_internet_e_mail X_RECIPIENT_EMAIL, REQ.customer_full_name RECIPIENT,replace(dbms_lob.substr(AP.fullname,"&QueryFactory_MaxLob&",1),';',chr(13)) APPROVERS,"&_
		"dbms_lob.substr(AP.PRO_REJECTIONREASON,"&QueryFactory_MaxLob&",1) COMMENTS,"&_
		GetTime("REQ.submit_date")&" SUBMIT_DATE,"&_
		GetTime("REQ.actual_start_date")&" ACTUAL_START_DATE,"&_
		GetTime("REQ.approval_date")&" APPROVAL_DATE,"&_
		GetTime("REQ.next_target_date")&" NEXT_TARGET_DATE,"&_
		GetTime("REQ.completion_date")&" COMPLETION_DATE,"&_
		GetTime("REQ.last_modified_date")&" LAST_MODIFIED_DATE,"&_
		GetTime("REQ.REQUIRED_DATE")&" REQUIRED_DATE "
		sqlFROM = "FROM "&schema1&".srm_requestapdetailsignature AP INNER JOIN "&schema1&".SRM_REQUEST REQ on (REQ.SYSREQUESTID=AP.REQUEST)"&_
		"LEFT JOIN "&schema1&".CTM_SUPPORT_GROUP SUBMITTER_GROUP ON (REQ.SUBMITTER_GROUP_ID = SUBMITTER_GROUP.SUPPORT_GROUP_ID) "&_
		"LEFT JOIN (SELECT a.INPUT_SRINSTANCEID, listagg(a.OUTPUT_QUESTION_TEXT||': '||a.OUTPUT_ANSWER_IN_CHAR, chr(13)) WITHIN GROUP (ORDER BY a.OUTPUT_QUESTIONORDER) QUESTS FROM "&schema1&".PRO_EUP_SRD_MULTIPLEQUESTIONRE a GROUP BY a.INPUT_SRINSTANCEID) allquest on (REQ.INSTANCEID = ALLQUEST.INPUT_SRINSTANCEID) LEFT JOIN "&schema1&".CTM_PEOPLE p0 on (ap.APPROVER_SIGNATURE=p0.REMEDY_LOGIN_ID)"
		
		If isArray(options.ticket_sql1) then
			sqlWHERE=" AND REQ.REQUEST_NUMBER in ("&query.protectArray("ARR1", options.ticket_sql1)&")"
		else
			sqlWHERE=" AND AP.approval_status=0 and AP.approvers like "&query.protect("CHAIRMAN","%"&options.current_user&"%")
		end if
		sql=sqlSELECT&sqlFROM&WhereLimiter&sqlWHERE
		field_id="SERVICE_REQUEST_ID"
	
	
	case "REQ-ANSWER" 
		sqlSELECT="select REQ.SYSREQUESTID X_SERVICE_REQUEST_CODE, REQ.REQUEST_NUMBER SERVICE_REQUEST_ID,RUA.OUTPUT_QUESTION_TEXT QUESTION, RUA.OUTPUT_ANSWER_IN_CHAR USER_ANSWER, RUA.OUTPUT_QUESTIONORDER DISPLAY_ORDER, REQ.SRD_NUMBER||': '||REQ.DESCRIPTION2 SRD, decode(OUTPUT_QUESTION_HIDDEN,1,'visible','hidden') HIDDEN FROM "&schema1&".SRM_REQUEST REQ INNER JOIN "&schema1&".PRO_EUP_SRD_MULTIPLEQUESTIONRE RUA ON REQ.INSTANCEID=RUA.INPUT_SRINSTANCEID "
		If isArray(options.ticket_sql1) then
			sqlWHERE=" AND REQ.REQUEST_NUMBER in ("&query.protectArray("ARR1", options.ticket_sql1)&")"
		else
			sqlWHERE=QueryFactory_NoResult
		end if
		sql=sqlSELECT&sqlFROM&WhereLimiter&sqlWHERE
		field_id="SERVICE_REQUEST_ID"	
	
	
	case "REQ-RWI"
		sqlSELECT="select RWI.WORK_INFO_ID ID," &_
		GetTime("RWI.SUBMIT_DATE")&" SUBMIT_DATE,"&_
		"RWI.WORKINFOTYPE TYPE,"&_
		"p2.CORPORATE_E_MAIL X_SUBMITTER_EMAIL,RWI.WORKINFOSUBMITTER X_SUBMITTER_LOGIN, nvl(p2.full_name,RWI.WORKINFOSUBMITTER) SUBMITTER," &_
		GetFileAttachmentName("RWI.Z2AF_ATTACHMENT1")&" ||' '|| "&GetFileAttachmentName("RWI.PRO_EUP_Z2AF_ATTACHMENT2")&" ||' '||"&GetFileAttachmentName("RWI.PRO_EUP_Z2AF_ATTACHMENT3")&" ATTACHMENTS,"&_
		"dbms_lob.substr(RWI.NOTES,"&QueryFactory_MaxLob&",1) DETAILS,RWI.SUMMARY SUMMARY "
		sqlFROM=replace("FROM [1].SRM_WORKINFO RWI LEFT JOIN [1].CTM_PEOPLE p2 ON (RWI.WORKINFOSUBMITTER=p2.REMEDY_LOGIN_ID)","[1]",schema1) 
		If isArray(options.ticket_sql1) then
			sqlWHERE=" and RWI.SRID in ("&query.protectArray("ARR1",options.ticket_sql1)&") order by RWI.WORK_INFO_ID"
		else
			sqlWHERE=QueryFactory_NoResult
		end if
		sql=sqlSELECT&sqlFROM&WhereLimiter&sqlWHERE
		field_id="ID"
	
	case "REQ-LOG"
		sqlSELECT = "select AL.REQUEST_ID ID,REQ.SYSREQUESTID X_SERVICE_REQUEST_CODE,REQ.REQUEST_NUMBER SERVICE_REQUEST_ID,"&GetTime("AL.Audit_date")&" AUDIT_DATE,p2.CORPORATE_E_MAIL X_SUBMITTER_EMAIL,AL.USER_X X_SUBMITTER_LOGIN, nvl(p2.full_name,AL.USER_X) SUBMITTER,dbms_lob.substr(AL.LOG,"&QueryFactory_MaxLob&",1) LOG"
		sqlFROM=" FROM "&replace("[1].SRM_REQUEST REQ inner join [1].SRM_SR_AUDITLOG AL on (REQ.SYSREQUESTID=AL.ORIGINAL_REQUEST_ID) LEFT JOIN [1].CTM_PEOPLE p2 ON (AL.USER_X=p2.REMEDY_LOGIN_ID)","[1]",schema1)
		if isArray(options.ticket_sql1) then 
			sqlWHERE=" AND REQ.REQUEST_NUMBER in ("&query.protectArray("ARR1", options.ticket_sql1)&") ORDER BY AL.REQUEST_ID"
		else
			sqlWHERE=QueryFactory_NoResult
		end if
		sql=sqlSELECT&sqlFROM&WhereLimiter&sqlWHERE
		field_id="ID"
	
	case else
		generateSelectNotFound options.type_ticket, options.query_selector 
	end select 
end sub
'******************************************************
private sub builderNgdcPBI(options)
	dim team_sql, tmp
	dim sqlSELECT, sqlFROM, sqlWHERE
	sqlWHERE=" WHERE (rownum <= "&C_MAX_ROW&") "
	team_sql=pointOfViewProblem(options.sens_rech,options.isMyself)
	select case options.query_selector
	case "PBI"
		'CURRENT VERSION WORKING		
		sqlSELECT="select PB.SYS_PROBLEM_INVESTIGATION_ID X_PROBLEM_CODE, PB.PROBLEM_INVESTIGATION_ID PROBLEM_ID, "&_
		"PB.product_categorization_tier_1||nvl2(PB.product_categorization_tier_2,' / '||PB.product_categorization_tier_2,'')||nvl2(PB.product_categorization_tier_3,' / '||PB.product_categorization_tier_3,'') product, PB.DESCRIPTION SUMMARY, "&_
		"pb.ASSIGNEE_LOGIN_ID X_ASSIGNEE_LOGIN, p2.CORPORATE_E_MAIL X_ASSIGNEE_email,p2.full_name ASSIGNEE,"&_
		"PB.serviceci SERVICE,PB.pbm_ci CI,AC1.REGION||nvl2(ac1.SITE,' '||ac1.SITE,'') LOCATION,"&_
		"decode(PB.priority,"&LIST_PRIORITY&") priority, "&_
		"decode(PB.INVESTIGATION_STATUS,"&LIST_PBI_STATUS&",PB.INVESTIGATION_STATUS) STATUS,"&_
		"pb.PROBLEM_MANAGER_LOGIN X_coordinator_LOGIN, p3.CORPORATE_E_MAIL X_coordinator_EMAIL, p3.full_name coordinator,"&_
		"PB.SUPPORT_GROUP_NAME_REQUESTER SUBMITTER_GROUP,pb.SUBMITTER X_SUBMITTER_LOGIN, pb.SUBMITTER X_SUBMITTER_EMAIL, nvl(p1.full_name,pb.SUBMITTER) SUBMITTER,"&_
		 GetTime("PB.LAST_MODIFIED_DATE")&" LAST_MODIFIED_DATE,"&GetTime("PB.SUBMIT_DATE")&" SUBMIT_DATE,"&_
		 "pb.ASSIGNED_GROUP ASSIGNED_GROUP,pb.ASSIGNED_GROUP_PBLM_MGR COORD_GROUP" 

		sqlFROM=" from "&schema1&".PBM_PROBLEM_INVESTIGATION pb LEFT JOIN "&schema1&".CTM_PEOPLE p1 on (PB.SUBMITTER=p1.REMEDY_LOGIN_ID) LEFT JOIN "&schema1&".CTM_PEOPLE p2 on (PB.ASSIGNEE_LOGIN_ID=p2.REMEDY_LOGIN_ID) LEFT JOIN "&schema1&".CTM_PEOPLE p3 on (PB.PROBLEM_MANAGER_LOGIN=p3.REMEDY_LOGIN_ID) LEFT JOIN "&schema1&".AST_COMPUTERSYSTEM AC1 on (pb.pbm_ci=AC1.NAME) LEFT JOIN "&schema2&".REF_REGION rr on (pb.REGION=rr.country)"
		
		if options.isFeature then 
			select case options.featureName
			'change ou je suis assigned
			case "P1"
				sqlFROM=sqlFROM&", "&schema1&".CTM_SUPPORT_GROUP REF "
				sqlWHERE=" AND (PB.priority=0) AND PB.INVESTIGATION_STATUS in (1,2,3,4,5) AND "&team_sql
			'n° query.protectArray( "ARR1", options.ticket_sql1 )
			case "REVIEW"
				sqlFROM=sqlFROM&", "&schema1&".CTM_SUPPORT_GROUP REF "
				sqlWHERE=" AND PB.INVESTIGATION_STATUS in ("&query.protect("CODE1",1)&","&query.protect("CODE1",2)&") AND "&team_sql 
			case "IMPLEMENTATION"
				sqlFROM=sqlFROM&", "&schema1&".CTM_SUPPORT_GROUP REF "
				sqlWHERE=" AND PB.INVESTIGATION_STATUS in ("&query.protect("CODE1",3)&","&query.protect("CODE1",4)&") AND "&team_sql 
			case "PENDING"
				sqlFROM=sqlFROM&", "&schema1&".CTM_SUPPORT_GROUP REF "
				sqlWHERE=" AND PB.INVESTIGATION_STATUS in (0,5,7) AND "&team_sql 
			case "DONE"
				sqlFROM=sqlFROM&", "&schema1&".CTM_SUPPORT_GROUP REF "
				sqlWHERE=" AND PB.INVESTIGATION_STATUS=6 AND "&team_sql 
			case "FRESH_CLOSED"
				sqlFROM=sqlFROM&", "&schema1&".CTM_SUPPORT_GROUP REF "
				sqlWHERE=" AND PB.INVESTIGATION_STATUS=8 AND ("&compare_ts("PB.CLOSED_DATE",">",query.protectDate("SINCE",options.date1))&") AND "&team_sql 
			case "ALL_SINCE"
				sqlFROM=sqlFROM&", "&schema1&".CTM_SUPPORT_GROUP REF "
				sqlWHERE=" AND ("&compare_ts("PB.LAST_MODIFIED_DATE",">",query.protectDate("SINCE",options.date1))&") AND "&team_sql 
			case else
				sqlWHERE=QueryFactory_NoResult
			end select
		else
			if isArray(options.ticket_sql2) then 
				sqlWHERE=" AND PB.pbm_ci in ("& query.protectArray( "ARR2", options.ticket_sql2 )&")"
			elseif isArray(options.ticket_sql1) then		 
				sqlWHERE=" AND (PB.PROBLEM_INVESTIGATION_ID in ("&query.protectArray("ARR1",options.ticket_sql1)&")) "
			else
				sqlFROM=sqlFROM&", "&schema1&".CTM_SUPPORT_GROUP REF "
				sqlWHERE=" AND PB.INVESTIGATION_STATUS in (0,1,3,4,5) AND "&team_sql
			end if
		end if
		sql=sqlSELECT&sqlFROM&WhereLimiter&sqlWHERE
		field_id="PROBLEM_ID"
	case "PBI-PIW"
	 'TODO	
		generateSelectNotFound options.type_ticket, options.query_selector 
	case else
		generateSelectNotFound options.type_ticket, options.query_selector 
	end select
end sub


private sub builderNgdcOTHER(options)
	dim team_sql, tmp
	dim sqlSELECT, sqlFROM, sqlWHERE
	sqlWHERE=" WHERE (rownum <= "&C_MAX_ROW&") "
	select case options.query_selector
	case "WO"
		team_sql=pointOfViewWorkOrder(options.sens_rech,options.isMyself)
		'select case options.sens_rech
		'	 case else 'submited
		'LEFT OUTER JOIN [1].CTM_PEOPLE p3 ON (CHG.CUSTOMER_PERSON_ID=p3.person_ID)
		
		sqlFROM="[1].WOI_WORKORDER WO LEFT OUTER JOIN "&schema2&".REF_REGION rr ON (WO.REGION=rr.country) LEFT JOIN [1].CTM_PEOPLE P0 on (WO.ASLOGID=P0.REMEDY_LOGIN_ID)"
		sqlSELECT="select WO.REQUEST_ID X_WORK_ORDER_CODE, WO.WORK_ORDER_ID,WO.SUPPORT_GROUP_NAME SUBMITER_GROUP,"&_
		"WO.submitter X_SUBMITTER_LOGIN,WO.INTERNET_E_MAIL X_SUBMITTER_EMAIL, WO.FIRST_NAME||' '||WO.LAST_NAME SUBMITTER,"&_
		"WO.ASLOGID X_ASSIGNEE_LOGIN, WO.ASCHG ASSIGNEE, NVL(P0.CORPORATE_E_MAIL, P0.INTERNET_E_MAIL) X_ASSIGNEE_EMAIL, WO.ASGRP ASSIGNEE_GROUP, WO.SUPPORT_GROUP_NAME2,"&_
		"decode(WO.STATUS,"&LIST_WO_STATUS&",WO.STATUS) STATUS,WO.STATUS_REASON,"&_
		"nvl(rr.region,WO.LOCATION_COMPANY) REGION,WO.TEMPLATENAME,WO.SRID SERVICE_REQUEST_ID,WO.SUMMARY SUMMARY,"&_
		"dbms_lob.substr(WO.DETAILED_DESCRIPTION,"&QueryFactory_MaxLob&",1) DESCRIPTION,dbms_lob.substr(WO.Z1D_REPORT_NAME,"&QueryFactory_MaxLob&",1) Z1D_REPORT_NAME,"&_
		"WO.PRIORITY, WO.WORK_ORDER_TYPE,inversion_ci(WO.WORK_ORDER_ID) CI," &_
		 GetTime("WO.SUBMIT_DATE")&" SUBMIT_DATE,"&_
		GetTime("WO.LAST_MODIFIED_DATE")&" LAST_MODIFIED_DATE"

		if options.isFeature then 
			select case options.featureName
				case "ALL_SINCE"
					sqlFROM="[1].CTM_SUPPORT_GROUP REF,"&sqlFROM
					sqlWHERE="AND ("&compare_ts("WO.SUBMIT_DATE"," > ",query.protectDate("SINCE",options.date1))&") AND "&team_sql
				case else
					sqlWHERE=QueryFactory_NoResult
			end select
		else
			if options.countTicket then 
				if isArray(options.ticket_sql1) then
					if isArray(options.ticket_sql0) then
						sqlWHERE=" AND (WO.WORK_ORDER_ID IN ("&query.protectArray("ARR1",options.ticket_sql1)&") OR WO.SRID IN ("&query.protectArray("ARR0",options.ticket_sql0)&")) "
					else
						sqlWHERE=" AND (WO.WORK_ORDER_ID IN ("&query.protectArray("ARR1",options.ticket_sql1)&")) "
					end if 
				else
					sqlWHERE=" AND (WO.SRID IN ("&query.protectArray("ARR0",options.ticket_sql0)&")) "
				end if
			else
				sqlFROM="[1].CTM_SUPPORT_GROUP REF,"&sqlFROM
				sqlWHERE=" AND (WO.STATUS not in (9,11,12)) AND "&team_sql
			end if
		end if
		sqlFROM=" FROM "&replace(sqlFROM,"[1]",schema1)
		sql=sqlSELECT&sqlFROM&WhereLimiter&sqlWHERE
		field_id="WORK_ORDER_ID"

	case "PEOPLE"
	'" P1.FULL_NAME MANAGER,NVL(P1.CORPORATE_E_MAIL, P1.INTERNET_E_MAIL ) X_MANAGER_EMAIL, "& _
	'LEFT JOIN [1].CTM_PEOPLE P1 ON ( P1.REMEDY_LOGIN_ID=P.MANAGERLOGINID )
		sqlSELECT ="select P.PERSON_ID X_LOGIN_CODE, P.REMEDY_LOGIN_ID LOGIN, P.FIRST_NAME, P.LAST_NAME,"&_
		" P.FULL_NAME PEOPLE, NVL(P.CORPORATE_E_MAIL, P.INTERNET_E_MAIL) X_PEOPLE_EMAIL, decode(p.profile_status,"&LIST_PPL_STATUS&",p.profile_status) STATUS,"&_
		"G.COMPANY,G.SUPPORT_ORGANIZATION ORGANISATION,G.SUPPORT_GROUP_ID X_SUPPORT_GROUP_CODE,G.SUPPORT_GROUP_NAME SUPPORT_GROUP," &_
		"decode(x.default_x,0,'(default) ','')||(select  Listagg( decode(sgr.C1000000171,'CAB-Member','Change Approver','CAB-Assignee','Change Coordinator','CAB-Manager','Change Manager',sgr.C1000000171),', ') within group (order by sgr.C1000000171 ) from "&schema1&".T931 sgr WHERE sgr.c4=P.REMEDY_LOGIN_ID and sgr.C1000000080= P.PERSON_ID and sgr.C1000000079=X.SUPPORT_GROUP_ID and sgr.C1000000346=0 group by sgr.C1000000080,sgr.C4,sgr.C1000000079) roles,"&_
		" P.SITE_COUNTRY||' ('||P.SITE_CITY ||')' ADDRESS FROM " 
		sqlFROM=replace("[1].CTM_PEOPLE P INNER JOIN [1].CTM_SUPPORT_GROUP_ASSOCIATION X ON (P.PERSON_ID=X.PERSON_ID) INNER JOIN [1].CTM_SUPPORT_GROUP G ON (G.SUPPORT_GROUP_ID=X.SUPPORT_GROUP_ID)","[1]",schema1)
		
		if isArray(options.ticket_sql1) then
			tmp=query.protectArray("ARR1",options.ticket_sql1 )
			sqlWHERE=" AND ((G.SUPPORT_GROUP_NAME in ("&tmp&") OR P.REMEDY_LOGIN_ID in ("&tmp&"))"
			if isArray(options.ticket_sql2) then
				sqlWHERE=sqlWHERE&" OR upper(P.LAST_NAME) in ("&query.protectArray("ARR2",options.ticket_sql2)&"))"
			else 
				sqlWHERE=sqlWHERE&")"
			end if 
		else
			if isArray(options.ticket_sql2) then
				sqlWHERE=" AND (upper(P.LAST_NAME) in ("&query.protectArray("ARR2",options.ticket_sql2)&"))"
			elseif options.isMyself then 
				sqlWHERE=" AND (P.REMEDY_LOGIN_ID in ("&currentUser&")) "			
			else
				sqlWHERE=" AND (G.SUPPORT_GROUP_NAME in ("&currentTeamName&")) "
			end if
		end if
		sql=sqlSELECT&sqlFROM&WhereLimiter&sqlWHERE
		field_id="LOGIN"
		
	case "CI"
		sqlSELECT="select AB.name CONFIGURATION_ITEM, AB.ASSET_ID_ CI_ID, decode(AP.personrole,"&LIST_PEOPLE_ROLE&",AP.personrole) role, AP.form_type, AP.Full_name PEOPLE, p1.CORPORATE_E_MAIL X_PEOPLE_EMAIL, AP.LOGIN_NAME X_PEOPLE_LOGIN, AB.userdisplayobjectname OBJECT_TYPE, AB.PRO_GXP, decode(AB.PRO_GXPRISKLEVEL,"&LIST_GXP&") GXP_LEVEL, AB.PRO_ENVIRONMENT, nvl(rr.region,AB.REGION) REGION, AB.COMPANY ||' > ' ||  AB.REGION || ' > '|| AB.SITE ||' > ' || AB.BUILDING LOCATION , decode(AB.ASSETLIFECYCLESTATUS,"&LIST_AST_STATUS&",AB.ASSETLIFECYCLESTATUS) CI_STATUS "
		sqlFROM=" from "&schema1&".AST_BASEELEMENT AB LEFT JOIN "&schema1&".AST_ASSETPEOPLE AP on AB.RECONCILIATION_IDENTITY=AP.ASSETINSTANCEID LEFT  JOIN "&schema2&".REF_REGION rr ON (AB.REGION=rr.country) LEFT JOIN "&schema1&".CTM_PEOPLE p1 ON (AP.login_name=p1.REMEDY_LOGIN_ID) "
		
		
		sqlWHERE="   "
		
		if isArray(options.ticket_sql2) then
			
			sqlWHERE=sqlWHERE&" AND name in ("&query.protectArray( "ARR2", options.ticket_sql2)&") "

		elseif isArray( options.ticket_sql0) then
			tmp="select ASSO1.LOOKUP_KEYWORD, ASSO1.request_description01, ASSO1.REQUEST_ID01 FROM "&schema1&".chg_associations ASSO1 WHERE REQUEST_TYPE01=6000 AND ASSO1.request_id02 in ("&query.protectArray("ARR1",options.ticket_sql0)&") UNION "&_
			" select ASSO2.LOOKUP_KEYWORD, ASSO2.request_description01, ASSO2.REQUEST_ID01	FROM "&schema1&".hpd_associations ASSO2 where REQUEST_TYPE01=6000 AND ASSO2.request_id02 in ("&query.protectArray("ARR1",options.ticket_sql0)&") UNION "&_
 			" select ASSO3.LOOKUP_KEYWORD, ASSO3.request_description01, ASSO3.REQUEST_ID01  FROM "&schema1&".pbm_investigation_associations ASSO3 where REQUEST_TYPE01=6000 AND ASSO3.request_id02 in ("&query.protectArray("ARR1",options.ticket_sql0)&") "
			
			sqlFROM=sqlFROM& " INNER JOIN (select distinct request_description01, LOOKUP_KEYWORD, REQUEST_ID01 from ("&tmp&")) Y  on (AB.NAME=Y.request_description01) "
			
			'sqlWHERE =sqlWHERE&" AND (AB.CLASS_ID=Y.LOOKUP_KEYWORD OR Y.REQUEST_ID01=AB.RECONCILIATION_IDENTITY)"
			sqlWHERE =sqlWHERE&" AND Y.REQUEST_ID01=AB.RECONCILIATION_IDENTITY "
			'sqlFROM= " INNER JOIN "&schema1&".hpd_associations ASSO2 ON ASSO2.INSTANCEID=AB.INSTANCEID "
		else
			sqlWHERE=QueryFactory_NoResult
		end if 
		field_id="CONFIGURATION_ITEM"
		sql=sqlSELECT&sqlFROM&WhereLimiter&sqlWHERE
	case else
		generateSelectNotFound options.type_ticket, options.query_selector 
	end select
end sub



'###############################################################################
'# LEGACY #
'###############################################################################
private sub builderLegacy(options)
	currentUser=query.protect("USER",options.current_user)
	if options.isAutoTeam then	
		currentTeamName="SELECT G.SUPPORT_GROUP_NAME FROM "&schema1&".CTM_PEOPLE P INNER JOIN "&schema1&".CTM_SUPPORT_GROUP_ASSOCIATION X ON (P.PERSON_ID=X.PERSON_ID) INNER JOIN GEN$ARS.CTM_SUPPORT_GROUP G ON (G.SUPPORT_GROUP_ID=X.SUPPORT_GROUP_ID) WHERE rownum<= "&C_MAX_ROW&" AND P.REMEDY_LOGIN_ID="&currentUser&" "
	else
		currentTeamName=query.protectArray("TEAM",options.team_name)
		currentTeamCode=query.protectArray("CODES",options.team_code)
	end if
	
	select case options.query_selector 
	'case "L|WKO"
	case "WKO"
 'IMPLEMENTOR_GROUP_ ASSIGNED_GROUP
	sql="SELECT TASK_ID_ WORKORDER, Change_ID_ REQUEST_ID, SUMMARY, nvl2(A_APPCode, A_APPCode ,'') APPCode,A_APPName APPName,REQUESTER_NAME,"&_
	"assignee_login_name X_ASSIGNEE_LOGIN, IMPLEMENTOR_NAME_ ASSIGNEE, "&_
	"decode(STATUS,0,'New',1,'Scheduled',2,'Work in Progress',3,'Pending',4,'Closed',STATUS)|| nvl2( pending,' ('||decode(PENDING,0,'Parts',1,'Requester Information',2,'Problem',3,'Client Hold',4,'Client Action Required',5,'Support Contact Hold',6, 'Supplier/Support Delivery',7,'Release Linked to Work Order',8,'User Request to Schedule',9,'IS Request to Schedule',10,'Tech Request to Schedule',PENDING)||')','') "&_
	"||nvl2(closure_code,' ('||decode(CLOSURE_CODE,0, 'Successful',1,'Successful with Problems',2, 'Unsuccessful',3,'Cancelled',CLOSURE_CODE)||')','') STATUS,"&_
	GetTime("planned_start_DATE")&" planned_DATE,"&_
	GetTime("A_EXPECTEDDATE")&" EXPECTED_DATE,"&_
	GetTime("A_EXPECTED_ATLEASTDATE")&" EXPECTED_AT_LEAST_DATE,"&_
	GetTime("A_EXPECTED_ATLASTDATE")&" A_EXPECTED_AT_LAST_DATE,"&_
	GetTime("CREATE_DATE")&" CREATE_DATE,"&_
	"CASE WHEN INSTR(summary,'041')>0 THEN "&_
	"nvl2(A_OPTION1,' DB/SCHEMA: '||A_OPTION1||' '||CHR(9) ,'') || "&_
	"nvl2(A_OPTION3,' SCRIPTS : '||A_OPTION3||' '||CHR(9)||CHR(9) ,'') || "&_
	"nvl2(A_REQUESTERCOMMENTS,' CMT : '||A_REQUESTERCOMMENTS ,'') "&_
	"WHEN summary='LWLIMS - Création Package de Transport DB' THEN "&_
	"'PACKAGE/VERSION: '||A_OPTION1||' '||CHR(9) || "&_
	"'<a href=""http://SERVER4/..../Lists/Packages/AllItems.aspx"" target=""_blank"">LWLIMS DELIVER PROCESS TRACKING</a>' "&_
	"END INFOS, "&_
	"IMPLEMENTOR_GROUP_ ASSIGNED_GROUP "&_
	"FROM GEN$ARS.CHG_TASK "&_
	"WHERE rownum <= "&C_MAX_ROW&" AND "

	if options.countTicket then 
		If isArray(options.ticket_sql1) then 
			If isArray(options.ticket_sql0) then 
				sql=sql&" (Change_ID_ in ("&query.protectArray("ARR1",options.ticket_sql1)&") OR TASK_ID_ in ("&query.protectArray("ARR0",options.ticket_sql0)&")) " 
			else 
				sql=sql&" (Change_ID_ in ("&query.protectArray("ARR1",options.ticket_sql1)&")) " 
			end if 
		else 
				sql=sql&" (TASK_ID_ in ("&query.protectArray("ARR0",options.ticket_sql0)&")) "
		end if 
	else
		sql=sql&" STATUS<4 AND IMPLEMENTOR_GROUP_ IN ("&currentTeamName&")"
	end if
	field_id="REQUEST_ID"
	
 case "INC"
	 'hd.ASSIGNED_GROUP
	 ' and (g.SUPPORT_GROUP_NAME like 'INC-FR%' or g.login_id is null) and w1.submitter=g.login_id(+)&_
	sql="select hd.INCIDENT_NUMBER INCIDENT_ID, hd.description, hd.a_appcode appcode,decode(hd.requester_name_,'HP OpenView Operations','OVO',hd.requester_name_) requester, "&_
	" assignee_login_id X_ASSIGNEE_LOGIN, hd.assignee ASSIGNEE, "&_
	" decode(HD.STATUS,0,'New',1,'Assigned',2,'In progress',3, 'Pending',4,'Resolved',5,'Closed',6,'Cancelled',HD.STATUS) STATUS,"&_
	" decode(HD.priority,"&LIST_PRIORITY&") priority,"&_
	GetTime("HD.REPORTED_DATE")&" REPORTED_DATE,"&_
	GetTime("w.SUBMIT_DATE")&" X_WLOG_date,"&_
	"X_WLOG_organization, decode(X_wlog_full_name, 'HP OpenView Operations','OVO',X_wlog_full_name) x_wlog_full_name, hd.ASSIGNED_GROUP, w.WLOG_DESCRIPTION "&_
	"from gen$ars.HPD_HELP_DESK hd,"&_
	"(SELECT DISTINCT w1.INCIDENT_NUMBER, w1.description X_WLOG_name,"&_
	"case when length(w1.DETAILED_DESCRIPTION)>3995 then '[...]'||to_char(substr(w1.DETAILED_DESCRIPTION,-3995)) else to_char(w1.DETAILED_DESCRIPTION) end WLOG_DESCRIPTION, "&_
	" w1.SUBMIT_DATE, g.support_organization X_WLOG_organization, g.full_name X_WLOG_full_name "&_
	"FROM gen$ars.HPD_WORKLOG w1, GEN$ARS.CTM_SUPPORT_GROUP_ASSOC_LOOKUP g, "&_
	"(SELECT INCIDENT_NUMBER, MAX(SUBMIT_DATE) max_submit_date FROM gen$ars.HPD_WORKLOG where description <> 'WL_AR_ESCALATOR' and INCIDENT_NUMBER in (select INCIDENT_NUMBER from gen$ars.HPD_HELP_DESK where STATUS in (1,2,3) and ASSIGNED_GROUP IN ("&currentTeamName&"))"&_
	" group by INCIDENT_NUMBER) w2 "&_
	" where w1.INCIDENT_NUMBER=w2.INCIDENT_NUMBER and w1.SUBMIT_DATE=w2.max_submit_date "&_
	" and (g.SUPPORT_GROUP_NAME like 'INC-FR%' or g.login_id is null) and w1.submitter=g.login_id(+) "&_
	") w "&_
	"where rownum <= "&C_MAX_ROW&" AND hd.INCIDENT_NUMBER=w.INCIDENT_NUMBER(+) "

	If isArray(options.ticket_sql1) then
		sql=sql&" AND (hd.INCIDENT_NUMBER in ("&query.protectArray("ARR1",options.ticket_sql1)&"))"
	else
		sql=sql&" and HD.STATUS in (1,2,3) and hd.ASSIGNED_GROUP IN ("&currentTeamName&")"
	end if
	field_id="INCIDENT_ID"

'case "L|PBI"
case "PBI"
	'ASSIGNED_GROUP
	sql="select PROBLEM_INVESTIGATION_ID PROBLEM_ID, A_APPCODE APPCODE, A_APPNAME APPNAME, DESCRIPTION,"&_
	"decode(priority,0,"&LIST_PRIORITY&") priority, decode(INVESTIGATION_STATUS,0,'Draft',1,'Under review',3,'Assigned',4,'Under investigation',5,'Pending',6,'Completed',8,'Closed',9,'Cancelled',INVESTIGATION_STATUS) STATUS, assignee_login_id X_ASSIGNEE_LOGIN, assignee ASSIGNEE,"&_
	GetTime("SUBMIT_DATE")&"SUBMIT_DATE,"&GetTime("LAST_MODIFIED_DATE")&" LAST_MODIFIED_DATE,ASSIGNED_GROUP "&_
	" FROM gen$ars.PBM_PROBLEM_INVESTIGATION "&_
	" WHERE rownum <= "&C_MAX_ROW&" AND "

	If IsArray(options.ticket_sql1 ) then
		sql=sql&" (PROBLEM_INVESTIGATION_ID in ("&query.protectArray("ARR1",options.ticket_sql1)&")) "
	else
		sql=sql&" INVESTIGATION_STATUS in (0,1,3,4,5) AND ASSIGNED_GROUP IN ("&currentTeamName&")"
	end if
	field_id="PROBLEM_ID"
case else
	generateSelectNotFound options.type_ticket, options.query_selector 	
end select 

end sub 


end class 
%>