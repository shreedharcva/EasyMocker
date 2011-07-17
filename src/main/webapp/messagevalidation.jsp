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

<%@page import="net.sf.sripathi.ws.mock.util.SoapUIUtil"%>
<%@page import="net.sf.sripathi.ws.mock.util.StringUtil"%>
<%@ page import="java.util.*"%>
<%
	String wsdlUrl = request.getParameter("wsdlUrl");
	String operationName = request.getParameter("operationName");
	String responseStr = request.getParameter("response");
	//responseStr = responseStr.replaceAll("NEW_LINE", "\\\n");
	try {
		List<String> errors = null;
		if (StringUtil.isValid(wsdlUrl)) {
			errors = SoapUIUtil.validateResponse(wsdlUrl, operationName, responseStr);
		}
		else {
			errors = SoapUIUtil.validateXml(responseStr);
		}
		if (errors.size() == 0) {
%>
		    	<font size="2px" face="arial" color="green">Valid Message</font>
<%
		}
		
		for (String error : errors) {
%>
  		    	<font size="2px" face="arial" color="red"><%=StringUtil.forHtmlComplete(error) %></font><br>
<%
		}
    } catch (Exception e) {
%>
    	<font size="2px" face="arial" color="red"><%=e.getMessage() %></font>
<%
    }
%>
<!-- Author - Sripathi Acharya -->
<!-- Version - 1.0 -->