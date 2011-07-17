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

public class MockException extends RuntimeException {

	/**
	 * 
	 */
	private static final long serialVersionUID = -6134253185981847980L;
	private String reason;
	
	public MockException() {
	
	}
	
	public MockException(String reason) {
		this.reason = reason;
	}
	
	public String getMessage() {
		return reason;
	}
}
