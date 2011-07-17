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

<%@page import="java.nio.ByteBuffer"%>
<%@page import="java.nio.channels.FileChannel"%>
<%@page import="net.sf.sripathi.ws.mock.util.StringUtil"%>
<%@ page import="java.io.*"%>
<%
	String logFile = request.getParameter("logFile");
	
	if (!StringUtil.isValid(logFile)) {
		logFile = "Mock.log";
	}
	String logLocation = application.getRealPath("/workspace") + "/" + logFile;
	String lastLineIndexStr = request.getParameter("lastLineIndex");
    long buffer = 0;
    long fileSize = 0;
	int maxLineCount = 10;
	RandomAccessFile raf = null;
	FileChannel fc = null;
	try {
    	raf = new RandomAccessFile(logLocation, "r");
    	fc = raf.getChannel();
    	long lastLineIndex = Long.parseLong(lastLineIndexStr);
   		fileSize = fc.size();
   		response.setHeader("file.size", fileSize+" bytes");
    	buffer = fileSize - lastLineIndex;
   		ByteBuffer buf = ByteBuffer.allocate((int) buffer);

 		fc.read(buf, lastLineIndex);
   		String line = new String(buf.array()).trim();
   		if (StringUtil.isValid(line)) {
%>
  		    	<%=StringUtil.forHtmlComplete(line) %><br>
<%
   		}
    } catch (Exception e) {
    }
    finally {
    	try {
    		raf.close();
    		fc.close();
    	} catch (Exception e){
    	}
    }
%>
<!-- Author - Sripathi Acharya -->
<!-- Version - 1.0 -->