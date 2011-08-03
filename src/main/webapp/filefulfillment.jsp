<%-- 
 *  Copyright 2010-2011 the original author or authors.
 *
 *  WebServiceMocker is free software; you can redistribute it and/or modify it under the 
 *  terms of version 2.1 of the GNU Lesser General Public License as published by 
 *  the Free Software Foundation.
 *
 *  WebServiceMocker is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without 
 *  even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. 
 *  See the GNU Lesser General Public License for more details at gnu.org.
 *  --%>
         
                                             
<%@page import="com.eviware.soapui.impl.wsdl.submit.transports.http.HttpResponse"%>
<%@page import="java.util.zip.ZipEntry"%>
<%@page import="java.util.Enumeration"%>
<%@page import="java.util.TreeSet"%>
<%@page import="java.net.URL"%>
<%@page import="java.net.URI"%>
<%@page import="org.apache.commons.io.IOUtils"%>
<%@page import="net.sf.sripathi.ws.mock.util.FileUtil"%>
<%@page import="net.sf.sripathi.ws.mock.util.SoapUIUtil"%>
<%@page import="java.util.Set"%>
<%@page import="java.util.zip.ZipFile"%>
<%@page import="java.util.List"%>
<%@page import="net.sf.sripathi.ws.mock.util.Folder"%>
<%@page import="org.apache.commons.fileupload.disk.DiskFileItemFactory"%>
<%@page import="java.net.URLEncoder"%>
<%@page import="org.apache.commons.fileupload.FileItem"%>
<%@page import="org.apache.commons.fileupload.servlet.ServletFileUpload"%>
<%@page import="net.sf.sripathi.ws.mock.util.HtmlUtil"%>
<%@page import="net.sf.sripathi.ws.mock.Domain"%>
<%@page import="net.sf.sripathi.ws.mock.DomainFactory"%>
<%@page import="net.sf.sripathi.ws.mock.util.MockException"%>
<%@page import="net.sf.sripathi.ws.mock.util.StringUtil"%>
<%@ page import="java.io.*"%>
        
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

String action = request.getParameter("action");
Folder rootFolder = DomainFactory.getInstance().getDomainFileFolder(domain);
String folderName = rootFolder.getPath();
String fileName = null;

if ("uploadFile".equals(action)) {
	
    try {
        
    	ServletFileUpload servletFileUpload = new ServletFileUpload(new DiskFileItemFactory());

    	@SuppressWarnings ("unchecked")
    	List<FileItem> items =  servletFileUpload.parseRequest(request);
    	FileItem fileItem = items.get(0);
    	folderName = items.get(1).getString();
    	String override = items.get(2).getString();
    	File curFolder = new File(folderName);
    	if (!curFolder.exists()) {
    		out.write(StringUtil.failureMsg("Unable to find folder - " + folderName));
    	} else {
    		fileName = fileItem.getName();
    		
    		if (fileName.toLowerCase().endsWith("wsdl") || fileName.toLowerCase().endsWith("xsd"))
    	 	{
    			//upload single file
    			String fName = folderName + "/" + fileName;
    			File file = new File(fName);
    			if (file.exists()) {
    				out.write(StringUtil.failureMsg("File already present"));
    			} else {
     	 			fileItem.write(file);
     	 			out.clear();
     	 			out.write("SUCCESS_UPLOAD");
     	 			out.write(fName);
     	 			return;
    			}
    	 	} else if (fileName.toLowerCase().endsWith("jar") || fileName.toLowerCase().endsWith("zip")) {

    	 		//Logic to extract the files from zip to upload
    	 		File file = new File(application.getRealPath("/workspace") + "/tmp/" + fileItem.getName());
    	 		fileItem.write(file);
    	 		String zipFileName = URLEncoder.encode(file.getAbsolutePath(), "UTF-8");
    	 		String zipFolderName = URLEncoder.encode(folderName, "UTF-8");
    	 		ZipFile zip = new ZipFile(file);
    	 		
    			Set<String> dups = new TreeSet<String>();
    			
    			@SuppressWarnings ("unchecked")
    			Enumeration<ZipEntry> entries = (Enumeration<ZipEntry>) zip.entries();
    			while (entries.hasMoreElements()) {
    				ZipEntry entry = entries.nextElement();
    				
    				if (entry.getName().toLowerCase().endsWith(".wsdl") || entry.getName().toLowerCase().endsWith(".xsd")) {
    					File t = new File(folderName + "/" + entry.getName());
    					if (t.exists()) {
    						dups.add(entry.getName());
    					}
    				}
    			}
    			
    	 		if (dups.size() == 0 || "true".equalsIgnoreCase(override)) {
    	 			FileUtil.createFilesAndFolder(folderName, zip);
    	 			out.write(StringUtil.successMsg("Archive files uploaded"));
    	 		} else {
					out.clear();
					out.write("FAILED-OF-DUPS");
       	 			out.write(dups.toString());
    	 		}
    	 		try {zip.close();}catch (Exception e) {}
       	 	}
      	}
    }
    catch (Exception e) {
        e.printStackTrace();
        message = StringUtil.failureMsg("Bad file");
    }
    
} else if ("Create New Folder".equals(action)) {
        	
   	String newFolderName = request.getParameter("newFolderName");
   	folderName = request.getParameter("currentFolder");
   	File curFolder = new File(folderName);
   	File newFolder = new File(folderName + "/" + newFolderName);

   	if (!StringUtil.isValid(newFolderName)) {
   		out.write(StringUtil.failureMsg("Provide a valid folder name"));
   	} else if (!curFolder.exists()) {
   		out.write(StringUtil.failureMsg("Unable to find folder - " + folderName));
   	} else if (newFolder.exists()) {
   		fileName = newFolderName;
   		out.write(StringUtil.failureMsg("Folder already present"));
   	} else {
	 	newFolder.mkdir();
   		out.write(StringUtil.successMsg("Folder created successfully"));
   	}
   	
} else if ("deleteFile".equals(action)) {
	
	fileName = request.getParameter("fileName");
	folderName = request.getParameter("folderName");
	File file = new File(fileName);
	boolean status = file.delete();
	if (status){
		out.write(StringUtil.successMsg("File deleted successfully"));
		rootFolder = DomainFactory.getInstance().getDomainFileFolder(domain);
	}
	else
		out.write(StringUtil.failureMsg("Failed to delete the file"));
}  else if ("deleteFolder".equals(action)) {
	
	folderName = request.getParameter("folderName");
	boolean status = FileUtil.deleteFolder(folderName);
	if (status){
		out.write(StringUtil.successMsg("Folder deleted successfully"));
		rootFolder = DomainFactory.getInstance().getDomainFileFolder(domain);
		folderName = folderName.substring(0, folderName.lastIndexOf("/"));
	}
	else
		message = StringUtil.failureMsg("Failed to delete the folder");
} else if ("downloadFile".equals(action)) {
 		
	String url = request.getParameter("url");
	response.setContentType("application/octet-stream");
    response.setHeader("Content-Disposition",
        "attachment;filename=\"" + url.substring(url.lastIndexOf("/")+1, url.length()) + "\"");
    out.clear();
    out.write(IOUtils.toString(new FileReader(new File(url))));
    return;
}
%>

<%-- Author - Sripathi Acharya --%>
<%-- Version - 1.0 --%>