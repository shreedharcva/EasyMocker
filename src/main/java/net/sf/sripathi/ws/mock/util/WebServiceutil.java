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
import java.io.ByteArrayOutputStream;
import java.io.PrintWriter;
import java.io.StringWriter;

import javax.xml.soap.MessageFactory;
import javax.xml.soap.MimeHeaders;
import javax.xml.soap.SOAPConnection;
import javax.xml.soap.SOAPConnectionFactory;
import javax.xml.soap.SOAPMessage;

import org.apache.commons.codec.binary.Base64;

/**
 * Utility class for web service invocation.
 * 
 * @author Sripathi
 *
 */
public class WebServiceutil {

	/**
	 * Invokes the web service using SAAJ API.
	 * 
	 * @param request soap request string.
	 * @param url end point URL.
	 * @param user user name for authentication.
	 * @param password password for authentication.
	 * 
	 * @return response soap string.
	 */
	public static String callWebService(String request, String url, String user, String password) {
		
		if (request == null) 
			request = "";
		try {
			SOAPConnection conn = SOAPConnectionFactory.newInstance().createConnection();
			
			MimeHeaders hd = new MimeHeaders();
			hd.addHeader("Content-Type", "text/xml");
			if (StringUtil.isValid(user) && StringUtil.isValid(password)) {
				String authorization = new String(Base64.encodeBase64((user +":" + password).getBytes()));
				hd.addHeader("Authorization", "Basic " + authorization);
			}
			
			SOAPMessage msg = MessageFactory.newInstance().createMessage(hd, new ByteArrayInputStream(request.getBytes()));
			SOAPMessage resp = conn.call(msg, url);
			ByteArrayOutputStream baos = new ByteArrayOutputStream();
			resp.writeTo(baos);
			return new String(baos.toByteArray());
		}
		catch (Exception e) {
			StringWriter sw = new StringWriter();
			e.printStackTrace(new PrintWriter(sw));
			return sw.toString();
		}
	}
}
