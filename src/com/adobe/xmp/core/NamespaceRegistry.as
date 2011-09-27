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
	 * This class stores XMLNS prefix-namespace pairs that 
	 * are used to serialize XMP into RDF/XML and for the debug method
	 * <code>XMPMeta#dumpObject()</code> that creates a human-readable String from an XMP object.
	 */ 
	internal class NamespaceRegistry
	{
		/** Contains a map between registered namespaces and prefixes */
		private var nsToPrefix: Object = new Object();
		/** Contains a map between registered prefixes and namespaces */
		private var prefixToNs: Object = new Object();
		/** Stores a prefix list to quickly find out which prefixes are alreay known. */
		private var prefixList: Array = new Array();


		/**
		 * Registers a new prefix, but only if neither 
		 * namespace has already been registered nor the prefix is already existing.
		 * @return Returns 
		 * <ul>
		 * 		<li>a Namespace object containing the existing prefix for the
		 * 			requested namespace string OR</li>
		 * 		<li>a Namespace object containing the existing prefix, 
		 * 			if the namespace has already been registered OR</li>
		 * 		<li>a Namespace object that does not contain a prefix if the prefix 
		 * 			is alreday bound to another namespace.</li>
		 * </ul>
		 */			
		internal function register(ns: String, prefix: String): Namespace
		{
			AssertParameter.notEmpty("ns", ns);
			AssertParameter.notEmpty("prefix", prefix);
			
			// Check with a trick that prefix has a valid xml Name
			if (new Namespace(prefix, "x").prefix == null)
			{
				throw new XMPException("The prefix is not a valid XML name", XMPError.BADSYNTAX);
			}
			
			var existingPrefix: String = nsToPrefix[ns];
			if (existingPrefix != null)
			{
				// Namespace already registered
				return new Namespace(existingPrefix, ns);
			}
			else if (prefixList.indexOf(prefix) < 0)
			{
				// register namespace - prefix pair
				nsToPrefix[ns] = prefix;
				prefixToNs[prefix] = ns;

				prefixList.push(prefix);
				return new Namespace(prefix, ns);
			}
			else
			{
				// Prefix already taken, return Namespace without prefix
				return new Namespace(ns);
			}
		}


		/**
		 * Removes a namespace and prefix pair from the registry.
		 * If it is tried to remove a non-existing namespace, the call is ignored.
		 * 
		 * @param ns a registered namespace.
		 */
		internal function unregister(ns: String): void
		{
			var prefix: String = nsToPrefix[ns];
			if (prefix != null)
			{
				var del: int = prefixList.indexOf(prefix);
				if (del >= 0)
				{
					prefixList.splice(del, 1);
				}
				
				delete nsToPrefix[ns];
				delete prefixToNs[prefix];
			}			
		}
		
		
		/**
		 * Returns a prefix for a requested namespace. If it is not known,
		 * a new prefix is generated in case the <code>generate</code> flag is set,
		 * other wise <code>null</code> is returned.
		 * 
		 * @param ns: a Namespace URI
		 * @param generate: Flag if a new prefix shall be generated if the namespace is unknown. 
		 * @return Returns a prefix or <code>null</code>, if the namespace is not registered.
		 */
		internal function getPrefix(ns: String, generate: Boolean = false): String
		{
			var prefix: String = nsToPrefix[ns];
			if (prefix != null)
			{
				return prefix;
			}
			else if (generate)
			{
				// generate and register a new prefix
				var no: int = 1;
				do
				{
					prefix = "ns" + no;
					no++;
				}
				while (prefixList.indexOf(prefix) >= 0);
			
				nsToPrefix[ns] = prefix;
				prefixToNs[prefix] = ns;				
				prefixList.push(prefix);
				return prefix;	
			}
			else
			{
				// prefix unknown, return null
				return null;
			}
		}
		
		
		/**
		 * Returns a requested namespace for a given prefix. 
		 * If it is not known, <code>null</code> is returned.
		 * 
		 * @param prefixns: a Namespace prefix
		 * @return Returns a namespace or <code>null</code>.
		 */
		public function getNamespace(prefix: String): String
		{
			return prefixToNs[prefix];		
		}


		/**
		 * @return Returns all registered <code>Namespace</code> objects in an Array. 
		 * All Namespace objects contain the associated prefix.
		 */  
		public function getNamespaces(): Array
		{
			var result: Array = [];
			for (var prefix: String in prefixToNs)
			{
				var uri: String = prefixToNs[prefix];
				var ns: Namespace = new Namespace(prefix, uri);
				result.push(ns);
			}
			return result;
		}
		
		
		/**
		 * Clone routine a namespace registry class. Copys the 2 arrays nsToPrefix and prefixList.
		 */
		public function clone():NamespaceRegistry
		{
			var clone:NamespaceRegistry = new NamespaceRegistry();
			clone.nsToPrefix = new Array(this.nsToPrefix);
			clone.prefixToNs = new Array(this.prefixToNs);
			clone.prefixList = new Array(this.prefixList);
			return clone;
		}
	}
}