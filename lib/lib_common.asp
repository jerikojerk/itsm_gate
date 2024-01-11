<% option explicit %><!--#INCLUDE FILE="lib_security.asp"--><!--#INCLUDE FILE="QuerySQL.class.asp"--><!--#INCLUDE FILE="QueryFactory.class.asp"--><!--#INCLUDE FILE="DatabaseEnv.class.asp"--><!--#INCLUDE FILE="UserOptions.class.asp"--><!--#INCLUDE FILE="PromiseWriter.class.asp"--><%

'in this file,constants/var used for non specific use.
Server.ScriptTimeout=600
Session.Timeout=720
'see lib_security
'features availability

'it's historical const...
'Those are class name...
Const C_FILLBORDER		="active"
Const C_REFRESH			="refresh"
Const C_UNASSIGNED		="sUnassigned" 'unassigned
Const C_MYSELF			="sAssigneeMyself" 'assignee myself
Const C_EMEA			="rEMEA"
Const C_APAC			="rAPAC"
Const C_AMER			="rAMER" 
'status class 
Const ST_CLOSED_FAILED	="sCloFailed"
Const ST_CLOSED_CANCEL	="sCloCancelled"
Const ST_CLOSED_SUCCES	="sCloSuccess"
Const ST_PENDING_ASSIG	="sPenAssignment"
Const ST_IMPLEMENT_REA	="sIMPLEMENTATION_ISSUE"
'Misc const
Const C_MAX_ROW			=20000	'hardcoded limit in query (as we do not sort... it's efficient )
Const C_TICKET_DIGIT	=15		'len of digit part of ticket
Const P_WELCOME	="W"	'flag value for options.display
Const P_NORMAL	="N"	'flag value for options.display
Const P_APPRO	="A"
Const P_DATA	="D"
Const P_PEOPLE	="P"
Const P_DOWNLOAD="D"
'IO variable
Const SENS_ASSIGNED="a"
Const SENS_MANAGED="m"
Const SENS_SUBMITED="s"
Const SENS_COORDINATE="c"

''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'*** LEGACY ***
Const LIB_GRP_ORA="L3 ORACLE"
Const LIB_GRP_MSSQL="L3 SQL SERVER"
Const LIB_GRP_UNIX="L3 UNIX"
Const LIB_GRP_ETL="L3 ETL/EAI"
Const LIB_GRP_SAP="L3 SAP"
Const LIB_GRP_SAN="L3 BACKUP/SAN"
Const LIB_GRP_WIN="L3 WINDOWS"
Const LIB_GRP_CTX="L3 VIRTUALIZATION X86"
Const LIB_GRP_MDW="L3 MIDDLEWARE"
Const LIB_GRP_GZM="L3 GENZYME"

'*** NGDC ***
' do not forget to update GetInfosGroupe when updating this one.
Dim ARYgroupes(47,2)

'keep this sorted cres as we will perform a dicotomy to find the match
'create a new constant
'generate ARY group initialisation
'make sure constant name sort itself like ARgroup( constant, 0)
'--> SELECT    'ARYgroupes(,2)="'|| LISTAGG (support_group_id, ',') WITHIN GROUP (ORDER BY SUPPORT_GROUP_NAME)||'"' FROM ITSMPRD.CTM_SUPPORT_GROUP WHERE SUPPORT_GROUP_NAME IN ('SH-WW-IN3-INSTANT_MESSAGING');
'copy constant list in  notepad using regex replace: =[0-9]+ by =
'copy generated list in excel, column A
'sort
'inset 0 at first B cell
'create increment in B column
'create new C column with formula =A1&B1
'copy colum C as your updated code

Const GRP_AMTF_L3=0
Const GRP_AS_ALL_L3=1
Const GRP_AS_CORP_L3=2
Const GRP_AS_GZM_L3=3
Const GRP_AS_IA_L3=4
Const GRP_AS_MER_L3=5
Const GRP_AS_PO_L3=6
Const GRP_AS_RSC_L3=7
Const GRP_AS_VAX_L3=8
Const GRP_BDOTHER_L3=9
Const GRP_BKP_L2=10
Const GRP_COLLAB_L2=11
Const GRP_COORD_L2=12
Const GRP_CTOOL_L3=13
Const GRP_DTMG=14
Const GRP_EROOM_L2=15
Const GRP_ETL_L3=16
Const GRP_EXCHG_L3=17
Const GRP_ITSM=18
Const GRP_MDW_L2=19
Const GRP_MDW_L3=20
Const GRP_MON_L2=21
Const GRP_MON_L3=22
Const GRP_MSG_L3=23
Const GRP_MSSQL_L2=24
Const GRP_MSSQL_L3=25
Const GRP_NETWK_L2=26
Const GRP_NETWRK_L2=27
Const GRP_OP_L1=28
Const GRP_OPTOOL_L2=29
Const GRP_ORA_L2=30
Const GRP_ORA_L3=31
Const GRP_OS400_L2=32
Const GRP_POD=33
Const GRP_PROVI_L2=34
Const GRP_PROVI_L3=35
Const GRP_PTC=36
Const GRP_SAN_L2=37
Const GRP_SAN_L3=38
Const GRP_SAP_L2=39
Const GRP_SAP_L3=40
Const GRP_SCHED_L2=41
Const GRP_SCHED_L3=42
Const GRP_SDP_L1=43
Const GRP_UNIX_L2=44
Const GRP_UNIX_L3=45
Const GRP_WIN_L2=46
Const GRP_WIN_L3=47


ARYgroupes(GRP_AS_RSC_L3,0)="AS_RSC-L3"
ARYgroupes(GRP_AS_RSC_L3,1)="SH-WW-IN3-APP_SERV_RESEARCH"

ARYgroupes(GRP_AS_IA_L3,0)=	"AS_IA-L3"
ARYgroupes(GRP_AS_IA_L3,1)="SH-WW-IN3-APP_SERV_IA"

ARYgroupes(GRP_AS_PO_L3,0)="AS_PO-L3"
ARYgroupes(GRP_AS_PO_L3,1)="SH-WW-IN3-APP_SERV_PO"

ARYgroupes(GRP_AS_VAX_L3,0)="AS_VAX-L3"
ARYgroupes(GRP_AS_VAX_L3,1)="SH-WW-IN3-APP_SERV_VACCINES"

ARYgroupes(GRP_AS_CORP_L3,2)="AS_CORP-L3"
ARYgroupes(GRP_AS_CORP_L3,1)="SH-WW-IN3-APP_SERV_CORPORATE"

ARYgroupes(GRP_AS_MER_L3,0)="AS_MER-L3"
ARYgroupes(GRP_AS_MER_L3,1)="SH-WW-IN3-APP_SERV_MERIAL"

ARYgroupes(GRP_AS_GZM_L3,0)="AS_GZM-L3"
ARYgroupes(GRP_AS_GZM_L3,1)="SH-WW-IN3-SERVER_PLATFORMS,SH-WW-IN3-APP_SERV_GENZYME"

ARYgroupes(GRP_AS_ALL_L3,0 )="AS_ALL-L3"
ARYgroupes(GRP_AS_ALL_L3,1)="SH-WW-IN3-APP_SERV_TT11,SH-WW-IN3-APP_SERV_CORPORATE,SH-WW-IN3-APP_SERV_CORPORATE,SH-WW-IN3-APP_SERV_IA,SH-WW-IN3-APP_SERV_MERIAL,SH-WW-IN3-APP_SERV_PO,SH-WW-IN3-APP_SERV_RESEARCH,SH-WW-IN3-APP_SERV_VACCINES,SH-WW-IN3-APP_SERV_GENZYME"

'******************** L3 *******************************
ARYgroupes(GRP_ORA_L3,0)="ORA-L3"
ARYgroupes(GRP_ORA_L3,1)="SH-WW-IN3-DATABASE_ORACLE"

ARYgroupes(GRP_MSSQL_L3,0)="MSSQL-L3"
ARYgroupes(GRP_MSSQL_L3,1)="SH-WW-IN3-DATABASE_SQL"

ARYgroupes(GRP_BDOTHER_L3,0)="BDOTHER-L3"
ARYgroupes(GRP_BDOTHER_L3,1)="SH-WW-IN3-DATABASE_OTHER"

ARYgroupes(GRP_DTMG,0)="DTMG"
ARYgroupes(GRP_DTMG,1)="SH-WW-IN3-DATABASE_OTHER,SH-WW-IN3-DATABASE_SQL,SH-WW-IN3-DATABASE_ORACLE,SH-WW-IN3-EAI_ETL,SH-WW-IN3-EAI"

ARYgroupes(GRP_ETL_L3,0)="ETL-L3"
ARYgroupes(GRP_ETL_L3,1)="SH-WW-IN3-EAI_ETL,SH-WW-IN3-EAI"

ARYgroupes(GRP_SAP_L3,0)="SAP-L3"
ARYgroupes(GRP_SAP_L3,1)="SH-WW-IN3-SAP"

ARYgroupes(GRP_UNIX_L3,0)="UNIX-L3"
ARYgroupes(GRP_UNIX_L3,1)="SH-WW-IN3-UNIX"

ARYgroupes(GRP_SAN_L3,0)="SAN-L3"
ARYgroupes(GRP_SAN_L3,1)="SH-WW-IN3-BACKUP_RESTORE,SH-WW-IN3-STORAGE"

ARYgroupes(GRP_WIN_L3,0)="WIN-L3"
ARYgroupes(GRP_WIN_L3,1)="SH-WW-IN3-WINDOWS"

ARYgroupes(GRP_MDW_L3,0)="MDW-L3"
ARYgroupes(GRP_MDW_L3,1)="SH-WW-IN3-MIDDLEWARE_SHAREPOINT,SH-WW-IN3-MIDDLEWARE_JAVA,SH-WW-IN3-MIDDLEWARE_.NET,SH-WW-IN3-MIDDLEW_JAVA,SH-WW-IN3-MIDDLEW_DOTNET,SH-WW-IN3-MIDDLEW_SHAREPOINT,SH-WW-IN3-MIDDLEW_BI,SH-WW-IN3-APPLI_ADMIN_OTHER"


ARYgroupes(GRP_MON_L3,0)="MON-L3"
ARYgroupes(GRP_MON_L3,1)="SH-WW-IN3-MONITORING_TOOLS"

ARYgroupes(GRP_SCHED_L3,0)="SCHED-L3"
ARYgroupes(GRP_SCHED_L3,1)="SH-WW-IN3-BATCH_SCHEDULING,SH-WW-IN3-SCHEDULING_TOOLS"

ARYgroupes(GRP_MSG_L3,0)="MSG-L3"
ARYgroupes(GRP_MSG_L3,1)="SH-WW-IN3-INSTANT_MESSAGING"

ARYgroupes(GRP_EXCHG_L3,0)="EXCHG-L3"
ARYgroupes(GRP_EXCHG_L3,1)="SH-WW-IN3-EXCHANGE"

ARYgroupes(GRP_PROVI_L3,0)="PROVI-L3"
ARYgroupes(GRP_PROVI_L3,1)="SH-WW-IN3-PROVISIONING_TOOLS"

ARYgroupes(GRP_CTOOL_L3,0)="CTOOL-L3"
ARYgroupes(GRP_CTOOL_L3,1)="SH-WW-IN3-CONFIG_MGMT_TOOLS"

ARYgroupes(GRP_PTC,0)="PTC"
ARYgroupes(GRP_PTC,1)="SH-EU-IS3-AMTF_PROJECT_LEAD,'SH-WW-IN3-APP_SERV_RESEARCH,SH-WW-IN3-APP_SERV_VACCINES,CM-EU-IS-NGDC_EUROPE"

ARYgroupes(GRP_AMTF_L3,0)="AMTF-L3"
ARYgroupes(GRP_AMTF_L3,1)="SH-WW-OP3-AMTF_PROVISIONING,SH-WW-IN3-AMTF,SH-WW-OP3-AMTF"

ARYgroupes(GRP_ITSM,0)="ITSM"
ARYgroupes(GRP_ITSM,1)="SH-WW-IN2-PROMISE,SH-WW-IN3-PROMISE,SH-WW-IN3-PROMISE_EXPERTISE,SH-WW-IN3-PROMISE_REPORTING,SH-WW-OP2-PROMISE_SUPPORT"

ARYgroupes(GRP_POD,0)="POD"
ARYgroupes(GRP_POD,1)="SH-WW-IN3-POD"

'***************** L2 **********************
ARYgroupes(GRP_MON_L2,0)="MON-L2"
ARYgroupes(GRP_MON_L2,1)="SH-WW-OP2-MONITORING_TOOLS"

ARYgroupes(GRP_PROVI_L2,0)="PROVI-L2"
ARYgroupes(GRP_PROVI_L2,1)="SH-WW-OP2-PROVISIONING_TOOLS"

ARYgroupes(GRP_OPTOOL_L2,0)="OPTOOL-L2"
ARYgroupes(GRP_OPTOOL_L2,1)="SH-WW-OP2-OPERATION_TOOLS_OTHER"

ARYgroupes(GRP_OS400_L2,0)="OS400-L2"
ARYgroupes(GRP_OS400_L2,1)="SH-WW-OP2-OS400"

ARYgroupes(GRP_UNIX_L2,0)="UNIX-L2"
ARYgroupes(GRP_UNIX_L2,1)="SH-WW-OP2-UNIX"

ARYgroupes(GRP_WIN_L2,0)="WIN-L2"
ARYgroupes(GRP_WIN_L2,1)="SH-WW-OP2-WINDOWS"

ARYgroupes(GRP_MDW_L2,0)="MDW-L2"
ARYgroupes(GRP_MDW_L2,1)="SH-WW-OP2-MIDDLEWARE"

ARYgroupes(GRP_ORA_L2,0)="ORA-L2"
ARYgroupes(GRP_ORA_L2,1)="SH-WW-OP2-DATABASE_ORACLE"

ARYgroupes(GRP_MSSQL_L2,0)="MSSQL-L2"
ARYgroupes(GRP_MSSQL_L2,1)="SH-WW-OP2-DATABASE_SQL"

ARYgroupes(GRP_SAN_L2,0)="SAN-L2"
ARYgroupes(GRP_SAN_L2,1)="SH-WW-OP2-STORAGE"

ARYgroupes(GRP_BKP_L2,0)="BKP-L2"
ARYgroupes(GRP_BKP_L2,1)="SH-WW-OP2-BACKUP_RESTORE"

ARYgroupes(GRP_NETWRK_L2,0)="NETDIR-L2"
ARYgroupes(GRP_NETWRK_L2,1)="SH-WW-OP2-NETWORK_DIRECTORY"

ARYgroupes(GRP_COLLAB_L2,0)="COLLAB-L2"
ARYgroupes(GRP_COLLAB_L2,1)="SH-WW-OP2-COLLABORATION"

ARYgroupes(GRP_EROOM_L2,0)="EROOM-L2"
ARYgroupes(GRP_EROOM_L2,1)="SH-WW-OP2-EROOM"

ARYgroupes(GRP_SCHED_L2,0)="SCHED-L2"
ARYgroupes(GRP_SCHED_L2,1)="SH-WW-OP2-BATCH_SCHEDULING"

ARYgroupes(GRP_SAP_L2,0)="SAP-L2"
ARYgroupes(GRP_SAP_L2,1)="SH-WW-OP2-SAP"

ARYgroupes(GRP_NETWK_L2,0)="NETWK-L2"
ARYgroupes(GRP_NETWK_L2,1)="SH-WW-OP2-NETWORK"

ARYgroupes(GRP_COORD_L2,0)="COORD-L2"
ARYgroupes(GRP_COORD_L2,1)="CM-WW-OP2-CHANGE_COORDINATION"

'***************** L1 **********************
ARYgroupes(GRP_OP_L1,0)="OP-L1"
ARYgroupes(GRP_OP_L1,1)="SH-WW-OP1-OPERATIONS"

ARYgroupes(GRP_SDP_L1,0)="SDP-L1"
ARYgroupes(GRP_SDP_L1,1)="SH-FR-SD1-SERVICE_DESK_PASTEUR"

''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

function GetInfosGroupe (id_groupe,byRef NomGroupe)
 dim it,res,up,down,tmp
 up=Ubound(ARYgroupes,1)
 down=0
 do until up<down
	it=int((up+down)/2)
	res=StrComp(id_groupe,ARYgroupes(it,0))
	'response.write " ("&down&":"&ARYgroupes(down,0)&" { "&it&":"&ARYgroupes(it,0)&" { "&up&":"&ARYgroupes(up,0)&") res: "&res&vbcrlf
	if  res=0  then
		NomGroupe=ARYgroupes(it,1)
'		codeGroupe=ARYgroupes(it,2)
		GetInfosGroupe=True
		exit function
	elseif res>0 then
		down=it+1'all are differents
	else
		up=it-1
	end if
 loop
'we didn't find it. that's ok, there is a default behavior

NomGroupe=""
GetInfosGroupe=False
end function


function Iif(proposition,vrai,faux)
	if proposition then
		Iif=vrai
	else
		Iif=faux
	end if
End Function

'overload default trim function as it does not do the trick.
function trim(x)
	dim l,r,tmp,s,d
	s=len(x )
	for l=1 to s
		tmp=mid(x,l,1)
		if tmp >= "!" then 
			exit for
		end if
	next 
	
	for r=s to l step -1
		tmp=mid(x,r,1)
		if tmp >= "!" then
			r=r+1
			exit for
		end if
	next 
	
	d=r-l
	if d>0 then
		trim=mid(x,l,d)
	else
		trim=empty
	end if
end function
	


%>