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

package net.sf.sripathi.ws.mock.servlet;

import java.io.File;
import java.io.InputStream;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import net.sf.sripathi.ws.mock.Domain;
import net.sf.sripathi.ws.mock.DomainFactory;
import net.sf.sripathi.ws.mock.Scenario;
import net.sf.sripathi.ws.mock.Service;
import net.sf.sripathi.ws.mock.util.MockException;
import net.sf.sripathi.ws.mock.util.SoapUtil;
import net.sf.sripathi.ws.mock.util.StringUtil;

import org.apache.commons.io.IOUtils;
import org.apache.log4j.Logger;
import org.apache.log4j.PatternLayout;
import org.apache.log4j.RollingFileAppender;


public class MockServlet extends HttpServlet {

	/**
	 * Default serial id.
	 */
	private static final long serialVersionUID = 3275583196562906368L;
	
	/**
	 * Path to working directory for the mocker
	 */
	private String workingDirectory = null;
	
	/**
	 * Log4j logger instance
	 */
	private Logger LOGGER = Logger.getLogger(MockServlet.class); 
	
	/**
	 * Initalize the servlet.
	 */
	@Override
	public void init() throws ServletException {
		super.init();
		
		//Check if there is a valid workspace set configured in the init param
	    workingDirectory =
            super.getServletContext().getInitParameter("WORKSPACE_DIR");
	    
	    //If init param is not set use default
	    if (!StringUtil.isValid(workingDirectory)) {
	    	workingDirectory = getServletContext().getRealPath("/workspace");
	    }
		
		workingDirectory = workingDirectory.replace('\\', '/');
		
		if (!new File(workingDirectory).exists()) {
			throw new ServletException("Unable to access specified path - " + workingDirectory + ". If workspace"
					+ " is specified in web.xml please make sure the specified folder exists and access is provided.");
		}
		
		DomainFactory.getInstance().setWorkingDir(workingDirectory);
		
		try {
			RollingFileAppender appender = new RollingFileAppender(new PatternLayout("| %d | %m %n"), workingDirectory + "/Mock.log", false);
			appender.setMaxFileSize(""+1024*512);
			Logger.getLogger(MockServlet.class).addAppender(appender);
		}
		catch (Exception e) {
			e.printStackTrace();
		}
	}

	/**
	 * The service operation generated the mocked response for the input SOAP request message.
	 */
	@Override
	public void service(HttpServletRequest req, HttpServletResponse resp) {
		
		long startTime = System.currentTimeMillis();
		
		try {
			String tmp =
				req.getRequestURI().substring((req.getContextPath() + "/mock/").length());
			String[] tmps = tmp.split("/");

			String domainName = tmps[0];
						
			Domain domain = DomainFactory.getInstance().getDomain(domainName);
			
			String soapResp = null;
			String soapReq = "";
			if (tmps.length != 3) {
				soapResp = SoapUtil.getSoapFault("NOT_A_VALID_URL", "URL " + req.getRequestURI() + " is not valid");
			}
			else if (domain == null) {
				soapResp = SoapUtil.getSoapFault("NOT_A_VALID_PROFILE", "Domain " + domainName + " is not valid");
				LOGGER.error(soapResp);
			}
			else {
				String serviceName = tmps[2];
				
				Service service = domain.getService(serviceName);
			
				if (service == null) {
					soapResp = SoapUtil.getSoapFault("NOT_A_VALID_SERVICE", "Service " + serviceName + " is not valid");
					LOGGER.error(soapResp);
				}
				else {
					LOGGER.info("Request received for service - " + serviceName + " on domain - " + domainName);
					InputStream is = req.getInputStream();
					
					soapReq = new String(IOUtils.toByteArray(is));
					
					this.getLogger(domainName,serviceName).info("Request - " + soapReq);
					try {
						Scenario scenario = service.getMockResponse(soapReq);
						soapResp = scenario.getResponse();
						
						if (scenario.getDelayInMilliSec() > 0) {
							long curTime = System.currentTimeMillis();
							long diff = curTime - startTime;
							if (diff < scenario.getDelayInMilliSec()) {
								Thread.sleep(scenario.getDelayInMilliSec() - diff);
							}
						}
						
					} catch (MockException me) {
						soapResp = SoapUtil.getSoapFault("UNABLE_TO_PROCESS_REQ", me.getMessage());
					}
					this.getLogger(domainName,serviceName).info("Mock Response - " + soapResp);
				}
			}
			
			if (soapReq.contains(  javax.xml.soap.SOAPConstants.URI_NS_SOAP_1_2_ENVELOPE  )){
			    resp.setContentType( javax.xml.soap.SOAPConstants.SOAP_1_2_CONTENT_TYPE );			   
			}else{
			    resp.setContentType( javax.xml.soap.SOAPConstants.SOAP_1_1_CONTENT_TYPE );			   
			}
			
			if (soapResp != null
				&& soapResp.indexOf("Fault>") != -1
				&& soapResp.indexOf("faultcode>") != -1
				&& soapResp.indexOf("faultstring>") != -1)
			{
				resp.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
			}
			
			resp.getOutputStream().write(soapResp.getBytes());
		}
		catch (Exception e) {
			e.printStackTrace();
		}
	}

	/**
	 * Save the domains as part of destroy.
	 */
	@Override
	public void destroy() {
		super.destroy();
		DomainFactory.getInstance().save();
	}
	
	private Logger getLogger(String domainName, String serviceName) {
		Logger logger = Logger.getLogger(domainName+"."+serviceName+"Logger");
		if (logger.getAppender(domainName+"."+serviceName+"Appender") == null) {
			try {
				RollingFileAppender appender = new RollingFileAppender(new PatternLayout("| %d | %m %n"), workingDirectory + "/"+domainName+"."+serviceName+".log", false);
				appender.setMaxFileSize(""+1024*512);
				appender.setName(domainName+"."+serviceName+"Appender");
				logger.addAppender(appender);
			}catch (Exception e) {
				e.printStackTrace();
			}
		}
		return logger;
	}
}
