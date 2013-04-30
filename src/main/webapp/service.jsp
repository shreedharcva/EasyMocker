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
<%@page import="net.sf.sripathi.ws.mock.Scenario"%>
<%@page import="net.sf.sripathi.ws.mock.Operation"%>
<%@page import="net.sf.sripathi.ws.mock.Service"%>
<%@page import="net.sf.sripathi.ws.mock.Domain"%>
<%@page import="net.sf.sripathi.ws.mock.DomainFactory"%>
<%@page import="net.sf.sripathi.ws.mock.util.MockException"%>
<%@page import="net.sf.sripathi.ws.mock.util.StringUtil"%>
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

            String serviceName = request.getParameter("serviceName");
            String operationName = null;
            String defaultResp = null;
			Service service = null;
            
            if (!StringUtil.isValid(serviceName)) {
            	message = StringUtil.failureMsg("Service " + serviceName + " not found!!!");
            }
            else {
            	service = domain.getService(serviceName);
            	if (service == null) {
            		
            		message = StringUtil.failureMsg("Service " + serviceName + " not found!!!");
            	}
            }
            
            String action = request.getParameter("action");

            if ("updateWsdl".equals(action)) {
            	String wsdlUrl = request.getParameter("wsdlLocation");
                String newServiceName = request.getParameter("newServiceName");
                boolean newSchemaVal = request.getParameter("newReqSchemaVal")==null?false:true;
                
            	if (newSchemaVal == service.isReqSchemaVal() && !StringUtil.isValid(wsdlUrl) && !StringUtil.isValid(newServiceName)) {
           			message = StringUtil.failureMsg("Provide any one valid input");
            	}
            	else if (wsdlUrl.equals(service.getWsdlUrl())) {
            		message = StringUtil.failureMsg("Same as previously configured WSDL");
            	}
                else if (newServiceName.trim().equals(serviceName)) {
					message = StringUtil.failureMsg("Same as previously configured service name");
				}
				else if (domain.getService(newServiceName) != null) {
					message = StringUtil.failureMsg("Another service with this name already present");
				}
            	else {
            		try {
                        if (StringUtil.isValid(newServiceName)) {
                            service.setName(newServiceName);
                            serviceName = newServiceName;
                        }
                        if (StringUtil.isValid(wsdlUrl)) {
                            service.updateWsdlUrl(wsdlUrl);
                        }
                        if (newSchemaVal != service.isReqSchemaVal()) {
                        	service.setReqSchemaVal(newSchemaVal);
                        }
            			DomainFactory.getInstance().updateDomain(domain);
            			message = StringUtil.successMsg("Service Updated Successfully");
            		}
	            	catch (MockException me) {
    	        		message = StringUtil.failureMsg(me.getMessage());
        	    	}
            	}
            }
            else if ("addOperation".equals(action)) {
            	operationName = request.getParameter("operationName");
            	defaultResp = request.getParameter("defaultResp");
            	
            	if (!StringUtil.isValid(operationName)) {
           			message = StringUtil.failureMsg("Provide Valid operation name");
            	}
            	else if (service == null) {
            	}
            	else if (service.getOperation(operationName.trim()) != null) {
            		message = StringUtil.failureMsg("Operation with name " + operationName + " already present");
            	}
            	else {
            		try {
               			Operation operation = new Operation(operationName);
                		Scenario scenario = new Scenario(Operation.DEFAULT_SCE_KEY, Operation.DEFAULT_SCE_DES, defaultResp);
                		operation.getScenarioList().add(scenario);
                		service.getOperationList().add(operation);
                		DomainFactory.getInstance().updateDomain(domain);
                		message = StringUtil.successMsg("Operation " + operationName + " added"); 
                		operationName = "";
                		defaultResp = "";
            		}
	            	catch (MockException me) {
    	        		message = StringUtil.failureMsg(me.getMessage());
        	    	}
            	}
            }
            else if ("deleteOperation".equals(action)) {

            	operationName = request.getParameter("operationName");
            	
				if (!StringUtil.isValid(operationName)) {
            		message = StringUtil.failureMsg("Operation " + operationName + " for service " + serviceName + " not found!!!");
            	}
            	else {
            		service.deleteOperation(operationName);
            		DomainFactory.getInstance().updateDomain(domain);
            		message = StringUtil.successMsg("Operation " + operationName + " deleted");
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
            function deleteService(serviceName) {
            	var answer = confirm("Are you sure you want to delete service " + serviceName);
            	if (answer) {
            		window.location = "index.jsp?action=deleteService&serviceName=" + encodeURIComponent(serviceName);
            	}
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
					        if (service != null) {
					        	String serviceEndpoint = "http://"+request.getLocalName()+":"+request.getLocalPort()+request.getContextPath()+"/mock/"+domainName+"/service/"+serviceName;
					        	String serName = serviceName.replaceAll("\\\\","\\\\\\\\");
				        	%>
				        		<font face="arial" size="2">Service <font color="green"><%=serviceName %></font> is configured
				        		for domain <font color="green"><%=domainName %></font>. Click on the operation name to see the mocked responses.</font><br><br>
				        		
				        		<fieldset style="text-align:left;" >
									<legend><b><a href="javascript:showContent('serviceDetailDiv')">&nbsp;Service Details&nbsp;</a></b></legend>
									<div id="serviceDetailDiv" style="display:block;">
										<table>
											<tr>
												<td width="110"><font face="arial" size="2"><b>Service Name</b></font></td>
												<td><font face="arial" size="2">&nbsp;<%=serviceName %></font></td>
											</tr>
											<tr>
												<td><font face="arial" size="2"><b>Mock Endpoint</b></font></td>
												<td><font face="arial" size="2" color="blue">&nbsp;<%=serviceEndpoint %></font></td>
											</tr>
											<tr>
												<td><font face="arial" size="2"><b>WSDL Location</b></font></td>
												<td><font face="arial" size="2">&nbsp;<%=service.getWsdlUrl() %></font></td>
											</tr>
				                		</table>
									</div>
								</fieldset>
				        		<br><font face="arial" size="2"> If you think the service is not configured as expected, update or delete using
				        		the following form.</font><br><br>
				        		<form action="service.jsp">
					        		<fieldset style="text-align:left;" >
										<legend><b><a href="javascript:showContent('wsdlUpdateDiv')">&nbsp;Update Service&nbsp;</a></b></legend>
										<div id="wsdlUpdateDiv" style="display:block;">
                                            <table border="0" cellpadding="0" cellspacing="2">
                                                <tr>
                                                    <td>
                                                        <input type="hidden" name="serviceName" value="<%=serviceName %>"/>
                                                        <input type="hidden" name="action" value="updateWsdl"/>
                                                        <font face="arial" size="2"><b>Service Name </b></font>
                                                    </td>
                                                    <td>
                                                        <input name="newServiceName" size="20" />
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td>
                                                        <font face="arial" size="2"><b>WSDL Location </b></font>
                                                    </td>
                                                    <td>
                                                        <input name="wsdlLocation" size="50" />
                                                    </td>
                                                </tr>
                                                <% if (StringUtil.isValid(service.getWsdlUrl())) { %>
                                                <tr>
                                                    <td>
                                                        <font face="arial" size="2"><b>Options </b></font>
                                                    </td>
                                                    <td>
                                                        <input name="newReqSchemaVal" type="checkbox" <%=service.isReqSchemaVal()?"checked='checked'":"" %>/>&nbsp;Validate SOAP request against WSDL</font>
                                                    </td>
                                                </tr>
                                                <% } %>
                                                <tr>
                                                    <td></td>
                                                    <td>
                                                        <input type="submit" value="Update Service"/>
                                                        <input type="button" value="Delete Service" onclick='javascript:deleteService("<%=serName %>")'/>
                                                    </td>
                                                </tr>
                                            </table>
										</div>
									</fieldset>
								</form>
				        		<font face="arial" size="2px">The following operations are configured for this service.</font><br><br>
					        	<%
					    		for (Operation operation : service.getOperationList()) {
					    			String opename = operation.getName();
					    			String opeurl = "operation.jsp?serviceName="+URLEncoder.encode(service.getName(), "UTF-8")+"&operationName=" + URLEncoder.encode(opename, "UTF-8");
					    			String key = operation.getKeyElement();
						        %>
								<fieldset style="text-align:left;" >
									<legend><b><a href="javascript:showContent('<%=opename %>Div')">&nbsp;<%=opename %>&nbsp;</a></b></legend>
									<div id="<%=opename %>Div" style="display:block;">
										<table>
											<tr>
												<td><font face="arial" size="2"><b>Operation Name</b></font></td>
												<td><font face="arial" size="2">&nbsp;<a href="<%=opeurl %>"><%=opename %></a></font></td>
											</tr>
											<tr>
												<td><font face="arial" size="2"><b>Key Element</b></font></td>
												<td><font face="arial" size="2">&nbsp;<%=key!=null?key:"<font color='red'>Not configured" %></font></td>
											</tr>
											<tr>
												<td><font face="arial" size="2"><b># mock responses</b></font></td>
												<td><font face="arial" size="2">&nbsp;<%=operation.getScenarioList().size() %></font></td>
											</tr>
				                		</table>
									</div>
								</fieldset>
								<br>
							<%
					        	}
					        }
					        if (service != null && !StringUtil.isValid(service.getWsdlUrl()))
					        {
					        %>
					        	<form action="service.jsp">
					        	<input type="hidden" name="serviceName" value="<%=serviceName %>" />
					        	<input type="hidden" name="action" value="addOperation" />
								<fieldset style="text-align:left;" >
									<legend><b><a href="javascript:showContent('addOperationDiv')">&nbsp;Add A New Operation&nbsp;</a></b></legend>
									<div id="addOperationDiv" style=''display:<%="addOperation".equals(action)&&!"".equals(operationName)?"block":"none" %>;">
										<table>
											<tr>
												<td><font face="arial" size="2"><b>Operation Name</b></font></td>
												<td><font face="arial" size="2"><input name="operationName"  <%=operationName!=null?"value='"+operationName+"'":"" %>/></font></td>
											</tr>
											<tr>
												<td><font face="arial" size="2"><b>Default Resp</b></font></td>
												<td><textarea name="defaultResp" cols="80" rows="10"><%=defaultResp!=null?defaultResp:"" %></textarea> </td>
											</tr>
											<tr>
												<td></td>
												<td><font face="arial" size="2"><input type="submit" name="Create"/></font></td>
											</tr>
				                		</table>
									</div>
								</fieldset>
								</form>
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