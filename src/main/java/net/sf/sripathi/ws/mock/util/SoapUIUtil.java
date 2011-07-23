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

import java.io.ByteArrayInputStream;
import java.net.URL;
import java.net.URLConnection;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Vector;

import javax.xml.soap.MessageFactory;
import javax.xml.soap.SOAPMessage;

import org.apache.xmlbeans.XmlError;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;

import com.eviware.soapui.SoapUI;
import com.eviware.soapui.impl.WsdlInterfaceFactory;
import com.eviware.soapui.impl.rest.RestRequestInterface.RequestMethod;
import com.eviware.soapui.impl.wsdl.WsdlInterface;
import com.eviware.soapui.impl.wsdl.WsdlOperation;
import com.eviware.soapui.impl.wsdl.WsdlProject;
import com.eviware.soapui.impl.wsdl.WsdlRequest;
import com.eviware.soapui.impl.wsdl.submit.transports.http.SSLInfo;
import com.eviware.soapui.impl.wsdl.submit.transports.http.WsdlResponse;
import com.eviware.soapui.impl.wsdl.support.wsdl.WsdlValidator;
import com.eviware.soapui.impl.wsdl.teststeps.WsdlResponseMessageExchange;
import com.eviware.soapui.model.iface.Attachment;
import com.eviware.soapui.model.iface.MessagePart.FaultPart;
import com.eviware.soapui.model.testsuite.AssertionError;
import com.eviware.soapui.settings.WsdlSettings;
import com.eviware.soapui.support.types.StringToStringsMap;

/**
 * Utility class to access soapUI lib.
 * @author Sripathi
 *
 */
public class SoapUIUtil {

	/**
	 * Contains the interface map for WSDLs.
	 */
	private static Map<String, WsdlInterface> intrMap =
		new HashMap<String, WsdlInterface>();
	
	private static void setSoapUISettings() {
		SoapUI.getSettings().setBoolean(WsdlSettings.XML_GENERATION_TYPE_EXAMPLE_VALUE, false);
		SoapUI.getSettings().setBoolean(WsdlSettings.XML_GENERATION_SKIP_COMMENTS, false);
		//SoapUI.getSettings().setString(SoapUI.DEFAULT_WORKSPACE_FILE, "soapui-settings.xml");
		
	}
	
	private static WsdlInterface loadWsdl(String wsdlUrl) {
		
		WsdlInterface intr = intrMap.get(wsdlUrl);
		
		if (intr == null) {
		
			try {
				if (wsdlUrl.substring(0, 4).equalsIgnoreCase("http")) {
					URL url = new URL(wsdlUrl);
					URLConnection conn = url.openConnection();  
					conn.setConnectTimeout(5000);  
					conn.setReadTimeout(5000);  
					conn.getInputStream().close();
				}
			} catch (Exception e) {
				throw new MockException("Unable to import WSDL from " + wsdlUrl);
			}
			
			intr = getWsdlInterface(wsdlUrl);
		}
		
		return intr;
	}
	
	private static WsdlInterface getWsdlInterface(String wsdlUrl) {
		
		WsdlInterface intr = null;
		
		try {
			setSoapUISettings();
			
			WsdlProject soapUIProject = new WsdlProject();
			
			WsdlInterface[] intrs = WsdlInterfaceFactory.importWsdl(soapUIProject, wsdlUrl, true);
			
			if (intrs == null || intrs.length == 0 || intrs.length >1) 
				throw new MockException("Not supported at the moment");
			
			intr = intrs[0];
			
			intrMap.put(wsdlUrl, intr);
			
		
		} 
		catch (Exception e) {
			
			e.printStackTrace();
			throw new MockException("Unable to import WSDL from " + wsdlUrl);
		}
		
		return intr;
	}
	
	/**
	 * Gets the service name for the WSDL.
	 * @param wsdlUrl WSDL URL.
	 * @return service name.
	 */
	public static String getServiceName(String wsdlUrl) {
		
		WsdlInterface intf = loadWsdl(wsdlUrl);
		
		String [] eps = intf.getEndpoints();
		
		if (eps == null || eps.length == 0) {
			return null;
		}
		
		String ep = eps[0];
		
		int lastIndex = ep.lastIndexOf("/service/");
		
		if (lastIndex == -1) {
			return null;
		}
		
		String serviceName = ep.substring(lastIndex + 9, ep.length());
		
		return serviceName;
	}
	
	private static WsdlOperation getOperation(WsdlInterface intf, String operationName) {
		WsdlOperation operation = intf.getOperationByName(operationName);
		
		if (operation == null) {
			throw new MockException("Operation not found - " + operationName);
		}
		
		return operation;
	}
	/**
	 * Gets the dummy response SOAP for the operation name.
	 * @param wsdlUrl WSDL URL.
	 * @param operationName operation name.
	 * @return dummy response SOAP message.
	 */
	public static String getDummyResponse(String wsdlUrl, String operationName) {
		
		WsdlInterface intf = loadWsdl(wsdlUrl);

		return getOperation(intf, operationName).createResponse(true);
	}
	/**
	 * Gets the dummy request SOAP for the operation name.
	 * @param wsdlUrl WSDL URL.
	 * @param operationName operation name.
	 * @return dummy request SOAP message.
	 */
	public static String getDummyRequest(String wsdlUrl, String operationName) {
		
		WsdlInterface intf = loadWsdl(wsdlUrl);

		return getOperation(intf, operationName).createRequest(true);
	}
	/**
	 * Gets the operations for the WSDL.
	 * @param wsdlUrl WSDL URL.
	 * @return list of operation names for the WSDL.
	 */
	public static List<String> getOperationList(String wsdlUrl) {
		
		WsdlInterface intf = loadWsdl(wsdlUrl);
		
		List<String> operationList = new ArrayList<String>();
		
		for (int i=0;i<intf.getOperationCount();i++) {
			operationList.add(intf.getOperationAt(i).getName());
		}
		
		return operationList;
	}
	
	public static void verifyWsdlUrl(String wsdlUrl) {
		getWsdlInterface(wsdlUrl);
	}
	
	public static void forceUpdateWsdlUrl(String wsdlUrl) {
		
		intrMap.put(wsdlUrl, getWsdlInterface(wsdlUrl));
	}
	/**
	 * Gets all the request elements of the soap request.
	 * @param wsdlUrl WSDL URL.
	 * @param operationName operation name.
	 * @return list of element names.
	 */
	public static List<String> getRequestElements(String wsdlUrl, String operationName) {
		
		List<String> elements = new ArrayList<String>();
		
		try {
			String reqxml = getDummyRequest(wsdlUrl, operationName);
			
			SOAPMessage msg =
				MessageFactory.newInstance().createMessage(
					null, new ByteArrayInputStream(reqxml.getBytes()));
			Node n = (Node) msg.getSOAPBody();
			
			addChildElements(n, elements);
			
		} catch (Exception e) {
			
		}
		
		return elements;
	}
	
	private static void addChildElements(Node n, List<String> elements) {
		
		NodeList nl = n.getChildNodes();
		
		for (int i=0; i<nl.getLength(); i++) {
			
			n = nl.item(i);
			if (n.getNodeType() != 1) {
				continue;
			} else {
				if (hasChild(n)) {
					addChildElements(n, elements);
				} else {
					
					if (!elements.contains(n.getLocalName()))
						elements.add(n.getLocalName());
				}
			}
		}
	}
	
	private static boolean hasChild(Node n) {
		
		NodeList nl = n.getChildNodes();
		
		for (int i=0; i<nl.getLength(); i++) {
			n = nl.item(i);
			if (n.getNodeType() == 1)
				return true;
		}
		return false;
	}
	
	/**
	 * Gets the dummy fault messages for the WSDL and operation name.
	 * @param wsdlUrl WSDL URL.
	 * @param operationName operation name.
	 * @return map of fault messages.
	 */
	public static Map<String, String> getDummyFaults(String wsdlUrl, String operationName) {
		
		WsdlInterface intf = loadWsdl(wsdlUrl);
		
		WsdlOperation operation = intf.getOperationByName(operationName);
		
		FaultPart[] faultParts = operation.getFaultParts();
		
		Map<String, String> faultRespMap = new HashMap<String, String>();
		
		for (FaultPart faultPart : faultParts) {
			String faultString = intf.getMessageBuilder().buildFault(faultPart);
			
			faultString = faultString.replaceAll("\r\n      <!--Optional:-->", "");
			faultString = faultString.replaceAll("\r\n      <faultactor>\\?</faultactor>", "");
			faultString = faultString.replaceAll("\r\n        <!--You may enter ANY elements at this point-->", "");
			
			faultString =
				faultString.replaceFirst(
					"<faultcode>\\?</faultcode>",
					"<faultcode>soapenv:Server</faultcode>");
			
			if ("technicalFault".equals(faultPart.getName())) {
				faultString = faultString.replaceFirst(
					"<faultstring xml:lang=\"\\?\">\\?</faultstring>",
					"<faultstring>Technical Exception</faultstring>");
			}
			else if ("businessFault".equals(faultPart.getName())) {
				faultString = faultString.replaceFirst(
					"<faultstring xml:lang=\"\\?\">\\?</faultstring>",
					"<faultstring>Business Exception</faultstring>");
			}
			
			faultRespMap.put(faultPart.getName(), faultString);
		}
		
		return faultRespMap;
	}
	/**
	 * Validates the response SOAP message against the WSDL.
	 * @param wsdlUrl WSDL URL.
	 * @param operationName operation name.
	 * @param response response SOAP message.
	 * 
	 * @return list of error messages if any. 
	 */
	public static List<String> validateResponse(String wsdlUrl, String operationName, String response) {
		
		WsdlInterface intf = loadWsdl(wsdlUrl);
		
		WsdlOperation operation = intf.getOperationByName(operationName);
		
		if (operation == null) {
			throw new MockException("Operation " + operationName + " not found.");
		}
		
		WsdlRequest req = operation.addNewRequest("something");
		req.setResponse(new MyResponse(response), null);
		WsdlValidator validator = new WsdlValidator(intf.getWsdlContext());
		
		List<String> errorList = new ArrayList<String>();
		
		try {
			AssertionError[] errors = validator.assertResponse(new WsdlResponseMessageExchange(req), false);
			
			for (AssertionError error : errors) {
				errorList.add(error.toString());
			}
		} catch (Exception e) {
			e.printStackTrace();
			throw new MockException("Unable to validate the message.");
		}
		
		return errorList;
	}
	
	/**
	 * Validates the XML structure.
	 * @param xml input xml.
	 * @return list of errors.
	 */
	public static List<String> validateXml(String xml) {
		WsdlValidator validator = new WsdlValidator(null);
		
		List<XmlError> errorList = new ArrayList<XmlError>();
		validator.validateXml(xml, errorList);
		List<String> errors = new ArrayList<String>();
		for (XmlError error : errorList) {
			errors.add("Line " + error.getLine() + ": " + error.getMessage());
		}
		return errors;
	}
	
	public static class MyResponse implements WsdlResponse {

		String resp = "";
		
		public MyResponse(String response) {
			resp = response;
		}
		public void setResponseContent(String arg0) {
		}
		public String getContentAsString() {
			return resp;
		}
		public long getContentLength() {
			return resp.length();
		}
		public Attachment[] getAttachments() {
			return null;
		}
		public Attachment[] getAttachmentsForPart(String arg0) {
			return null;
		}
		public String getContentType() {
			return null;
		}
		public String getProperty(String arg0) {
			return null;
		}
		public String[] getPropertyNames() {
			return new String [] {};
		}
		public byte[] getRawRequestData() {
			return null;
		}
		public byte[] getRawResponseData() {
			return null;
		}
		public String getRequestContent() {
			return null;
		}
		public StringToStringsMap getRequestHeaders() {
			return null;
		}
		public StringToStringsMap getResponseHeaders() {
			return null;
		}
		public long getTimeTaken() {
			return 0;
		}
		public long getTimestamp() {
			return 0;
		}
		public void setProperty(String arg0, String arg1) {
			
		}
		public String getContentAsXml() {
			return null;
		}
		public String getHttpVersion() {
			return null;
		}
		public RequestMethod getMethod() {
			return null;
		}
		public SSLInfo getSSLInfo() {
			return null;
		}
		public int getStatusCode() {
			return 0;
		}
		public URL getURL() {
			return null;
		}
		public Vector<?> getWssResult() {
			return null;
		}
		public WsdlRequest getRequest() {
			return null;
		}
	}
}
