/*
 *  Copyright 2010-2011 the original author or authors.
 *
 *  WebServiceMocker is free software; you can redistribute it and/or modify it under the 
 *  terms of version 2.1 of the GNU Lesser General Public License as published by 
 *  the Free Software Foundation.
 *
 *  WebServiceMocker is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without 
 *  even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. 
 *  See the GNU Lesser General Public License for more details at gnu.org.
 */

package net.sf.sripathi.ws.mock.util;


public class HtmlUtil {

	private HtmlUtil() {

	}
	
	public static String getFolderTree(Folder folder) {
		
		StringBuilder html = new StringBuilder();
		
		html.append("<ul class='mktree' id='folderTree'>");

		addFolder(html, folder, true);
		
		html.append("</ul>");
		
		return html.toString();
	}
	
	private static void addFolder(StringBuilder html, Folder folder, boolean root) {
		
		String name = folder.getName();
		
		if (root) {
			name = "ROOT";
		}
		
		html.append("<li id='");
		html.append(folder.getPath());
		html.append("'><a href='javascript:onClickFolder(\"");
		html.append(folder.getPath());
		html.append("\")'>");
		html.append("<img src='img/folder.gif' border='0' />&nbsp;");
		html.append(name);
		html.append("</a>");
		
		//Add sub folders
		if (folder.getSubFolders().size() != 0) {

			html.append("<ul id='");
			html.append(folder.getPath());
			html.append(".UL'>");
			for (Folder subFolder : folder.getSubFolders()) {
				
				addFolder(html, subFolder, false);
			}
			html.append("</ul>");
		}
		
		//Add files 
		if (folder.getFiles().size() != 0) {
			
			html.append("<ul>");			
			for (String file : folder.getFiles()) {
				
				html.append("<li id='");
				html.append(folder.getPath());
				html.append("/");
				html.append(file);
				html.append("'><a href='javascript:onClickFile(\"");
				html.append(folder.getPath() + "/" + file);
				html.append("\")'>");
				
				if (file.toLowerCase().endsWith("wsdl"))
					html.append("<img src='img/wsdl.gif' border='0' />&nbsp;");
				else if (file.toLowerCase().endsWith("xsd"))
					html.append("<img src='img/xsd.gif' border='0' />&nbsp;");
				else 
					html.append("<img src='img/file.gif' border='0' />&nbsp;");
				
				html.append(file);
				html.append("</a>");
				
			}
			html.append("</ul>");
		}
		
		html.append("</li>");
		
	}
}
