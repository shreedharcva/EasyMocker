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

<%@page import="net.sf.sripathi.ws.mock.DomainFactory"%>
<%@page import="net.sf.sripathi.ws.mock.Domain"%>
<%@page import="net.sf.sripathi.ws.mock.util.StringUtil"%>


<html>
    <head>
        <title>Web Service Mocker</title>
        
        <link href="prettify.css" type="text/css" rel="stylesheet" />
        <script type="text/javascript" src="prettify.js"></script>
        
        <link rel="stylesheet" type="text/css" href="jqueryFileTree.css" />
		<script src="jquery.js" type="text/javascript"></script>
		<script src="jquery.easing.js" type="text/javascript"></script>
		<script src="jqueryFileTree.js" type="text/javascript"></script>
		<script src="jquery.form.js" type="text/javascript"></script>
        
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
            
            String folderName = DomainFactory.getInstance().getWorkingDir() + "/" + domain.getName();
            
        %>
        <script type="text/javascript">
        
	        var folder = null;
	        var folderName = '<%=folderName %>';
	        var rootFolderName = folderName;
        
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
            function onClickFile(name1) {
            	var name = new String(name1.substring(0, name1.lastIndexOf("/")));
            	addPathDetail(name);
        		loadFileContent(name1);
            }
            function addPathDetail(name) {
            	folderName = name;
        		document.fileUploadForm.currentFolder.value = name;
        		document.folderCreateForm.currentFolder.value = name;
        		var str = 'ROOT' + name.substring(rootFolderName.length, name.length);
        		if (name != rootFolderName) {
        			str = str + "&nbsp;<input type='button' value='Delete Folder' onclick='javascript:deleteFolder(\"" + name + "\")' />"; 
        		} else {
        			str = str + "&nbsp;<input type='button' value='Delete Folder' onclick='javascript:deleteFolder(\"" + name + "\")' disabled='disabled'/>";
        		}
        		
            	document.getElementById("currentPathSpan").innerHTML = str;
            }
            function loadFileContent(name1) {
           
            	var name = new String(name1);
            	name = name.substring(rootFolderName.length+1, name.length);
            	var url = 'workspace/<%=domainName %>/' + name;

           		respSpan = document.getElementById("fileContentDiv");
       			var str = "";
       			if (name.substring(name.length-5, name.length).toLowerCase() == ".wsdl") {
       				str = "<input type='button' value='Create Mock' onclick='javascript:createMock(\"" + url + "\")' />";
       			}
       			
            	$.ajax({
					url: url,
					dataType: "html",
					beforeSend: function() {
						respSpan.innerHTML = "<img src='img/ajax-loader.gif' height='12' width='12'/>";
					},
					success: function(resp) {
						resp = resp.replace(/</g, "&lt;").replace(/>/g, "&gt;").replace(/\t/g, "&nbsp;&nbsp;&nbsp;&nbsp;");
						respSpan.innerHTML = str + "<input type='button' value='Download File' onclick='javascript:downloadFile(\"" + name1 + "\")' \><input type='button' value='Delete File' onclick='javascript:deleteFile(\"" + encodeURI(name1) + "\")' /><br><pre class='prettyprint lang-xml' style='overflow:auto; overflow-x:auto; overflow-y:auto; width: 740px; height: 432px;'>" + resp + "</pre>";
						prettyPrint();
					}
            	});
            }
            function createMock(url) {
            	
            	var wsdl = new String("<%=request.getRequestURL() %>");
            	wsdl = wsdl.substring(0, wsdl.length - 9).concat(url);
            	
            	window.location = "newservice.jsp?action=addService&nameType=generate&wsdlUrl=" + wsdl
            	
            }
            function deleteFile(name) {
            	
            	var answer = confirm("Are you sure you want to delete the file");
            	
            	if (answer) {
            		var url = "filefulfillment.jsp?action=deleteFile&folderName="+folderName+"&fileName="+name;
            				
                	$.ajax({
    					url: url,
    					dataType: "html",
    					success: function(data) {
    						loadFolder();
    						loadContent("fileContentDiv", data);
    						//$("#fileContentDiv").fadeOut(4000);
    					}
                	});
            	}
            }
            function deleteFolder(name) {
            	
            	var answer = confirm("Are you sure you want to delete the folder and content");
            	if (answer) {
            	
	            	var url = "filefulfillment.jsp?action=deleteFolder&folderName=" + name;
	            	
	            	$.ajax({
						url: url,
						dataType: "html",
						success: function(data) {
							folder = null;
							addPathDetail(rootFolderName);
							loadFolder();
							loadContent("fileContentDiv", data);
							//$("#fileContentDiv").fadeOut(4000);
						}
	            	});
            	}
            }
            function downloadFile(url) {
            	window.location = "filefulfillment.jsp?action=downloadFile&url=" + url
            }
            
            function loadFolder() {
                if(folder == null) {
                    $('#fileExplorerDiv').fileTree({ 
                        root: '<%=DomainFactory.getInstance().getDomainFileFolder(domain).getPath() %>',
                        script: 'jqueryFileTree.jsp',
                        multiFolder: false
                    }, function (f) {
                        folder = f;
                        onClickFolder($(f).attr('rel'));
                    },
                    function (file) {
						onClickFile(file);
                    });
                } else {
                    $(folder).click();
                    $(folder).click();
                }
            }
            
            function loadContent(id, content) {
            	document.getElementById(id).innerHTML = content;
            }
            
            $(document).ready( function() {

            	loadFolder();
            	
                $('#folderCreateForm').ajaxForm(function(responseText) { 
                	
					loadContent("fileContentDiv", responseText);
					loadFolder();
                }); 
                
                $('#fileUploadForm').ajaxForm(function(responseText) {
                	var ret = new String(responseText);
                	document.fileUploadForm.override.value = "false";
                	if (ret.indexOf("FAILED-OF-DUPS") == 0) {
                		
                		//Failed because of the dups
                		var answer = confirm("Following files already present. Do you want to override?\n " + ret.substring(14));

                		if (answer) {
                			document.fileUploadForm.override.value = "true";
                			$('#fileUploadForm').submit();
                		}
                	} else if (ret.indexOf("SUCCESS_UPLOAD") == 0) {
                		loadFolder();
                		loadFileContent(ret.substring(14));
                	} else {
						loadContent("fileContentDiv", responseText);
						loadFolder();
                	}
                });
            });

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
		                	<table cellpadding="2px" cellspacing="0px">
		                		<tr>
				                    <td valign="top">
				                    	<font face="arial" size="2"><b>File Explorer </b></font><br><br>
										<div style="overflow:auto; overflow-x:auto; overflow-y:scroll; width:250px; height: 620px; " id="fileExplorerDiv"></div>
									</td>
									<td valign="top" width="100%">
									
										<font face="arial" size="2"><b>Current Folder : </b><span id="currentPathSpan">ROOT&nbsp;<input type='button' value='Delete Folder' disabled='disabled'/></span></font>
										
										<br><br>
									
										<fieldset style="text-align:left;">
											<legend><b><a href="javascript:showContent('uploadFileDiv')">Upload File</a></b></legend>
											<div id="uploadFileDiv" style="display:block; width: 100%; ">

								       			<form name="folderCreateForm" id="folderCreateForm" action="filefulfillment.jsp">
													<font face="arial" size="2">Folder Name </font>
													<input name="newFolderName" />
													<input type="hidden" name="currentFolder" value='<%=folderName %>' />
													<input type="submit" name="action" value="Create New Folder" />
													<span id="createFolderResp"></span>
												</form>
											
					        					<form name="fileUploadForm" id="fileUploadForm"  action="filefulfillment.jsp?action=uploadFile" method="post" ENCTYPE="multipart/form-data">
							                		<font face="arial" size="2">File (wsdl/xsd/zip/jar) </font>
						                        	<input type="file" name="fileName" onchange="javascript:checkFileType()"/>
						                        	<input type="hidden" name="currentFolder" value='<%=folderName %>' />
						                        	<input type="hidden" name="override" value="false" />
							                        <input type="submit" name="submitInput" value="Upload" disabled="disabled" />
							                        <span id="fileUploadResp"></span>
								        		</form>

											</div>
										</fieldset>
										<br>
										<div id="fileContentDiv"></div>
										
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