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

import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.ObjectInputStream;
import java.io.ObjectOutputStream;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Hashtable;
import java.util.List;
import java.util.Map;

import javax.xml.bind.JAXBContext;
import javax.xml.bind.Marshaller;
import javax.xml.bind.Unmarshaller;

import net.sf.sripathi.ws.mock.util.Folder;

/**
 * Factory class to maintain domains.
 * 
 * @author Sripathi
 *
 */
public class DomainFactory {

	/**
	 * Self instance.
	 */
	private static DomainFactory me = new DomainFactory();
	
	/**
	 * Working directory location.
	 */
	private String workingDir = "";
	
	/**
	 * Map hold the created domain instances.
	 */
	private Map<String, Domain> domainMap = null;
	
	/**
	 * Private constructor.
	 */
	private DomainFactory() {
		
	}
	/**
	 * Factory method to get its instance.
	 * @return instance of this class.
	 */
	public static DomainFactory getInstance() {
		return me;
	}
	
	/**
	 * Sets the working directory for the application.
	 * @param workingDir string represnting the working directory.
	 */
	@SuppressWarnings("unchecked")
	public void setWorkingDir(String workingDir) {
		this.workingDir = workingDir;
		
        try
        {
            FileInputStream fis = new FileInputStream(new File(workingDir + "/mockconf.dat"));
            ObjectInputStream ois = new ObjectInputStream(fis);
            this.domainMap = (Map<String, Domain>) ois.readObject();
            fis.close();
            ois.close();
        }
        catch (FileNotFoundException fn) {
        	System.out.println("File " + workingDir + "/mockconf.dat not found");
        	this.domainMap = new Hashtable<String, Domain>();
        	save();
        }
        catch(Exception fe)
        {
        	fe.printStackTrace();
        	this.domainMap = new Hashtable<String, Domain>();
        }
        
        if (domainMap.get("default") == null) 
        	domainMap.put("default", new Domain("default"));
	}
	/**
	 * Saves the domains to file.
	 */
	public void save() {
        try
        {
        	FileOutputStream fos = new FileOutputStream(new File(workingDir + "/mockconf.dat"));
        	ObjectOutputStream oos = new ObjectOutputStream(fos);
            oos.writeObject(domainMap);
            fos.close();
            oos.close();
        }
        catch (Exception e) {
        	e.printStackTrace();
        }
	}
	/**
	 * Gets the domain using domain name.
	 * @param domainName domain name string.
	 * @return instance of domain.
	 */
	public Domain getDomain(String domainName) {
		return this.domainMap.get(domainName);
	}
	/**
	 * Gets the all domains.
	 * @return list of domains.
	 */
	public Collection<String> getDomains() {
		return this.domainMap.keySet();
	}
	/**
	 * Creates a new domains.
	 * @param name domain name.
	 * @return instance of domain.
	 */
	public Domain createDomain(String name) {
		Domain domain = new Domain(name);
		this.domainMap.put(name, domain);
		return domain;
	}
	/**
	 * Saves a particular domain.
	 * @param domain
	 */
	public void updateDomain(Domain domain) {
		this.save();
	}
	/**
	 * Removes the domain.
	 * @param domain domain instance.
	 */
	public void removeDomain(Domain domain) {
		this.domainMap.remove(domain.getName());
	}
	/**
	 * Gets the domains which has password.
	 * @return list of domains.
	 */
	public Collection<String> getSecureDomains() {
		
		List<String> domainNames = new ArrayList<String>();
		
		for (Domain domain : this.domainMap.values()) {
			if (domain.getPassword() != null) {
				domainNames.add(domain.getName());
			}
		}
		
		return domainNames;
	}
	
	/**
	 * Gets the domain specific folder.
	 * 
	 * @param work
	 * @return
	 */
	public Folder getDomainFileFolder(Domain domain) {
		
		return Folder.getInstance(workingDir + "/" + domain.getName());
	}
	/**
	 * Exports the domain into XML file.
	 * @param domainName domain name.
	 * @return file name of the XML.
	 * @throws Exception in case of errors.
	 */
	public String exportDomain(String domainName)
		throws Exception
	{

		Domain domain = this.domainMap.get(domainName);
		
		JAXBContext contx = 
			JAXBContext.newInstance(Domain.class, Service.class, Operation.class, Scenario.class);
		Marshaller mar = contx.createMarshaller();
		
		File file = new File(workingDir + "/" + domainName + ".xml");
		file.delete();
		file.createNewFile();
		
		mar.marshal(domain, new FileOutputStream(file));
		
		return workingDir + "/" + domainName + ".xml";
	}
	/**
	 * Imports the domain from XML file.
	 * @param file XML file of the domain.
	 * @param merge a flag to represent domain merger.
	 * @return Domain instance.
	 * @throws Exception in case of error.
	 */
	public Domain importDomain(File file, boolean merge) throws Exception {
		
		JAXBContext contx = 
			JAXBContext.newInstance(Domain.class, Service.class, Operation.class, Scenario.class);
		Unmarshaller unmar = contx.createUnmarshaller();
		
		Domain domain = (Domain) unmar.unmarshal(file);
		
		Domain oldDomain = getDomain(domain.getName());
		
		if (oldDomain != null) {
			
			if (!merge) {
				return null;
			}
			
			//Merge service
			for (Service oldService : oldDomain.getServiceList()) {
				
				Service newService = domain.getService(oldService.getName());
				
				if (newService != null) {
					//Merge operation
					
					for (Operation oldOperation : oldService.getOperationList()) {
						
						Operation newOperartion = newService.getOperation(oldOperation.getName());
						
						if (newOperartion != null){
							
							if (newOperartion.getKeyElement()==null 
								|| !newOperartion.getKeyElement().equals(oldOperation.getKeyElement()))
							{
								continue;
							}
							
							//Merge scenarios
							for (Scenario oldScenario : oldOperation.getScenarioList()) {
								Scenario newScenario = newOperartion.getScenario(oldScenario.getKey());
								if (newScenario == null) {
									newOperartion.getScenarioList().add(oldScenario);
								}
							}
							//Merge templates
							for (String key : oldOperation.getTemplateMap().keySet()) {
								
								if (newOperartion.getTemplateMap().get(key) == null) {
									if (newOperartion.getTemplateMap().size() < 3) {
										newOperartion.getTemplateMap().put(key, oldOperation.getTemplateMap().get(key));
									}
								}
							}
						}
						else {
							newService.getOperationList().add(oldOperation);
						}
					}
				}
				else {
					domain.addService(oldService);
				}
			}
		}
		
		if (oldDomain != null) {
			this.domainMap.put(domain.getName(), domain);
		}
		else {
			this.domainMap.put(domain.getName(), domain);
		}
		
		return domain;
	}
}
