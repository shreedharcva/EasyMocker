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
import java.io.InputStream;
import java.util.Enumeration;
import java.util.Set;
import java.util.TreeSet;
import java.util.zip.ZipEntry;
import java.util.zip.ZipFile;

import org.apache.commons.io.IOUtils;

public class FileUtil {

	private FileUtil() {
		
	}
	
	public static boolean deleteFolder(String name) {
		
		File file = new File(name);
		
		if (file.isDirectory()) {
			deleteFiles(file);
		}
		
		return file.delete();
	}
	
	private static void deleteFiles(File file) {
		if (file.listFiles() != null) {
			for (File child : file.listFiles()) {
			
				if (child.isDirectory()) {
					deleteFiles(child);
					child.delete();
				} else {
					child.delete();
				}
			}
		}
	}

	public static void createFilesAndFolder(String root, ZipFile zip) {
		
		@SuppressWarnings("unchecked")
		Enumeration<ZipEntry> entries = (Enumeration<ZipEntry>) zip.entries();
		Set<String> files = new TreeSet<String>(); 
		while (entries.hasMoreElements()) {
			ZipEntry entry = entries.nextElement();
			
			if (entry.getName().toLowerCase().endsWith(".wsdl") || entry.getName().toLowerCase().endsWith(".xsd"))
				files.add(entry.getName());
		}
		
		File rootFolder = new File(root);
		if (!rootFolder.exists()) {
			throw new MockException("Unable to create file - " + root);
		}
		
		for (String fileStr : files) {
			
			String folder = root;
			
			String [] split = fileStr.split("/");

			if (split.length > 1) {

				for (int i=0; i<split.length-1; i++) {
					
					folder = folder + "/" + split[i];
					File f = new File(folder);
					if (!f.exists()) {
						f.mkdir();
					}
				}
			}
			
			File file = new File(folder + "/" + split[split.length-1]);
			FileOutputStream fos = null;
			InputStream zipStream = null;
			try {
				fos = new FileOutputStream(file);
				zipStream = zip.getInputStream(zip.getEntry(fileStr));
				fos.write(IOUtils.toByteArray(zipStream));
			} catch (Exception e) {
				throw new MockException("Unable to create file - " + fileStr);
			} finally {
				try {fos.close();}catch (Exception e) {}
				try {zipStream.close();}catch (Exception e) {}
			}
		}
	}
}
