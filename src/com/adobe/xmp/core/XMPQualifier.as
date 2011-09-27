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
	import flash.utils.flash_proxy;
	
	use namespace flash_proxy; 


	/**
	 * Represents a set of qualifiers of any other node. This class behaves like
	 * a structure node that contains the named qualifier nodes, except that it cannot be 
	 * implicitly converted to a simple property or array. Every node contains a read-only
	 * <code>qualifier</code> property containing an object of this type, through which 
	 * you can access the qualifier nodes by name; for example,
	 * <code>myProperty.qualifier.myQualifier</code>.
	 */
	public class XMPQualifier extends XMPStruct
	{
		/** 
		 * Outputs the child nodes of this object (a complete set of qualifiers
		 * for one node in the XMP data tree) into a human-readable string, 
		 * for debugging purposes. It does not include the node itself, which 
		 * contains no value.
		 * @return The qualifier nodes in a formatted string.
		 */
		override internal function dumpNode(buffer: ByteArray, xmp: XMPMeta, usedNS: Array, 
			indent: int, index: int = 0): void 
		{
			// write top-level nodes, no qualifier			
			for (var j: int = 0; j < children.length; j++)
			{
				var node: XMPNode = children.getItemAt(j);
				node.dumpNode(buffer, xmp, usedNS, indent + 1);
			}
		}
		
		
		/**
		 * If a node has been created implicitly THROUGH the definition of a qualifier,
		 * it cannot be accepted because there's no information what kind of node to create as
		 * parent.
		 */
		override internal function acceptImplicitNodes(): void
		{
			if (implicit)
			{
				throw new XMPException("Cannot set qualifier on implicitly created properties",
					XMPError.BADSYNTAX);
			}		
		}
	}
}