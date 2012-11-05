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

<%@page import="org.apache.commons.io.IOUtils"%>
<%@page import="java.net.URLEncoder"%>
<%@page import="org.apache.commons.fileupload.FileItem"%>
<%@page import="org.apache.commons.fileupload.disk.DiskFileItemFactory"%>
<%@page import="org.apache.commons.fileupload.servlet.ServletFileUpload"%>
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
            
            if (domainName == null) {
            	domainName = "default";
            	session.setAttribute("stub.domainName", domainName);
            }
            
            Domain domain = 
                DomainFactory.getInstance().getDomain(domainName);

            String user = request.getParameter("user");
            if (user == null) {
                user = (String) session.getAttribute("stub.user");
            }
            session.setAttribute("stub.user", user);
            
            String action = request.getParameter("action");

            if ("changeDomain".equals(action)) {
                String domainSelection = request.getParameter("domainSelection");
                String domainPassword = request.getParameter("domainPassword");

                if (domainSelection != null) {
                	
                	if (domainSelection.equals(domainName)) {
                		message = StringUtil.failureMsg("Same as current workspace");
                	}
                	else {
                		
                		Domain tmp = DomainFactory.getInstance().getDomain(domainSelection);
                		
                		if (tmp.authenticate(domainPassword)) {
                			domainName = domainSelection;
                    		session.setAttribute("stub.domainName", domainName);
                    		domain = DomainFactory.getInstance().getDomain(domainName);
                    		message = StringUtil.successMsg("Workspace changed to " + domainName);
                		} else {
                			message = StringUtil.failureMsg("Authentication failed");
                		}
                	}
                }
            }
            else if ("createDomain".equals(action)) {
                
                String domainStr = request.getParameter("domainName");
                if (!StringUtil.isValid(domainStr)) {
                	message = StringUtil.failureMsg("Give a valid name");
                }
                else if (DomainFactory.getInstance().getDomain(domainStr) != null) {
                    message = StringUtil.failureMsg("Workspace already exists");
                }
                else {
                    domain = DomainFactory.getInstance().createDomain(domainStr);
                    domainName = domainStr;
                    session.setAttribute("stub.domainName", domainName);
                    message = StringUtil.successMsg("Workspace " + domainName + " created");
                }
            }
            else if ("deleteDomain".equals(action)) {
                
                DomainFactory.getInstance().removeDomain(domain);
                message = StringUtil.successMsg("Workspace " + domainName + " deleted");
                domainName = "default";
                domain = DomainFactory.getInstance().getDomain(domainName);
                session.setAttribute("stub.domainName", domainName);

            }
            else if ("exportDomain".equals(action)) {

                String fileName = DomainFactory.getInstance().exportDomain(domainName);
                response.reset();
                response.setContentType("application/octet-stream");
                response.setHeader("Content-Disposition",
                    "attachment;filename=" + domainName + ".xml");
                
                out.clear();
                out.write(IOUtils.toString(new FileReader(new File(fileName))));
                return;

            }
            else if ("importDomain".equals(action)) {
            	
                try {
                    
                	ServletFileUpload servletFileUpload = new ServletFileUpload(new DiskFileItemFactory());

                	FileItem fileItem = (FileItem) servletFileUpload.parseRequest(request).get(0);

               	 	File file = new File(application.getRealPath("/workspace") + "/" + fileItem.getName());
               	 	fileItem.write(file);
               	  	String fileName = URLEncoder.encode(file.getName(), "UTF-8");
                    domain = DomainFactory.getInstance().importDomain(file, false);
                    
                    if (domain == null) {
                    	%>
                    	<script type="text/javascript">
                    		window.addEventListener("load", function(e) { 
                    			var answer = confirm("Workspace already present. Do you want to merge?");
                            	if (answer) {
                            		window.location = "domain.jsp?action=mergeDomain&domainFileName=<%=fileName %>"
                            	}
                            	else {
                            		window.location = "domain.jsp?action=cancelMerge"
                            	}
                    		}, false); 
                    	</script>
                    	<%
                    } else {
                    	domainName = domain.getName();
                    	session.setAttribute("stub.domainName", domainName);
                    	message = StringUtil.successMsg("Domain " + domainName + " imported successfully.");
                    }
                }
                catch (Exception e) {
                    e.printStackTrace();
                    message = StringUtil.failureMsg("Bad file");
                }
            }
            else if ("mergeDomain".equals(action)) {
                try {
                    
               	 	File file = new File(application.getRealPath("/workspace") + "/" + request.getParameter("domainFileName"));
               	  	
                    domain = DomainFactory.getInstance().importDomain(file, true);
                    domainName = domain.getName();
                    session.setAttribute("stub.domainName", domainName);
                    message = StringUtil.successMsg("Workspace " + domainName + " imported successfully.");
                }
                catch (Exception e) {
                    e.printStackTrace();
                    message = StringUtil.failureMsg("Bad file");
                }
            } else if ("cancelMerge".equals(action)) {
            	message = StringUtil.failureMsg("Workspace merge cancelled");
            }
            else if ("secureDomain".equals(action)) {
             	String password = request.getParameter("domainPassword");
             	String confirmPassword = request.getParameter("confirmDomainPassword");
                if (!StringUtil.isValid(password)) {
                	message = StringUtil.failureMsg("Give a valid password");
                }
                else if (!StringUtil.isValid(confirmPassword)) {
                	message = StringUtil.failureMsg("Confirm the password");
                }
                else if (!password.equals(confirmPassword)) {
                	message = StringUtil.failureMsg("Password confirmation failed");
                }
                else {
               		domain.setPassword(password);
               		DomainFactory.getInstance().updateDomain(domain);
               		message = StringUtil.successMsg("Domain " + domainName + " is now secured");
               	}
            }
            else if ("updateDomainPassword".equals(action)) {
             	try {
             		String oldPassword = request.getParameter("domainPassword");
             		String newPassword = request.getParameter("newDomainPassword");
             		domain.updatePassword(oldPassword, newPassword);
             		if (StringUtil.isValid(newPassword))
             			message = StringUtil.successMsg("Workspace password updated");
             		else 
             			message = StringUtil.successMsg("Workspace password removed");
             		DomainFactory.getInstance().updateDomain(domain);
             	}
             	catch (Exception e) {
             		message = StringUtil.failureMsg(e.getMessage());
             	}
            }
        %>
        
        <style type="text/css">
            a
            {
                color: #606060;
                font-size: 13px;
                font-family: arial;
                text-decoration: none
            }
            a:hover
            {
                text-decoration: none;
                color: #FF6600;
                font-size: 13px;
                font-family: arial;
            }
        
            a.active
            {
                color: #a22022;
                font-size: 13px;
                font-family: arial;
                text-decoration: none
            }
            a.active:hover
            {
                text-decoration: none;
                color: #FF6600;
                font-size: 13px;
                font-family: arial;
            }
            table.ts {
                border-left-width: 1px;
                border-right-width: 0px;
                border-top-width: 1px;
                border-bottom-width: 0px;
                border-style: solid;
                border-color: #808080
            }
            table.ts td {
                border-left-width: 0px;
                border-right-width: 1px;
                border-top-width: 0px;
                border-bottom-width: 1px;
                border-style: solid;
                border-color: #808080
            }
            fieldset {
            	padding: 10px;
            }
        </style>
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
            function exportDomain() {
                window.location = "domain.jsp?action=exportDomain";
            }            
            function deleteDomain(domainName) {
            	var answer = confirm("Are you sure you want to delete workspace " + domainName);
            	if (answer) {
            		window.location = "domain.jsp?action=deleteDomain";
            	}
            }
            function secureThisDomain(domainName) {
            	var answer = confirm("Are you sure you want to setup authentication to workspace " + domainName);
            	if (answer) {
            		document.secureDomain.submit();
            	}
            }
            function updatePassword(domainName) {
            	var answer = confirm("Are you sure you want to update authentication to workspace " + domainName);
            	if (answer) {
            		document.updateDomainPassword.submit();
            	}
            }
            function checkForPassword(domainName) {
            	var securedDomains = new Array();
            	<%
           		int i = 0;
           		for (String sdName : DomainFactory.getInstance().getSecureDomains()) {
       			%>
       			securedDomains[<%=i %>] = "<%=sdName %>";
       			<%
       				i++;
           		}
            	%>
            	
            	if (securedDomains.contains(domainName)) {
            		document.getElementById("domainPasswordSpan").style.display = "inline";
            	} else {
            		document.getElementById("domainPasswordSpan").style.display = "none";
            	}
            	
            }
            Array.prototype.contains = function(obj) {
        		var i = this.length;
        		while (i--) {
					if (this[i] == obj) {
        	    		return true;
        	   		}	
        		}
        	  	return false;
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
		                    	<font size="2" face="arial">
		                    		<%
		                    		if ("default".equals(domainName)) {
		                    		%>
		                    		You are currently using default workspace. <font color="red">You should change to your dedicated workspace or create a new
		                    		workspace to avoid complication.</font>
		                    		<%
		                    		} else {
		                    		%>
		                    		You are currently using <b><%=domainName %></b> workspace. The system does not store information on file/DB, it is advisable to
                                    export your workspace on timely basis as backup.
                                    <br><br>
                                    <input type="button" onclick='javascript:exportDomain()' name='expDom' value="Export this workspace"/>
                                    <input type="button" onclick='javascript:deleteDomain("<%=domainName %>")' name='delDom' value="Delete this workspace"/>
		                    		<%
		                    		}
		                    		%>
	                            </font>
	                            <br><br>
		                    </td>
		                </tr>
		            	<tr>
							<td>
						        <form action="domain.jsp" method="post">
						            <input type="hidden" name="action" value="changeDomain" />     
									<fieldset style="text-align:left;" >
										<legend><b><a href="javascript:showContent('changeDomainDiv')">Change workspace</a></b></legend>
										<div id="changeDomainDiv" style="display:block;">
					                		<font face="arial" size="2">Select a workspace from list : </font>
				                        	<select id="domainSelection" name="domainSelection" onchange="javascript:checkForPassword(this.value)">
					                            <option value="default">default</option>
					                            <%
					                            for (String dom : DomainFactory.getInstance().getDomains()) 
					                            {
					                                if (!"default".equals(dom)) {
					                            %>
					                                <option value="<%=dom %>" <%=(domainName.equals(dom))?"selected='selected'":"" %> ><%=dom %></option>
					                            <%
					                                }
					                            }
					                            %>
					                        </select>
				                        	<span id="domainPasswordSpan" style="display:none"><font face="arial" size="2">Password : </font>
				                        	<input name="domainPassword" type="password" /></span>
					                        &nbsp;<input type="submit" value="Change">
										</div>
									</fieldset>
						        </form>
			        		</td>
		        		</tr>
		        		<tr>
		        			<td>
			        			<form action="domain.jsp" method="post">
				           			<input type="hidden" name="action" value="createDomain" />   
									<fieldset style="text-align:left;" >
										<legend><b><a href="javascript:showContent('createDomainDiv')">Create New workspace</a></b></legend>
										<div id="createDomainDiv" style="display:block;">
					                		<font face="arial" size="2">Name : </font>
				                        	<input name="domainName" type="text"/>&nbsp;
					                        <input type="submit" value="Create">
										</div>
									</fieldset>  
			        			</form>
		        			</td>
	        			</tr>
			        	<tr>
			        		<td>
			        			<form action="domain.jsp?action=importDomain" method="post" ENCTYPE="multipart/form-data">
									<fieldset style="text-align:left;" >
										<legend><b><a href="javascript:showContent('importDomainDiv')">Import workspace</a></b></legend>
										<div id="importDomainDiv" style="display:block;">
					                		<font face="arial" size="2">File : </font>
				                        	<input type="file" name="domainFile"/>&nbsp;
					                        <input type="submit" value="Import"/>
										</div>
									</fieldset>  
						        </form>
					        </td>
				        </tr>
				        <%
				        if (!"default".equals(domainName)) {
				        	if (domain.getPassword() == null) {
				        		
				        %>
				        	<tr>
				        		<td>
				        			<form name="secureDomain" action="domain.jsp" method="post">
										<fieldset style="text-align:left;" >
											<legend><b><a href="javascript:showContent('secureDomainDiv')">Secure Your workspace</a></b></legend>
											<div id="secureDomainDiv" style="display:none;">
												<input type="hidden" name="action" value="secureDomain" />
						                		<font face="arial" size="2">Password : </font>
					                        	<input type="password" name="domainPassword"/>&nbsp;
						                		<font face="arial" size="2">Confirm Password : </font>
					                        	<input type="password" name="confirmDomainPassword"/>&nbsp;
						                        <input type="button" value="Secure" onclick='javascript:secureThisDomain("<%=domainName %>")'/>
											</div>
										</fieldset>  
							        </form>
						        </td>
					        </tr>
				        <%
				        	}
				        	else {
				        %>
				        	<tr>
				        		<td>
				        			<form name="updateDomainPassword" action="domain.jsp" method="post">
										<fieldset style="text-align:left;" >
											<legend><b><a href="javascript:showContent('updateDomainPasswordDiv')">Update Password</a></b></legend>
											<div id="updateDomainPasswordDiv" style="display:none;">
												<input type="hidden" name="action" value="updateDomainPassword" />
						                		<font face="arial" size="2">Current Password : </font>
					                        	<input type="password" name="domainPassword"/>&nbsp;
						                		<font face="arial" size="2">New Password : </font>
					                        	<input type="password" name="newDomainPassword"/>&nbsp;
						                        <input type="button" value="Update" onclick='javascript:updatePassword("<%=domainName %>")'/>
											</div>
										</fieldset>  
							        </form>
						        </td>
					        </tr>
				        <%
				        	}
				        }
				        %>
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