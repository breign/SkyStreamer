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
	 * Main API class of the XMPCore portion of the "Adobe XMP Library for ActionScript". 
	 * Each instance is an XMP data-model object that represents a complete set of XMP 
	 * metadata for one asset. The metadata object is the root of a nested tree of properties, 
	 * which have individual object representations in the data model. This object contains
	 * the top-level properties, and adds parsing and serializing functionality for transforming
	 * the data from and to the RFD/XML XMP Packet format.
	 * 
	 * Legal Audit ID: <AdobeIP#0000781>
	 */
	public class XMPMeta extends XMPStruct
	{
		/** locally registered namespaces. This can happen by parsing or manually with
		 * 	registerNamespace(). */
		private var localNamespaces: NamespaceRegistry = new NamespaceRegistry();
		
		/** Name of the metadata object. When serialized, this is rendered in the "about"  
		 *  attribute of the rdf:Descriptions-nodes. */
		public var name: String;
		
		/**
		 * Read-only. Reflects the read-write flag in the packet wrapper. 
		 * The parser sets the flag, and the serializer writes either "r" 
		 * for read-only or "w" for read-write into the closing tag of the packet wrapper.
		 * For example: &lt;?xpacket end="r"?&gt;. 
		 * 
		 * The parser cannot evaluate this flag from an XML object, which does not accept 
		 * a processing instruction as the first node.  
		 *
		 * <em>Note:</em> The serializing option <code>omitPacketWrapper</code> prevents  
		 * the serializing of the packet wrapper (and the read/write flag).
		 */ 
		public var readOnly: Boolean = false;
		

		/**
		 * Creates an empty XMPMeta object, or parses the passed XMP packet 
		 * to initialize the new XMPMeta object.
		 * 
		 * @param xmpPacket	An XMP Packet, as a String, a ByteArray or an XML object. 
		 * 		All	other objects are converted to a String.
		 * @param options A <code>ParseOptions</code> object containing non-default
		 * 		options for how the parser converts the packet data. In not supplied,
		 * 		default options are used.
		 */   
		public function XMPMeta(xmpPacket: Object = null, options: ParseOptions = null)
		{
			if (xmpPacket != null)
			{
				new Parser().parse(xmpPacket, this, options);
			}	 
		}


		/**
		 * Terminates the library and frees all statically-assigned memory 
		 * (that is, the global namespaces).
		 */ 
		public static function terminate(): void
		{
			GlobalNamespaces.unregisterAll();	
		}

		
		/**
		 * Used internally to retrieve a named property from the data tree. 
		 * Do not use this method directly; it is invoked when you request a
		 * property using the "." or "[]" operators.
		 * 
		 * @param name The property <code>QName</code>, which includes the namespace identifier and property key.
		 * @return The property object. Creates an implicit node or throws an exception
		 */
		override flash_proxy function getProperty(name: *): *
		{
			return super.getProperty(name);
		}
		
		
		/**
		 * Used internally; do not call directly.
		 * Catches all calls to undefined methods of this object (with their arguments).
		 * Array method calls to implicit struct nodes convert them to arrays and insert an
		 * implicit item to the new array. 
		 */
		override flash_proxy function callProperty(name:*, ... args): * 
		{
			return super.callProperty(name, args);
		}	
			
		
		/**
		 * Used internally to set the value of a named property in the data tree. 
	 	 * Do not use this method directly; it is invoked when you assign a property
		 * value using the "." or "[]" operators. If the named property does not yet exist, it is
		 * created. You can remove a property by assigning it a null value.
		 * 
		 * @param name The property <code>QName</code>, which includes the namespace identifier and property key.
		 * @param value The new property value.
		 * 
		 */
		override flash_proxy function setProperty(name:*, value:*): void
		{
			super.setProperty(name, value);
		}
		
		
		/**
		 * Serializes the XMP data in this object to a ASCII string containing an RDF/XML XMP Packet, 
		 * according to the provided options, which control the encoding and size of the resulting XMP Packet.
		 * @param options An object containing non-default serialization options, or null to use defaults.
		 * @return The XMP Packet as a String
		 */
		public function serialize(options: SerializeOptions = null): String
		{
			return new Serializer().serializeToString(this, options);
		}
		
		
		/**
		 * Serializes the XMP data in this object to a byte-array string containing an RDF/XML XMP Packet, 
		 * according to the provided options, which control the encoding and size of the resulting XMP Packet.
		 * @param options An object containing non-default serialization options, or null to use defaults.
		 * @return The XMP Packet as a ByteArray
		 */
		public function serializeToBuffer(options: SerializeOptions = null): ByteArray
		{
			return new Serializer().serializeToBuffer(this, options);
		}


		/**
		 * Serializes the XMP data in this object to an XML object containing 
		 * an RDF/XML XMP Packet, according to the provided options. 
		 * Options concerning the layout of the packet, such as <code>padding</code>,
		 * <code>exactPacketLength</code> and <code>encoding</code>, are ignored 
		 * when serializing to XML.
		 * @param options An object containing non-default serialization options, or null to use defaults.
		 * @return The XMP Packet as an <code>XML</code> object.
		 */
		public function serializeToXML(options: SerializeOptions = null): XML
		{
			return new Serializer().serializeToXML(this, options);
		}
		
		
		/**
		 * Registers a namespace and prefix pair. All Adobe namespaces are pre-registered 
		 * as global namespaces, and assigned to contants in the <code>XMPConst</code> class.
		 * 
		 * The registration of the prefix affects only serialization and object dumps; it is not 
		 * used within the library. If the proposed prefix already exists locally, the namespace 
		 * is not registered with a prefix at all; the call returns a <code>Namespace</code> object 
		 * without a prefix. 
		 * 
		 * It is not necessary to register a namespace with a prefix in order to use it in API calls; 
		 * you can create a <code>Namespace</code> object with the <code>new</code> operator instead. 
		 * If a namespace is not bound to a prefix, or if the namespace-prefix pair is deleted with 
		 * <code>unregisterNamespace()</code>, a prefix such as "ns1, ns2, ns3 ..." is generated 
		 * when the packet is serialized.
		 * 
		 *	A defined namespace is registered in either the global or the local registry; 
		 * 	when a namespace is registered globally, it is removed from the local registry, 
		 * 	if necessary. If it is registered locally and already exists in the global registry, 
		 * 	the local registration is ignored.
		 *
		 * @param ns A namespace URI string.
		 * @param prefix A prefix string
		 * @param global True if the namespace and prefix pair is registered globally; that is, 
		 * 		it is globally valid for the library. The default is False, meaning that it is 
		 * 		valid only for this metadata object.
		 *		
		 * @return A <code>Namespace</code> object representing the registered namespace 
		 * 		   for immediate use. If registration fails, returns a valid object without a prefix.
		 */
		public function registerNamespace(
			ns: String, prefix: String, global: Boolean = false): Namespace
		{
			// global and prefix not locally taken
			if (global  &&  localNamespaces.getNamespace(prefix) == null)
			{
				// delete namespace from local registry and register it globally
				localNamespaces.unregister(ns);
				return GlobalNamespaces.register(ns, prefix);
			}
			// local and prefix not globally taken and namespace not globally registered
			else if (!global  &&
				  	 GlobalNamespaces.getNamespace(prefix) == null  &&
				  	 GlobalNamespaces.getPrefix(ns) == null) 
			{
				return localNamespaces.register(ns, prefix);
			}
			
			// return a Namesapce object w/o prefix by default
			return new Namespace(ns);	
		}
		
		/**
		 * Removes a prefix definition for a locally or globally registered namespace.
		 * If a namespace is not bound to a prefix, or if the namespace-prefix pair is 
		 * deleted with this function, a prefix in the form ns1, ns2, ns3, ... is generated 
		 * when the packet is serialized.
		 * 
		 * @param ns The namespace URI string.
		 */
		public function unregisterNamespace(
			ns: String): void
		{
			GlobalNamespaces.unregister(ns);
			localNamespaces.unregister(ns);
		}
				
		/**
		 * Finds the prefix that is registered for the given namespace URI 
		 * in the context of this metadata object. Checks first for an existing 
		 * Adobe default prefix; see <code>XMPConst</code>. If none is found, 
		 * checks the global, and then the local registry for a namespace that 
		 * has been registered in the current session. Local registration can 
		 * occur through parsing, or through explicit creation of a <code>Namespace</code> object.
		 * 
		 * If no prefix is associated with the namespace URI, you can use this call 
		 * to generate one. A prefix is generated, if necessary, when the packet is serialized.
		 * @return The found or generated prefix string.
		 * @see XMPConst
		 */   
		public function getPrefix(ns: String, createPrefix: Boolean = true): String
		{
			// Check that the namespace is not empty
			AssertParameter.notEmpty("ns", ns);
			
			// 1. Is there an Adobe default Prefix existing
			// 2. Does the user has registered a global ns prefix for the current session
			var prefix: String = GlobalNamespaces.getPrefix(ns);
			if (prefix != null)
			{
				return prefix;
			}
			
			// 3. Does the xmp object has stored a temporary prefix &
			// 4. Create a prefix in the form ns1, ns2, ...
			return localNamespaces.getPrefix(ns, createPrefix);
		}


		/**
		 * Retrieves the namespace URI associated with a given prefix 
		 * in the context of this metadata object. Checks first for an 
		 * existing Adobe default prefix; see <code>XMPConst</code>. 
		 * If none is found, checks the global, and then the local registry 
		 * for a namespace that has been registered in the current session.
		 * @return A namespace URI string if one is found, or null if the prefix 
		 * 		is not associated with any namespace. 
		 * @see XMPConst
		 */   
		public function getNamespace(prefix: String): String
		{
			// Check that the prefix is not empty
			AssertParameter.notEmpty("prefix", prefix);
			
			// 1. Is there an Adobe default Namespace existing for that prefix
			// 2. Does the user has registered a global ns prefix for the current session
			var ns: String = GlobalNamespaces.getNamespace(prefix);
			if (ns != null)
			{
				return ns;
			}
			
			// 3. Does the xmp object has stored a temporary namespace
			return localNamespaces.getNamespace(prefix);
		}


		/**
		 * Finds all namespaces that have been explicitly registered, either locally only, 
		 * or both locally and globally.
		 * @param inclGlobal True to search the global namespace registry; if False 
		 *		or not supplied, searches only local namespaces.
		 * @return The registered namespace-prefix pairs, as an Array of
		 * 		<code>Namespace</code> objects.
		 * 	@see Namespace
		 */
		public function getNamespaces(inclGlobal: Boolean = true): Array
		{
			var namespaces: Array = localNamespaces.getNamespaces();
			if (inclGlobal)
			{
				namespaces = namespaces.concat(GlobalNamespaces.getNamespaces());
			}
			
			return namespaces;
		}


		/**
		 * This function is inherited from <code>XMPStruct</code>, but because the root
		 * object is not allowed to have qualifiers, it throws an exception in this case.
		 */
		override public function get qualifier(): XMPQualifier
		{
			throw new XMPException("The XMPMeta object cannot have qualifiers", XMPError.BADSYNTAX);
		} 


		/**
		 * Retrieves the current name and version of this library.
		 * @return The version string.
		 */
		public function getVersion(): String
		{
			return Version.getMessage();
		}


		/**
		 * Outputs the content of the XMP data tree in this object into a human-readable string, 
		 * for debugging purposes.
		 * @return The XMP data tree in a formatted string.
		 */
		public function dumpObject(): String
		{
			var buffer: ByteArray = new ByteArray();
			var usedNS: Array = new Array();
			dumpNode(buffer, this, usedNS, 0, 0);
			buffer.position = 0;
			return buffer.readUTFBytes(buffer.length);
		}		
		
		
		/**
		 * Performs a deep copy of this object. Creates a new object that contains 
		 * no references to the object from which it is cloned.
		 * @return A new <code>XMPMeta</code> object containing the same data as this one.
		 */
		override public function clone(): *
		{
			var clone:XMPMeta =  super.clone();
			if (this.name)
				clone.name = this.name;
			
			clone.localNamespaces = this.localNamespaces.clone();
			return clone;
		}
	
	
		/** Renders the top-level node and the name of the metadata object */
		override internal function dumpNode(buffer: ByteArray, xmp: XMPMeta, usedNS: Array, 
			indent: int, index: int = 0): void 
		{
			// render the root node and name of the metadata object
			buffer.writeUTFBytes("XMP Metadata");
			if (name != null  &&  name.length > 0)
			{
				buffer.writeUTFBytes(" (" + name + ")");				
			}
			buffer.writeUTFBytes('\n');

			// write top-level nodes, no qualifier			
			var currentURI: String;
			for (var j: int = 0; j < children.length; j++)
			{
				var node: XMPNode = children.getItemAt(j);
				if (j != 0  &&  j != children.length - 1  &&  
					node.qname.uri != currentURI)
				{
					buffer.writeUTFBytes("\n");					
				}
				currentURI = node.qname.uri;
				node.dumpNode(buffer, xmp, usedNS, indent + 1, j + 1);
			}
			
			// render the prefix legend
			
			if (usedNS.length > 0)
			{
				buffer.writeUTFBytes("\nUsed Namespace Prefixes:\n");
				
				// sort by prefixes
				usedNS.sortOn("pre");
				for each (var ns: Object in usedNS)
				{
					buffer.writeUTFBytes("\t" + ns.pre + ":\t" + ns.uri + "\n");
				}
			}	
		}
		
		
		/**
		 * This overwritten method keeps the top-level properties sorted by namespace.
		 * Within the the properties of the same namespace, the nodes can be in any order.
		 * 
		 * @param existingNode A named existing node to be replaced. Can be null
		 * @param newNode A new node that either replaces the existing one with the same name
		 * 				  or is appended.
		 */ 		
		override protected function addOrReplaceNode(existingNode: XMPNode, newNode: XMPNode): void
		{
			if (existingNode != null  ||  children.length == 0)
			{
				// replace existing node, no sorting needed
				super.addOrReplaceNode(existingNode, newNode);
			}
			else
			{
				// if there is at least one node in the same namespace
				// 		insert node after it
				// if there is no note with the same namespace,
				//		insert it alphabetically  
				for (var i: int = children.length - 1; i >= 0; i--)
				{
					var node: XMPNode = children.getItemAt(i);
					if (newNode.qname.uri == node.qname.uri  ||
						newNode.qname.uri > node.qname.uri)
					{
						children.addItemAt(newNode, i + 1);
						return;
					}
				}
				
				// if not cannot be inserted somewhere, its becomes the first item
				children.addItemAt(newNode, 0);
			}
		}
	}
}