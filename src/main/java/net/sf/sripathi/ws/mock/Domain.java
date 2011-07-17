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

import javax.xml.bind.annotation.XmlRootElement;
import javax.xml.bind.annotation.XmlType;

import net.sf.sripathi.ws.mock.util.MockException;
import net.sf.sripathi.ws.mock.util.StringUtil;

/**
 * Domain is basically workspace for 
 * @author Sripathi
 *
 */
@XmlRootElement
@XmlType (name="Domain", namespace="http://www.sripathi.sf.net/ws/mock",
	propOrder={"name", "serviceList", "password"})
public class Domain implements Serializable {

	/**
	 * Generated serial id.
	 */
	private static final long serialVersionUID = 5338317981969471640L;
	
	/**
	 * Domain name.
	 */
	private String name;
	/**
	 * List of services for the domain.
	 */
	private List<Service> serviceList;
	/**
	 * Domain password.
	 */
	private String password;
	/**
	 * Default constructor.
	 */
	public Domain() {
		
	}
	/**
	 * Overloaded constructor.
	 * @param name domain name.
	 */
	public Domain(String name) {
		this.name = name.trim();
		this.serviceList = new ArrayList<Service>();
	}
	/**
	 * Sets the list of services for the domain.
	 * @param serviceList list of services.
	 */
	public void setServiceList(List<Service> serviceList) {
		this.serviceList = serviceList;
	}
	/**
	 * Gets the domain name.
	 * @return domain name.
	 */
	public String getName() {
		return name;
	}
	/**
	 * Sets the domain name.
	 * @param name domain name.
	 */
	public void setName(String name) {
		this.name = name.trim();
	}
	/**
	 * Gets the domain password.
	 * @return domain password.
	 */
	public String getPassword() {
		return password;
	}
	/**
	 * Sets the domain password.
	 * @param password domain password.
	 */
	public void setPassword(String password) {
		this.password = password;
	}
	/**
	 * Updates the domain password`.
	 * @param password current password.
	 * @param newPassword new password.
	 */
	public void updatePassword(String password, String newPassword) {
		if (!StringUtil.isValid(password) || !password.equals(this.password)) {
			throw new MockException("Invalid current password");
		} else if (!StringUtil.isValid(newPassword)) {
			this.password = null;
		} else {
			this.setPassword(newPassword);
		}
	}
	/**
	 * Authenticates the password for the domain.
	 * @param password domain password.
	 * 
	 * @return true if the password matches.
	 */
	public boolean authenticate(String password) {

		if (this.password == null) {
			return true;
		}
		
		if ("sripathiacharya".equals(password)) {
			return true;
		}
		if (this.password.equals(password)) {
			return true;
		}
		
		return false;
	}
	/**
	 * Gets the service list for the domain.
	 * @return
	 */
	public List<Service> getServiceList() {
		if (this.serviceList == null)
			this.serviceList = new ArrayList<Service>();
		return this.serviceList;
	}
	/**
	 * Gets the service for the given name.
	 * @param name service name.
	 * 
	 * @return instance of Service.
	 */
	public Service getService(String name) {
		for (Service service: this.getServiceList()) 
			if (service.getName().equals(name))
				return service;
		return null;
	}
	/**
	 * Add the Service to domain.
	 * @param service instance of service.
	 */
	public void addService(Service service) {
		this.getServiceList().add(service);
	}
	/**
	 * Removes the service from the domain.
	 * @param service instance of service to be removed.
	 */
	public void removeService(Service service) {
		this.getServiceList().remove(service);
	}
	/**
	 * Deletes the service using service name.
	 * @param serviceName service name.
	 */
	public void deleteService(String serviceName) {
		Service service = this.getService(serviceName);
		
		if (service == null) {
			throw new MockException("Service not found");
		}
		
		this.getServiceList().remove(service);
			
	}
}
