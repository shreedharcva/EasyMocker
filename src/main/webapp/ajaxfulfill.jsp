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

<%@page import="net.sf.sripathi.ws.mock.util.MockException"%>
<%@page import="net.sf.sripathi.ws.mock.Service"%>
<%@page import="net.sf.sripathi.ws.mock.DomainFactory"%>
<%@page import="net.sf.sripathi.ws.mock.Domain"%>
<%@page import="net.sf.sripathi.ws.mock.util.SoapUIUtil"%>
<%@page import="java.nio.ByteBuffer"%>
<%@page import="java.nio.channels.FileChannel"%>
<%@page import="net.sf.sripathi.ws.mock.util.StringUtil"%>
<%@ page import="java.util.*"%>
<%@ page import="java.io.*"%>
<%

String domainName = (String) session.getAttribute("stub.domainName");

if (!StringUtil.isValid(domainName))
{
%>
    <font size="2px" face="arial" color="red">No domain in session. Reselect domain</font><br>
<%
	return;
}

Domain domain = 
    DomainFactory.getInstance().getDomain(domainName);

if (domain == null)
{
%>
    <font size="2px" face="arial" color="red">No domain in session. Reselect domain</font><br>
<%
	return;
}

String action = request.getParameter("action");

if ("updateDefaultMock".equals(action)) {
	
	String serviceName = request.getParameter("serviceName");
	String operationName = request.getParameter("operationName");
	String defaultMockResponse = request.getParameter("defaultMockResponse");
	String newDelayStr = request.getParameter("delayInMillisec");
	String message = "";
	
	Service service = domain.getService(serviceName);
	if (service == null) {
		message = StringUtil.failureMsg("Service Not found " + serviceName);
	}
	else if (service.getOperation(operationName) == null) {
		message = StringUtil.failureMsg("Operation Not found " + operationName);
	}
	else if (!StringUtil.isValid(defaultMockResponse)) {
		message = StringUtil.failureMsg("Provide a valid response");
	}
	else if (defaultMockResponse.equals(service.getOperation(operationName).getDefaultScenario().getResponse())
		&& ("" + service.getOperation(operationName).getDefaultScenario().getDelayInMilliSec()).equals(newDelayStr))
	{
		message = StringUtil.failureMsg("Same as before");
	}
	else {
		try {
			
			if (StringUtil.isValid(newDelayStr)) {
				int delayInt = Integer.parseInt(newDelayStr.trim());
				service.getOperation(operationName).overrideDefaultScenario(defaultMockResponse, delayInt);
			}
			else {
				service.getOperation(operationName).overrideDefaultScenario(defaultMockResponse);
			}
			DomainFactory.getInstance().updateDomain(domain);
			message = StringUtil.successMsg("Default mock response updated successfully");
		}
		catch (NumberFormatException ne) {
			message = StringUtil.failureMsg("Provide valid delay in milliseconds");
		}
		catch (MockException me) {
			message = StringUtil.failureMsg( me.getMessage());
		}
	}
%>
	<font size="2px" face="arial"><%=message %></font>
<%
}

else if ("updateMock".equals(action)) {
	
	String serviceName = request.getParameter("serviceName");
	String operationName = request.getParameter("operationName");
	String scenarioKey = request.getParameter("scenarioKey");
	String newMockResponse = request.getParameter("mockResponse");
	String newDelayStr = request.getParameter("delayInMillisec");
	String newKeyElementValue = request.getParameter("newKeyElementValue");
	String message = "";
	int delayInt = 0;
	
	Service service = domain.getService(serviceName);
	if (service == null) {
		message = StringUtil.failureMsg("Service Not found " + serviceName);
	}
	else if (service.getOperation(operationName) == null) {
		message = StringUtil.failureMsg("Operation Not found " + operationName);
	}
	else if (!StringUtil.isValid(scenarioKey)) {
		message = StringUtil.failureMsg("Provide a valid key");
	}
	else if (!StringUtil.isValid(newMockResponse)) {
		message = StringUtil.failureMsg("Provide a valid response");
	}
	else if (!StringUtil.isValid(newKeyElementValue)) {
		message = StringUtil.failureMsg("Provide a valid key element value");
	}
	else if (service.getOperation(operationName).getScenario(scenarioKey) == null) {
		message = StringUtil.failureMsg("Scenario not found. Refresh the page");
	}
	else if (newMockResponse.equals(service.getOperation(operationName).getScenario(scenarioKey).getResponse())
			&& (service.getOperation(operationName).getKeyElement() + " = " + newKeyElementValue).equals(scenarioKey)
		&& (""+service.getOperation(operationName).getScenario(scenarioKey).getDelayInMilliSec()).equals(newDelayStr))
	{
		message = StringUtil.failureMsg("Same as before");
	}
	else {
		try {
			
			if (StringUtil.isValid(newDelayStr)) {
				delayInt = Integer.parseInt(newDelayStr.trim());
				service.getOperation(operationName).updateScenario(scenarioKey, newMockResponse, delayInt, newKeyElementValue);
			}
			else {
				service.getOperation(operationName).updateScenario(scenarioKey, newMockResponse, newKeyElementValue);
			}
			DomainFactory.getInstance().updateDomain(domain);
			message = StringUtil.successMsg("Mock response update for scenario '" + scenarioKey + "'");
		}
		catch (NumberFormatException ne) {
			message = StringUtil.failureMsg("Provide valid delay in milliseconds");
		}
		catch (MockException me) {
			message = StringUtil.failureMsg( me.getMessage());
		}
	}
%>
	<font size="2px" face="arial"><%=message %></font>
<%
}

else if ("updateTemplate".equals(action)) {
	
	String serviceName = request.getParameter("serviceName");
	String operationName = request.getParameter("operationName");
	String templateName = request.getParameter("templateName");
	String newTemplate = request.getParameter("newTemplate");
	String message = "";
	
	Service service = domain.getService(serviceName);
	if (service == null) {
		message = StringUtil.failureMsg("Service Not found " + serviceName);
	}
	else if (service.getOperation(operationName) == null) {
		message = StringUtil.failureMsg("Operation Not found " + operationName);
	}
	else if (!StringUtil.isValid(templateName)) {
		message = StringUtil.failureMsg("Provide a valid template name");
	}
	else if (!StringUtil.isValid(newTemplate)) {
		message = StringUtil.failureMsg("Provide a valid template");
	}
	else if (newTemplate.equals(service.getOperation(operationName).getTemplateMap().get(templateName))) {
		message = StringUtil.failureMsg("Same as before.");
	}
	else {
		service.getOperation(operationName).getTemplateMap().put(templateName, newTemplate);
		DomainFactory.getInstance().updateDomain(domain);
		message = StringUtil.successMsg("Template " + templateName + " updated sccessfully.");
	}
%>
	<font size="2px" face="arial"><%=message %></font>
<%
}
%>
<!-- Author - Sripathi Acharya -->
<!-- Version - 1.0 -->