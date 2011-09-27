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


/**
 * Serializer for the RDF/XML format. 
 */
internal class Serializer
{
	/** the XMP packet header */
	private const PACKET_HEADER: String =
		'<?xpacket begin="\uFEFF" id="W5M0MpCehiHzreSzNTczkc9d"?>';
	/** the XMP packet trailer - The w/r is missing inbetween. */
	private const PACKET_TRAILER: String = '<?xpacket end="';
	/** xmpmeta start tag */
	private const RDF_XMPMETA_START: String = 
		'<x:xmpmeta xmlns:x="adobe:ns:meta/"';
	private const RDF_XMPTK: String = ' x:xmptk="'
	/** xmpmeta end tag */
	private const RDF_XMPMETA_END: String = "</x:xmpmeta>";
	/** RDF start tag with NS */
	private const RDF_RDF_START: String = 
		'<rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">';
	/** RDF end tag */
	private const RDF_RDF_END: String = "</rdf:RDF>";
	/** RDF li element */
	private const RDF_LI: String = "rdf:li";
	/** Schema start tag */
	private const RDF_SCHEMA_START: String = "<rdf:Description";
	/** Schema end tag */
	private const RDF_SCHEMA_END: String = "</rdf:Description>";
	/** a set of all rdf attribute qualifier */
	private const RDF_ATTR_QUALIFIER: String = "resource ID bagID nodeID";
	/** 100 Padding spaces */
	private const spaces100: String = 
		"                                                  " +
		"                                                  ";
	
	/** the xmp object to serialize */
	private var xmp: XMPMeta;
	/** character write function of the desired encoding */
	private var write: Function;
	/** the options handed to the serialize-method */
	private var options: SerializeOptions;
	/** the packet tail  */
	private var tailStr: String = "";
	/** the serialized output */
	private var output: ByteArray;
	/** flag if serialized to String  */
	private var toString: Boolean = false;
	/** serialized bytes */
	private var packetLength: int = 0;
	/** tracks the indentation level */ 
	private var _indent: uint = 0;


	/**
	 * Serialize XMP packet to ByteBuffer.
	 * 
	 * @param xmp the xmp object to serialize
	 * @param options the serialize options.
	 * @return Returns the serialized XMP packet as ByteArray.
	 */
	internal function serializeToBuffer(xmp: XMPMeta, options: SerializeOptions): ByteArray
	{
		// remember parameters
		this.xmp = xmp;
		this.options = options != null ? options : new SerializeOptions();
		write = (toString  ||  this.options.encoding == SerializeOptions.UTF8) ?
			writeUTF8 : writeUTF16;
		
		// make sure that a new output buffer is used		
		output = new ByteArray();
		// serializes the whole packet, but don't write the tail yet 
		serializePacket();
		
		output.position = 0;
		return output;
	}
	
	
	/**
	 * Serialize XMP packet to String.
	 * 
	 * @param xmp the xmp object to serialize
	 * @param options the serialize options.
	 * @return Returns the serialized XMP packet as String.
	 */
	internal function serializeToString(xmp: XMPMeta, options: SerializeOptions): String
	{
		toString = true;
		serializeToBuffer(xmp, options);
		return output.readUTFBytes(output.length);
	}


	/**
	 * Serialize XMP packet to an XML object.
	 * 
	 * @param xmp the xmp object to serialize
	 * @param options the serialize options.
	 * @return Returns the serialized XMP packet as XML object.
	 */
	internal function serializeToXML(xmp: XMPMeta, options: SerializeOptions): XML
	{
		try
		{
			return new XML(serializeToBuffer(xmp, options));
		}
		catch (e: Error)
		{
			throw new XMPException("Unknown error: " + e.message, XMPError.UNKNOWN);
		}
		return null;				
	}
	
	
	/**
	 * Writes the (optional) packet wrapper.
	 */ 
	private function serializePacket(): void
	{
		// Write the packet header PI.
		if (!options.omitPacketWrapper)
		{
			writeIndent();
			write(PACKET_HEADER);
			writeNewline();
		}

		serializeAsRDF();
		
		// Write the packet trailer PI into the tail string as UTF-8.
		if (!options.omitPacketWrapper)
		{
			for (var level: int = options.baseIndent; level > 0; level--)
			{
				tailStr += options.indent;
			}

			tailStr = PACKET_TRAILER;
			tailStr += xmp.readOnly ? 'r' : 'w';
			tailStr += "\"?>";
		}
		
		// adds padding according to the options
		addPaddingAndTail();
	}
	
	
	/**
	 * Writes the outer rdf-tags.
	 * <br>
	 * <em>Note:</em> The option to render "pretty/verbose" is not available in this implementation.
	 */  
	private function serializeAsRDF(): void
	{
		// Write the xmpmeta element's start tag.
		writeIndent();
		write(RDF_XMPMETA_START);
		
		if (!options.omitVersionAttribute)
		{	
			write(RDF_XMPTK + xmp.getVersion() + '"');
		}	
		write('>');
		writeNewline();
	
		// Write the rdf:RDF start tag.
		increaseIndent();
			writeIndent();
			write(RDF_RDF_START);
			writeNewline();
			
			// Write all of the properties. 
			serializeRDFSchemas();
		
			// Write the rdf:RDF end tag.
			writeIndent();
			write(RDF_RDF_END);
			writeNewline();
		decreaseIndent();
		// Write the xmpmeta end tag.
		writeIndent();		
		write(RDF_XMPMETA_END);
		writeNewline();
	}


	/**
	 * Serializes the metadata schemas and properties.
	 */
	private function serializeRDFSchemas(): void
	{
		// Begin the rdf:Description start tag.
		increaseIndent();
			writeIndent();
			write(RDF_SCHEMA_START);
			
			var about: String = xmp.name != null ? xmp.name : "";
			write(" rdf:about=\"");
			writeEncodedValue(about, true);
			write("\"");			
			
			// Write all necessary xmlns:prefix="uri" attributes.
			var usedNS: Array = new Array();
			usedNS.push(XMPConst.xml.uri);
			increaseIndent();
				increaseIndent();
					declareUsedNamespaces(xmp, usedNS);
				decreaseIndent();
			decreaseIndent();
			
			// Write the top level "attrProps" and close the rdf:Description start tag.
			var allAreAttrs: Boolean = true;
			
			increaseIndent();
				allAreAttrs &&= serializeCompactRDFAttrProps(xmp);
			decreaseIndent();
			
			if (allAreAttrs)
			{
				write("/>");
				writeNewline();
				// ! Done if all properties in all schema are written as attributes.			
				//return;
			}
			else
			{
				write('>');
				writeNewline();
		
				// Write the remaining properties for each schema.
				increaseIndent();
					serializeCompactRDFElementProps(xmp);
				decreaseIndent();
		
				// Write the rdf:Description end tag.
				// *** Elide the end tag if everything (all props in all schema) is an attr.
				writeIndent();
				write(RDF_SCHEMA_END);
				writeNewline();
			}
		decreaseIndent();
	}


	/**
	 * Write each of the parent's simple unqualified properties as an attribute. Returns true if all
	 * of the properties are written as attributes.
	 * 
	 * @param parentNode the parent property node
	 * @return Returns true if all properties could be rendered as RDF attribute.
	 */
	private function serializeCompactRDFAttrProps(parentNode: XMPNode): Boolean
	{
		var allAreAttrs: Boolean = true;
	
		for each (var prop: XMPNode in parentNode)
		{
			if (canBeRDFAttrProp(prop))
			{
				var prefix: String = xmp.getPrefix(prop.qname.uri);
				writeNewline();
				writeIndent();
				write(prefix + ':' + prop.qname.localName + '="');
				writeEncodedValue((prop as XMPProperty).value, true);
				write('"');
			}
			else
			{
				allAreAttrs = false;
			}
		}
		return allAreAttrs;
	}


	/**
	 * Recursively handles the "value" for a node that must be written as an RDF
	 * property element. It does not matter if it is a top level property, a
	 * field of a struct, or an item of an array. The indent is that for the
	 * property element. The patterns below ignore attribute qualifiers such as
	 * xml:lang, they don't affect the output form.
	 * 
	 * <blockquote>
	 * 
	 * <pre>
	 *  	&lt;ns:UnqualifiedStructProperty-1
	 *  		... The fields as attributes, if all are simple and unqualified
	 *  	/&gt;
	 *  
	 *  	&lt;ns:UnqualifiedStructProperty-2 rdf:parseType=&quot;Resource&quot;&gt;
	 *  		... The fields as elements, if none are simple and unqualified
	 *  	&lt;/ns:UnqualifiedStructProperty-2&gt;
	 *  
	 *  	&lt;ns:UnqualifiedStructProperty-3&gt;
	 *  		&lt;rdf:Description
	 *  			... The simple and unqualified fields as attributes
	 *  		&gt;
	 *  			... The compound or qualified fields as elements
	 *  		&lt;/rdf:Description&gt;
	 *  	&lt;/ns:UnqualifiedStructProperty-3&gt;
	 *  
	 *  	&lt;ns:UnqualifiedArrayProperty&gt;
	 *  		&lt;rdf:Bag&gt; or Seq or Alt
	 *  			... Array items as rdf:li elements, same forms as top level properties
	 *  		&lt;/rdf:Bag&gt;
	 *  	&lt;/ns:UnqualifiedArrayProperty&gt;
	 *  
	 *  	&lt;ns:QualifiedProperty rdf:parseType=&quot;Resource&quot;&gt;
	 *  		&lt;rdf:value&gt; ... Property &quot;value&quot; 
	 *  			following the unqualified forms ... &lt;/rdf:value&gt;
	 *  		... Qualifiers looking like named struct fields
	 *  	&lt;/ns:QualifiedProperty&gt;
	 * </pre>
	 * 
	 * </blockquote>
	 * 
	 * @param parentNode the parent node
	 */
	private function serializeCompactRDFElementProps(parentNode: XMPNode): void
	{
		var elemName: String;
		var emitEndTag: Boolean;
		var indentEndTag: Boolean;
		var hasGeneralQualifiers: Boolean;
 		var hasRDFResourceQual: Boolean;
 		 
		for each (var node: XMPNode in parentNode)
		{
			// omit nodes that are already serialized as attribute
			if (canBeRDFAttrProp (node))
			{	
				continue;
			}
	
			emitEndTag = true;
			indentEndTag = true;
	
			// Determine the XML element name, write the name part of the start tag. 
			if (node.qname != null)
			{
				// node is a property or struct field
				var prefix: String = xmp.getPrefix(node.qname.uri);
 				elemName = prefix + ":" + node.qname.localName;				
			}
			else
			{
				// node is array item
				elemName = RDF_LI;
			}

			writeIndent();
			write("<" + elemName);				

	
			// Look over the
			// qualifiers to decide on "normal" versus "rdf:value" form. Emit the attribute
			// qualifiers at the same time.
			hasGeneralQualifiers = false;
			hasRDFResourceQual = false;
	
			for each (var qual: XMPNode in node.qualifier)
			{
				if (!isRDFQualifier(qual))
				{
					hasGeneralQualifiers = true;
				}
				// assure that the attribute qualifier is simple
				else if (qual is XMPProperty)
				{
					hasRDFResourceQual = 
						qual.qname.localName == "resource"  &&
						qual.qname.uri == XMPConst.rdf.uri;
					write(' ');
					if(qual.qname.uri == XMPConst.xml.uri  && qual.qname.localName == "lang")
					{
						write("xml:");
					}	
					else
					{
						write("rdf:");
					}	
					write(qual.qname.localName);
					write("=\"");
					writeEncodedValue((qual as XMPProperty).value, true);
					write('"');
				}
			}
			
			
			// Process the property according to the standard patterns.
			if (hasGeneralQualifiers)
			{
				serializeCompactRDFGeneralQualifier(node);
			}
			else
			{
				// This node has only attribute qualifiers. Emit as a property element.
				if (node is XMPProperty)
				{
					emitEndTag = serializeCompactRDFSimpleProp(node as XMPProperty);
					indentEndTag = !emitEndTag;
				}
				else if (node is XMPArray)
				{
					serializeCompactRDFArrayProp(node as XMPArray);
				}
				else
				{
					emitEndTag = serializeCompactRDFStructProp(
						node as XMPStruct, hasRDFResourceQual);
				}
			}

			// Emit the property element end tag.
			if (emitEndTag)
			{
				if (indentEndTag)
				{
					writeIndent();
				}
				write("</");
				write(elemName);
				write('>');
				writeNewline();
			}
		}		
	}


	/**
	 * Serializes a simple property.
	 * 
	 * @param node a simple property
	 * @return Returns whether an end tag has to be rendered.
	 */ 
	private function serializeCompactRDFSimpleProp(node: XMPProperty): Boolean
	{
		var emitOrIndentEndTag: Boolean;

		if (node.uri)
		{
			write(" rdf:resource=\"");
			writeEncodedValue(node.value, true);
			write("\"/>");
			writeNewline();
			emitOrIndentEndTag = false;
		}
		else if (node.value == null  ||  node.value.length == 0)
		{
			write("/>");
			writeNewline();
			emitOrIndentEndTag = false;
		}
		else
		{
			write('>');
			writeEncodedValue(node.value, false);
			emitOrIndentEndTag = true;
		}
		
		return emitOrIndentEndTag;
	}


	/**
	 * Serializes an array property.
	 * 
	 * @param node an XMPNode 
	 */
	private function serializeCompactRDFArrayProp(node: XMPArray): void
	{
		// This is an array.
		write('>');
		writeNewline();
		increaseIndent();
			emitRDFArrayTag (node, true);
		decreaseIndent();
		
		// add x-default item to alt-text arrays
		if (options.addXDefault)
		{
			node = addXDefaultItem(node as XMPArray);
		}

		increaseIndent();
			increaseIndent();
				serializeCompactRDFElementProps(node);
			decreaseIndent();
		decreaseIndent();
		
		increaseIndent();
			emitRDFArrayTag(node, false);
		decreaseIndent();
	}


	/**
	 * Serializes a struct property.
	 * 
	 * @param node an XMPNode 
	 * @param hasRDFResourceQual Flag if the element has resource qualifier
	 * @return Returns true if an end tag shall be emitted.
	 */
	private function serializeCompactRDFStructProp(
		node: XMPStruct, hasRDFResourceQual: Boolean): Boolean
	{
		// This must be a struct.
		var hasAttrFields: Boolean = false;
		var hasElemFields: Boolean = false;
		var emitEndTag: Boolean = true;
		
		for each (var field: XMPNode in node)
		{
			if (canBeRDFAttrProp(field))
			{
				hasAttrFields = true;
			}
			else
			{
				hasElemFields = true;
			}

			if (hasAttrFields  &&  hasElemFields)
			{
				break;	// No sense looking further.
			}
		}
		
		if (hasRDFResourceQual && hasElemFields)
		{
			throw new XMPException(
				"Can't mix rdf:resource qualifier and element fields",
				XMPError.BADRDF);
		}

		if (node.length == 0)
		{
			// Catch an empty struct as a special case. The case
			// below would emit an empty
			// XML element, which gets reparsed as a simple property
			// with an empty value.
			write(' rdf:parseType="Resource"/>');
			writeNewline();
			emitEndTag = false;
		}
		else if (!hasElemFields)
		{
			// All fields can be attributes, use the
			// emptyPropertyElt form.
			increaseIndent();
				serializeCompactRDFAttrProps(node);
			decreaseIndent();
			write("/>");
			writeNewline();
			emitEndTag = false;

		}
		else if (!hasAttrFields)
		{
			// All fields must be elements, use the
			// parseTypeResourcePropertyElt form.
			write(' rdf:parseType="Resource">');
			writeNewline();
			increaseIndent();
				serializeCompactRDFElementProps(node);
			decreaseIndent();
		}
		else
		{
			// Have a mix of attributes and elements, use an inner rdf:Description.
			increaseIndent();
				write('>');
				writeNewline();
				writeIndent();
				write(RDF_SCHEMA_START);
				
				increaseIndent();
					serializeCompactRDFAttrProps(node);
					write(">");
					writeNewline();
					serializeCompactRDFElementProps(node);
				decreaseIndent();
				
				writeIndent();
				write(RDF_SCHEMA_END);
				writeNewline();
			decreaseIndent();
		}
		return emitEndTag;
	}
	
	
	/**
	 * Serializes the general qualifier.  
	 * 
	 * @param node the root node of the subtree
	 */
	private function serializeCompactRDFGeneralQualifier(node: XMPNode): void
	{
		// The node has general qualifiers, ones that can't be
		// attributes on a property element.
		// Emit using the qualified property pseudo-struct form. The
		// value is output by a call
		// to SerializePrettyRDFProperty with emitAsRDFValue set.
		write(" rdf:parseType=\"Resource\">");
		writeNewline();

		increaseIndent();
			serializePrettyRDFProperty(node, true);

			for each (var qualifier: XMPNode in node.qualifier)
			{
				if (qualifier.qname.localName != "lang"  ||  qualifier.qname.uri != XMPConst.xml.uri)
				{  
					serializePrettyRDFProperty(qualifier, false);
				}	
			}
		decreaseIndent();
	}
	
	
	/**
	 * Recursively handles the "value" for a node. It does not matter if it is a
	 * top level property, a field of a struct, or an item of an array. The
	 * indent is that for the property element. An xml:lang qualifier is written
	 * as an attribute of the property start tag, not by itself forcing the
	 * qualified property form. The patterns below mostly ignore attribute
	 * qualifiers like xml:lang. Except for the one struct case, attribute
	 * qualifiers don't affect the output form.
	 * 
	 * <blockquote>
	 * 
	 * <pre>
	 * 	&lt;ns:UnqualifiedSimpleProperty&gt;value&lt;/ns:UnqualifiedSimpleProperty&gt;
	 * 
	 * 	&lt;ns:UnqualifiedStructProperty rdf:parseType=&quot;Resource&quot;&gt;	
	 * 		(If no rdf:resource qualifier)
	 * 		... Fields, same forms as top level properties
	 * 	&lt;/ns:UnqualifiedStructProperty&gt;
	 * 
	 * 	&lt;ns:ResourceStructProperty rdf:resource=&quot;URI&quot;
	 * 		... Fields as attributes
	 * 	&gt;
	 * 
	 * 	&lt;ns:UnqualifiedArrayProperty&gt;
	 * 		&lt;rdf:Bag&gt; or Seq or Alt
	 * 			... Array items as rdf:li elements, same forms as top level properties
	 * 		&lt;/rdf:Bag&gt;
	 * 	&lt;/ns:UnqualifiedArrayProperty&gt;
	 * 
	 * 	&lt;ns:QualifiedProperty rdf:parseType=&quot;Resource&quot;&gt;
	 * 		&lt;rdf:value&gt; ... Property &quot;value&quot; following the unqualified 
	 * 			forms ... &lt;/rdf:value&gt;
	 * 		... Qualifiers looking like named struct fields
	 * 	&lt;/ns:QualifiedProperty&gt;
	 * </pre>
	 * 
	 * </blockquote>
	 * 
	 * @param node the property node
	 * @param emitAsRDFValue property shall be renderes as attribute rather than tag
	 */
	private function serializePrettyRDFProperty(
		node: XMPNode, emitAsRDFValue: Boolean): void
			
	{
		var emitEndTag: Boolean   = true;
		var indentEndTag: Boolean = true;
		var prefix: String;
		var qual: XMPNode;		
		 	
		// Determine the XML element name. Open the start tag with the name and
		// attribute qualifiers.
		var elemName: String;
		if (emitAsRDFValue)
		{
			// node value rendered in <rdf:value>-tag
			elemName = "rdf:value";
		}
		else if (node.qname == null)
		{
			// node is array item
			elemName = RDF_LI;
		}
		else
		{
			// node is rendered as normal tag
			prefix = xmp.getPrefix(node.qname.uri);
 			elemName = prefix + ":" + node.qname.localName;				
		}
 
 		writeIndent();
		write('<');
		write(elemName);
		
		var hasGeneralQualifiers: Boolean = false;
		var hasRDFResourceQual: Boolean = false;
		
		for each (qual in node.qualifier)
		{
			if (!isRDFQualifier(qual))
			{
				hasGeneralQualifiers = true;
			}
			else
			{
				hasRDFResourceQual = 
					qual.qname.localName == "resource"  &&
					qual.qname.uri == XMPConst.rdf.uri;
				if (!emitAsRDFValue && (qual is XMPProperty))
				{
					prefix = xmp.getPrefix(qual.qname.uri);
					write(' ' + prefix + ':' + qual.qname.localName + '="');
					writeEncodedValue((qual as XMPProperty).value, true);
					write('"');
				}
			}
		}
		
		// Process the property according to the standard patterns.
		increaseIndent();
			if (hasGeneralQualifiers  &&  !emitAsRDFValue)
			{
				// This node has general, non-attribute, qualifiers. Emit using the
				// qualified property form.
				// The value is output by a recursive call ON THE SAME NODE with
				// emitAsRDFValue set.
		
				if (hasRDFResourceQual)
				{
					throw new XMPException("Can't mix rdf:resource and general qualifiers",
							XMPError.BADRDF);
				}
				
				write(" rdf:parseType=\"Resource\">");
				writeNewline();
		
				serializePrettyRDFProperty(node, true);
			
				for each (qual in node.qualifier)
				{
					if (!isRDFQualifier(qual))
					{	
						serializePrettyRDFProperty(qual, false);
					}
				}
			}
			else
			{
				// This node has no general qualifiers. Emit using an unqualified form.
				if (node is XMPProperty)
				{
					// This is a simple property.
					if ((node as XMPProperty).uri)
					{
						write(" rdf:resource=\"");
						writeEncodedValue((node as XMPProperty).value, true);
						write("\"/>");
						writeNewline();
						emitEndTag = false;
					}
					else if ((node as XMPProperty).value == null  ||  (node as XMPProperty).value == "")
					{
						write("/>");
						writeNewline();
						emitEndTag = false;
					} 
					else
					{
						write('>');
						writeEncodedValue((node as XMPProperty).value, false);
						indentEndTag = false;
					}
				}
				else if (node is XMPArray)
				{
					// This is an array.
					write('>');
					writeNewline();
					emitRDFArrayTag(node as XMPArray, true);
					
					// add x-default item to alt-text arrays
					if (options.addXDefault)
					{
						node = addXDefaultItem(node as XMPArray);
					}
					
					for each (var child: XMPNode in node)
					{
						increaseIndent();
							serializePrettyRDFProperty(child, false);
						decreaseIndent();
					}
					emitRDFArrayTag(node as XMPArray, false);
				} 
				else if (!hasRDFResourceQual)
				{
					// This is a "normal" struct, use the rdf:parseType="Resource" form.
					if ((node as XMPStruct).length == 0) // no children
					{
						write(" rdf:parseType=\"Resource\"/>");
						writeNewline();
						emitEndTag = false;
					}
					else
					{
						write(" rdf:parseType=\"Resource\">");
						writeNewline();
						for each (child in node)
						{
							serializePrettyRDFProperty(child, false);
						}
					}
				}
				else
				{
					// This is a struct with an rdf:resource attribute, use the
					// "empty property element" form.
					for each (child in node)
					{
						if (!canBeRDFAttrProp(child))
						{
							throw new XMPException("Can't mix rdf:resource and complex fields",
									XMPError.BADRDF);
						}
						writeNewline();
						writeIndent();
						write(' ');
						prefix = xmp.getPrefix(child.qname.uri);
	 					write(prefix + ":" + child.qname.localName + '="');				
						writeEncodedValue((child as XMPProperty).value, true);
						write('"');
					}
					write("/>");
					writeNewline();
					emitEndTag = false;
				}
			}
		decreaseIndent();
		// Emit the property element end tag.
		if (emitEndTag)
		{
			if (indentEndTag) 
			{
				writeIndent();
			}
			write("</");
			write(elemName);
			write('>');
			writeNewline();
		}		
	}
		

	/**
	 * A node can be serialized as RDF-Attribute, if it meets the following conditions:
	 * <ul>
	 *  	<li>is not array item
	 * 		<li>don't has qualifier
	 * 		<li>is no URI
	 * 		<li>is no composite property
	 * </ul> 
	 * 
	 * @param node an XMPNode
	 * @return Returns true if the node serialized as RDF-Attribute
	 */
	private function canBeRDFAttrProp(node: XMPNode): Boolean
	{
		return	node is XMPProperty  &&
				!(node as XMPProperty).uri  &&
				node.qname != null  &&
				node.qualifier.length == 0;
	}


	/**
	 * Writes the array start and end tags.
	 *  
	 * @param arrayNode an array node
	 * @param isStartTag flag if its the start or end tag
	 */
	private function emitRDFArrayTag(array: XMPArray, isStartTag: Boolean): void 
	{
		if (isStartTag  ||  array.length > 0)
		{
			writeIndent();
			write(isStartTag ? "<rdf:" : "</rdf:");
		
			switch (array.getType())
			{
				case XMPArray.SEQ:		write("Seq"); break;
				case XMPArray.ALT: 		write("Alt"); break;
				default:				write("Bag"); break;
			}

			if (isStartTag  &&  array.length == 0)
			{
				write("/>");
			}
			else
			{
				write(">");
			}
			
			writeNewline();
		}	
	}


	/**
	 * Serializes the node value in XML encoding. Its used for tag bodies and
	 * attributes.
	 * <br>
	 * <em>Note:</em> The attribute is always limited by quotes,
	 *                thats why <code>&amp;apos;</code> is never serialized. 
	 * <br>
	 * <em>Note:</em> Control chars are written unescaped, but if the user uses others than tab, 
	 *                LF and CR the resulting XML will become invalid.
	 * 
	 * @param value the value of the node
	 * @param forAttribute flag if value is an attribute value
	 */
	private function writeEncodedValue(value: String, forAttribute: Boolean): void
	{
		// catch null values
		if (value == null)
		{
			return;
		}
		
		// fast path: check if escaping is necessary
		var needsEscaping: Boolean = false;
		for (var i: int = 0; i < value.length; i++)
        {
            var c: String = value.charAt(i);
			if (
				 c == '<'  ||  c == '>'  ||  c == '&'  ||	// XML element chars
				(forAttribute  &&  c == '"'))				// add quote for attrs	
			{
				needsEscaping = true;
				break;
			}
        }
				
		if (needsEscaping)
		{
			// slow path
			var x: XML;
			
			if (forAttribute)
			{
				x = <a b={value}/>;
				value = x.attributes()[0].toXMLString();
			}
			else // for tag body
			{
				// preserve leading and trailing spaces by adding X
				value = "X" + value + "X";
				x = <a>{value}</a>;

				value = x.text()[0].toXMLString();
				value = value.substr(1, value.length - 2);
			}
		}		
		
		write(value);
	}


	/** 
	 * Writes all used namespaces of the subtree in node to the output. 
	 * The subtree is recursivly traversed.
	 * 
	 * @param node the root node of the subtree
	 * @param usedNS an array of all namespace uris used.
	 */
	private function declareUsedNamespaces(node: XMPNode, usedNS: Array): void
	{
		if (!(node is XMPMeta)  &&  node.qname != null)
		{
			declareNamespace(node.qname, usedNS);
		} 

		for each (var child: XMPNode in node)
		{
			declareUsedNamespaces(child, usedNS);
		}
		
		if (!(node is XMPMeta))
		{
			for each (var qual: XMPNode in node.qualifier)
			{
				declareUsedNamespaces(qual, usedNS);
			}
		}
	}


	/**
	 * Writes one namespace declaration to the output.
	 * 
	 * @param prefix a namespace prefix (without colon) or a complete qname (when namespace == null)
	 * @param namespace the a namespace
	 * @param usedNS an array containing currently used namespace uris
	 */
	private function declareNamespace(qname: QName, usedNS: Array): void
	{
		if (usedNS.indexOf(qname.uri) < 0)
		{
			// retrieve prefix
			var prefix: String = xmp.getPrefix(qname.uri);
			writeNewline();
			writeIndent();
			write('xmlns:' + prefix + '="' + qname.uri + '"');
			usedNS.push(qname.uri);
		}
	}
	

	/**
	 * Calulates the padding according to the options and 
	 * write padding and tail to the stream.
	 */
	private function addPaddingAndTail(): void
	{
		var padding: int = options.padding;
		
		if (!options.omitPacketWrapper)
		{
			// add padding only when packet is serialized
			if (options.exactPacketLength > 0)
			{
				padding = options.exactPacketLength;
				
				// the string length of the tail is equal to the length of the UTF-8 encoding
				var minSize: int;
				if (toString)
				{
					minSize = packetLength + tailStr.length;
				}
				else
				{
					minSize = output.length + tailStr.length * options.charSize;
				}
				
				if (minSize > padding)
				{
					throw new XMPException("Can't fit into specified packet size",
						XMPError.BADSERIALIZE);
				}
				padding -= minSize;	// Now the actual amount of padding to add.
			}
	
			// fix rest of the padding according to Unicode unit size.
			if (!toString && (padding % options.charSize) != 0)
			{
				throw new XMPException(
					"The exact packet size or padding must be a multiple of the Unicode element",
					XMPError.BADOPTIONS);
			}
			padding /= options.charSize;
			
			var newlineLen: int = options.newline.length;
			if (padding >= newlineLen)
			{
				padding -= newlineLen;	// Write this newline last.
				while (padding >= (100 + newlineLen))
				{
					write(spaces100);
					writeNewline();
					padding -= (100 + newlineLen);
				}
				write(spaces100.substr(0, padding));
				writeNewline();
			}
			else
			{
				write(spaces100.substr(0, padding));				
			}
		}	

		// writes the tail
		write(tailStr);
	}


	/**
	 * @param qual a qualifier
	 * @return Returns whether the qualifier is either xml:lang or and rdf:* qualifier.
	 */
	private function isRDFQualifier(qual: XMPNode): Boolean
	{
		return (
				qual.qname.uri == XMPConst.xml.uri  &&
				qual.qname.localName == "lang"
			)	||
			(
				qual.qname.uri == XMPConst.rdf.uri  &&
				RDF_ATTR_QUALIFIER.indexOf(qual.qname.localName) >= 0
			);
	}


	/**
	 * Increases the pretty printing indent.
	 */
	private function increaseIndent() : void { 
		_indent++; 
	}
	
	
	/**
	 * Decreases the pretty printing indent.
	 */
	private function decreaseIndent() : void { 
		if( _indent > 0 )
			_indent--; 
	}
	
	
	/**
	 * Writes indentation as deep as set by the identationlevel and 
	 * automatically includes the baseindent from the options. 
	 */
	private function writeIndent(): void
	{
		for (var i: int = options.baseIndent + _indent; i > 0; i--)
		{
			write(options.indent);
		}
	}
	
	
	/**
	 * Writes a newline according to the options.
	 */
	private function writeNewline(): void
	{
		write(options.newline);
	}
	
	
	/**
	 * Writes a String to the output int UTF-8 encoding.
	 * @param str a String
	 */
	private function writeUTF8(str: String): void
	{
		output.writeUTFBytes(str);
		packetLength += str.length;
	}


	/**
	 * Writes a String to the output in UTF-16BE or LE encoding.
	 * @param str a String
	 */
	private function writeUTF16(str: String): void
	{
		output.writeMultiByte(str, options.encodingLabel);
	}
	
	
	/**
	 * Make sure that the first item of an non-empty alt-text array has 
	 * the locale "x-default" at its first position.
	 * This method is triggered through the flag "addXDefault".<br>
	 * <em>Note:</em> Its does not fix broken alt text arrays. Alt text arrays are recognized
	 * by the existance of a language qualifier on the first item in the array.
	 *     
	 * @param  altText an alternative array that will be normalized. 
	 * @return Returns the altText node. When it has been modified, a clone of the original
	 * 		   node is returned (because the serializer must not change the data model).
	 */
	private function addXDefaultItem(altText: XMPArray): XMPArray
	{
		const xml: Namespace = XMPConst.xml;
		if (altText.getType() == XMPArray.ALT  &&
		    altText.length > 0)
		{
			var langQual: String = altText[1].qualifier.xml::lang.valueOf();				
			
			if (langQual != null  &&
				langQual != XMPConst.X_DEFAULT)
			{
				altText = altText.clone();	
				altText.lang[XMPConst.X_DEFAULT] = altText[1];
			}	
		}
		return altText;
	}
}
}