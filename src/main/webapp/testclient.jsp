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

<%@page import="net.sf.sripathi.ws.mock.util.WebServiceutil"%>
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
        
	        String domainName = (String) session.getAttribute("stub.domainName");
	        
	        if (domainName == null) {
	        	domainName = "default";
	        	session.setAttribute("stub.domainName", domainName);
	        }
	        
            String message = null;
            String action = request.getParameter("action");
            String url = request.getParameter("endpointUrl");
            String soapReq = request.getParameter("soapReq");
            String username = request.getParameter("username");
            String password = request.getParameter("password");
            String wsdlLocation = request.getParameter("wsdlLocation");
            String soapResp = "";
            
            if ("Load".equals(action)) {
            	String operationName = request.getParameter("operationName");
            	try {
            		soapReq = SoapUIUtil.getDummyRequest(wsdlLocation, operationName);
            	} catch (Exception e) {
            		soapReq = "Unable to generate request soap";
            	}
            }
            else if ("Test".equals(action)) {
            	
            	if (!StringUtil.isValid(url)) {
           			message = StringUtil.failureMsg("Provide Valid end point");
            	}
            	else {
            		soapResp = WebServiceutil.callWebService(soapReq, url, username, password);
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
            function formatXml(element)
            {
                s = new String(element.value);
                s = formatXmlString(s);
                s = additionalXMLFormat(s);
                element.value = s;
            }
            function formatXmlString(input)
            {
                input = input.replace(/\ \ /g,"");
                input = input.replace(/\t/g,"");
                return input;
            }
            function additionalXMLFormat(s)
            {
                var tokens = s.split("<");
                var i = 0;
                var final = "";
                var tab = "  ";
                var howManyTab = -1;
                var lastToken = "";
                if (tokens.length <= 2)
                    return s;
                while (i < tokens.length)
                {
                    var token = tokens[i];
                    token = token.trim();
                    if (token == null || token.length == 0)
                    {
                        i++;
                        continue;
                    }
                    if (token.charAt(0) == '?')
                    {
                        final += '<';
                        final += token;
                        i ++;
                        continue;
                    }
                    if ((token.length - 1) <= (lastToken.length) 
                        &&
                        token.charAt(0) == '/'
                        &&
                        token.substring(1, token.indexOf('>')) == lastToken.substring(0, (token.indexOf('>')-1)))
                    {
                        howManyTab--;
                        final += '<';
                        final += token;
                        i++;
                        lastToken = token;
                        continue;
                    }
                    if (token.charAt(0) == '!' || token.charAt(token.length - 2) == '/')
                    {
                        if (final != "")
                            final += "\n";
                        howManyTab++;
                        for (var j=0; j<howManyTab; j++)
                        {
                            final += tab;
                        }
                        final += "<";
                        final += token;
                        i++;
                        howManyTab--;
                        lastToken = token;
                        continue;
                    }
                    if (token.charAt(0) != '/')
                    {
                        if (final != "")
                            final += "\n";
                        howManyTab++;
                        for (var j=0; j<howManyTab; j++)
                        {
                            final += tab;
                        }
                        final += "<";
                        final += token;
                        i++;
                    }
                    else
                    {
                        if (final != "")
                            final += "\n";

                        for (var j=0; j<howManyTab; j++)
                        {
                            final += tab;
                        }
                        howManyTab--;
                        final += "<";
                        final += token;
                        i++;
                    }
                    lastToken = token;
                }
                return final;
            }
            function wrap(area) {
                if (area.wrap) {
                	if (area.wrap == "off") 
                    	area.wrap="physical";
                	else
                		area.wrap="off";
                } else { // wrap attribute not supported - try Mozilla workaround
                	if (area.getAttribute("wrap") == "off")
                    	area.setAttribute("wrap", "physical");
                	else
                		area.setAttribute("wrap", "off");	
                    var newarea= area.cloneNode(true);
                    newarea.value= area.value;
                    area.parentNode.replaceChild(newarea, area);
                }
            }
            function getRequestSoap(input) {
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
              			if ("1" == xmlhttp.getResponseHeader("OpeataionCount")) {
              				document.getElementById("soapReq").value=additionalXMLFormat(xmlhttp.responseText);
              			}
              			else {
              				document.getElementById("operationList").innerHTML=xmlhttp.responseText;
              				document.getElementById("soapReq").value="select an operation";
              			}
                	}
              		else {
              			document.getElementById("soapReq").value="loading";
              		}
              	}
            	
            	xmlhttp.open("GET","requestgenerator.jsp?wsdlUrl="+encodeURI(input.value),true);
            	xmlhttp.send();
            }
            function populateRequest(value) {
            	value = ReplaceAll(value, "RETURN_CAR", "\r");
            	value = ReplaceAll(value, "NEW_LINE", "\n");
            	value = ReplaceAll(value, "DOUBLE_QUOTE", "\"");
            	value = ReplaceAll(value, "SINGLE_QUOTE", "\''");
            	document.getElementById("soapReq").value = value;
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
		                    <td align="center">
		                    	<form action="testclient.jsp" method="post">
	                    			<table>
	                    				<tr>
	                    					<td width="72" nowrap="nowrap"><font size="2px" face="arial">End Point</font></td>
	                    					<td colspan="3"><input name="endpointUrl" size="58" value='<%=StringUtil.isValid(url)?url:"" %>'></td>
	                    					<td align="left" nowrap="nowrap"><input type="submit" name="action" value="Test"></td>
                    					</tr>
                    					<tr>
                    						<td><font size="2px" face="arial">User Name</font></td>
                    						<td width="150" nowrap="nowrap"><input name="username" value='<%=StringUtil.isValid(username)?username:"" %>'/></td>
                    						<td width="66" nowrap="nowrap"><font size="2px" face="arial">Password</font></td>
                    						<td width="150" nowrap="nowrap">&nbsp;<input name="password" value='<%=StringUtil.isValid(password)?password:"" %>'/></td>
                   						</tr>
                   						<tr>
                   							<td><font size="2px" face="arial">WSDL</font></td>
                   							<td colspan="3" nowrap="nowrap"><input name="wsdlLocation" size="58" value='<%=StringUtil.isValid(wsdlLocation)?wsdlLocation:"" %>'/></td>
                   							<td><input type="button" onclick="javascript:getRequestSoap(wsdlLocation)" value="Generate Request"/>
                   						</tr>
                   						<tr>
                   							<td colspan="5"><span id="operationList"></span></td>
                   						</tr>
                   						<tr>
                   							<td colspan="4">
	                    						<textarea rows="30" cols="50" id="soapReq" name="soapReq" wrap="off"><%=StringUtil.isValid(soapReq)?soapReq:"" %></textarea>
                    						</td>
                    						<td>
	                    						<textarea rows="30" cols="50" name="soapResp" wrap="off"><%=StringUtil.isValid(soapResp)?soapResp:"" %></textarea>
                    						</td>
                   						</tr>
                   						<tr>
                   							<td colspan="4">
                   								<input type="button" value="Wrap" onclick="javascript:wrap(soapReq)"/>
                   								<input type="button" value="Format" onclick="javascript:formatXml(soapReq)"/>
                							</td>
                   							<td>
                   								<input type="button" value="Wrap" onclick="javascript:wrap(soapResp)"/>
                   								<input type="button" value="Format" onclick="javascript:formatXml(soapResp)"/>
                							</td>
									</table>
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