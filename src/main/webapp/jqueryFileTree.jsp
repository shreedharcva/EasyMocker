<%@page import="net.sf.sripathi.ws.mock.Domain"%>
<%@page import="net.sf.sripathi.ws.mock.DomainFactory"%>
<%@page import="net.sf.sripathi.ws.mock.util.StringUtil"%>
<%@ page
	import="java.io.File,java.io.FilenameFilter,java.util.Arrays"%>
<%
/**
  * jQuery File Tree JSP Connector
  * Version 1.0
  * Copyright 2008 Joshua Gould
  * 21 April 2008
*/	

	//ServletContext context = getServletContext();
	final String domainName = (String) session.getAttribute("stub.domainName");
	
	if (!StringUtil.isValid(domainName))
	{
	%>
	    <jsp:forward page="domain.jsp"/>
	<%
	}
    
    String dir = request.getParameter("dir");
    if (dir == null) {
    	return;
    }
	
	if (dir.charAt(dir.length()-1) == '\\') {
    	dir = dir.substring(0, dir.length()-1) + "/";
	} else if (dir.charAt(dir.length()-1) != '/') {
	    dir += "/";
	}
	
	dir = java.net.URLDecoder.decode(dir, "UTF-8");	
	final boolean isRoot = dir.equals(DomainFactory.getInstance().getWorkingDir()+"/");
	if (new File(dir).exists()) {
    
		String[] files = new File(dir).list(new FilenameFilter() {
			
		    public boolean accept(File dir, String name) {
                if (name.charAt(0) == '.')
                    return false;
//				else if (isRoot && !name.equals(domainName))
//                    return false;
                
                return true;
		    }
		});
		Arrays.sort(files, String.CASE_INSENSITIVE_ORDER);
        
		out.print("<ul class=\"jqueryFileTree\" style=\"display: none;\">");
		// All dirs
		for (String file : files) {
		    if (new File(dir, file).isDirectory()) {
				out.print("<li class=\"directory collapsed\"><a href=\"#\" rel=\"" + dir + file + "/\">"
					+ file + "</a></li>");
		    }
		}
		// All files
		for (String file : files) {
		    if (!new File(dir, file).isDirectory()) {
				int dotIndex = file.lastIndexOf('.');
				String ext = dotIndex > 0 ? file.substring(dotIndex + 1) : "";
				out.print("<li class=\"file ext_" + ext + "\"><a href=\"#\" rel=\"" + dir + file + "\">"
					+ file + "</a></li>");
		    	}
		}
		out.print("</ul>");
    }
%>