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

package net.sf.sripathi.ws.mock;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.List;

import javax.xml.bind.annotation.XmlType;

import net.sf.sripathi.ws.mock.util.MockException;
import net.sf.sripathi.ws.mock.util.SoapUIUtil;
import net.sf.sripathi.ws.mock.util.SoapUtil;


@XmlType(name="Service", namespace="http://www.sripathi.sf.net/ws/mock",
		propOrder={"name","wsdlUrl","reqSchemaVal","operationList"})
public class Service implements Serializable {

	/**
	 * Generated serial id.
	 */
	private static final long serialVersionUID = 4956197967313447631L;

	/**
	 * Service name.
	 */
	private String name;
	
	/**
	 * WSDL url.
	 */
	private String wsdlUrl;
	
	/**
	 * True if schema validation is required.
	 */
	private boolean reqSchemaVal;
	
	/**
	 * List of operations.
	 */
	private List<Operation> operationList;

	/**
	 * Default constructor.
	 */
	public Service() {
		
	}
	
	/**
	 * Overloaded constructor.
	 * 
	 * @param name service name.
	 * @param wsdlUrl service WSDL URL.
	 */
	public Service(String name, String wsdlUrl) {
		this.name = name.trim();
		this.wsdlUrl = wsdlUrl.trim();
		if (this.wsdlUrl.length() > 0) {
    		SoapUIUtil.forceUpdateWsdlUrl(wsdlUrl);
    		for (String oprName : SoapUIUtil.getOperationList(wsdlUrl)) {
    			Operation operation = new Operation(oprName, wsdlUrl);
    			this.getOperationList().add(operation);
    		}
		}
	}

	/**
	 * Gets the service name.
	 * 
	 * @return service name.
	 */
	public String getName() {
		return name;
	}

	/**
	 * Sets the service name.
	 * 
	 * @param name service name.
	 */
	public void setName(String name) {
		this.name = name.trim();
	}

	/**
	 * Gets the WSDL URL.
	 * 
	 * @return WSDL URL.
	 */
	public String getWsdlUrl() {
		return wsdlUrl;
	}

	/**
	 * Sets the WSDL URL.
	 * 
	 * @param wsdlUrl WSDL URL.
	 */
	public void setWsdlUrl(String wsdlUrl) {
		this.wsdlUrl = wsdlUrl.trim();
	}

	/**
	 * @return the reqSchemaVal
	 */
	public boolean isReqSchemaVal() {
		return reqSchemaVal;
	}

	/**
	 * @param reqSchemaVal the reqSchemaVal to set
	 */
	public void setReqSchemaVal(boolean reqSchemaVal) {
		this.reqSchemaVal = reqSchemaVal;
	}

	/**
	 * Sets the operation list.
	 * 
	 * @param operationList list of operations.
	 */
	public void setOperationList(List<Operation> operationList) {
		this.operationList = operationList;
	}

	/**
	 * Gets the operation list.
	 * 
	 * @return list of operations.
	 */
	public List<Operation> getOperationList() {
		if (this.operationList == null)
			this.operationList = new ArrayList<Operation>();
		return this.operationList;
	}

	/**
	 * 
	 * @param reqSoap soap request string.
	 * 
	 * @return response soap string.
	 */
	public Scenario getMockResponse(String reqSoap) {
		
		String operationName = SoapUtil.getOperationName(reqSoap);
		
		if (operationName == null) {
			throw new MockException("Unable to find operation.");
		}
		
		Operation operation = this.getOperationByRootElement(operationName);
		
		if (operation == null) {
			throw new MockException("Operation " + operationName + " is not configured for service " + this.name);
		}
		
		if (this.reqSchemaVal) {
			List<String> errors = SoapUIUtil.validateRequest(wsdlUrl, operation.getName(), reqSoap);
			
			if (errors != null && errors.size() != 0) {
				throw new MockException("Schema Validation failed. Errors " + errors);
			}
		}
		
		String keyElementValue = SoapUtil.getXmlElementTrimmedValue(reqSoap, operation.getKeyElement());

		if (keyElementValue == null) {
			return operation.getDefaultScenario();
		}
		
		Scenario scenario = operation.getScenarioForKeyElementValue(keyElementValue);
		
		if (scenario == null) {
			return operation.getDefaultScenario();
		}
		
		return scenario;
	}
	
	/**
	 * Updates the WSDL URL for the service.
	 * 
	 * @param wsdlUrl WSDL URL.
	 */
	public void updateWsdlUrl(String wsdlUrl) {
		SoapUIUtil.verifyWsdlUrl(wsdlUrl);
		this.wsdlUrl = wsdlUrl;
	}
	
	/**
	 * Gets the operation for the service using the operation name.
	 * 
	 * @param operationName operation name string.
	 *  
	 * @return instance of Operation.
	 */
	public Operation getOperation(String operationName) {
		
		for (Operation operation : this.getOperationList()) {
			if (operation.getName().equalsIgnoreCase(operationName)) {
				return operation;
			}
		}
		
		return null;
	}
	
	/**
	 * Gets the operation for the service using the root element name.
	 * 
	 * @param operationName operation name string.
	 *  
	 * @return instance of Operation.
	 */
	public Operation getOperationByRootElement(String rootElement) {
		
		for (Operation operation : this.getOperationList()) {
			if (operation.getRootElement().equalsIgnoreCase(rootElement)) {
				return operation;
			}
		}
		
		return null;
	}
	
	
	/**
	 * Deletes the operation for the service using the operation name.
	 * @param operationName operation name string.
	 */
	public void deleteOperation(String operationName) {
		Operation operation = this.getOperation(operationName);
		this.getOperationList().remove(operation);
	}
	
	/**
	 * Constructs a <code>String</code> with all attributes
	 * in name = value format.
	 *
	 * @return a <code>String</code> representation 
	 * of this object.
	 */
	public String toString()
	{
	    final String TAB = "    ";
	    
	    String retValue = "";
	    
	    retValue = "Service ( "
	        + super.toString() + TAB
	        + "name = " + this.name + TAB
	        + "wsdlUrl = " + this.wsdlUrl + TAB
	        + "operationList = " + this.operationList + TAB
	        + " )";
	
	    return retValue;
	}
}
