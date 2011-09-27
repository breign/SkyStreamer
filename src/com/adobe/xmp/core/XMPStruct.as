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
	 * Represents a structure node in the data tree contained in an <code>XMPMeta</code> object.
	 * This type of node represents a complex property of type "struct". It does not have a value, 
	 * but contains other nodes ("fields") that can be nested complex properties or simple properties 
	 * with values.
	 */
	public class XMPStruct extends XMPNode
	{
		/**
		 * Creates an <code>XMPStruct</code> object. 
		 * @param qname The fully-qualified name of this property. Can be null.
		 * @return The new object.
		 */
		public function XMPStruct(qname: QName = null) 
		{
			super(qname);
		}
		
		
		/**
		 * Used internally to retrieve a named property from the data tree. 
		 * Do not use this method directly; it is invoked when you request a
		 * property using the "." or "[]" operators.
		 * Finds and returns an existing item in this structure that matches the given name. If none is
		 * found, creates an implicit node if possible. If the name cannot be resolved to a
		 * valid structure, throws an exception. 
		 * @param name The fully-qualified name of the property.
		 * @return The found or created node object.
		 */
		override flash_proxy function getProperty(name: *): *
		{
			if (name is QName  &&  (name as QName).uri != "")
			{
				var node: XMPNode = children.getItem(name);
				if (node != null)
				{
					return node;
				}
				else
				{
					return createImplicitStruct(name);
				}
			}
			else if (!isNaN(parseInt(name)))
			{
				// implicit array creation, happens only when index resolves to number 1.
				// Switch this node from struct to default array
				if (!implicit)
				{
					throw new XMPException ("A struct cannot contain array items.",
						XMPError.BADPARAM);
				}
				else if (parseInt(name) != 1)
				{
					throw new XMPException (
						"Array index is out of bounds only [1..length + 1] is allowed.",
						XMPError.BADINDEX);
				}

				return createImplicitArrayItem(_qname);
			}
			else if (name == "last()")
			{
				if (implicit)
				{
					return createImplicitArrayItem(_qname);
				}
				else
				{
					throw new XMPException ("A struct does not support the last() funtion.", 
						XMPError.BADPARAM);
				}
			}  
			else
			{
				throw new XMPException ("Properties need to be provided with " +
					"namespace in the form 'namespace::property'.", XMPError.BADSYNTAX);
			}
		}
		
		
		/**
		 * Used internally; do not call directly.
		 * Catches all calls to undefined methods of this object (with their arguments).
		 * Array method calls to implicit struct nodes convert them to arrays and insert an
		 * implicit item to the new array. 
		 */
		override flash_proxy function callProperty(name:*, ... args):* 
		{
			if (implicit)
			{
				var array: XMPArray;
				if (name == "append")
				{
					if (args.length < 1  ||  args.length > 2)
					{
						throw new XMPException("" + 
							"Wrong parameters for XMPArray#append(*, arrayType: int = 0)",
							XMPError.BADPARAM); 
					}
					
					array = createImplicitArray(_qname, this.parent);
					if (args.length == 2)
					{
						// when an array is created implicitly its possible to add the type
						// e.g. xmp.my::implicitArray.append("one", XMPArray.SEQ)
						array.setType(args[1]);
					}
					return array.append(args[0]);
				} 
				else if (name == "insert")
				{
					if (args.length < 2  ||  args.length > 3)
					{
						throw new XMPException("" + 
							"Wrong parameters for XMPArray#insert(index: int, *, arrayType: int = 0)",
							XMPError.BADPARAM); 
					}
					array = createImplicitArray(_qname, this.parent);
					if (args.length == 3)
					{
						// when an array is created implicitly its possible to add the type
						// e.g. xmp.my::implicitArray.append("one", XMPArray.SEQ)
						array.setType(args[2]);
					}
					return array.insert(args[0], args[1]);
				}
				else if (name == "remove")
				{
					return null;
				}
			}
			
			return super.callProperty(name, args);
		}	
		
		
		/**
		 * Used internally to set a named property in the data tree. 
		 * Do not use this method directly; it is invoked when you request a
		 * property using the "." or "[]" operators.
		 * If the specified property exists, its value is replaced, or, if the new value is
		 * null, it is removed. If the child node does not exist, it is implicitly created and
		 * given the new value.
		 * @param name The fully-qualified name of the property, as a <code>QName</code> or String.
		 * @param value The new value or node to be added to this structure.
		 */
		override flash_proxy function setProperty(name:*, value:*): void
		{
			if (name is QName  &&  (name as QName).uri != "")
			{
				var existingNode: XMPNode = children.getItem(name);
				
				if (value == null)
				{
					// delete the property
					children.removeItem(name);
				}
				else if (value is XMPNode)
				{
					// put the QName the node is assigned to, into the node
					// add this node as parent
					// (can be null or different before).
					(value as XMPNode)._qname = name; 

					// if node already exists it will be overwritten
					addOrReplaceNode(existingNode, value);
					acceptImplicitNodes();	
					
				}
				else
				{
					if (existingNode is XMPProperty)
					{
						// node with the same name and type already exists, just change value
						(existingNode as XMPProperty).value = value;
					}						
					else 
					{
						var newNode: XMPProperty = new XMPProperty(name, value);
						addOrReplaceNode(existingNode, newNode);
					}
					acceptImplicitNodes();
				}
			}
			else if (!isNaN(parseInt(name)))
			{
				// implicit array creation, happens only when index resolves to number 1.
				// Switch this node from struct to default array
				if (!implicit)
				{
					throw new XMPException ("A struct cannot contain array items.", 
						XMPError.BADPARAM);
				}
				else if (parseInt(name) != 1)
				{
					throw new XMPException (
						"Array index is out of bounds only [1..length + 1] is allowed.",
							XMPError.BADINDEX);
				}
				
				createImplicitArray(_qname, this.parent)
					.setProperty(name, value);
			}
			else if (name == "last()")
			{
				if (implicit)
				{
					createImplicitArray(qname, this.parent)
						.setProperty(name, value);
				}
				else
				{
					throw new XMPException ("A struct does not support the last() funtion.", 
						XMPError.BADPARAM);
				}
			}  
			else
			{
				throw new XMPException ("Properties need to be provided " +
					"with namespace in the form 'namespace::property'.", XMPError.BADSYNTAX);
			}
		}
		
		/** 
		 * Used internally. Reports whether this object represents an attribute.
		 * @return Always false.
		 */
		override flash_proxy function isAttribute(name:*): Boolean
		{
			return false;
		}		
		

				
		/**
		 * Used internally to evaluate the <code>delete</code> operator, 
		 * removing a child item from this structure. Do not call directly.
		 * @param name The fully-qualified name of the property, as a <code>QName</code> or String.
		 * @return True if an item has been deleted.
		 */
		override flash_proxy function deleteProperty(name: *): Boolean
		{
			return children.removeItem(name) >= 0;	
		}
		
		
		/**
		 * Used internally to retrieve the next item in the iteration of this 
		 * structure's node tree. Do not call directly.
		 * @param index. The 1-based index.
		 * @return The name of the node at the given index.
		 */
		override flash_proxy function nextName(index: int): String
		{
			var xmpNode: XMPNode = children.getItemAt(index - 1);
			if (xmpNode != null)
			{
				return xmpNode.qname.toString();
			}
			else
			{
				return "";
			}	
		} 
		
		
		/**
		 * If this structure is implicit, converts it to a language-alternatives array to provide
		 * access to localized text values.
		 * 
		 * @return An AltTextFacade object, or throws an exception if the structure is not implicit.
		 */
		public function get lang(): AltTextFacade
		{
			if (implicit)
			{
				// convert implicit struct to implicit alt-text array
				// create implicit alt-text array and return the language interface
				var altText: XMPArray = createImplicitArray(qname, this.parent);
				// altText.setType(XMPArray.ALTTEXT);
				altText.setType(XMPArray.ALT);
				return altText.lang;
			}
			else
			{
				throw new XMPException (
					"The language interface is only available to Alt-Text arrays.",
					XMPError.BADSYNTAX);
			}
		}		

	
		/**
		 * Creates a symbolic string representation of this node.
		 * @return The string.
		 */		
		override public function toString(): String
		{
			if (!implicit)
			{
				return "<struct>";
			}
			else
			{
				return null;
			}	
		}
		
		/**
		 * Replaces an existing node with another, or appends the new node if it does not
		 * already exist in the child-node list.
		 * 
		 * @param existingNode A named existing node to be replaced. Can be null
		 * @param newNode A new node that either replaces the existing one with the same name
		 * 				  or is appended.
		 */ 		
		protected function addOrReplaceNode(existingNode: XMPNode, newNode: XMPNode): void
		{
			if (existingNode != null)
			{
				var index: int = children.removeItem(existingNode.qname);
				if (index < 0)
				{
					index = children.length;
				}
				children.addItemAt(newNode, index);
			}
			else
			{
				children.addItem(newNode);
			}
		}
		

		/** 
		 * Create implicit array containing one struct .
		 */
		private function createImplicitArrayItem(qname: QName): XMPStruct
		{		
			var array: XMPArray = createImplicitArray(qname, this.parent);
			var struct: XMPStruct = array.createImplicitStruct(null, array);
			return struct;
		}	
	}
}