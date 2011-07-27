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
import java.util.HashMap;
import java.util.List;

import javax.xml.bind.annotation.XmlType;

import net.sf.sripathi.ws.mock.util.MockException;
import net.sf.sripathi.ws.mock.util.SoapUIUtil;


@XmlType(name="Operation", namespace="http://www.sripathi.sf.net/ws/mock",
		propOrder={"name","keyElement","scenarioList", "templateMap", "faultMap", "defaultGeneratedReq", "defaultGeneratedResp", "tagNames"})
public class Operation implements Serializable {

	/**
	 * generated serial id.
	 */
	private static final long serialVersionUID = 3039528424213624237L;
	/**
	 * Constant for default scenario.
	 */
	public static final String DEFAULT_SCE_KEY = "DEFAULT_SCENARIO";
	/**
	 * Default scenario response.
	 */
	public static final String DEFAULT_SCE_DES = "This is a default response. This will be returned by service when mocked response is not found.";
	/**
	 * Operation name.
	 */
	private String name;
	/**
	 * Key element for the operation.
	 */
	private String keyElement;
	/**
	 * Mocked scenario list.
	 */
	private List<Scenario> scenarioList;
	/**
	 * Template of response map.
	 */
	private HashMap<String, String> templateMap;
	/**
	 * Fault message map.
	 */
	private HashMap<String, String> faultMap;
	/**
	 * Generated request xml.
	 */
	private String defaultGeneratedReq;
	/**
	 * Generated response xml.
	 */
	private String defaultGeneratedResp;
	/**
	 * Tag names for the operation.
	 */
	private List<String> tagNames;
	/**
	 * Default constructor.
	 */
	public Operation() {
		
	}
	/**
	 * Overloaded constructor.
	 * @param name operation name.
	 */
	public Operation(String name) {
		this.name = name.trim();
	}
	/**
	 * Overloaded constructor.
	 * @param name operation name.
	 * @param wsdlUrl WSDL URL to load some details.
	 */
	public Operation(String name, String wsdlUrl) {
		this.name = name.trim();
		this.defaultGeneratedReq = SoapUIUtil.getDummyRequest(wsdlUrl, name);
		this.defaultGeneratedResp = SoapUIUtil.getDummyResponse(wsdlUrl, name);
		this.faultMap = SoapUIUtil.getDummyFaults(wsdlUrl, name);
		this.tagNames = SoapUIUtil.getRequestElements(wsdlUrl, name);
		this.addDefaultScenario(wsdlUrl);
	}
	
	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name.trim();
	}

	public String getKeyElement() {
		return keyElement;
	}

	public void setKeyElement(String keyElement) {
		this.keyElement = keyElement.trim();
	}
	
	public List<Scenario> getScenarioList() {
		if (this.scenarioList == null) 
			this.scenarioList = new ArrayList<Scenario>();
		return this.scenarioList;
	}

	public void setScenarioList(List<Scenario> scenarioList) {
		this.scenarioList = scenarioList;
	}

	public HashMap<String, String> getTemplateMap() {
		if (this.templateMap == null) {
			this.templateMap = new HashMap<String, String>();
		}
		return templateMap;
	}

	public void setTemplateMap(HashMap<String, String> templateMap) {
		this.templateMap = templateMap;
	}
	
	public HashMap<String, String> getFaultMap() {
		if (this.faultMap == null) {
			this.faultMap = new HashMap<String, String>();
		}
		return faultMap;
	}
	public void setFaultMap(HashMap<String, String> faultMap) {
		this.faultMap = faultMap;
	}
	public String getDefaultGeneratedReq() {
		return defaultGeneratedReq;
	}
	public void setDefaultGeneratedReq(String defaultGeneratedReq) {
		this.defaultGeneratedReq = defaultGeneratedReq;
	}
	public String getDefaultGeneratedResp() {
		return defaultGeneratedResp;
	}
	public void setDefaultGeneratedResp(String defaultGeneratedResp) {
		this.defaultGeneratedResp = defaultGeneratedResp;
	}
	public List<String> getTagNames() {
		if (this.tagNames == null) {
			this.tagNames = new ArrayList<String>();
		}
		return tagNames;
	}
	public void setTagNames(List<String> tagNames) {
		this.tagNames = tagNames;
	}
	
	public void addDefaultScenario(String wsdlUrl) {
		Scenario scenario = new Scenario();
		scenario.setKey(DEFAULT_SCE_KEY);
		scenario.setDescription(DEFAULT_SCE_DES);
		scenario.setResponse(SoapUIUtil.getDummyResponse(wsdlUrl, this.name));
		this.getScenarioList().add(scenario);
	}
	
	public Scenario getDefaultScenario() {
		for (Scenario scenario : this.getScenarioList()) {
			
			if (DEFAULT_SCE_KEY.equals(scenario.getKey())) {
				return scenario;
			}
		}
		
		return null;
	}
	
	public void overrideDefaultScenario(String defaultResp) {

		Scenario defaultSce = null;
		
		for (Scenario scenario : this.getScenarioList()) {
			
			if (DEFAULT_SCE_KEY.equals(scenario.getKey())) {
				defaultSce = scenario;
				break;
			}
		}
		
		if (defaultSce != null) {
			this.getScenarioList().remove(defaultSce);
			
			defaultSce.setResponse(defaultResp);
			
			this.getScenarioList().add(defaultSce);
		}
		else {
			defaultSce = new Scenario();
			defaultSce.setKey(DEFAULT_SCE_KEY);
			defaultSce.setDescription(DEFAULT_SCE_DES);
			defaultSce.setResponse(defaultResp);
			this.getScenarioList().add(defaultSce);
		}
	}
	
	public void overrideDefaultScenario(String defaultResp, int delay) {

		Scenario defaultSce = null;
		
		for (Scenario scenario : this.getScenarioList()) {
			
			if (DEFAULT_SCE_KEY.equals(scenario.getKey())) {
				defaultSce = scenario;
				break;
			}
		}
		
		if (defaultSce != null) {
			defaultSce.setResponse(defaultResp);
			defaultSce.setDelayInMilliSec(delay);
		}
		else {
			defaultSce = new Scenario();
			defaultSce.setKey(DEFAULT_SCE_KEY);
			defaultSce.setDescription(DEFAULT_SCE_DES);
			defaultSce.setResponse(defaultResp);
			defaultSce.setDelayInMilliSec(delay);
			this.getScenarioList().add(defaultSce);
		}
	}
	
	public void addScenario(String keyElementValue, String response) {
		
		String key = this.keyElement + " = " + keyElementValue;
		
		if (this.getScenario(key) != null) {
			throw new MockException("Scenario Already Present for "
					+ key);
		}
		
		Scenario scenario = new Scenario(key, null, response);
		
		this.getScenarioList().add(scenario);		
	}
	
	public void addScenario(String keyElementValue, String response, int delay) {
		
		String key = this.keyElement + " = " + keyElementValue;
		
		if (this.getScenario(key) != null) {
			throw new MockException("Scenario Already Present for "
					+ key);
		}
		
		Scenario scenario = new Scenario(key, null, response);
		scenario.setDelayInMilliSec(delay);
		
		this.getScenarioList().add(scenario);		
	}
	
	public void updateScenario(String key, String response) {
		
		Scenario scenario = this.getScenario(key);
		if (scenario == null) {
			throw new MockException("Scenario not found for "
					+ key);
		}
		scenario.setResponse(response);
	}
	
	public void updateScenario(String key, String response, String keyElementValue) {
		
		Scenario scenario = this.getScenario(key);
		if (scenario == null) {
			throw new MockException("Scenario not found for "
					+ key);
		}
		Scenario newScenario = new Scenario();
		newScenario.setKey(this.keyElement + " = " + keyElementValue);
		newScenario.setResponse(response);
		this.getScenarioList().remove(scenario);
		this.getScenarioList().add(newScenario);
	}
	
	public void updateScenario(String key, String response, int delay, String keyElementValue) {
		
		Scenario scenario = this.getScenario(key);
		if (scenario == null) {
			throw new MockException("Scenario not found for "
					+ key);
		}
		Scenario newScenario = new Scenario();
		newScenario.setKey(this.keyElement + " = " + keyElementValue);
		newScenario.setResponse(response);
		newScenario.setDelayInMilliSec(delay);
		this.getScenarioList().remove(scenario);
		this.getScenarioList().add(newScenario);
	}
	
	public void updateScenario(String key, String response, int delay) {
		
		Scenario scenario = this.getScenario(key);
		if (scenario == null) {
			throw new MockException("Scenario not found for "
					+ key);
		}
		scenario.setResponse(response);
		scenario.setDelayInMilliSec(delay);
	}
	
	public Scenario getScenario(String key) {
		
		for (Scenario scenario : this.getScenarioList()) {
			if (scenario.getKey().equals(key)) {
				return scenario;
			}
		}
		
		return null;
	}

	public Scenario getScenarioForKeyElementValue(String keyElementValue) {
		
		String key = this.keyElement + " = " + keyElementValue;
		
		for (Scenario scenario : this.getScenarioList()) {
			if (scenario.getKey().equals(key)) {
				return scenario;
			}
		}
		
		return null;
	}
	
	public void deleteScenario(String key) {
		
		Scenario scenario = this.getScenario(key);
		
		if (scenario == null) {
			throw new MockException("Scenario not found");
		}
		
		this.getScenarioList().remove(scenario);
	}
	
	public void updateKeyElement(String keyElement) {
		
		List<Scenario> newScenarioList = new ArrayList<Scenario>();
		try{
		for (Scenario scenario : this.scenarioList) {
			
			if (DEFAULT_SCE_KEY.equals(scenario.getKey())) {
				newScenarioList.add(scenario); 
				continue;
			}
			
			Scenario newScenario = new Scenario();
			newScenario.setKey(keyElement + scenario.getKey().substring(this.keyElement.length()));
			//newScenario.setKey(scenario.getKey().replaceFirst(this.keyElement, keyElement));
			newScenario.setResponse(scenario.getResponse());
			newScenario.setDescription(scenario.getDescription());
			newScenarioList.add(newScenario);
		}
		}catch (Exception e) {
			e.printStackTrace();
		}
		this.setKeyElement(keyElement);
		this.setScenarioList(newScenarioList);
		
	}

	public void addTemplate(String name, String template) {
		if (this.templateMap == null) {
			this.templateMap = new HashMap<String, String>();
		}
		this.templateMap.put(name, template);
	}

	public void deleteTemplate(String name) {
		if (this.templateMap == null) {
			this.templateMap = new HashMap<String, String>();
		}
		this.templateMap.remove(name);
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
	    
	    retValue = "Operation ( "
	        + super.toString() + TAB
	        + "name = " + this.name + TAB
	        + "keyElement = " + this.keyElement + TAB
	        + "scenarioList = " + this.scenarioList + TAB
	        + "templateMap = " + this.templateMap + TAB
	        + " )";
	
	    return retValue;
	}


}
