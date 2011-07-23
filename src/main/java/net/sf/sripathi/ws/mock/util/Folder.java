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

import java.io.File;
import java.io.FileOutputStream;
import java.util.Enumeration;
import java.util.HashMap;
import java.util.Map;
import java.util.Set;
import java.util.TreeSet;
import java.util.zip.ZipEntry;
import java.util.zip.ZipFile;

import org.apache.commons.io.IOUtils;

/**
 * Contains the files and sub folder information.
 * 
 * @author Sripathi
 *
 */
public class Folder implements Comparable<Folder> {

	private static Map<String, Folder> folderMap;
	private static Set<String> fileSet;
	
	/**
	 * Folder absolute path
	 */
	private String path;
	
	/**
	 * Local name of the folder
	 */
	private String name;
	
	/**
	 * Sub folders under the folder.
	 */
	private Set<Folder> subFolders = new TreeSet<Folder>();
	
	/**
	 * Files under the folder.
	 */
	private Set<String> files = new TreeSet<String>();  
	
	/**
	 * Constructor.
	 * 
	 * @param path absolute path of the folder.
	 * @param file folder file.
	 */
	private Folder(String path, File file) {
		this.path = path;
		this.name = file.getName();
		
		try {
			File [] subFiles = file.listFiles();
			
			if (subFiles != null) {
				for (File subFile : subFiles) {
					
					if (subFile.isFile()) {
						files.add(subFile.getName());
						fileSet.add(this.path + "/" + subFile.getName());
					} else if (subFile.isDirectory()) {
						subFolders.add(new Folder(path + "/" + subFile.getName(), subFile));
					}
				}
			}
			
			Folder.folderMap.put(path, this);
			
		} catch (Exception e) {
			throw new MockException("Unable to read dir " + path + " make sure access is set correctly");
		}
	}
	
	/**
	 * Gets the folder information for the path provided.
	 * If the folder is not present creates a new folder.
	 * 
	 * @param path folder path string.
	 * 
	 * @return instance of Folder class.
	 */
	public static Folder getInstance(String path) {
		
		Folder folder = null;
		Folder.folderMap = new HashMap<String, Folder>();
		Folder.fileSet = new TreeSet<String>();
		
		try {
			File file = new File(path);
			
			if (!file.exists()) {
				file.mkdir();
			}
			
			if (!file.isDirectory() && !file.canRead() && !file.canWrite()) {
				throw new MockException("Unable to read dir " + path + " make sure access is set correctly");
			}
			
			//Get root and sub directories
			folder = new Folder(path, file);
			
			Folder.folderMap.put(path, folder);
			
		} catch (Exception e) {
			throw new MockException("Unable to read dir " + path + " make sure access is set correctly");
		}
		
		return folder;
	}
	
	/**
	 * Creates a file under the folder.
	 * 
	 * @param name name of the file.
	 * @return instance of File.
	 */
	public File createFile(String name) {
		
		String fName = this.path + "/" + name;
		File file = new File(fName);

		try {
			file.createNewFile();
		} catch (Exception e) {
			throw new MockException("Unable to create file " + fName);
		}
		
		this.files.add(name);
		fileSet.add(file.getAbsolutePath());
		return file;
	}
	
	/**
	 * Creates a sub folder under the folder.
	 * @param name name of the sub folder.
	 * @return instance of the Folder.
	 */
	public Folder createSubFolder(String name) {
		
		String fName = this.path + "/" + name;
		File file = new File(fName);
		try {
			file.mkdir();
		} catch (Exception e) {
			throw new MockException("Unable to create folder " + fName);
		}
		
		Folder folder = new Folder(fName, file);
		this.subFolders.add(folder);
		
		return folder;
	}
	
	public Set<String> checkDuplicateFiles(ZipFile zip) {
		
		Set<String> dups = new TreeSet<String>();
		
		@SuppressWarnings("unchecked")
		Enumeration<ZipEntry> entries = (Enumeration<ZipEntry>) zip.entries();
		while (entries.hasMoreElements()) {
			ZipEntry entry = entries.nextElement();
			if (fileSet.contains(this.path + "/" + entry.getName()))
				dups.add(entry.getName());
		}
		
		return dups;
		
	}
	
	public void createFilesAndFolder(ZipFile zip) {
		
		@SuppressWarnings("unchecked")
		Enumeration<ZipEntry> entries = (Enumeration<ZipEntry>) zip.entries();
		Set<String> files = new TreeSet<String>(); 
		while (entries.hasMoreElements()) {
			ZipEntry entry = entries.nextElement();
			
			if (entry.getName().toLowerCase().endsWith(".wsdl") || entry.getName().toLowerCase().endsWith(".xsd"))
				files.add(entry.getName());
		}
		
		for (String fileStr : files) {
			
			String [] split = fileStr.split("/");
			Folder parent = this;
			if (split.length > 1) {

				Folder sub = null;
				for (int i=0; i<split.length-1; i++) {
					
					sub = parent.getSubFolderByName(split[i]);
					if (sub == null) {
						sub = parent.createSubFolder(split[i]);
					}
					parent = sub;
				}
			}
			
			File file = parent.createFile(split[split.length-1]);
			try {
				FileOutputStream fos = new FileOutputStream(file);
				fos.write(IOUtils.toByteArray(zip.getInputStream(zip.getEntry(fileStr))));
			} catch (Exception e) {
				throw new MockException("Unable to create file - " + fileStr);
			}
		}
	}
	
	private Folder getSubFolderByName(String name) {
		for (Folder folder : this.subFolders) {
			if (name.equalsIgnoreCase(folder.getName()))
				return folder;
		}
		return null;
	}
	
	public Folder lookupFolder(String name) {
		return Folder.folderMap.get(name);
	}

	
	public String getPath() {
		return this.path;
	}
	
	public String getName() {
		return this.name;
	}
	
	public Set<Folder> getSubFolders() {
		return subFolders;
	}

	public Set<String> getFiles() {
		return files;
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
	    
	    retValue = "Folder ( "
	        + super.toString() + TAB
	        + "path = " + this.path + TAB
	        + "subFolders = " + this.subFolders + TAB
	        + "files = " + this.files + TAB
	        + " )";
	
	    return retValue;
	}

	@Override
	public int compareTo(Folder o) {
		return this.path.compareTo(o.path);
	}
}
