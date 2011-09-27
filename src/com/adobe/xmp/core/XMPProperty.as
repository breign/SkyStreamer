// Adobe Systems Incorporated, 2009
// Copyright 2009, Adobe Systems Incorporated. All rights reserved.
// Redistribution and use in source and binary forms, with or without modification, 
// are permitted provided that the following conditions are met:
//
// 1. Redistributions of source code must retain the above copyright notice, 
//    this list of conditions and the following disclaimer.
//
// 2. Redistributions in binary form must reproduce the above copyright notice, 
//    this list of conditions and the following disclaimer in the documentation and/or 
//    other materials provided with the distribution.
//
// 3. Neither the name of Adobe nor the names of its contributors may be used to endorse or 
//    promote products derived from this software without specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND 
// ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF 
// MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT 
// SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, 
// SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT 
// OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
// HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, 
// OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, 
// EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

package com.adobe.xmp.core
{
	import flash.utils.flash_proxy;
	
	use namespace flash_proxy; 

	/**
	 * Represents a simple property node in an XMP data tree contained in
	 * an <code>XMPMeta</code> object. A simple property can be a leaf
	 * node within a complex property (a struct or array).
 	 */
	public class XMPProperty extends XMPNode
	{
		/** the xmp value is always a string, but only simple properties have values,
		 *  for arrays and structs the value has to be <code>null</null>. */ 
		private var _value: String;
		/** True if this property is a URI.
		 *  A URI property is serialized as
		 *  &lt;ns:simpleUri rdf:resource="http://simpleUri"/&gt; */
		public var uri: Boolean = false;
		
		/** 
		 * Creates an <code>XMPProperty</code> object.
		 *	@param qname The fully-qualified name of this property. Can be null.
		 * 	@param value The value of this property. Can be null.
		 *  @return The new object.
		 */
		public function XMPProperty(qname: QName = null, value: * = null)
		{
			// special treatment of Boolean values
			this.value = value;
			
			super(qname);
		}


		/**
		 * Factory method to create a simple property as URI.
		 * @param uriValue The URI string.
		 * @return The new object.
		 */
		public static function newURI(uriValue: String): XMPProperty
		{
			var prop: XMPProperty = new XMPProperty(null, uriValue);
			prop.uri = true;
			
			return prop;
		}

		/**
		 * Retrieves the value of this property.
		 * @return The value as a string.
		 */
		public function get value(): String
		{
			return _value;
		}

		/**
		 * Sets the value of this property.
		 * @param nodeValue The value as a String, or as a Boolean or Date
		 * 		that is converted to a String.
		 */		
		public function set value(nodeValue: *): void
		{
			if (nodeValue is Boolean)
			{
				// make sure that boolean values start with an uppercase letter
				_value = nodeValue ? "True" : "False";
			}
			else if (nodeValue is Date)
			{
				// convert a Date into an ISO 8601 string
				_value = XMPDateTime.convertDateToISO8601(nodeValue);
			}
			else
			{
				_value = nodeValue;
			}
		}


		/**
		 * Retrieves the property value and converts it to a Boolean.
		 * @return The Boolean value.
		 */
		public function toBoolean(): Boolean
		{
			var bool: String = _value != null ? _value.toLowerCase() : null;
			return bool == "true" ||
				   bool == "on"  ||
				   bool == "yes"  ||
				   bool == "1";
		}		


		/**
		 * Retrieves the property value and converts it to an Integer.
		 * @return The Integer value.
		 */
		public function toInteger(): int
		{
			return parseInt(_value);
		}		


		/**
		 * Retrieves the property value and converts it to a Float.
		 * @return The Float value.
		 */
		public function toFloat(): Number
		{
			return parseFloat(_value);
		}		
		
		/**
		 * Retrieves the property value and converts it to a Date.
		 * @return The Date value.
		 */
		
		public function toDate(): Date
		{
			return XMPDateTime.convertISO8601ToDate(_value);	
		}
		
		
		/** 
		 * Used internally to prevent iteration; this object represents a simple property
		 * with no children.
		 */
		override flash_proxy function nextNameIndex(index: int): int 
		{
			return 0;
		}
		
		/**
		 * Creates a symbolic string representation of this node.
		 * @return The string.
		 */		
		override public function toString(): String
		{
			return _value;
		}
		
		
		/**
		 * Copies the contents of this object into a new object; the new object contains no references 
		 * to the object from which it is cloned.
		 * @return A new <code>XMPProperty</code> object containing the same data as this one.
		 */
		override public function clone(): *
		{
			var clone:XMPProperty = super.clone();		
			clone._value = this._value;
			return clone;		
		} 
	}
}