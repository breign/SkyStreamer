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
	import flash.utils.ByteArray;
	import flash.utils.Proxy;
	import flash.utils.flash_proxy;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	
	
	/**
	 * The base class for all kinds of XMP nodes.
	 */
	public class XMPNode extends Proxy
	{
		/** the xmp node name is always a qname with namespace and localname. */ 
		internal var _qname: QName;
		/** the parent node */
		internal var _parent: XMPNode;
		/** Variable that tracks whether the struct has been created during path traversal.
		 *  In that case it has to be cleared if a call is read-only OR the set command fails. */
		internal var implicit:Boolean = false;
		/** A list containing the node's children: struct fields or array items */
		private var _children: NodeList;
		/** A node containing the node's qualifiers */
		private var _qualifier: XMPQualifier;
		
		
		/**
		 * Constructor for the node, providing an optional name. 
		 * 
		 * @param qname A fully-qualified name with which to create a named node
		 */   
		public function XMPNode(qname: QName = null) 
		{
			this._qname = qname;
		}


		/**
		 * Overwritten by inherited nodes.
		 */
		override flash_proxy function getProperty(name: *): *
		{
			throw new XMPException("Unknown property '" + name + "' requested on XMPNode.",
				XMPError.BADSYNTAX); 
		}
		
		
		/**
		 * Overwritten by inherited nodes.
		 */
		override flash_proxy function callProperty(name:*, ... args):* 
		{
			throw new XMPException("Unknown method '" + name + "' called on XMPNode.",
				XMPError.BADSYNTAX); 
		}	
			
		
		/**
		 * Overwritten by inherited nodes.
		 */
		override flash_proxy function setProperty(name:*, value:*): void
		{
			throw new XMPException("Unknown property '" + name + "' set on XMPNode.",
				XMPError.BADSYNTAX); 
		}
		
		
		/**
		 * Retrieves the next index of an iteration, in the range [1 to <code>children.length</code>]
		 * (the 0-based index plus 1).
		 * @return The next index, or 0 if there are no children to iterate OR if the interation is done. 
		 */ 
		override flash_proxy function nextNameIndex(index: int): int 
		{
			if (index == 0)
			{
				// start
				return children.length > 0 ? 
					1 : 0;
			}
			else 
			{
				return index < children.length ?
					index + 1 : 0;
			} 
		} 
		
		
		/**
		 * Retrieves the node at a given index of an iteration
		 * @param index The index, in the range [1 to <code>children.length</code>]
		 * 			(the 0-based index plus 1).
		 * @return The node, or null if the index is beyond the end of the iteration.
		 */
		override flash_proxy function nextValue(index: int): * 
		{
			var xmpNode: XMPNode = children.getItemAt(index - 1);
			if (xmpNode != null)
			{
				return xmpNode;
			}
			else
			{
				return null;
			}	
		}		


		/**
		 * Retrieves the qualifier facet of any node.
		 * @return The qualifier object.
		 */ 
		public function get qualifier(): XMPQualifier
		{
			if (_qualifier == null)
			{
				_qualifier = new XMPQualifier();
				_qualifier._parent = this;
				_qualifier.implicit = this.implicit;
			}  
			return _qualifier;
		} 


		/**
		 * Retrieves the number of complex property nodes beneath this one in the tree.
		 * For <code>XMPProperty</code> it is always 0.
		 * @return The number of struct fields or array items.
		 */
		public function get length(): int
		{
			return children.length;
		}	


		/**
		 * Reports whether this node exists. The node must have been explicitly
		 * created and not contain a null value. 
		 * @return True if the node exists. False if the node was created temporarily and
		 * 		not yet added to the data tree, or has a null value.
 		 */ 
		public function exists(): Boolean
		{
			return !implicit  &&  toString() != null;
		}

		/** Retrieves the fully qualified name of this node. 
		 * @return The name object.
		 **/
		public function get qname(): QName
		{
			return _qname;
		}


		/** Retrieves the parent of this node in the data tree. 
		 * @return The node object.
		 **/
		public function get parent(): XMPNode
		{
			return _parent;
		}
		
		
		/**
		 * Dumps a human readable representation of the node 
		 * and its children and qualifier recursively.
		 * 
		 * @param buffer the buffer to dump the node into.
		 * @parem xmp the XMP object
		 * @param usedNS array of used namespace uris in the xmp object.
		 * @param indent the current indent in the output.
		 * @param index if an array is dumped, the current array index 
		 */ 
		internal function dumpNode(buffer: ByteArray, xmp: XMPMeta, usedNS: Array, 
			indent: int, index: int = 0): void 
		{
			// write indent
			for (var i: int = 0; i < indent; i++)
			{
				buffer.writeUTFBytes('\t');
			}
		
			// render Node
			if (_parent is XMPArray)
			{
				buffer.writeUTFBytes('[' + index + ']');
			}
			else if (_qname != null)
			{
				if (_parent is XMPQualifier)
				{
					// write qualifier indicator
					buffer.writeUTFBytes("?");
				}
				
				var prefix: String = (xmp as XMPMeta).getPrefix(_qname.uri);
				buffer.writeUTFBytes(prefix + ":" + _qname.localName);
				
				var existing: Boolean = false;
				for each (var ns: Object in usedNS)
				{
					existing ||= ns.pre == prefix;
				}
				if (!existing)
				{
					usedNS.push({pre: prefix, uri: _qname.uri});
				}	
			}
			else
			{
				buffer.writeUTFBytes("<QName not set>");
			}
			
			if (this is XMPProperty)
			{
				if ((this as XMPProperty).uri)
				{
					// URI marker
					buffer.writeUTFBytes(" (URI)"); 
				}
				buffer.writeUTFBytes(" = " + (this as XMPProperty).value + "\n");
			}
			else
			{
				buffer.writeUTFBytes(" " + toString() + "\n"); 
			}
			
			// render qualifier
			if (_qualifier != null)
			{
				_qualifier.dumpNode(buffer, xmp, usedNS, indent + 1);
			}
			
			// render children
			for (var j: int = 0; j < children.length; j++)
			{
				var node: XMPNode = children.getItemAt(j);
				node.dumpNode(buffer, xmp, usedNS, indent + 1, j + 1);
			}
		}
		
		
		/**
		 * @return Creates and returns the list of child nodes.
		 */
		internal function get children(): NodeList
		{
			if (_children == null)
			{
				_children = new NodeList(this);
			}  
			return _children;
		}
		
		
		/**
		 * Add implicit struct node.
		 * It is flagged with the "implicit" tag and is linked to its parent node in the XMP tree.
		 * The node is NOT added as child of the parent node yet. 
		 * <em>Note:</em> Implicit struct nodes return <code>null</null> when queried for a value
		 * (pretending they do not exist). 
		 */
		internal function createImplicitStruct(qname: QName = null, parent: XMPNode = null): XMPStruct
		{
			var struct: XMPStruct = new XMPStruct(qname);
			struct.implicit = true;
			struct._parent = parent != null ? parent: this;
			return struct;
		} 


		/**
		 * Add implicit array node.
		 * It is flagged with the "implicit" tag and is linked to its parent node in the XMP tree.
		 * The node is NOT added as child of the parent node yet. 
		 * <em>Note:</em> Implicit struct nodes return <code>null</null> when queried for a value
		 * (pretending they do not exist). 
		 */
		internal function createImplicitArray(qname: QName = null, parent: XMPNode = null): XMPArray
		{
			var array: XMPArray = XMPArray.newBag(qname);
			array.implicit = true;
			array._parent = parent != null ? parent : this;
			return array;
		} 
		

		/**
		 * Adds the implicit nodes to their parent nodes, 
		 * when the complete operation has been successful.
		 */
		internal function acceptImplicitNodes(): void
		{
			if (implicit  &&  _parent != null)
			{
				_parent.acceptImplicitNodes();
				_parent.children.addItem(this);
			}		
			implicit = false;
		}


		/**
		 * Helper to create a (named) node from an unknown value.
		 */
		protected function createNodeFromValue(qname: QName, value: *, orginalIndex: int = 0): XMPNode
		{
			if (value is XMPNode)
			{
				// attach QName to the node
				(value as XMPNode)._qname = qname; 
			}
			else if (value == null)
			{
				// do not create an XMPNode
			}
			else
			{
				// create new simple property
				value = new XMPProperty(null, value);
			}
			
			return value;
		}
		

		/**
		 * @see Object#valueOf()
		 * @return The String representation of the object.
		 */
		public function valueOf(): Object
		{
			return toString();
		} 
		
		
		/**
		 * Creates a symbolic string representation of this node.
		 * @return The string.
		 */
		public function toString(): String
		{
			return "<XMP Node>";
		}
		
		
		/**
		 * Performs a deep copy of this object; the new object contains no references 
		 * to the object from which it is cloned. Copies the properties and calls the clone
		 * routine of every node in the child-node list and the qualifier list, then
		 * resets the parent references of the children and the cloned node.
		 * @return A new node object containing the same data as this one.
		 */	 
		public function clone(): *
		{
			var ClassReference:Class = getDefinitionByName(getQualifiedClassName(this)) as Class;
			var clone:XMPNode = new ClassReference();
			clone._qname = this._qname;
			
			if (this._children)
			{
				clone._children = this._children.clone();
				for each ( var child:XMPNode in clone._children)
					child._parent = clone;
			}
			
			if (this._qualifier)
			{
				clone._qualifier = XMPQualifier(this._qualifier.clone());
				clone._qualifier._parent = clone;
			}
			
			
			clone._parent = this._parent;			
			clone.implicit = this.implicit;
			return clone;
		} 
	}
}