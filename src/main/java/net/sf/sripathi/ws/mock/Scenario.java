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

import javax.xml.bind.annotation.XmlType;

import net.sf.sripathi.ws.mock.util.MockException;


@XmlType(name="Scenario", namespace="http://www.sripathi.sf.net/ws/mock",
		propOrder={"key","description","response","delayInMilliSec"})
public class Scenario implements Serializable {

	/**
	 * 
	 */
	private static final long serialVersionUID = -2079478941501443444L;
	
	private String key;
	private String description;
	private String response;
	private int delayInMilliSec;
	
	public Scenario() {
		
	}
	
	public Scenario(String key, String description, String response) {
		this.key = key.trim();
		this.description = description;
		this.response = response;
	}
	
	public String getKey() {
		return key;
	}
	public void setKey(String key) {
		this.key = key.trim();
	}
	public String getDescription() {
		return description;
	}
	public void setDescription(String description) {
		this.description = description;
	}
	public String getResponse() {
		return response;
	}
	public void setResponse(String response) {
		this.response = response;
	}
	public int getDelayInMilliSec() {
		return delayInMilliSec;
	}
	public void setDelayInMilliSec(int delayInMilliSec) {
		
		if (delayInMilliSec > 60*1000) {
			throw new MockException("Delay cannot be greater than 1 minute");
		}
		else {
			this.delayInMilliSec = delayInMilliSec;
		}
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
	    
	    retValue = "Scenario ( "
	        + super.toString() + TAB
	        + "key = " + this.key + TAB
	        + "description = " + this.description + TAB
	        + "response = " + this.response + TAB
	        + "delayInMilliSec = " + this.delayInMilliSec + TAB
	        + " )";
	
	    return retValue;
	}

}
