<%
function home_GenURL(id_groupe  )
    Home_GenURL = "?e="&options.env&"&amp;g=" & ARYgroupes(id_groupe, GRP_ID) 
end function 'Home_GenURL

sub home_welcome2(options)
	%>
	<p> Please fill the gaps in the form and submit it.
	<%
end sub

sub home_welcome (options)
	dim tmp
	tmp = "&amp;t="&options.type_ticket&"&amp;s="&options.sens_rech&"&amp;query="&options.ticket_user
%>
<div id="portal">
	<p> Please select on of the below link...</p>
	<div class="levels ">
		<h2>PTC - AMTF</h2>
		<div class="groups">	
		<ul>
			<li><a href="<% = Home_GenURL(GRP_PTC) & tmp %>"><% = ARYgroupes(GRP_PTC, GRP_LIB) %></a></li>
			<li><a href="<% = Home_GenURL(GRP_AMTF3) & tmp %>"><% = ARYgroupes(GRP_AMTF3, GRP_LIB) %></a></li>			
		</ul><div class="reset"></div>
		</div>
	</div>
		<div class="levels">
		<h2>LEVEL 3</h2>
		<div class="groups">
			<ul>
				<li><h3>DATA MANAGEMENT</h3></li>
				<li><a href="<% = Home_GenURL(GRP_L3_ORA)	& tmp %>"><% = ARYgroupes(GRP_L3_ORA, GRP_LIB) %></a></li>
				<li><a href="<% = Home_GenURL(GRP_L3_MSSQL)	& tmp %>"><% = ARYgroupes(GRP_L3_MSSQL, GRP_LIB) %></a></li>
				<li><a href="<% = Home_GenURL(GRP_L3_OTHER)	& tmp %>"><% = ARYgroupes(GRP_L3_OTHER, GRP_LIB) %></a></li>
				<li><a href="<% = Home_GenURL(GRP_L3_ETL)	& tmp %>"><% = ARYgroupes(GRP_L3_ETL, GRP_LIB) %></a></li>
			</ul><div class="reset"></div>
		</div>
		<div class="groups">
			<ul>
				<li><h3>SERVERS / STORAGE MGT</h3></li>
				<li><a href="<% = Home_GenURL(GRP_L3_UNIX)	& tmp %>"><% = ARYgroupes(GRP_L3_UNIX, GRP_LIB) %></a></li>
				<li><a href="<% = Home_GenURL(GRP_L3_SAN)	& tmp %>"><% = ARYgroupes(GRP_L3_SAN, GRP_LIB) %></a></li>
				<li><a href="<% = Home_GenURL(GRP_L3_WIN)	& tmp %>"><% = ARYgroupes(GRP_L3_WIN, GRP_LIB) %></a></li>
			</ul><div class="reset"></div>
		</div>
		<div class="groups">
				<ul>
				<li><h3>TOOLS</h3></li>
				<li><a href="<% = Home_GenURL(GRP_L3_MON)	& tmp %>"><% = ARYgroupes(GRP_L3_MON, GRP_LIB) %></a></li>
				<li><a href="<% = Home_GenURL(GRP_L3_SCHED)	& tmp %>"><% = ARYgroupes(GRP_L3_SCHED, GRP_LIB) %></a></li>
				<li><a href="<% = Home_GenURL(GRP_L3_PTOOL)	& tmp %>"><% = ARYgroupes(GRP_L3_PTOOL, GRP_LIB) %></a></li>
				<li><a href="<% = Home_GenURL(GRP_L3_CTOOL)	& tmp %>"><% = ARYgroupes(GRP_L3_CTOOL, GRP_LIB) %></a></li>
			</ul><div class="reset"></div>
		</div>
		<div class="groups">
			<ul>
				<li><h3>APPLICATION GIS SERVICES</h3></li>
				<li><a href="<% = Home_GenURL(GRP_L3_AS)	& tmp %>"><% = ARYgroupes(GRP_L3_AS, GRP_LIB) %></a></li>
				<li><a href="<% = Home_GenURL(GRP_L3_AS_IA)	& tmp %>"><% = ARYgroupes(GRP_L3_AS_IA, GRP_LIB) %></a></li>
				<li><a href="<% = Home_GenURL(GRP_L3_AS_PO)	& tmp %>"><% = ARYgroupes(GRP_L3_AS_PO, GRP_LIB) %></a></li>
				<li><a href="<% = Home_GenURL(GRP_L3_RSCH)	& tmp %>"><% = ARYgroupes(GRP_L3_RSCH, GRP_LIB) %></a></li>
				<li><a href="<% = Home_GenURL(GRP_L3_AS_VAX)	& tmp %>"><% = ARYgroupes(GRP_L3_AS_VAX, GRP_LIB) %></a></li>
				<li><a href="<% = Home_GenURL(GRP_L3_AS_CORP)& tmp %>"><% = ARYgroupes(GRP_L3_AS_CORP, GRP_LIB) %></a></li>
				<li><a href="<% = Home_GenURL(GRP_L3_GZM)	& tmp %>"><% = ARYgroupes(GRP_L3_GZM, GRP_LIB) %></a></li>
				<li><a href="<% = Home_GenURL(GRP_L3_AS_MER)	& tmp %>"><% = ARYgroupes(GRP_L3_AS_MER, GRP_LIB) %></a></li>
			</ul><div class="reset"></div>
		</div>
		<div class="groups">
			<ul>
					<li><h3>SOFTWARE & WEB SERVICES</h3></li>
					<li><a href="<% = Home_GenURL(GRP_L3_SAP)	& tmp %>"><% = ARYgroupes(GRP_L3_SAP, GRP_LIB) %></a></li>
					<li><a href="<% = Home_GenURL(GRP_L3_MDW)	& tmp %>"><% = ARYgroupes(GRP_L3_MDW, GRP_LIB) %></a></li>
			</ul><div class="reset"></div>
		</div>
		<div class="groups">		
			<ul>
				<li><h3>COLLABORATION SERVICES</h3></li>
				<li><a href="<% = Home_GenURL(GRP_L3_EXCHG)	& tmp %>"><% = ARYgroupes(GRP_L3_EXCHG, GRP_LIB) %></a></li>
				<li><a href="<% = Home_GenURL(GRP_L3_MSG)	& tmp %>"><% = ARYgroupes(GRP_L3_MSG, GRP_LIB) %></a></li>
			</ul><div class="reset"></div>
		</div>
	</div>
	<div class="levels">
		<h2>LEVEL2 - MANAGED SERVICES</h2><div class="groups">
		<ul>
			<li><a href="<% = Home_GenURL(GRP_L2_MONIT)	& tmp %>"><% = ARYgroupes(GRP_L2_MONIT, GRP_LIB) %></a></li>
			<li><a href="<% = Home_GenURL(GRP_L2_PROVI)	& tmp %>"><% = ARYgroupes(GRP_L2_PROVI, GRP_LIB) %></a></li>
			<li><a href="<% = Home_GenURL(GRP_L2_OPTOOL)& tmp %>"><% = ARYgroupes(GRP_L2_OPTOOL, GRP_LIB) %></a></li>
			<li><a href="<% = Home_GenURL(GRP_L2_OS400)	& tmp %>"><% = ARYgroupes(GRP_L2_OS400, GRP_LIB) %></a></li>
			<li><a href="<% = Home_GenURL(GRP_L2_UNIX)	& tmp %>"><% = ARYgroupes(GRP_L2_UNIX, GRP_LIB) %></a></li>
			<li><a href="<% = Home_GenURL(GRP_L2_WIN)	& tmp %>"><% = ARYgroupes(GRP_L2_WIN, GRP_LIB) %></a></li>
			<li><a href="<% = Home_GenURL(GRP_L2_MDW)	& tmp %>"><% = ARYgroupes(GRP_L2_MDW, GRP_LIB) %></a></li>
			<li><a href="<% = Home_GenURL(GRP_L2_ORA)	& tmp %>"><% = ARYgroupes(GRP_L2_ORA, GRP_LIB) %></a></li>
			<li><a href="<% = Home_GenURL(GRP_L2_MSSQL)	& tmp %>"><% = ARYgroupes(GRP_L2_MSSQL, GRP_LIB) %></a></li>
			<li><a href="<% = Home_GenURL(GRP_L2_SAN)	& tmp %>"><% = ARYgroupes(GRP_L2_SAN, GRP_LIB) %></a></li>
			<li><a href="<% = Home_GenURL(GRP_L2_BCKUP)	& tmp %>"><% = ARYgroupes(GRP_L2_BCKUP, GRP_LIB) %></a></li>
			<li><a href="<% = Home_GenURL(GRP_L2_NET)	& tmp %>"><% = ARYgroupes(GRP_L2_NET, GRP_LIB) %></a></li>
			<li><a href="<% = Home_GenURL(GRP_L2_NETWRK)	& tmp %>"><% = ARYgroupes(GRP_L2_NETWRK, GRP_LIB) %></a></li>
			<li><a href="<% = Home_GenURL(GRP_L2_COLLAB)	& tmp %>"><% = ARYgroupes(GRP_L2_COLLAB, GRP_LIB) %></a></li>
			<li><a href="<% = Home_GenURL(GRP_L2_EROOM)	& tmp %>"><% = ARYgroupes(GRP_L2_EROOM, GRP_LIB) %></a></li>
			<li><a href="<% = Home_GenURL(GRP_L2_SCHED)	& tmp %>"><% = ARYgroupes(GRP_L2_SCHED, GRP_LIB) %></a></li>
			<li><a href="<% = Home_GenURL(GRP_L2_SAP)	& tmp %>"><% = ARYgroupes(GRP_L2_SAP, GRP_LIB) %></a></li>
		</ul><div class="reset"></div>
		</div>
	</div>
	<div class="levels ">
		<h2>LEVEL 1</h2>
		<div class="groups">
		<ul>
			<li><a href="<% = Home_GenURL(GRP_L1_OP)	& tmp %>"><% = ARYgroupes(GRP_L1_OP, GRP_LIB) %></a></li>
		</ul><div class="reset"></div>
		</div>
	</div>
</div>
<%
end sub ' home_welcome 
%>