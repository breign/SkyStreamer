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
	 * Represents an array node in the data tree contained in an <code>XMPMeta</code> object.
	 * This type of node represents a complex property of type "array". It does not have a value, 
	 * but contains other nodes ("items") that can be nested complex properties or simple properties 
	 * with values. Arrays can be unordered ("bag"), ordered ("seq"), or sets of alternative values ("alt").
	 */
	public class XMPArray extends XMPNode
	{
		/** Constant for XMP bag array type (unordered). */
		public static const BAG: int = 0;	
		/** Constant for XMP seq array type (ordered). */
		public static const SEQ: int = 1;	
		/** Constant for XMP alt array type (set of alternatives). */
		public static const ALT: int = 2;	
						
		/** Enumeration of array type, bag is default */
		private var arrayType: int = BAG;
		
		
		/**
		 * Factory function to create an <code>XMPArray</code> object of type XMP bag.
		 * @param qname The fully-qualified name of this property. Can be null.
		 * @return The new node object.
		 */
		public static function newBag(qname: QName = null): XMPArray
		{
			return new XMPArray(qname, BAG);
		}


		/**
		 * Factory function to create an <code>XMPArray</code> object of type XMP seq.
		 * @param qname The fully-qualified name of this property. Can be null.
		 * @return The new node object.
		 */
		public static function newSeq(qname: QName = null): XMPArray
		{
			return new XMPArray(qname, SEQ);
		}


		/**
		 * Factory function to create an <code>XMPArray</code> object of type XMP alt.
		 * @param qname The fully-qualified name of this property. Can be null.
		 * @return The new node object.
		 */
		public static function newAlt(qname: QName = null): XMPArray
		{
			return new XMPArray(qname, ALT);
		}
		
		
		/**
		 * Creates an <code>XMPArray</code> object.
		 * @param qname The fully-qualified name of this property. Can be null.
		 * @param options The array type, one of these type constants:
		 * <ul>
		 * 		<li>XMPArray.BAG = 0</li>
		 * 		<li>XMPArray.SEQ = 1</li>
		 * 		<li>XMPArray.ALT = 2</li>
		 * </ul>

		 * @return The new node object.
		 */
		public function XMPArray(qname: QName = null, arrayType: int = BAG) 
		{
			this.arrayType = arrayType;
			super(qname);
		}
		
		
		/**
		 * Used internally to retrieve an array item from the data tree. 
		 * Do not use this method directly; it is invoked when you request a
		 * property using the "." or "[]" operators.
 		 * @param indexStr An array index or the function call <code>last()</code>
		 * @return An array-item node object.
		 */
		override flash_proxy function getProperty(indexStr: *): *
		{
			var index:int = evaluateIndex(indexStr, true);
			if (index < children.length)
			{
				return children.getItemAt(index);
			}
			else
			{
				return createImplicitStruct();
			}	
		}
		
		
		/**
		 * Used internally to set an array item in the data tree. 
		 * Do not use this method directly; it is invoked when you access a
		 * property using the "." or "[]" operators.
  		 * @param indexStr An array index or the function call <code>last()</code>
		 * @param value The new value or node to be assigned to the array at the given index.
		 */
		override flash_proxy function setProperty(indexStr:*, value:*): void
		{
			var index:int = evaluateIndex(indexStr, true);
			value = createNodeFromValue(null, value, index);
				
			if (index == children.length)
			{
				// append item to array  
				children.addItem(value);
				acceptImplicitNodes();	
			}
			else if (value == null)
			{
				// null means delete item, remove implicit nodes
				children.removeItemAt(index);
			}
			else
			{
				// replace array item
				children.setItemAt(value, index);
				acceptImplicitNodes();	
			}
		}


		/**
		 * Used internally; do not call directly.
		 * Catches all calls to undefined methods of this object (with their arguments).
		 */
		override flash_proxy function callProperty(name:*, ... args): * 
		{
			return super.callProperty(name, args);
		}	
		
		
		/**
		 * Used internally to evaluate the <code>delete</code> operator, 
		 * removing a child item from this structure. Do not call directly.
		 * @param index The 1-based array index of the item to remove.
		 * @return True if an item has been deleted.
		 */
		override flash_proxy function deleteProperty(index: *): Boolean
		{
			try
			{
				var i: int = evaluateIndex(index);
				return children.removeItemAt(i) != null;
			}
			catch (e: XMPException)
			{
				// delete does not throw an exception if the object is not existing. 
			}
			return false;			
		}
		
		
		/**
		 * Used internally to retrieve the next item in the iteration of this 
		 * structure's node tree. Do not call directly.
		 * @param index. The 1-based index.
		 * @return The name of the node at the given index.
		 */
		override flash_proxy function nextName(index: int): String
		{
			return index.toString();
		} 
		
		
		/**
		 * Appends an item to this array. Returns the modified array, in order to 
		 * facilitate multiple, sequential calls.
		 * 
		 * @param value The new value or node to append to this array
		 * @return This array.  
		 */ 
		public function append(value: Object): XMPArray
		{
			children.addItem(createNodeFromValue(null, value));
			acceptImplicitNodes();			
			return this;
		}
		

		/**
		 * Inserts an item into this array at the given index. 
		 * Returns the modified array, in order to facilitate multiple, sequential calls.
		 * @param index The array index.
	 	 * @param value The new value or node to add to this array
		 * @return This array.  		 
		 */ 
		public function insert(index: int, value: Object): XMPArray
		{
			index = evaluateIndex(index, true);
			children.addItemAt(createNodeFromValue(null, value), index);
			acceptImplicitNodes();			
			return this;
		}


		/**
		 * Removes an item from this array at the given index.
		 * @param index The array index.
		 * @return The removed node.
		 */ 
		public function remove(index: int): XMPNode
		{
			index = evaluateIndex(index, false, false);
			return children.removeItemAt(index);
		}
		
		
		/**
		 * Retrieves the language facade for this array, to handle "alt-text" arrays.
		 * @return A language-facade object
		 */
		public function get lang(): AltTextFacade
		{
			return new AltTextFacade(this);
		}
		
		
		/**
		 * Retrieves the array type.
		 * @return One of these type constants:
		 * <ul>
		 * 		<li>XMPArray.BAG = 0</li>
		 * 		<li>XMPArray.SEQ = 1</li>
		 * 		<li>XMPArray.ALT = 2</li>
		 * </ul>
		 */
		public function getType(): int
		{
			return arrayType;
		}		


		/** 
		 * Changes the type of this array.
		 * @param type The new type; one of these type constants:
		 * <ul>
		 * 		<li>XMPArray.BAG = 0</li>
		 * 		<li>XMPArray.SEQ = 1</li>
		 * 		<li>XMPArray.ALT = 2</li>
		 * </ul>
		 */
		public function setType(type: int): void
		{
			this.arrayType = type;
		}		
		
		
		/**
		 * Creates a symbolic string representation of this node.
		 * @return The string.
		 */		
		override public function toString(): String
		{
			if (!implicit)
			{
				switch (arrayType)
				{
					case 2: return "<Alt>";
					case 1: return "<Seq>";
					default: return "<Bag>";
				}
			}
			else
			{
				return null;
			}	
		}
		
		
		/**
		 * Performs a deep copy of this object. Creates a new object that contains 
		 * no references to the object from which it is cloned.
		 * @return A new <code>XMPArray</code> object containing the same data as this one.
		 */
		override public function clone(): *
		{
			var clone:XMPArray = super.clone();
			clone.arrayType = this.arrayType;
			return clone;		
		}

		
		/**
		 * Evaluates an array index for this array and converts the interval from [1..] to [0..] interval:
		 * <ul>
		 * 		<li>for property getting the interval [1 .. length] is valid. 
		 * 		<li>for property setting the interval [1 .. length + 1] is valid (for appending an item).
		 * </ul>
		 * 
		 * @param indexStr The parameter to be converted to an index.
		 * @param setIndex True if the index is allowed to exceed the end of the array by one
		 * @param exception True to throw an exception; otherwise returns -1 on error.  
		 * @return The given index value minus 1, if it is valid.
		 */
		private function evaluateIndex(indexStr: *, 
			setIndex: Boolean = false, exception: Boolean = true): int
		{
			if (!(indexStr is QName))
			{
				var index:int = parseInt(indexStr);
				if (index >= 1  &&  index <= (children.length + (setIndex ? 1 : 0)))
				{
					index--;
					return index;				
				}
				else if (exception)
				{
					var setStr: String = setIndex ? " + 1" : "";
					throw new XMPException (
						"Array index is out of bounds only [1..length" + setStr + "] is allowed.",
						XMPError.BADINDEX);
				}
				else
				{
					return -1;
				}
			}
			else
			{
				var qname: QName = indexStr as QName;
  				
				if (qname.uri == ""  ||  qname.uri == null)
				{
					if (qname.toString() != "last()")
					{
						return evaluateIndex(qname.localName, setIndex);
					}
					else if (setIndex)
					{
						return evaluateIndex(Math.max(children.length, 1), setIndex);
					}
					else
					{
						return evaluateIndex(children.length, setIndex);
					}
				}
			}
			
			// index cannot be interpreted
			if (exception)
			{
				throw new XMPException ("Indices must be numeric or 'last()'", XMPError.BADINDEX)
			}
			else
			{
				return -1;
			}	
		}
	}
}