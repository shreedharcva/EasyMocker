<!-- 
 *  Copyright 2010-2011 the original author or authors.
 *
 *  WebServiceMocker is free software; you can redistribute it and/or modify it under the 
 *  terms of version 2.1 of the GNU Lesser General Public License as published by 
 *  the Free Software Foundation.
 *
 *  WebServiceMocker is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without 
 *  even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. 
 *  See the GNU Lesser General Public License for more details at gnu.org.
 *  -->

<%@page import="java.net.URLEncoder"%>
<%@page import="net.sf.sripathi.ws.mock.Operation"%>
<%@page import="net.sf.sripathi.ws.mock.Service"%>
<%@page import="net.sf.sripathi.ws.mock.DomainFactory"%>
<%@page import="net.sf.sripathi.ws.mock.Domain"%>

<%

String domainName = (String) session.getAttribute("stub.domainName");
Domain domain = null;

if (domainName != null) {
	domain = DomainFactory.getInstance().getDomain(domainName);
}

String path = request.getServletPath();
String serviceName = request.getParameter("serviceName");
String operationName = request.getParameter("operationName");
%>

<script type="text/javascript">
	function showContent(d) 
	{
		element1 = document.getElementById(d);  
		
	    if (element1.style.display == "block"  || element1.style.display == '')
	    {
	    	element1.style.display = "none";
	    }
	    else
	    {
	    	element1.style.display = "block";
	    }
	}
    function hideContent(d) 
    {
        document.getElementById(d).style.display = "none";
    }

</script>
<fieldset style="padding:5px; border: 1px solid #a22022; background-color: #FFF9F9">
	<table id="LinksTab">
	    <tr>
	        <td align="left" width="200" nowrap="nowrap">
	            <b><a href="index.jsp" <%="/index.jsp".equals(path)?"class='active'":"" %>>Home</a></b>
	        </td>
	    </tr>
	    <tr>
	        <td align="left">
	            <b><a href="newservice.jsp" <%="/newservice.jsp".equals(path)?"class='active'":"" %>>New Service</a></b>
	        </td>
	    </tr>
	    <tr>
	        <td align="left">
	            <b><a href="files.jsp" <%="/files.jsp".equals(path)?"class='active'":"" %>>File Repository</a></b>
	        </td>
	    </tr>
	    <tr>
	        <td align="left">
	            <b><a href="log.jsp" <%="/log.jsp".equals(path)?"class='active'":"" %>>View Logs</a></b>
	        </td>
	    </tr>
	    <tr>
	        <td align="left">
	            <b><a href="testclient.jsp" <%="/testclient.jsp".equals(path)?"class='active'":"" %>>Test Client</a></b>
	        </td>
	    </tr>
	    <tr>
	        <td align="left">
	            <font face="arial" size="2px" color="#606060">Workspace : </font><b><a href="domain.jsp" <%="/domain.jsp".equals(path)?"class='active'":"" %>><%=domainName %></a></b>
	        </td>
	    </tr>
	</table>
</fieldSet>
<br>
<% 
if(domain != null) {
  	int i = 0;
  	
  	if (domain.getServiceList().size() > 0) {
%>
	<fieldset style="padding:5px; border: 1px solid #a22022; background-color: #FFF9F9">
		<legend align="center"><a href="javascript:showContent('ServicesTab')">&nbsp;Mocked Services&nbsp;</a></legend>
		<table id="ServicesTab">
	<% 
	  	for (Service service : domain.getServiceList())
		{
			String sername = service.getName();
			String serNameDisplay = sername;
			if (sername.length() > 31) {
				serNameDisplay = sername.substring(0, 29) + "..";
			}
			String serurl = "service.jsp?serviceName=" + URLEncoder.encode(sername, "UTF-8");
	%> 
		    <tr>
		    	<td align="left">
		    		<b><a href="<%=serurl %>" <%=sername.equals(serviceName)?"class='active'":"" %>><%=serNameDisplay %></a></b>
		    		<%
		    		if (sername.equals(serviceName))
		    		{
	    			%>
			    		<table cellpadding="2" cellspacing="0">
			    		<%
			    		for (Operation operation : service.getOperationList()) {
			    			String opename = operation.getName();
			    			String opeNameDisplay = opename;
			    			if (opename.length() > 32) {
			    				opeNameDisplay = opename.substring(0, 30) + "..";
			    			}
			    			String opeurl = "operation.jsp?serviceName="+URLEncoder.encode(sername, "UTF-8")+"&operationName=" + URLEncoder.encode(opename, "UTF-8");
			    		%>
			    			<tr>
			    				<td align="left"><a href='<%=opeurl %>' <%=opename.equals(operationName)?"class='active'":"" %>>-<%=opeNameDisplay %></a></td>
			    			</tr>
			    		
			    		<%
			    		}
			    		%>
			    		</table>
	    			<%
	    			}
		    		%>
		    	</td>
		    </tr>
    <%
    		i++;
    	}
  	%>

	</table>
</fieldSet>
<%
  	}
} 
%>
<br>

<!-- Author - Sripathi Acharya -->
<!-- Version - 1.0 -->