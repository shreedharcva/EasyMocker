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
<%@page import="net.sf.sripathi.ws.mock.Domain"%>
<%@page import="net.sf.sripathi.ws.mock.DomainFactory"%>
<%@page import="net.sf.sripathi.ws.mock.util.MockException"%>
<%@page import="net.sf.sripathi.ws.mock.util.StringUtil"%>
<%@page import="net.sf.sripathi.ws.mock.util.SoapUIUtil"%>
<%@ page import="java.util.*"%>
<%@ page import="java.io.*"%>
<html>
    <head>
        <title>Generic Web Service Stubbing Utility</title>
        
        <%
            String message = null;
            //ServletContext context = getServletContext();
            String domainName = (String) session.getAttribute("stub.domainName");
            
            if (!StringUtil.isValid(domainName))
            {
            %>
                <jsp:forward page="domain.jsp"/>
            <%
            }
            
            Domain domain = 
                DomainFactory.getInstance().getDomain(domainName);
            
            if (domain == null) {
            	message = "Domain loading error.";
            }
            
            String action = request.getParameter("action");
            
            if ("deleteService".equals(action)) {
            	
            	String serviceName = request.getParameter("serviceName");
            	
            	if (!StringUtil.isValid(serviceName)) {
           			message = StringUtil.failureMsg("Provide Valid service name");
            	}
            	else {
            		try {
            			domain.deleteService(serviceName);
            			DomainFactory.getInstance().updateDomain(domain);
            			message = StringUtil.successMsg("Deleted service " + serviceName);
            		}
	            	catch (MockException me) {
    	        		message = StringUtil.failureMsg(me.getMessage());
        	    	}
            	}
            }
        %>
        <script type="text/javascript">
            function showContent(d) 
            {
                if (document.getElementById(d).style.display != "block")
                {
                    document.getElementById(d).style.display = "block";
                }
                else
                {
                    document.getElementById(d).style.display = "none";
                }
            }
            function hideContent(d) 
            {
                document.getElementById(d).style.display = "none";
            }
            function showFirstHideSecond(sd, hd)
            {
                showContent(sd);
                hideContent(hd);
            }
            function populateServiceName() {
            	var wsdl = new String(document.addService.wsdlUrl.value);
            	var start = wsdl.lastIndexOf("/") + 1;
            	var end = wsdl.lastIndexOf("wsdl") - 1;
            	var serviceName = wsdl.substring(start, end);
            	document.addService.serviceName.value = serviceName;
            }
            function ohMyGod(action, status) {
            	
            }
        </script>
    </head>
    <body>

        <jsp:include page="header.jsp"/>

		<table width="100%" border="0" cellpadding="2" cellspacing="0">
            <tr>
                <td height="100%" valign="top" width="15%">
                    <jsp:include page="nav.jsp"/>
                </td>


                <td  valign="top">
					<div style="padding:5px; border: 1px solid #a22022; background-color: #F9F9F9;">
                    <table width="100%">
                    	<tr>
						<% if (message != null) {%>
							<td align="center" bgcolor="#FFDD00"><b><%=message %></b></td>
						<%} else { %>
							<td></td>
						<%} %>
                    	</tr>
					                <tr>
		                    <td>
					
					        <%
					        if (domain.getServiceList().size() != 0) {
				        	%>
				        		<font face="arial" size="2">Following are the mocked services for this domain. Click on the service name to
				        		view more details.</font><br><br>
				        	<%
					        	for (Service service : domain.getServiceList()) {
					        		String sername = service.getName();
					    			String serurl = "service.jsp?serviceName=" + URLEncoder.encode(sername, "UTF-8");
					        		String endpoint = "http://"+request.getLocalName()+":"+request.getLocalPort()+request.getContextPath()+"/mock/"+domainName+"/service/"+sername;
					        %>
								<fieldset style="text-align:left;" >
									<legend><b><a href="javascript:showContent('<%=sername %>Div')">&nbsp;<%=sername %>&nbsp;</a></b></legend>
									<div id="<%=sername %>Div" style="display:block;">
										<table>
											<tr>
												<td width="110"><font face="arial" size="2"><b>Service Name</b></font></td>
												<td><font face="arial" size="2"><b><a href="<%=serurl %>"><%=sername %></a></b></font></td>
											</tr>
											<tr>
												<td><font face="arial" size="2"><b>Mock Endpoint</b></font></td>
												<td><font face="arial" size="2" color="blue"><%=endpoint %></font></td>
											</tr>
											<tr>
												<td><font face="arial" size="2"><b>Operation List</b></font></td>
												<td><font face="arial" size="2">
			                			    		<%
			                			    		int i=0;
										    		for (Operation operation : service.getOperationList()) {
										    			String opename = operation.getName();
										    			String opeurl = "operation.jsp?serviceName="+URLEncoder.encode(sername, "UTF-8")+"&operationName=" + URLEncoder.encode(opename, "UTF-8");
										    		%>
										    			<a href="<%=opeurl %>"><%=opename %></a> &nbsp;&nbsp;
										    		<%
										    			i++;
										    			if (i%4==0) {
								    				%>
								    					<br>
								    				<%
										    			}
										    		}
										    		%>
													</font>
												</td>
											</tr>
				                		</table>
									</div>
								</fieldset>
								<br>
							<%
					        	}
					        } else {
					       	%>
					       		<font face="arial" size="2">No services are mocked for this domain.<a href="newservice.jsp">Click Here</a> to mock a new service.</font>
					       	<%
					        }
					        %>
		        			</td>
	        			</tr>
        			</table>
	                </div>
	        	</td>
	        </tr>
        </table>

        <jsp:include page="tail.jsp"/>   
        
    </body>
</html>

<!-- Author - Sripathi Acharya -->
<!-- Version - 1.0 -->