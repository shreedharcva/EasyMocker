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

import javax.xml.soap.MessageFactory;
import javax.xml.soap.SOAPMessage;

import org.w3c.dom.Node;
import org.w3c.dom.NodeList;

/**
 * A utility class to acccess soap message.
 * 
 * @author Sripathi
 *
 */
public final class SoapUtil {
	
	/**
	 * private constructor
	 */
	private SoapUtil() {
		
	}
	
	/**
	 * Constructs the string SOAP fault message.
	 * 
	 * @param code fault code.
	 * @param description fault description.
	 * 
	 * @return string representing the SOAP fault.
	 */
	public static String getSoapFault(String code, String description) {
		StringBuffer buf = new StringBuffer();
		buf.append("<env:Envelope xmlns:env=\"http://schemas.xmlsoap.org/soap/envelope/\"><env:Body><env:Fault><faultcode>");
		buf.append(code);
		buf.append("</faultcode><faultstring>");
		buf.append(description);
		buf.append("</faultstring></env:Fault></env:Body></env:Envelope>");
		return buf.toString();
	}
	
	/**
	 * Finds the operation name from the input SOAP request string message.
	 * 
	 * @param soapRequest string SOAP message.
	 * 
	 * @return operation name.
	 */
	public static String getOperationName(String soapRequest) {
		
		try {
			SOAPMessage msg =
				MessageFactory.newInstance().createMessage(
					null, new ByteArrayInputStream(soapRequest.getBytes()));
			Node n = (Node) msg.getSOAPBody();
			
			NodeList cnList = n.getChildNodes();
			
			for (int i=0;i<cnList.getLength();i++) {
				if (cnList.item(i).getLocalName() != null) {
					return cnList.item(i).getLocalName();
				}
			}
		}
		catch (Exception e){
			e.printStackTrace();
			throw new MockException("Unable to find operation name from request");
		}
		
		return null;
	}
	
    /**
     * Gets the element value from the input XML for the provided element name.
     * 
     * @param xml XML string from which the element value needs to be derived.
     * @param element XML element name.
     * 
     * @return a string value of XML element.
     */
    public static String getXmlElementValue(String xml, String element) {
        
        //Search for the element
        int startInd = xml.indexOf("<" + element);
        if (startInd == -1) {
            //Element not found
            return null;
        }

        //Search for the end for the element. This is because of the name space
        startInd = xml.indexOf('>', startInd);
        if (startInd == -1) {
            //Element end not found
            return null;
        }
        
        //Find the closing element
        int endInd = xml.indexOf("</" + element);
        if (endInd == -1 || endInd <= startInd) {
            //This could be an empty element
            return null;
        }
        
        //Element found. Return its value
        return xml.substring(startInd + 1, endInd);
        
    }

    /**
     * Gets the element value (trimmed) from the input XML for the provided
     * element name.
     * 
     * @param xml XML string from which the element value needs to be derived.
     * @param element XML element name.
     * 
     * @return a string value of XML element.
     */
    public static String getXmlElementTrimmedValue(String xml, String element) {

        String dirtyValue = getXmlElementValue(xml, element);
        
        if (dirtyValue == null) {
            return dirtyValue;
        }
        
        String cleanValue = dirtyValue.replaceAll("\\n", "");
        cleanValue = cleanValue.replaceAll("\\r", "");
        cleanValue = cleanValue.replaceAll("\\t", "");
        
        return cleanValue.trim();
    }

    /**
     * Gets the element value from the input XML for the provided element name.
     * 
     * @param xml XML string from which the element value needs to be derived.
     * @param element XML element name.
     * @param wrapperElement wrapper element.
     * 
     * @return a string value of XML element.
     */
    public static String getXmlElementValue(
        String xml, String element, String wrapperElement)
    {
        
        //Get the content under wrapper element
        String intXml = getXmlElementValue(xml, wrapperElement);
        
        if (intXml == null) {
            
            return intXml;
        }
        
        return getXmlElementValue(intXml, element);
        
    }

    /**
     * Gets the element value (trimmed) from the input XML for the provided
     * element name.
     * 
     * @param xml XML string from which the element value needs to be derived.
     * @param element XML element name.
     * @param wrapperElement wrapper element.
     * 
     * @return a string value of XML element.
     */
    public static String getXmlElementTrimmedValue(
        String xml, String element, String wrapperElement)
    {

        //Get the content under wrapper element
        String intXml = getXmlElementValue(xml, wrapperElement);
        
        if (intXml == null) {
            
            return intXml;
        }
        
        return getXmlElementTrimmedValue(intXml, element);
    }
}
