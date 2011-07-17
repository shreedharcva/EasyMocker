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

<%@page import="net.sf.sripathi.ws.mock.Service"%>
<%@page import="net.sf.sripathi.ws.mock.DomainFactory"%>
<%@page import="net.sf.sripathi.ws.mock.Domain"%>
<%@page import="java.nio.ByteBuffer"%>
<%@page import="java.nio.channels.FileChannel"%>
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
            
            if (domain == null) {
            	message = "Domain loading error.";
            }
            
            String logFile = request.getParameter("logFile");
            
            if (!StringUtil.isValid(logFile)) {
            	logFile = "Mock.log";
            }
            
            String logLocation = application.getRealPath("/workspace") + "/" + logFile;
            String log = "";
            int buffer = 2048;
            long fileSize = 0;
            
            RandomAccessFile raf = null;
            FileChannel fc = null;
            try {
            	raf = new RandomAccessFile(logLocation, "r");
            	fc = raf.getChannel();

           		ByteBuffer buf = ByteBuffer.allocate(buffer);
            	
           		fileSize = fc.size();
           		if (fileSize > buffer) {
           			fc.read(buf, fc.size() - buffer);
           		} else {
           			fc.read(buf);
           		}
           		
            	log = new String(buf.array()).trim();
            	
            } catch (FileNotFoundException fnfe) {
            	
            }
            catch (Exception e) {
            	message = StringUtil.failureMsg("Unable to read file from " + logLocation);
            }
            finally {
            	try {
            		raf.close();
            		fc.close();
            	} catch (Exception e) {
            		e.printStackTrace();
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

            function loadMoreLog(logFile, lastLineIndex)
            {
            	if (window.XMLHttpRequest)
              	{// code for IE7+, Firefox, Chrome, Opera, Safari
              		xmlhttp=new XMLHttpRequest();
              	}
            	else
              	{// code for IE6, IE5
              		xmlhttp=new ActiveXObject("Microsoft.XMLHTTP");
              	}
            	
            	xmlhttp.onreadystatechange=function()
              	{
              		if (xmlhttp.readyState==4 && xmlhttp.status==200)
                	{
                		document.getElementById("moreLog").innerHTML=xmlhttp.responseText;
                		document.getElementById("fileSize").innerHTML=xmlhttp.getResponseHeader("file.size");
                		document.getElementById("loading").innerHTML="<a href='javascript:loadMoreLog(\"<%=logFile %>\",\"<%=fileSize %>\")'>Refresh</a>";
                	}
              		else {
              			document.getElementById("loading").innerHTML="<img src='img/ajax-loader.gif' height='16' width='16'/>";
              			document.getElementById("fileSize").innerHTML="<img src='img/ajax-loader.gif' height='12' width='12'/>";
              		}
              	}
            	
            	xmlhttp.open("GET","morelog.jsp?logFile="+logFile+"&lastLineIndex="+lastLineIndex,true);
            	xmlhttp.send();
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
					
				        		<font face="arial" size="2">Here you can see the log file entries for Mocker application. The mocker application
				        		logs request and response SOAP messages.</font><br><br>
								<form action="log.jsp">
								<fieldset style="text-align:left;" >
									<legend><b><a href="javascript:showContent('logFileDiv')">&nbsp;Log File&nbsp;</a></b></legend>
									<div id="logFileDiv" style="display:block;">
										<table>
											<tr>
												<td><font face="arial" size="2"><b>Log File</b></font></td>
												<td><font face="arial" size="2">
													<select name="logFile" onchange="javascript:submit()">
														<option value="Mock.log">system log</option>

														<%
														for (Service service : domain.getServiceList()) {
															String logFileTemp = domainName + "." + service.getName() + ".log";
														%>
															<option value="<%=logFileTemp %>" <%=logFileTemp.equals(logFile)?"selected='selected'":"" %>>service log - <%=service.getName() %></option>
														<%
														}
														%>

													</select>
												</font></td>
											</tr>
											<tr>
												<td><font face="arial" size="2"><b>File Size</b></font></td>
												<td><font face="arial" size="2">&nbsp;<span id="fileSize"><%=fileSize %> bytes</span></font></td>
											</tr>
											<tr>
												<td><font face="arial" size="2"><b>File Location&nbsp;</b></font></td>
												<td><font face="arial" size="2">&nbsp;<%=logLocation %></font></td>
											</tr>
				                		</table>
									</div>
								</fieldset>
								</form>
								<font face="arial" size="2">The following shows the last <%=buffer %> bytes of log file. Click on refresh to update.</font><br><br>
								<fieldset style="text-align:left;" >
									<legend><b><a href="javascript:showContent('logContentDiv')">&nbsp;Log Content&nbsp;</a></b></legend>
									<div id="logContentDiv" style="display:block;">
										<font size="1px" face="verdana">
											<%
											if (fileSize > buffer) {
											%>
											....<br>
											<%
											}
											%>
											<%=StringUtil.forHtmlComplete(log) %><br>
											<span id="moreLog">
											</span>
											<br>
										</font>
										<span id="loading"><a href='javascript:loadMoreLog("<%=logFile %>","<%=fileSize %>")'>Refresh</a></span>
									</div>
								</fieldset>
								<br>
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