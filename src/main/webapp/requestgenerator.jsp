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

	try {
		Map<String, String> requestMap = new HashMap<String, String>();
		if (StringUtil.isValid(wsdlUrl)) {
			
			for (String operation : SoapUIUtil.getOperationList(wsdlUrl)) {
				
				requestMap.put(operation, SoapUIUtil.getDummyRequest(wsdlUrl, operation));
			}
		}

		if (requestMap.size() == 0) {
			response.setHeader("OpeataionCount", "0");
			
			%>
				<font size="2px" face="arial" color="red">Unable to get request XML. No operation found</font>
			<%
		} else if (requestMap.size() == 1) {
			response.setHeader("OpeataionCount", "1");
			%>
				<%=requestMap.values().iterator().next().trim() %>
			<%
		} else {
			response.setHeader("OpeataionCount", ""+requestMap.size());
			
			%>
			<font size="2px" face="arial">Select an operation: </font>
			<%
			for (String key : requestMap.keySet()) {
			%>
				<a href='javascript:populateRequest("<%=StringUtil.forHTML(requestMap.get(key)) %>")'><%= key%></a>&nbsp;&nbsp;
			<%
			}
		}
    } catch (Exception e) {
%>
    	<font size="2px" face="arial" color="red">Unable to get request XML - <%=e.getMessage() %></font>
<%
    }
%>