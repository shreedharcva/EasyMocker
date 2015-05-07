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
<%@page import="java.util.Map.Entry"%>
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
        	boolean failed = false;
        
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
            String operationName = request.getParameter("operationName");
            String serviceEndpoint = "http://"+request.getLocalName()+":"+request.getLocalPort()+request.getContextPath()+"/mock/"+domainName+"/service/"+serviceName;
			Service service = null;
			Operation operation = null;
			String mockResponse = null;
			String newMockResponse = null;
			boolean isDelayed = false;
			String delayStr = null;
			String newDelayStr = null;
			String defaultDelayStr = null;
			String keyElementValue = null;
			String newKeyElementValue = null;
			String templateName = null;
			String template = null;
			String dummyResponse = "Unable to create dummy response from WSDL. Paste the entire SOAP response here.";
			Map<String, String> faultRespMap = null;
			List<String> requestElements = new ArrayList<String>();
            
            if (!StringUtil.isValid(serviceName)) {
            	message = StringUtil.failureMsg("Service " + serviceName + " not found!!!");
            }
            else {
            	service = domain.getService(serviceName);
            	if (service == null) {
            		message = StringUtil.failureMsg("Service " + serviceName + " not found!!!");
            	}
            	else {
            		operation = service.getOperation(operationName);
            		if (operation == null) {
            			message = StringUtil.failureMsg("Operation " + operationName + " for service " + serviceName + " not found!!!");
            		}
            		else {
            			try {
            				if (StringUtil.isValid(service.getWsdlUrl())) {

            					dummyResponse = operation.getDefaultGeneratedResp();
            					faultRespMap = operation.getFaultMap();
            					requestElements = operation.getTagNames();
            				}
            			}
            			catch (Exception e) {
            				e.printStackTrace();
            			}
            		}
            	}
            }
            
            String action = request.getParameter("action");
            String divToDisplay = "";

            if ("setKeyElement".equals(action)) {
            	
            	String keyElementName = request.getParameter("keyElementName");
            	
            	if (!StringUtil.isValid(keyElementName)) {
            		message = StringUtil.failureMsg("Provide a valid element name");
            	}
            	else {
            		operation.setKeyElement(keyElementName);
            		DomainFactory.getInstance().updateDomain(domain);
            		message = StringUtil.successMsg("Key element name set to " + keyElementName);
            	}
            }
            else if ("addMockResponse".equals(action)) {
            	
            	keyElementValue = request.getParameter("keyElementValue");
            	mockResponse = request.getParameter("mockResponse");
            	delayStr = request.getParameter("delayInMillisec");
            	String [] checkBox = request.getParameterValues("isDelayed");
            	int delayInt = 0;
            	
    			if (checkBox != null && checkBox.length == 1) {
       				isDelayed = true;
       				delayInt = Integer.parseInt(delayStr.trim());
    			}
            	
            	if (!StringUtil.isValid(keyElementValue)) {
            		message = StringUtil.failureMsg("Provide a valid element value");
            		failed = true;	
            	}
            	else if (!StringUtil.isValid(mockResponse)) {
            		message = StringUtil.failureMsg("Provide a valid response");
            		failed = true;
            	}
            	else {

            		try {

            			if (isDelayed) {
            				operation.addScenario(keyElementValue, mockResponse, delayInt);
            			}
            			else {
            				operation.addScenario(keyElementValue, mockResponse);
            			}
            			DomainFactory.getInstance().updateDomain(domain);
       	    			message = StringUtil.successMsg("Mock response for key value " + keyElementValue + " added successfully.");
       	    			divToDisplay = operation.getKeyElement() + " = " + keyElementValue + "Div";
       	    			delayStr = null;
       	    			keyElementValue = null;
       	    			isDelayed = false;
            		}
            		catch (NumberFormatException ne) {
            			message = StringUtil.failureMsg("Provide valid delay in milliseconds");
            			failed = true;
            			divToDisplay = operation.getKeyElement() + " = " + keyElementValue + "Div";
            		}
            		catch (MockException me) {
            			message = StringUtil.failureMsg( me.getMessage());
            			failed = true;
            			divToDisplay = operation.getKeyElement() + " = " + keyElementValue + "Div";
            		}
            	}
            }
            else if ("deleteMock".equals(action)) {
            	
            	String scenarioKey = request.getParameter("scenarioKey");
            	
            	if (!StringUtil.isValid(scenarioKey)) {
            		message = StringUtil.failureMsg("Provide a valid key");
            	}
            	else {
            		try {
            			operation.deleteScenario(scenarioKey);
            			DomainFactory.getInstance().updateDomain(domain);
            			message = StringUtil.successMsg("Mock response deleted for scenario '" + scenarioKey + "'"); 
            		}
            		catch (MockException me) {
            			message = StringUtil.failureMsg(me.getMessage());
            		}
            	}
            }
            else if ("updateKeyElement".equals(action)) {

            	String keyElementName = request.getParameter("keyElementName");
            	
            	if (!StringUtil.isValid(keyElementName)) {
            		message = StringUtil.failureMsg("Provide a valid key element name");
            		failed = true;
            	}
            	else {
            		operation.updateKeyElement(keyElementName);
            		DomainFactory.getInstance().updateDomain(domain);
            		message = StringUtil.successMsg("Key element updated");
            	}
            }
            else if ("addTemplate".equals(action)) {

            	templateName = request.getParameter("templateName");
            	template = request.getParameter("template");
            	
            	if (!StringUtil.isValid(templateName)) {
            		message = StringUtil.failureMsg("Provide a valid template name");
            	}
            	else if (!StringUtil.isValid(template)) {
            		message = StringUtil.failureMsg("Provide a valid template");
            	}
            	else if (operation.getTemplateMap().get(templateName) != null) {
            		message = StringUtil.failureMsg("Template " + templateName + " already present.");
            	}
            	else {
            		operation.addTemplate(templateName, template);
            		DomainFactory.getInstance().updateDomain(domain);
            		message = StringUtil.successMsg("Template " + templateName + " added successfully.");
            		templateName = null;
            		template = null;
            	}
            }
	        else if ("deleteTemplate".equals(action)) {
	
	        	templateName = request.getParameter("templateName");
	        	
	        	if (!StringUtil.isValid(templateName)) {
	        		message = StringUtil.failureMsg("Provide a valid template name");
	        	}
	        	else {
	        		operation.deleteTemplate(templateName);
	        		DomainFactory.getInstance().updateDomain(domain);
	        		message = StringUtil.successMsg("Template " + templateName + " deleted successfully.");
	        		templateName = null;
	        	}
	        }
        %>

        <script type="text/javascript">
	        String.prototype.trim = function () 
	        {
	            return this.replace(/^\s*/, "").replace(/\s*$/, "");
	        }
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
            function deleteScenario(serviceName, operationName, key) {
            	var answer = confirm("Are you sure you want to delete scenario " + key);
            	if (answer) {
            		window.location = "operation.jsp?action=deleteMock&serviceName=" + encodeURIComponent(serviceName) + "&operationName=" + encodeURIComponent(operationName) + "&scenarioKey=" + encodeURIComponent(key);
            	}
            }
            function changeValue(value) {
            	value = ReplaceAll(value, "RETURN_CAR", "\r");
            	value = ReplaceAll(value, "NEW_LINE", "\n");
            	value = ReplaceAll(value, "DOUBLE_QUOTE", "\"");
            	value = ReplaceAll(value, "SINGLE_QUOTE", "\''");
            	document.addMockForm.mockResponse.value = value;
            	document.getElementById("validationResponse").innerHTML="";
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
            function ohMyGod(action, failed, div) {
            	if (("addMockResponse" == action || "updateMock" == action) && !failed) {
            		document.getElementById("defaultScenarioDiv").style.display = "none";
            		document.getElementById(div).style.display = "block";
            	}
            	else if (("addMockResponse" == action || "updateMock" == action) && failed) {
            		document.getElementById("defaultScenarioDiv").style.display = "none";
            	}
            	else if ("addTemplate" == action || "deleteTemplate" == action || "updateTemplate" == action) {
            		document.getElementById("defaultScenarioDiv").style.display = "none";
            		document.getElementById("addMockDiv").style.display = "none";
            		document.getElementById("templateDiv").style.display = "block";
            	}
            	else if ("updateKeyElement" == action && failed) {
            		document.getElementById("updateKeyElementDiv").style.display = "block";
            	}
            }
            function deleteOperation(serviceName, operationName) {
            	var answer = confirm("Are you sure you want to delete this operation " + operationName);
            	if (answer) {
            		window.location = "service.jsp?action=deleteOperation&serviceName=" + encodeURIComponent(serviceName) + "&operationName=" + encodeURIComponent(operationName);
            	}
            }
            function deleteTemplate(serviceName, operationName, templateName) {
            	var answer = confirm("Are you sure you want to delete template " + templateName);
            	if (answer) {
            		window.location = "operation.jsp?action=deleteTemplate&serviceName=" + encodeURIComponent(serviceName) + "&operationName=" + encodeURIComponent(operationName) + "&templateName=" + encodeURIComponent(templateName);
            	}
            }
            function showHideDelay() 
            {
            	
            	element1 = document.addMockForm.elements["delayInMillisec"];
                if (element1.style.display == "inline"  || element1.style.display == '')
                {
                	element1.style.display = "none";
                }
                else
                {
                	element1.style.display = "inline";
                }
            }
            function enableDelay() {
            	element1 = document.addMockForm.elements["delayInMillisec"];
            	element1.value="";
            	element1.style.color="#000000";
            }
            function disableDelay() {
            	element1 = document.addMockForm.elements["delayInMillisec"];
            	if (element1.value=="") {
            		element1.style.color="#AAAAAA";
            		element1.value="In Milliseconds";
            	}
            }
            function validateSchema(area, respSpan)
            {
            	var url = "messagevalidation.jsp";
            	var params = "wsdlUrl=" + encodeURIComponent("<%=service.getWsdlUrl().replaceAll("\\\\","\\\\\\\\") %>")
           				+ "&operationName=" + encodeURIComponent("<%=operationName %>")
            			+ "&response=" + encodeURIComponent(area.value);
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
              			respSpan.innerHTML=xmlhttp.responseText;
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
            function validateXml(area, respSpan)
            {
            	var url = "messagevalidation.jsp";
            	var params = "response=" + encodeURIComponent(area.value);
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
              			respSpan.innerHTML=xmlhttp.responseText;
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
            function updateMock(scenarioKey, newKay, newDelay, newResp, respSpan)
            {
            	var serviceName = encodeURIComponent("<%=serviceName %>");
            	var operationName = encodeURIComponent("<%=operationName %>");

            	var url = "ajaxfulfill.jsp";
            	
            	var params = "action=updateMock&serviceName=" + serviceName
            			+ "&operationName=" + operationName
            			+ "&scenarioKey=" +  encodeURIComponent(scenarioKey)
            			+ "&mockResponse=" +  encodeURIComponent(newResp.value)
            			+ "&delayInMillisec=" +  encodeURIComponent(newDelay.value)
            			+ "&newKeyElementValue=" +  encodeURIComponent(newKay.value);

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
              			respSpan.innerHTML=xmlhttp.responseText;
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
            function updateDefaultMock(newDelay, newResp, respSpan)
            {
            	var serviceName = encodeURIComponent("<%=serviceName %>");
            	var operationName = encodeURIComponent("<%=operationName %>");

            	var url = "ajaxfulfill.jsp";
            	var params = "action=updateDefaultMock&serviceName=" + serviceName
        			+ "&operationName=" + operationName
        			+ "&defaultMockResponse=" +  encodeURIComponent(newResp.value)
        			+ "&delayInMillisec=" +  encodeURIComponent(newDelay.value);

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
              			respSpan.innerHTML=xmlhttp.responseText;
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
            function updateTemplate(templateName, template, respSpan)
            {
            	var serviceName = encodeURIComponent("<%=serviceName %>");
            	var operationName = encodeURIComponent("<%=operationName %>");

            	var url = "ajaxfulfill.jsp";
            	var params = "action=updateTemplate&serviceName=" + serviceName
            			+ "&operationName=" + operationName
            			+ "&templateName=" +  templateName
            			+ "&newTemplate=" +  encodeURIComponent(template.value);

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
              			respSpan.innerHTML=xmlhttp.responseText;
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
            function launchTestClient() {
            	var endpointUrl = "<%=URLEncoder.encode(serviceEndpoint, "UTF-8") %>";
            	var wsdlLocation = "<%=URLEncoder.encode(service.getWsdlUrl(), "UTF-8") %>";
            	var operationName = "<%=URLEncoder.encode(operationName, "UTF-8") %>";
            	var serviceName = "<%=URLEncoder.encode(serviceName, "UTF-8") %>";
            	
            	window.location = 'testclient.jsp?action=Load&endpointUrl='+endpointUrl+'&wsdlLocation='+wsdlLocation+'&operationName='+operationName+'&serviceName='+serviceName
            }
        </script>
    </head>
    <body onload='javascript:ohMyGod("<%=action %>", <%=failed %>, "<%=divToDisplay %>")'>

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
			        		if (operation != null) {
		        			%>
		        				<font face="arial" size="2">Operation <font color="green"><%=operationName %></font> for service <font color="green"><%=serviceName %></font> is mocked
		        					for domain <font color="green"><%=domainName %></font>. <br><br><input type="button" onclick="javascript:launchTestClient()" value="Launch test client for this operation" name="testClient"/>
		        			<%
		        			if(!StringUtil.isValid(service.getWsdlUrl()))
		        			{
	        				%>
		        				<a href='javascript:deleteOperation("<%=serviceName %>","<%=operationName %>")'>Click here</a> to delete this operation.
		        			<%
		        			}
		        			%>
				        		<br><br>Following is the default response for this operation. When
				        		no mocked response is found system returns this message as response for mocked service.</font><br><br>
			
				        		<form action="operation.jsp" method="post">
					        		<fieldset style="text-align:left;" >
										<legend><b><a href="javascript:showContent('defaultScenarioDiv')">&nbsp;Default Response&nbsp;</a></b></legend>
										<div id="defaultScenarioDiv" style="display:block;">
					                		<font face="arial" size="2">
					                			<input type="hidden" name="serviceName" value="<%=serviceName %>" />
					                			<input type="hidden" name="operationName" value="<%=operationName %>" />
					                			<input type="hidden" name="action" value="updateDefaultMock" />
					                			Delay In Milliseconds&nbsp;<input name="delayInMillisec" size="10" value="<%=operation.getDefaultScenario().getDelayInMilliSec() %>"><br>
					                			<textarea rows="10" cols="80" wrap="off" name="defaultMockResponse" ondblclick="javascript:formatXml(this)"><%=operation.getDefaultScenario().getResponse() %></textarea>
					                			<br>
					                			<input type="button" onclick="javascript:wrap(defaultMockResponse)" value="Wrap" />
					                			<input type="button" onclick="javascript:formatXml(defaultMockResponse)" value="Format" />
					                			<%
					                			if (StringUtil.isValid(service.getWsdlUrl())) {
					                			%>
					                			<input type="button" onclick="javascript:validateSchema(defaultMockResponse, validationDefaultResponse)" value="Validate Schema" />
					                			<%
					                			} else {
					                			%>
					                			<input type="button" onclick="javascript:validateXml(defaultMockResponse, validationDefaultResponse)" value="Validate XML" />
					                			<%
					                			}
					                			%>
					                			<input type="button" onclick="javascript:updateDefaultMock(delayInMillisec, defaultMockResponse, validationDefaultResponse)" value="Update" />
					                			<span id="validationDefaultResponse"></span>
					                			
					                		</font>
										</div>
									</fieldset>
								</form>
			        		<%
			        		if (operation.getKeyElement() == null) {
			        		%>
				        		<font face="arial" size="2px">
			        			To create new mock service you need to set the key element for this operation. Key element is the
			        			one, who's value is used to derive the mocked response. Ex: You can set msisdn element as the key element, then
			        			you can setup two mock response for two different msisdns. Note: If duplicate elements are present, the first one
			        			will be considered</font><br><br>
				        		<form action="operation.jsp" method="post">
					        		<fieldset style="text-align:left;" >
										<legend><b><a href="javascript:showContent('keyElementDiv');">&nbsp;Set Key Element&nbsp;</a></b></legend>
										<div id="keyElementDiv" style="display:block;">
					                		<font face="arial" size="2">
					                			<input type="hidden" name="serviceName" value="<%=serviceName %>" />
					                			<input type="hidden" name="operationName" value="<%=operationName %>" />
					                			<input type="hidden" name="action" value="setKeyElement" />
					                			Key Element Name :
					                			
					                			<%
					                			if (requestElements.size() == 0) {
				                				%>
				                				<input name="keyElementName" />
				                				<%
				                				} else { %>
				                				<select name="keyElementName">
				                					<option value=""></option>
				                					<%
				                					for (String requestElement : requestElements) {
			                						%>
			                							<option value="<%=requestElement %>"><%=requestElement %></option>
			                						<%
				                					}
				                					%>
				                				</select>
				                				<%
					                			}
					                			%>
					                			
					                			
					                			&nbsp;
					                			<input type="submit" value="Set"/>
					                		</font>
										</div>
									</fieldset>
								</form>
			        		<%
			        		}
			        		else
			        		{
			        		%>
			        			<font face="arial" size="2px">The key element for this operation is <font color="green"><b><%=operation.getKeyElement() %></b></font>. <a href="javascript:showContent('updateKeyElementDiv')">Click here</a> to update the key element name.</font>
			        			
		        				<form action="operation.jsp" method="post">
									<div id="updateKeyElementDiv" style="display:none;">
										<br>
			        					<fieldset style="text-align:left; background:#ffffcc;">
				        					<input type="hidden" name="serviceName" value="<%=serviceName %>" />
				        					<input type="hidden" name="operationName" value="<%=operationName %>" />
				        					<input type="hidden" name="action" value="updateKeyElement" />
				        					<font face="arial" size="2px">New Key Element Name : </font>
				                			<%
				                			if (requestElements.size() == 0) {
			                				%>
			                				<input name="keyElementName" />
			                				<%
			                				} else { %>
			                				<select name="keyElementName">
			                					<%
			                					for (String requestElement : requestElements) {
		                						%>
		                							<option value="<%=requestElement %>" <%=operation.getKeyElement().equals(requestElement)?"selected='selected'":""%>><%=requestElement %></option>
		                						<%
			                					}
			                					%>
			                				</select>
			                				<%
				                			}
				                			%>
				        					&nbsp;
				        					<input type="submit" value="Update" />
			        					</fieldset>
			        				</div>
		        				</form>
				        		<form action="operation.jsp" name="addMockForm" method="post">
					        		<fieldset style="text-align:left;" >
										<legend><b><a href="javascript:showContent('addMockDiv');javascript:hideContent('defaultScenarioDiv')">&nbsp;Add A Mock Response&nbsp;</a></b></legend>
										<div id="addMockDiv" style='display:<%=(failed && "addMockResponse".equals(action))?"block":"none" %>;'>
					                		<font face="arial" size="2">
					                			<input type="hidden" name="serviceName" value="<%=serviceName %>" />
					                			<input type="hidden" name="operationName" value="<%=operationName %>" />
					                			<input type="hidden" name="action" value="addMockResponse" />
					                			<b><%=operation.getKeyElement() %></b> Element Value :
					                			<input name="keyElementValue" value='<%=keyElementValue!=null?keyElementValue:"" %>'/>&nbsp;
					                			Add Delay
					                			<input align="bottom" name="isDelayed" type="checkbox" onchange="javascript:showHideDelay()" <%=isDelayed?"checked='checked'":"" %> />
					                			<input name="delayInMillisec" size="10" <%=isDelayed?"style='display:inline;' value='"+delayStr+"'":"style='display:none; color:#AAAAAA;' value='In Milliseconds'" %>  onfocus="javascript:enableDelay()" onblur="javascript:disableDelay()"/>
					                			<br><br>
					                			<%
					                			if (dummyResponse != null) {
				                				%>
				                					<a href='javascript:changeValue("<%=StringUtil.forHTML(dummyResponse) %>")'>Auto Response</a>
				                				<%
					                			}
					                			
					                			if (faultRespMap != null) {
					                				Set<String> faultTypeSet = faultRespMap.keySet();
					                				for (String faultType : faultTypeSet) {
			                					%>
			                						&nbsp;&nbsp;&nbsp;<a href='javascript:changeValue("<%=StringUtil.forHTML(faultRespMap.get(faultType)) %>")'>Fault:<%=faultType %></a>
			                					<%
					                				}
					                			}
					                			
					                			for (Entry<String, String> entry : operation.getTemplateMap().entrySet()) {
					                				
					                			%>
					                				&nbsp;&nbsp;&nbsp;<a href='javascript:changeValue("<%=StringUtil.forHTML(entry.getValue()) %>")'>Template:<%=entry.getKey() %></a>
					                			<%
					                			}
					                			%>
					                			
					                			
					                			<br><textarea rows="15" cols="90" wrap="off" name="mockResponse" ondblclick="javascript:formatXml(this)"><%=(mockResponse!=null)?mockResponse:dummyResponse %></textarea>
					                			<br>

					                			<input type="button" onclick="javascript:wrap(mockResponse)" value="Wrap" />
					                			<input type="button" onclick="javascript:formatXml(mockResponse)" value="Format" />
					                			<%
					                			if (StringUtil.isValid(service.getWsdlUrl())) {
					                			%>
					                			<input type="button" onclick="javascript:validateSchema(mockResponse, validationResponse)" value="Validate Schema" />
					                			<%
					                			} else {
					                			%>
					                			<input type="button" onclick="javascript:validateXml(mockResponse, validationResponse)" value="Validate XML" />
					                			<%
					                			}
					                			%>
					                			<input type="submit" value="Add"/>
					                			<span id="validationResponse"></span>
					                		</font>
										</div>
									</fieldset>
								</form>
				        		
				        		<fieldset style="text-align:left;" >
									<legend><b><a href="javascript:showContent('templateDiv');javascript:hideContent('defaultScenarioDiv');javascript:hideContent('addMockDiv')">&nbsp;Templates&nbsp;</a></b></legend>
									<div id="templateDiv" style='display:<%=(failed && "addMockResponse".equals(action))?"block":"none" %>;'>
				                		<font face="arial" size="2">
				                			Templates are helpful while configuring new mock response. You can configure upto 3 templates.<br>
				                			<%
				                			int ti = 0;
				                			for (Entry<String, String> entry : operation.getTemplateMap().entrySet())
				                			{
				                				ti++;
				                			%>
				                			<form action="operation.jsp" method="post">
					                			<input type="hidden" name="serviceName" value="<%=serviceName %>" />
					                			<input type="hidden" name="operationName" value="<%=operationName %>" />
					                			<input type="hidden" name="action" value="updateTemplate" />
					                			<input type="hidden" name="templateName" value="<%=entry.getKey() %>" />
				                				<br><b>Template Name : </b><%=entry.getKey() %>
				                				<br><textarea name="newTemplate" rows="10" cols="80"><%=entry.getValue() %></textarea>
				                				<br>
					                			<input type="button" onclick="javascript:wrap(newTemplate)" value="Wrap" />
					                			<input type="button" onclick="javascript:formatXml(newTemplate)" value="Format" />
					                			<%
					                			if (StringUtil.isValid(service.getWsdlUrl())) {
					                			%>
					                			<input type="button" onclick="javascript:validateSchema(newTemplate, valTemSpan<%=ti %>)" value="Validate Schema" />
					                			<%
					                			} else {
					                			%>
					                			<input type="button" onclick="javascript:validateXml(template, valTemSpan<%=ti %>)" value="Validate XML" />
					                			<%
					                			}
					                			%>
				                				<input type="button" onclick='javascript:updateTemplate("<%=entry.getKey() %>", newTemplate, valTemSpan<%=ti %>)' value="Update" />
				                				<input type="button" value="Delete" onclick='javascript:deleteTemplate("<%=serviceName.replaceAll("\\\\","\\\\\\\\") %>","<%=operationName %>","<%=entry.getKey() %>")'/>
				                				<span id="valTemSpan<%=ti %>"></span>
				                				<br>
			                				</form>
				                			<%
				                			} if (operation.getTemplateMap().size() < 3) {
				                			%>
				                			<br><b>Add A new Template</b><br><br>
				                			<form action="operation.jsp" name="templateForm" method="post">
					                			<input type="hidden" name="serviceName" value="<%=serviceName %>" />
				                				<input type="hidden" name="operationName" value="<%=operationName %>" />
				                				<input type="hidden" name="action" value="addTemplate" />
				                				Template Name :
				                				<input name="templateName"/>&nbsp;
				                				<br><textarea rows="10" cols="80" name="template" ondblclick="javascript:formatXml(this)"><%=(template!=null)?template:"" %></textarea>
				                				<br>
					                			<input type="button" onclick="javascript:wrap(template)" value="Wrap" />
					                			<input type="button" onclick="javascript:formatXml(template)" value="Format" />
					                			<%
					                			if (StringUtil.isValid(service.getWsdlUrl())) {
					                			%>
					                			<input type="button" onclick="javascript:validateSchema(template, validationTemplate)" value="Validate Schema" />
					                			<%
					                			} else {
					                			%>
					                			<input type="button" onclick="javascript:validateXml(template, validationTemplate)" value="Validate XML" />
					                			<%
					                			}
					                			%>
					                			<input type="submit" value="Add"/>
					                			<span id="validationTemplate"></span>
				                			</form>
				                			<%
				                			}
				                			%>
				                		</font>
									</div>
								</fieldset>
								
								<%
								if (operation.getScenarioList().size() > 1)
								{
								%>
					        		<br><font face="arial" size="2px">The following mock scenarios are configured for this operation.</font><br><br>
						        	<%
						        	int i=0;
						    		for (Scenario scenario : operation.getScenarioList()) {
						    			
						    			i++;
						    			if (scenario.getKey().equals(Operation.DEFAULT_SCE_KEY)) {
						    				continue;
						    			}
						    			
						    			String scename = scenario.getKey();
						    			
						    			if (scenario.getDelayInMilliSec() > 0) {
						    				scename = scename + " | Delay = " + scenario.getDelayInMilliSec() + " Milliseconds";
						    			}
							        %>
							        <form action="operation.jsp" method="post">
										<fieldset style="text-align:left;" >
											<legend><b><a href="javascript:showContent('<%=scenario.getKey() %>Div');javascript:hideContent('defaultScenarioDiv');javascript:hideContent('addMockDiv')">&nbsp;<%=scename %>&nbsp;</a></b></legend>
											<div id="<%=scenario.getKey() %>Div" style="display:none;">
						                		<font face="arial" size="2">
						                			<input type="hidden" name="serviceName" value="<%=serviceName %>" />
						                			<input type="hidden" name="operationName" value="<%=operationName %>" />
						                			<input type="hidden" name="action" value="updateMock" />
						                			<input type="hidden" name="scenarioKey" value="<%=scenario.getKey() %>" />
						                			<b><%=operation.getKeyElement() %></b> Element Value :
					                				<input name="newKeyElementValue" value='<%=newKeyElementValue!=null?newKeyElementValue:scenario.getKey().substring(operation.getKeyElement().length() + 3) %>'/>
						                			Delay In Milliseconds&nbsp;<input name="delayInMillisec" size="10" value="<%=newDelayStr!=null?newDelayStr:scenario.getDelayInMilliSec() %>">
						                			<br><textarea rows="15" cols="80" wrap="off" name="mockResponse" ondblclick="javascript:formatXml(this)"><%=scenario.getResponse() %></textarea>
						                			<br>
						                			<input type="button" onclick="javascript:wrap(mockResponse)" value="Wrap" />
						                			<input type="button" onclick="javascript:formatXml(mockResponse)" value="Format" />
						                			<%
						                			if (StringUtil.isValid(service.getWsdlUrl())) {
						                			%>
						                			<input type="button" onclick="javascript:validateSchema(mockResponse, validateSpan<%=i %>)" value="Validate Schema" />
						                			<%
						                			} else {
						                			%>
						                			<input type="button" onclick="javascript:validateXml(mockResponse, validateSpan<%=i %>)" value="Validate XML" />
						                			<%
						                			}
						                			%>
						                			<input type="button" value="Update" onclick='javascript:updateMock("<%=scenario.getKey() %>", newKeyElementValue, delayInMillisec, mockResponse, validateSpan<%=i %>)''/>
						                			<input type="button" value="Delete" onclick='javascript:deleteScenario("<%=serviceName.replaceAll("\\\\","\\\\\\\\") %>","<%=operationName %>","<%=scenario.getKey() %>")'/>
						                			<span id="validateSpan<%=i %>" ></span>
						                		</font>
											</div>
										</fieldset>
									</form>
									<br>
							<%
				        		}
			        		}
			        	}
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