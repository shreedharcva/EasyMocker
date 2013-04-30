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
<%@page import="net.sf.sripathi.ws.mock.util.SoapUIUtil"%>
<%@ page import="java.util.*"%>
<%@ page import="java.io.*"%>
<html>
    <head>
        <title>Generic Web Service Stubbing Utility</title>
        
        <%
            String message = null;
        	boolean failed = false;
            //ServletContext context = getServletContext();
            String domainName = (String) session.getAttribute("stub.domainName");
            
            if (!StringUtil.isValid(domainName))
            {
            %>
                <jsp:forward page="domain.jsp"/>
            <%
            }
            String serviceName = null;
            String operationName = null;
            String defaultResp = null;
            String wsdlUrl = null;
            boolean reqSchemaVal = true;
            Domain domain = 
                DomainFactory.getInstance().getDomain(domainName);

            String action = request.getParameter("action");
            if ("addService".equals(action)) {
            	serviceName = request.getParameter("serviceName");
            	wsdlUrl = request.getParameter("wsdlUrl");
            	
            	String nameType = request.getParameter("nameType");
                if (request.getParameter("reqSchemaVal") == null) {
                    reqSchemaVal = false;
                }
            	if (nameType != null && nameType.equals("generate")) {

            		try {
            			serviceName = SoapUIUtil.getServiceName(wsdlUrl);
            		} catch (Exception e) {

            		}
            		
            		if (serviceName == null) {
            			try {
            				serviceName = wsdlUrl.substring(wsdlUrl.lastIndexOf('/')+1, wsdlUrl.length() - 5);
            			} catch (Exception e1) { e1.printStackTrace(); }
            		}
            	}
            	
            	
            	if (!StringUtil.isValid(wsdlUrl)) {
           			message = StringUtil.failureMsg("Provide Valid URL");
           			failed = true;
            	}
            	else if (!StringUtil.isValid(serviceName)){
            		message = StringUtil.failureMsg("Provide Valid Name");
            		failed = true;
            	}
            	else if (!serviceName.equals(URLEncoder.encode(serviceName, "UTF-8"))) {
            		message = StringUtil.failureMsg("Special characters are not allowed for service name");
            		failed = true;
            	}
            	else if (domain.getService(serviceName) != null) {
    				message = StringUtil.failureMsg("Service with name " + serviceName + " already present.");
    				failed = true;
    			}
            	else {
            		try {
               			Service service = new Service(serviceName, wsdlUrl);
                        service.setReqSchemaVal(reqSchemaVal);
               			domain.addService(service);
               			DomainFactory.getInstance().updateDomain(domain);
            		}
	            	catch (Exception me) {
	            		me.printStackTrace();
    	        		message = StringUtil.failureMsg(me.getMessage());
    	        		failed = true;
        	    	}
            	}
            }
            else if ("addCustomService".equals(action)) {
            	serviceName = request.getParameter("serviceName");
            	operationName = request.getParameter("operationName");
            	defaultResp = request.getParameter("defaultResp");

            	if (!StringUtil.isValid(serviceName)){
            		message = StringUtil.failureMsg("Provide Valid Service Name");
            		failed = true;
            	}
            	else if (!serviceName.equals(URLEncoder.encode(serviceName, "UTF-8"))) {
            		message = StringUtil.failureMsg("Special characters are not allowed for service name");
            		failed = true;
            	}
            	else if (!StringUtil.isValid(operationName)) {
           			message = StringUtil.failureMsg("Provide Valid Opearation Name");
           			failed = true;
            	}
            	else if (domain.getService(serviceName) != null) {
    				message = StringUtil.failureMsg("Service with name " + serviceName + " already present");
    				failed = true;
    			}
            	else {
            		try {
            			
                		Service service = new Service(serviceName, "");
                		
               			Operation operation = new Operation(operationName);
                		Scenario scenario = new Scenario(Operation.DEFAULT_SCE_KEY, Operation.DEFAULT_SCE_DES, defaultResp);
                		operation.getScenarioList().add(scenario);
                		service.getOperationList().add(operation);
                		domain.addService(service);
                		DomainFactory.getInstance().updateDomain(domain);
            		}
	            	catch (Exception me) {
	            		me.printStackTrace();
    	        		message = StringUtil.failureMsg(me.getMessage());
    	        		failed = true;
        	    	}
            	}
            }
            else if ("getServiceName".equals(action)) {
            	wsdlUrl = request.getParameter("wsdlUrl");
            	String serName = null;
            	
            	try {
					
					serName = SoapUIUtil.getServiceName(wsdlUrl);
					
            	} catch (Exception e) {
            		//Http not available
            	}
            	
           		response.setHeader("newServiceName", serName);
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
            	wsdl = ReplaceAll(wsdl, "\\", "/");
            	var start = wsdl.lastIndexOf("/") + 1;
            	var end = wsdl.lastIndexOf("wsdl") - 1;
            	var serviceName = wsdl.substring(start, end);
            	document.addService.serviceName.value = serviceName;
            }
            function ReplaceAll(Source,stringToFind,stringToReplace){
				var temp = Source;
				var index = temp.indexOf(stringToFind);
				while(index != -1){
				temp = temp.replace(stringToFind,stringToReplace);
				index = temp.indexOf(stringToFind);
				}
				return temp;
           	}
	        String.prototype.trim = function () 
	        {
	            return this.replace(/^\s*/, "").replace(/\s*$/, "");
	        }
            function loadWsdl() {
            	wsdlUrl = document.forms[0].wsdlUrl.value;
            	
            	if (wsdlUrl.trim() == "") {
            		alert("Provide a valid WSDL URL")
            	} else {
            		
            		
            		
            		wsdlUrl = ReplaceAll(wsdlUrl, "\\", "/");
                	var start = wsdlUrl.lastIndexOf("/") + 1;
                	var end = wsdlUrl.lastIndexOf("wsdl") - 1;
                	var serviceName = wsdlUrl.substring(start, end);
                	
                	var url = "newservice.jsp";
                	var params = "wsdlUrl=" + encodeURI(wsdlUrl)
                		+ "&tmpServiceName=" + serviceName
                		+ "&action=getServiceName";
                	
                	if (window.XMLHttpRequest)
                  	{// code for IE7+, Firefox, Chrome, Opera, Safari
                  		xmlhttp=new XMLHttpRequest();
                  	}
                	else
                  	{// code for IE6, IE5
                  		xmlhttp=new ActiveXObject("Microsoft.XMLHTTP");
                  	}
                	
                	respSpan = document.getElementById("serviceLoadSpan");
                	
                	xmlhttp.onreadystatechange=function()
                  	{
                  		if (xmlhttp.readyState==4 && xmlhttp.status==200)
                    	{
                    		var sname = xmlhttp.getResponseHeader("newServiceName");
                    		
                    		if (sname == null) {
                    			sname = serviceName;
                    		}
                    		
                    		document.forms[0].serviceName.value = sname;
                    		document.getElementById("serviceNameRow").style.display = "";
                    		document.getElementById("serviceSubmitRow").style.display = "";
                            document.getElementById("serviceOptionRow").style.display = "";
                    		document.getElementById("serviceLoadSpan").style.display = "none";
                    	}
                  		else {
                  			respSpan.innerHTML="<img src='img/ajax-loader.gif' height='12' width='12'/>";
                  		}
                  	}
                	xmlhttp.open("POST", url, true);
                	xmlhttp.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
                	xmlhttp.setRequestHeader("Content-length", params.length);
                	xmlhttp.setRequestHeader("Connection", "close");
                	xmlhttp.send(params);
            	}
            }
            function doSomething(a) {
            	if ("addService" == a) {
            		document.getElementById("serviceNameRow").style.display = "";
            		document.getElementById("serviceSubmitRow").style.display = "";
                    document.getElementById("serviceOptionRow").style.display = "";
            		document.getElementById("serviceLoadSpan").style.display = "none";
            	}
            }
        </script>
    </head>
    <body onload='javascript:doSomething("<%=action %>")'>

		<%
        if (!failed && serviceName != null && ("addService".equals(action) || "addCustomService".equals(action))) {
        
        %>
            <script type="text/javascript">
              window.location = 'service.jsp?serviceName=' + encodeURIComponent("<%=serviceName.replaceAll("\\\\","\\\\\\\\") %>")
            </script>
        <%
        }
		%>

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
                            	<font face="arial" size="2">Here you can create a new mock service. <br><br>You can choose to import the service from WSDL, in this case a valid WSDL URL is required. If you want to use a local WSDL file, upload the file first to <a href="files.jsp">File Repository</a><br>
                            	<br>Ex: http://localhost:8080/services/GetSomething.wsdl<br>or<br>http://localhost:8080/GetSomethingService?wsdl
                            	<br><br>
                            	</font>
						        <form action="newservice.jsp" method="get" name="addService">
						            <input type="hidden" name="action" value="addService" />        
									<fieldset style="text-align:left;" >
										<legend><b><a href="javascript:showContent('wsdlImportDiv');javascript:hideContent('customServiceDiv')">WSDL Import</a></b></legend>
											<div id="wsdlImportDiv" style='display:<%="addCustomService".equals(action)?"none":"block" %>;'>
												<table>
													<tr>
														<td><font face="arial" size="2"><b>Wsdl Url</b></font></td>
														<td><input name="wsdlUrl" size="60" onchange="javascript:populateServiceName()" <%=wsdlUrl!=null?"value='"+wsdlUrl+"'":"" %>/>
															<span id="serviceLoadSpan"><input type="button" name="serviceLoad" value="Load" onclick="javascript:loadWsdl()" /></span> 
														</td>
													</tr>
													<tr style="display: none" id="serviceNameRow">
														<td><font face="arial" size="2"><b>Name</b></font></td>
														<td>
                                                            <input name="serviceName" size="40" <%=serviceName!=null?"value='"+serviceName+"'":"" %>/>
                                                        </td>
													</tr>
													<tr style="display: none" id="serviceOptionRow">
														<td><font face="arial" size="2"><b>Options</b></font></td>
														<td>
                                                            <input name="reqSchemaVal" type="checkbox" checked="checked" /><font face="arial" size="2">&nbsp;Validate SOAP request against WSDL</font>
                                                        </td>
													</tr>  
													<tr style="display: none" id="serviceSubmitRow">
														<td/>
														<td><input type="submit" value="Import"></td>
													</tr>
												</table>
											</div>
									</fieldset>
						        </form>
						        
                            	<font face="arial" size="2">Or you can create a custom service by providing service and operation names. In this case you will lose the option to auto generate the response XMLs.
                            	<br><br>
                            	</font>
						        
						        <form>
						        	<input type="hidden" name="action" value="addCustomService" />   
									<fieldset style="text-align:left;" >
										<legend><b><a href="javascript:showContent('customServiceDiv');javascript:hideContent('wsdlImportDiv')">Custom Service Config</a></b></legend>
											<div id="customServiceDiv" style='display:<%="addCustomService".equals(action)?"block":"none" %>;'>
												<table>
													<tr>
														<td><font face="arial" size="2"><b>Service Name</b></font></td>
														<td><input name="serviceName" <%=serviceName!=null?"value='"+serviceName+"'":"" %>/>
													</tr>
													<tr>
														<td><font face="arial" size="2"><b>Operation Name</b></font></td>
														<td><input name="operationName" <%=operationName!=null?"value='"+operationName+"'":"" %>/></td>
													</tr>
													<tr>
														<td><font face="arial" size="2"><b>Default Resp</b></font></td>
														<td><textarea name="defaultResp" cols="80" rows="10"><%=defaultResp!=null?defaultResp:"" %></textarea> </td>
													</tr>
													<tr>
														<td/>
														<td><input type="submit" value="Create"></td>
													</tr>
												</table>
											</div>
									</fieldset>
								</form>

						        
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