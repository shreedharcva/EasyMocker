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
<html>
    <head>
        <title>Web Service Mocker</title>
        <link rel="stylesheet" type="text/css" href="mktree.css" />
        <SCRIPT SRC="mktree.js" LANGUAGE="JavaScript"></SCRIPT> 
        
        <link href="prettify.css" type="text/css" rel="stylesheet" />
        <script type="text/javascript" src="prettify.js"></script>
        
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

                	List<FileItem> items =  servletFileUpload.parseRequest(request);
                	FileItem fileItem = items.get(0);
                	folderName = items.get(1).getString();
                	Folder folder = rootFolder.lookupFolder(folderName);
                	if (folder == null) {
                		message = StringUtil.failureMsg("Unable to find folder - " + folderName);
                	}
                	else {
                		fileName = fileItem.getName();
                		
                		if (fileName.toLowerCase().endsWith("wsdl") || fileName.toLowerCase().endsWith("xsd"))
	               	 	{
                			//upload single file
                			File file = folder.createFile(fileName);
	    	           	 	fileItem.write(file);
    		           	 	message = StringUtil.successMsg("File uploaded sucessfully");
	               	 	} else if (fileName.toLowerCase().endsWith("jar") || fileName.toLowerCase().endsWith("zip")) {
	               	 		//Logic to extract the files from zip to upload
	               	 		File file = new File(application.getRealPath("/workspace") + "/tmp/" + fileItem.getName());
	               	 		fileItem.write(file);
	               	 		String zipFileName = URLEncoder.encode(file.getAbsolutePath(), "UTF-8");
	               	 		String zipFolderName = URLEncoder.encode(folderName, "UTF-8");
	               	 		ZipFile zip = new ZipFile(file);
	               	 		Set<String> dups = folder.checkDuplicateFiles(zip);
	               	 		if (dups.size() == 0) {
	               	 			folder.createFilesAndFolder(zip);
	               	 			message = StringUtil.successMsg("Files from archive are uploaded successfully");
	               	 		} else {
		                    	%>
		                    	<script type="text/javascript">
		                    		window.addEventListener("load", function(e) { 
		                    			var answer = confirm("Following files are already present, do you want to override? \n<%=dups.toString() %>");
		                            	if (answer) {
		                            		window.location = "files.jsp?action=override&zipFileName=<%=zipFileName %>&folderName=<%=zipFolderName %>"
		                            	}
		                    		}, false); 
		                    	</script>
		                    	<%
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
            	Folder folder = rootFolder.lookupFolder(folderName);
            	Folder newFolder = rootFolder.lookupFolder(folderName + "/" + newFolderName);
            	if (!StringUtil.isValid(newFolderName)) {
            		message = StringUtil.failureMsg("Provide a valid folder name");
            	} else if (folder == null) {
            		message = StringUtil.failureMsg("Unable to find folder - " + folderName);
            	} else if (newFolder != null) {
            		fileName = newFolderName;
            		message = StringUtil.failureMsg("Folder already present");
            	} else {
            		fileName = newFolderName;
            		folder.createSubFolder(newFolderName);
            		message = StringUtil.successMsg("Folder created successfully");
            	}
            	
            }  else if ("override".equals(action)) {
        		String zipFileName = request.getParameter("zipFileName");
        		folderName = request.getParameter("folderName");
        		Folder folder = rootFolder.lookupFolder(folderName);
        		File file = new File(zipFileName);
        		ZipFile zip = new ZipFile(file);
        		folder.createFilesAndFolder(zip);
        		try {zip.close();}catch (Exception e) {}
        	}  else if ("deleteFile".equals(action)) {
        		fileName = request.getParameter("fileName");
        		folderName = request.getParameter("folderName");
        		File file = new File(fileName);
        		boolean status = file.delete();
        		if (status){
        			message = StringUtil.successMsg("File deleted successfully");
        			rootFolder = DomainFactory.getInstance().getDomainFileFolder(domain);
        		}
        		else
       				message = StringUtil.failureMsg("Failed to delete the file");
        	}  else if ("deleteFolder".equals(action)) {
        		folderName = request.getParameter("folderName");
        		boolean status = FileUtil.deleteFolder(folderName);
        		if (status){
        			message = StringUtil.successMsg("Folder deleted successfully");
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
            function checkFileType() {
            	var file = new String(document.fileUploadForm.fileName.value);
            	var index = file.lastIndexOf(".");
            	if (index == -1) {
            		alert("Only WSDL/XSD/ZIP/JAR files can be uploaded");
            		return;
            	} 
            	
           	 	var fileExt = file.substring(index+1, file.length);
           	 	if (fileExt.toLowerCase() != "wsdl" && fileExt.toLowerCase() != "xsd" && fileExt.toLowerCase() != "zip" && fileExt.toLowerCase() != "jar") {
            		alert("Only WSDL/XSD/ZIP/JAR files can be uploaded");
            		return;
           	 	}
           	 	
            	document.fileUploadForm.submitInput.disabled = false;
            }
            function onClickFolder(name) {
            	addPathDetail(name);
            }
            function onPageLoad() {
            	
            	<% if ("Create New Folder".equals(action)) { 
            			if (fileName != null) {
            	%>
	        		var name = new String('<%=folderName + "/" +  fileName %>');
	   				<% } else { %>
	   				var name = new String('<%=folderName %>');
	   				<% } %>
        		addPathDetail(name);
        		expandToItem('folderTree', name);
            	<% }  else if ("uploadFile".equals(action)) { %>
        		var name = new String('<%=folderName %>');
        		addPathDetail(name);
        		expandToItem('folderTree', '<%=folderName + "/" +  fileName %>');
        		<% if (fileName.toLowerCase().endsWith(".wsdl") || fileName.toLowerCase().endsWith(".xsd")) { %>
        		loadFileContent('<%=folderName + "/" +  fileName %>')
        		<% }} else if ("deleteFile".equals(action)){ %>
        		var name = new String('<%=fileName!=null?fileName.substring(0, fileName.lastIndexOf("/")):folderName %>');
        		addPathDetail(name);
        		expandToItem('folderTree', '<%=folderName %>');
        		<% } else { %>
        		var name = new String('<%=folderName %>');
        		addPathDetail(name);
        		expandToItem('folderTree', '<%=folderName %>');
        		<% } %>
            }
            function onClickFile(name1) {
            	var name = new String(name1.substring(0, name1.lastIndexOf("/")));
            	addPathDetail(name);
        		loadFileContent(name1);
            }
            function addPathDetail(name) {
        		document.fileUploadForm.currentFolder.value = name;
        		document.folderCreateForm.currentFolder.value = name;
        		var str = 'ROOT' + name.substring(<%=rootFolder.getPath().length() %>, name.length);
        		if (name != '<%=rootFolder.getPath() %>') {
        			str = str + "&nbsp;<input type='button' value='Delete Folder' onclick='javascript:deleteFolder(\"" + name + "\")' />"; 
        		} else {
        			str = str + "&nbsp;<input type='button' value='Delete Folder' onclick='javascript:deleteFolder(\"" + name + "\")' disabled='disabled'/>";
        		}
        		
            	document.getElementById("currentPathSpan").innerHTML = str;
            }
            function loadFileContent(name1) {
            	
            	var name = new String(name1);
            	name = name.substring(<%=rootFolder.getPath().length()+1 %>, name.length);
            	var url = 'workspace/<%=domainName %>/' + name;
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
            		respSpan = document.getElementById("fileContentDiv");
              		if (xmlhttp.readyState==4 && xmlhttp.status==200)
                	{
              			var str = "";
              			if (name.substring(name.length-5, name.length).toLowerCase() == ".wsdl") {
              				str = "<input type='button' value='Create Mock' onclick='javascript:createMock(\"" + url + "\")' />";
              			}
             			
              			var resp = xmlhttp.responseText;
                        resp = resp.replace(/</g, "&lt;").replace(/>/g, "&gt;");
                        respSpan.innerHTML=str + "<input type='button' value='Download File' onclick='javascript:downloadFile(\"" + name1 + "\")' \><input type='button' value='Delete File' onclick='javascript:deleteFile(\"" + encodeURI(name1) + "\")' /><br><pre class='prettyprint lang-xml' style='overflow:auto; overflow-x:auto; overflow-y:auto; width: 740px; height: 396px;'>" + resp + "</pre>";
                        
                        prettyPrint();

                	}
              		else {
              			respSpan.innerHTML="<img src='img/ajax-loader.gif' height='12' width='12'/>";
              		}
              	}
            	
            	xmlhttp.open("GET", url, false);
            	xmlhttp.setRequestHeader("Content-type", "text/xml");
            	xmlhttp.send();
            }
            function createMock(url) {
            	
            	var wsdl = new String("<%=request.getRequestURL() %>");
            	wsdl = wsdl.substring(0, wsdl.length - 9).concat(url);
            	
            	window.location = "newservice.jsp?action=addService&nameType=generate&wsdlUrl=" + wsdl
            	
            }
            function deleteFile(name) {
            	
            	var answer = confirm("Are you sure you want to delete the file");
            	
            	if (answer) {
            		window.location = "files.jsp?action=deleteFile&folderName=<%=folderName %>&fileName=" + name
            	}
            }
            function deleteFolder(name) {
            	
            	var answer = confirm("Are you sure you want to delete the folder and content");
            	
            	if (answer) {
            		window.location = "files.jsp?action=deleteFolder&folderName=" + name
            	}
            }
            function downloadFile(url) {
            	window.location = "files.jsp?action=downloadFile&url=" + url
            }
        </script>        
    </head>
    <body onload="javascript:onPageLoad()">

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
		                	<table cellpadding="2px" cellspacing="0px">
		                		<tr>
				                    <td valign="top">
										<div style="overflow:auto; overflow-x:auto; overflow-y:auto; width:250px; height: 620px; ">
											<pre style="padding: 0px; margin: 0px; "><%=HtmlUtil.getFolderTree(rootFolder) %></pre>
										</div>
									</td>
									<td valign="top" width="100%">
									
										<font face="arial" size="2"><b>Current Folder : </b><span id="currentPathSpan"><%="ROOT/" + folderName.replace(rootFolder.getPath(), "") %></span></font>
										
										<br><br>
									
										<fieldset style="text-align:left;">
											<legend><b><a href="javascript:showContent('uploadFileDiv')">Upload File</a></b></legend>
											<div id="uploadFileDiv" style="display:block; width: 100%; ">

								       			<form name="folderCreateForm" action="files.jsp">
													<font face="arial" size="2">Folder Name </font>
													<input name="newFolderName" />
													<input type="hidden" name="currentFolder" value='<%=folderName %>' />
													<input type="submit" name="action" value="Create New Folder" />
												</form>
											
					        					<form name="fileUploadForm" action="files.jsp?action=uploadFile" method="post" ENCTYPE="multipart/form-data">
							                		<font face="arial" size="2">File (wsdl/xsd/zip/jar) </font>
						                        	<input type="file" name="fileName" onchange="javascript:checkFileType()"/>
						                        	<input type="hidden" name="currentFolder" value='<%=folderName %>' />
							                        <input type="submit" name="submitInput" value="Upload" disabled="disabled" />
								        		</form>

											</div>
										</fieldset>
										<br>
										<div id="fileContentDiv">
										</div>
										
				        			</td>
		        				</tr>
		        			</table>
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