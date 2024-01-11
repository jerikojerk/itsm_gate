
PUBLIC FEATURES


database default listing for ticket's population
------------------------------------------------
- CRQ assigned: where team is either manager or coordinator
- CRQ managed: where team is manager
- CRQ submitted: where team was submiter
- INC assigned
- INC submitted / managed
- PBI submited
- PBI assigned / managed
- Approvals
- REQ 
- WO (but perf huge issues)


View concept
------------
for most queries, there are 2 to 4 standpoint 
 - submitter => where current team is submitter of the ticket
 - assignment => where current team is set as assignee on the ticket to handled it (for CRQ manager OR coordinator).
 - manager => where current team is manager of current ticket when manager concept exist for this ticket.
 - coordinator => where current team is coordinator of current tickets 



Support group
-------------
Support group is the "heart" of itsm_gate concept. The tool retreive ticket based on the selected written.
You can also add your own support group thanks to the interface (and book-it for reuse). Support group is a commat separated list of promise support group name.
There are 2 smart support group:
 - myself where the support group is not checked but the assignee/manager/coordinator is instead
 - auto where the support groups are deduced from itsm_gate login.



database simple search
----------------------
- search INC, CRQ, PBI by 1 or multiple CI => @CI 
	- 2 syntax @CI or @"C I" when CI name include @ or spaces.
- search task by CRQ, by PBI or WO CRQ and TAS
- search task by task
- search INC by INC
- search CRQ by CRQ or REQ
- search PBI by PBI
- search people by login, support group, last name.
- search pending approval tickets where requested login is in the list of approver )
- search REQ by REQ
- search REQ approvals/signature by REQ 
- search CRQ approvals/signature by CRQ



database featured search
------------------------
- CRQ -----------------------------------------
	- P1: search P1 crq + emergency changes
	- AMTF: search AMTF change ( CRQ handled to current team + word "AMFT" in the summary )
	- ALL_SINCE: searchs all change handled by current team since a date ( x months defaults )
	- BETWEEN : future use.
	- CHECK_TEMPLATE: search miss-use of standard template (team reassigment)
	- REVIEW:  search CRQ status: [planning in progress -> scheduled] handled by current team 
	- PENDING: search CRQ with status: Draft,Request for authorization,Pending,Rejected 
	- IMPLEMENTATION: search currently active task for current team
	- DONE
	- FRESH_CLOSED
	- FROM_TOOL: search open CRQ created through an init request (actualy critera is the submiter tool) handled by current team
	- NO_TASK: search open CRQ where there are no task in it (usefull for ad-hoc change)
	- NO_DB : search opene changes handled by current team where no db CI is in relationships
	- NO_SERVER: search open changes handled by current team where no server CI is in relationships 
	- NO_CI : search open changes handled by current team where no CI at all is in relationships.
	- NO_APP : search open changes handled by current team where no APPLLICATION is in relationships.
	
- TAS -----------------------------------------
	- AMTF: search AMTF tasks ( TASK of CRQ handled to current team + word "AMFT" in the summary )
	- CHECK_TEMPLATE: search miss-use of standard template (team reassigment) for changes handled by currentteam
	- OLD: search tasks where the scheduled end time is missed.
	- SLOW: search task where task is active for a long time assigned to current team
	- REVIEW
	- IMPLEMENTATION
	- PENDING: all task with status is pending but not pending error in our team changes
	- DONE
	- FRESH_CLOSED make use of hidden/optional parameter "since" 
	- ALL_SINCE: searchs all change handled by current team since a date ( x months defaults )	
- INC -----------------------------------------
	- FROM_TOOL :  incident created by monitoring assigned to current team.
	- P1
	- REVIEW
	- IMPLEMENTATION
	- DONE
	- FRESH_CLOSED make use of hidden/optional parameter "since" 
	- NO_DB
	- NO_SERVER
	- NO_APP
	- ALL_SINCE

- PBI -----------------------------------------
	- P1
	- ALL_SINCE
	- REVIEW
	- IMPLEMENTATION
	- DONE
	- FRESH_CLOSED make use of hidden/optional parameter "since"



interface feature
-----------------
- export as csv (use menu) 
- comment on lines (disable by default, activate it in the search form (button "...") then activate by select, ctrl+dblclic ) 
- filter on list / filter on simplified regex (multicolumn) or is  pipe (|), jocker is star (*) 
- timezone switching 
- date to elapsed days + remedy like time display  
- ajax refresh of page 
- multicolumn sort 
- multicolumn filtering 
- cell displayed count (+ total count )
- row highlighting (ctrl+click)
- first column gathering for use in research field 
- restore current value 
- activate or not au-detect type of ticket written in search field to avoid to search INCIDENT ID into CHANGE tables (but problematic when looking for task by change)
- user spoofing for MYSELF or Auto , activate it in the search form (button "...")
_ support for user created support group (beta)


ticket browsing (popup/new tab)
-------------------------------
from 1 CRQ
 - get relationship graph
 - get child tasks
 - get Audit of change
 - get work details
 - get change approvals (signature or pending) 
 - get change compliency
 - get change more information than default display


from 1 TAS
 - get workinfo
 - get task audit log
 - get more information than default display
 - get schedule analysis
 
from 1 INC
 - get workinfo
 - get relationship graph
 - get previous incident owner
 - get more information (including resolution field)
 
from 1 PBI
 - get relationships graph
 - get child tasks

from 1 WO 
 - get child tasks
 
from 1 REQ
 - get display in remedy (read-only)
 - get REQ approval-signatures
 - get a link to submit similar REQ
 - get req workinfo (to check for files for example)


browser integration search plugin
---------------------------------
 - tasks (ngdc)
 - people (ngdc)
 - problem (ngdc)
 - incident (ngdc) 


additional searchs and features
-------------------------------
 - download generated sql
 - get list of change template and their tasks where 
	- template set your team a change manager
	- template set your team a change coordinator
	- template set your team as task assignee
	- template was "authored" by your team
 

HIDDEN FEATURES
---------------
- query=ALL_SINCE&since=<n month>
- search CRQ_FREEZE
- state less tool


KNOWN BUGS
----------
 - sort by date is not working properly.
 - filter export is not easy to use, buggy and not IE8 compatible
 - some request need rewrite/indexes as they are inefficients use of existing one. ex WO.
 - some menu option need clarification
 - asp language/asp ADO driver does not support some of oracle syntax & named parameters.

