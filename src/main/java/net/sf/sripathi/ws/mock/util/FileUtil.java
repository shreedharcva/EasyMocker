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
}
