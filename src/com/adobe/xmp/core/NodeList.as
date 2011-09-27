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
	/**
	 * Contains a list of <code>XMPNode</code> objects, accessed using an index in the 
	 * range [0 .. length - 1].
	 * Does not throw exceptions; if you attempt to access a member using an incorrect index,
	 * it either does nothing or returns null.  
 	 */
	internal class NodeList
	{
		/** the list of nodes is a simple array, 
		 *  it contains any class inherited from XMPNode */ 
		private var _list: Array = new Array();
		/** the list owner, any class inherited from XMPNode */ 
		private var _owner: XMPNode;
		
		
		/**
		 * Creates a new list object within an existing node.
		 * @param owner The owning node of this list
		 * @return The new list, containing all child nodes of the owner.
		 */
		public function NodeList(owner: XMPNode)
		{
			_owner = owner;
		}
		
		
		/**
		 * Retrieves a member node from this list by name.
		 * @param qname The fully-qualified name of the node.
		 * @return A node object, or null if not found in this list.
		 */ 
		public function getItem(qname: QName): XMPNode
		{
			for each (var node:XMPNode in _list)
			{
				if (qname.localName == node.qname.localName  &&
					qname.uri == node.qname.uri)
				{
					return node;
				}	
			}
			
			return null;
		}


		/**
		 * Retrieves a member node from this list by its array index.
		 * 
		 * @param index The index, in the range [0 .. length - 1].
		 * @return A node object, or null if the index is out of bounds.
		 */
		public function getItemAt(index: int): XMPNode
		{
			if (index >= 0  &&  index < _list.length)
			{
				return _list[index] as XMPNode;
			}
			else
			{
				return null;
			}
		}
		
		
		/**
		 * Retrieves the index of a a member node by name.
		 * @param qname The fully-qualified name of the node.
		 * @return The list index of the member node, or -1 if not found. 
		 */ 
		public function getItemIndex(qname: QName): int
		{
			var index: int = 0;
			for each (var node:XMPNode in _list)
			{
				if (node.qname != null  &&
					qname.localName == node.qname.localName  &&
					qname.uri == node.qname.uri)
				{
					return index;
				}
				index++;
			}
			
			return -1;
		}
				
		
		/**
		 * Appends a node member to the end of the list.
		 * @param node The node object.
		 */
		public function addItem(node: XMPNode): void
		{
			node._parent = _owner;
			_list.push(node);
		} 


		/**
		 * Inserts a member node into the list at a given index.
 		 * @param node The node object.
		 * @param index The index at which to insert the node, in the 
		 *			range [0 .. length - 1].
		 */
		public function addItemAt(node: XMPNode, index: int): void
		{
			if (index >= 0  &&  index <= _list.length)
			{
				node._parent = _owner;
				
				_list.splice(index, 0, node);
			}	
		} 



		/**
		 * Replaces a node in the list at a given index.
 		 * @param node The new node object.
		 * @param index The index of the node to replace, in the 
		 *			range [0 .. length - 1].
		 */
		public function setItemAt(node: XMPNode, index: int): void
		{
			if (index >= 0  &&  index < _list.length)
			{
				node._parent = _owner;
				_list[index] = node;
			}	
		} 
		
		
		/**
		 * Removes a node from the list at a given index.
	 	 * @param index The index of the node to remove, in the 
		 *			range [0 .. length - 1].
		 * @return The removed node object.
		 */
		public function removeItemAt(index: int): XMPNode
		{
			if (index >= 0)
			{
				var removed: Array = _list.splice(index, 1);
				if (removed.length > 0)
				{ 
					return removed[0];
				}
			}
			
			return null;	
		}
		

		/**
		 * Removes a node from the list by name.
 		 * @param name The fully-qualified name of the node to remove
		 * @return The index of the removed node, or -1 if the node is not found.
		 */
		public function removeItem(name: QName): int
		{
			var index: int = getItemIndex(name);
			if (index >= 0)
			{
				removeItemAt(index);
				return index;
			}
			else
			{
				return -1;
			}	
		}

		
	    /**
	     * Clears the list.
	     */
	    public function removeAll(): void
	    {
	    	_list = null;
	    	_list = new Array();	
	    }
		
		
		/**
		 * Reports the length of the list.
		 * @return The number of member nodes.
		 */
		public function get length(): int
		{
			return _list.length;
		}
		
		
		/**
		 * Performs a deep copy of this object by calling the 
		 * <code>clone()</code> method of every node in the list.
		 * @return The new node-list object.
		 */
		public function clone(): NodeList
		{
			var clone:NodeList = new NodeList(this._owner);
			for each (var node:XMPNode in this._list)
			{
				clone.addItem(node.clone());
			}
			return clone;
		}
	}
}