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
 * Parser for RDF/XML files, provided in an XML object.
 */ 	
public class RDFXMLParser
{
	/** */
	public static const RDFTERM_OTHER: int = 0;
	/** */
	public static const RDFTERM_RDF: int = 1;
	/** */
	public static const RDFTERM_ID: int = 2;
	/** */
	public static const RDFTERM_ABOUT: int = 3;
	/** */
	public static const RDFTERM_PARSE_TYPE: int = 4;
	/** */
	public static const RDFTERM_RESOURCE: int = 5;
	/** */
	public static const RDFTERM_NODE_ID: int = 6;
	/** */
	public static const RDFTERM_DATATYPE: int = 7;
	/** */
	public static const RDFTERM_DESCRIPTION: int = 8; 
	/** */
	public static const RDFTERM_LI: int = 9;
	/** */
	public static const RDFTERM_ABOUT_EACH: int = 10; 
	/** */
	public static const RDFTERM_ABOUT_EACH_PREFIX: int = 11;
	/** */
	public static const RDFTERM_BAG_ID: int = 12;
	/** */
	public static const RDFTERM_FIRST_CORE: int = RDFTERM_RDF;
	/** */
	public static const RDFTERM_LAST_CORE: int = RDFTERM_DATATYPE;
	/** */
	public static const RDFTERM_FIRST_SYNTAX: int = RDFTERM_FIRST_CORE;
	/** */
	public static const RDFTERM_LAST_SYNTAX: int = RDFTERM_LI;
	/** */
	public static const RDFTERM_FIRST_OLD: int = RDFTERM_ABOUT_EACH;
	/** */
	public static const RDFTERM_LAST_OLD: int = RDFTERM_BAG_ID;	
	/** pwhitespaces */
	public static const WHITESPACES: Array = [0x20, 0x09, 0x0A, 0x0D, 0x0B, 0x0C, 
		0x1C, 0x1D, 0x1E, 0x1F, 0xA0, 0x2007];
	
	/** the XMP object to store the parsing results */
	private var xmp: XMPMeta;  
	/** the parsing options */
	private var options: ParseOptions;
	
	
	/**
  	 * The main parsing method. The XML tree is walked through from the root node and and XMP tree
	 * is created. This is a raw parse, the normalisation of the XMP tree happens outside.
	 * Each of these parsing methods is responsible for recognizing an RDF
	 * syntax production and adding the appropriate structure to the XMP tree.
	 * They simply return for success, failures will throw an exception.
	 * 
 	 * 7.2.9 start-element(URI == rdf:RDF, attributes == set())
	 *       nodeElementList
	 *       end-element()
	 *  
	 * @param rdfRDF the input XML file, "rdf:Rdf" has to be the outer node
	 * @param xmp the XMP object to store the parsing results
	 * @param options the parsing options
	 */ 
	public function parse(rdfRDF: XML, xmp: XMPMeta, options: ParseOptions): void 
	{
		if (rdfRDF == null)
		{
			return;
		}
		else if (rdfRDF.attributes().length() == 0)
		{
			this.xmp = xmp;
			this.options = options;
			rdf_NodeElementList (rdfRDF);
		}	
		else
		{	
			throw new XMPException("Invalid attributes of rdf:RDF element", XMPError.BADRDF);
		}
	}


	/**
	 * 7.2.10 nodeElementList<br>
	 * ws* ( nodeElement ws* )*
	 * 
	 * Note: this method is only called from the rdf:RDF-node (top level)
	 * 
	 * @param rdfRdfNode the top-level xml node
	 */
	private function rdf_NodeElementList(rdfRdfNode: XML): void 
	{
		for each (var child: XML in rdfRdfNode.children())
		{
			if (!isWSNode(child))
			{
				rdf_NodeElement(xmp, child);
			}	
		}
	}


	/**
 	 * 7.2.5 nodeElementURIs
	 * 		anyURI - ( coreSyntaxTerms | rdf:li | oldTerms )
	 *
 	 * 7.2.11 nodeElement
	 * 		start-element ( URI == nodeElementURIs,
	 * 		attributes == set ( ( idAttr | nodeIdAttr | aboutAttr )?, propertyAttr* ) )
	 * 		propertyEltList
	 * 		end-element()
	 * 
	 * A node element URI is rdf:Description or anything else that is not an RDF
	 * term.
	 * 
	 * @param xmpParent the parent xmp node
	 * @param xmlNode the currently processed XML node
	 */
	private function rdf_NodeElement(xmpParent: XMPNode, xmlNode: XML): void
	{
		var nodeTerm: int = getRDFTermKind (xmlNode);
		if (nodeTerm != RDFTERM_DESCRIPTION  &&  nodeTerm != RDFTERM_OTHER)
		{
			throw new XMPException("Node element must be rdf:Description or typed node",
				XMPError.BADRDF);
		}
		else if (xmpParent == xmp  &&  nodeTerm == RDFTERM_OTHER)
		{
			throw new XMPException("Top level typed node not allowed", XMPError.BADXMP);
		}
		else
		{
			rdf_NodeElementAttrs (xmpParent, xmlNode);
			rdf_PropertyElementList (xmpParent, xmlNode);
		}
	}


	/**
	 * 
	 * 7.2.7 propertyAttributeURIs
	 * 		anyURI - ( coreSyntaxTerms | rdf:Description | rdf:li | oldTerms )
	 *
	 * 7.2.11 nodeElement
	 * start-element ( URI == nodeElementURIs,
	 * 					attributes == set ( ( idAttr | nodeIdAttr | aboutAttr )?, propertyAttr* ) )
	 * 					propertyEltList
	 * 					end-element()
	 * 
	 * Process the attribute list for an RDF node element. A property attribute URI is 
	 * anything other than an RDF term. The rdf:ID and rdf:nodeID attributes are simply ignored, 
	 * as are rdf:about attributes on inner nodes.
	 * 
	 * @param xmpParent the parent xmp node
	 * @param xmlNode the currently processed XML node
	 */
	private function rdf_NodeElementAttrs(xmpParent: XMPNode, xmlNode: XML): void
	{
		// Used to detect attributes that are mutually exclusive.
		var exclusiveAttrs: int = 0;	
	
		for each (var attr: XML in xmlNode.attributes())  
		{
			var attrTerm: int = getRDFTermKind(attr);

			switch (attrTerm)
			{
				case RDFTERM_ABOUT:
				case RDFTERM_ID:
				case RDFTERM_NODE_ID:
					if (exclusiveAttrs > 0)
					{
						throw new XMPException("Mutally exclusive about, ID, nodeID attributes",
							XMPError.BADRDF);
					}
					
					exclusiveAttrs++;
	
					if (xmpParent == xmp  &&  attrTerm == RDFTERM_ABOUT)
					{
						// This is the rdf:about attribute on a top level node. Set
						// the XMP tree name if it doesn't have a name yet. 
						// Make sure this name matches the XMP tree name.
						if (xmp.name != null  &&  xmp.name.length > 0)
						{
							if (xmp.name != attr.toString())
							{
								throw new XMPException("Mismatched top level rdf:about values",
									XMPError.BADXMP);
							}
						}
						else
						{
							xmp.name = attr;
						}
					}
					break;
	
				case RDFTERM_OTHER:
					// this can be a simple property or an "rdf:value"  
					addChildNode(xmpParent, attr, XMPProperty);
					break;
	
				default:
					throw new XMPException("Invalid nodeElement attribute", XMPError.BADRDF);
			}

		}		
	}


	/**
	 * 7.2.13 propertyEltList
	 * ws* ( propertyElt ws* )*
	 * 
	 * @param xmpParent the parent xmp node
	 * @param xmlParent the currently processed XML node
	 */
	private function rdf_PropertyElementList(xmpParent: XMPNode, 
		xmlParent: XML): void
	{
		for each (var child: XML in xmlParent.children())  
		{
			if (child.nodeKind() == "element")
			{
				rdf_PropertyElement(xmpParent, child);
			}
			else if (!isWSNode(child))
			{
				throw new XMPException("Expected property element node not found", XMPError.BADRDF);
			}	
		}
	}


	/**
	 * 7.2.14 propertyElt
	 * 
	 *		resourcePropertyElt | literalPropertyElt | parseTypeLiteralPropertyElt |
	 *		parseTypeResourcePropertyElt | parseTypeCollectionPropertyElt | 
	 *		parseTypeOtherPropertyElt | emptyPropertyElt
	 *
	 * 7.2.15 resourcePropertyElt
	 *		start-element ( URI == propertyElementURIs, attributes == set ( idAttr? ) )
	 *		ws* nodeElement ws*
	 *		end-element()
	 *
	 * 7.2.16 literalPropertyElt
	 *		start-element (
	 *			URI == propertyElementURIs, attributes == set ( idAttr?, datatypeAttr?) )
	 *		text()
	 *		end-element()
	 *
	 * 7.2.17 parseTypeLiteralPropertyElt
	 *		start-element (
	 *			URI == propertyElementURIs, attributes == set ( idAttr?, parseLiteral ) )
	 *		literal
	 *		end-element()
	 *
	 * 7.2.18 parseTypeResourcePropertyElt
	 *		start-element (
	 *			 URI == propertyElementURIs, attributes == set ( idAttr?, parseResource ) )
	 *		propertyEltList
	 *		end-element()
	 *
	 * 7.2.19 parseTypeCollectionPropertyElt
	 *		start-element (
	 *			URI == propertyElementURIs, attributes == set ( idAttr?, parseCollection ) )
	 *		nodeElementList
	 *		end-element()
	 *
	 * 7.2.20 parseTypeOtherPropertyElt
	 *		start-element ( URI == propertyElementURIs, attributes == set ( idAttr?, parseOther ) )
	 *		propertyEltList
	 *		end-element()
	 *
	 * 7.2.21 emptyPropertyElt
	 *		start-element ( URI == propertyElementURIs,
	 *			attributes == set ( idAttr?, ( resourceAttr | nodeIdAttr )?, propertyAttr* ) )
	 *		end-element()
	 *
	 * The various property element forms are not distinguished by the XML element name, 
	 * but by their attributes for the most part. The exceptions are resourcePropertyElt and 
	 * literalPropertyElt. They are distinguished by their XML element content.
	 *
	 * NOTE: The RDF syntax does not explicitly include the xml:lang attribute although it can 
	 * appear in many of these. We have to allow for it in the attibute counts below.	 
	 *  
	 * @param xmpParent the parent xmp node
	 * @param xmlNode the currently processed XML node
	 */
	private function rdf_PropertyElement(xmpParent: XMPNode, xmlNode: XML): void
	{
		var nodeTerm: int = getRDFTermKind (xmlNode);
		if (!isPropertyElementName(nodeTerm)) 
		{
			throw new XMPException("Invalid property element name", XMPError.BADRDF);
		}
		else if (xmlNode.attributes().length() > 3)
		{
			// Only an emptyPropertyElt can have more than 3 attributes.
			rdf_EmptyPropertyElement(xmpParent, xmlNode);
		} 
		else 
		{
			// Look through the attributes for one that isn't rdf:ID or xml:lang, 
			// it will usually tell what we should be dealing with. 
			// The called routines must verify their specific syntax!
	
			for each (var attr: XML in xmlNode.attributes())
			{
				var attrLocal: String = attr.localName();
				var attrValue: String = attr;
				var isRDF: Boolean = attr.namespace() == XMPConst.rdf;
				
				if (!(attrLocal == "lang"  &&  attr.namespace() == XMPConst.xml)  &&
					!(isRDF  &&  attrLocal == "ID"))
				{
					if (isRDF  &&  attrLocal == "datatype")
					{
						rdf_LiteralPropertyElement (xmpParent, xmlNode);
					}
					else if (!(isRDF  &&  attrLocal == "parseType"))
					{
						rdf_EmptyPropertyElement (xmpParent, xmlNode);
					}
					else if (attrValue == "Literal")
					{
						rdf_ParseTypeLiteralPropertyElement();
					}
					else if (attrValue == "Resource")
					{
						rdf_ParseTypeResourcePropertyElement(xmpParent, xmlNode);
					}
					else if (attrValue == "Collection")
					{
						rdf_ParseTypeCollectionPropertyElement();
					}
					else
					{
						rdf_ParseTypeOtherPropertyElement();
					}
		
					return;
				}
			}
			
			// Only rdf:ID and xml:lang, could be a resourcePropertyElt, a literalPropertyElt, 
			// or an emptyPropertyElt. Look at the child XML nodes to decide which.

			if (xmlNode.hasComplexContent())
			{
				rdf_ResourcePropertyElement(xmpParent, xmlNode);
			}
			else if (xmlNode.children().length() > 0)
			{
				rdf_LiteralPropertyElement (xmpParent, xmlNode);
			}
			else
			{
				rdf_EmptyPropertyElement (xmpParent, xmlNode);
			}	
		}		
	}


	/**
	 * 7.2.15 resourcePropertyElt
	 *		start-element ( URI == propertyElementURIs, attributes == set ( idAttr? ) )
	 *		ws* nodeElement ws*
	 *		end-element()
	 *
	 * This handles structs using an rdf:Description node, 
	 * arrays using rdf:Bag/Seq/Alt, and typedNodes. It also catches and cleans up qualified 
	 * properties written with rdf:Description and rdf:value.
	 * 
	 * @param xmpParent the parent xmp node
	 * @param xmlNode the currently processed XML node
	 */
	private function rdf_ResourcePropertyElement(xmpParent: XMPNode, xmlNode: XML): void
	{
		var qualifier: XMPNode;
		
		// walk through the attributes
		for each (var attr: XML in xmlNode.attributes())
		{
			if (attr.localName() == "lang"  &&  attr.namespace() == XMPConst.xml)
			{
				qualifier = addQualifierNode (null, attr, attr);
			} 
			else if (attr.localName() == "ID"  &&  attr.namespace() == XMPConst.rdf)
			{
				// Ignore all rdf:ID attributes.
				continue;	
			}
			else
			{
				throw new XMPException(
					"Invalid attribute for resource property element", XMPError.BADRDF);
			}
		}

		// walk through the children
		var newCompound: XMPNode; 		
		var found: Boolean = false;
		for each (var currChild: XML in xmlNode.children())
		{
			if (isWSNode(currChild))
			{
				continue;
			}
			else if (currChild.nodeKind() == "element"  &&  !found)
			{
				var isRDF: Boolean = currChild.namespace() == XMPConst.rdf;
				var childLocal: String = currChild.localName();
				
				if (isRDF  &&  childLocal == "Bag")
				{
					newCompound = addChildNode(xmpParent, xmlNode, XMPArray);
					(newCompound as XMPArray).setType(XMPArray.BAG);
				}
				else if (isRDF  &&  childLocal == "Seq")
				{
					newCompound = addChildNode(xmpParent, xmlNode, XMPArray);
					(newCompound as XMPArray).setType(XMPArray.SEQ);
				}
				else if (isRDF  &&  childLocal == "Alt")
				{
					newCompound = addChildNode(xmpParent, xmlNode, XMPArray);
					(newCompound as XMPArray).setType(XMPArray.ALT);
				}
				else
				{
					newCompound = addChildNode(xmpParent, xmlNode, XMPStruct);
					if (!isRDF  &&  childLocal != "Description")
					{
						var typeName: String = currChild.namespace();
						if (typeName == null)
						{
							throw new XMPException(
									"All XML elements must be in a namespace", XMPError.BADXMP);
						}
						typeName += ':' + childLocal;
						addQualifierNode (newCompound, 
							<rdf:type xmlns:rdf="{XMPConst.rdf.uri}"/>, typeName);
					}
				}

				if (qualifier != null)
				{
					newCompound.qualifier.children.addItem(qualifier);
				}
				
				rdf_NodeElement (newCompound, currChild);
				
				if (hasValueChild(newCompound))
				{
					fixupQualifiedNode (newCompound);
				} 
				
				found = true;
			}
			else if (found)
			{
				// found second child element
				throw new XMPException(
					"Invalid child of resource property element", XMPError.BADRDF);
			}
		}
		
		if (!found)
		{
			// didn't found any child elements
			throw new XMPException("Missing child of resource property element", XMPError.BADRDF);
		}
	}	


	/**
	 * 7.2.21 emptyPropertyElt
	 *		start-element ( URI == propertyElementURIs,
	 *						attributes == set (
	 *							idAttr?, ( resourceAttr | nodeIdAttr )?, propertyAttr* ) )
	 *		end-element()
	 *
	 *	<ns:Prop1/>  <!-- a simple property with an empty value --> 
	 *	<ns:Prop2 rdf:resource="http: *www.adobe.com/"/> <!-- a URI value --> 
	 *	<ns:Prop3 rdf:value="..." ns:Qual="..."/> <!-- a simple qualified property --> 
	 *	<ns:Prop4 ns:Field1="..." ns:Field2="..."/> <!-- a struct with simple fields -->
	 *
	 * An emptyPropertyElt is an element with no contained content, just a possibly empty set of
	 * attributes. An emptyPropertyElt can represent three special cases of simple XMP properties: a
	 * simple property with an empty value (ns:Prop1), a simple property whose value is a URI
	 * (ns:Prop2), or a simple property with simple qualifiers (ns:Prop3). 
	 * An emptyPropertyElt can also represent an XMP struct whose fields are all simple and 
	 * unqualified (ns:Prop4).
	 *
	 * It is an error to use both rdf:value and rdf:resource - that can lead to invalid  RDF in the
	 * verbose form written using a literalPropertyElt.
	 *
	 * The XMP mapping for an emptyPropertyElt is a bit different from generic RDF, partly for 
	 * design reasons and partly for historical reasons. The XMP mapping rules are:
	 * <ol> 
	 *		<li> If there is an rdf:value attribute then this is a simple property
	 *				 with a text value.
	 *		All other attributes are qualifiers.
	 *		<li> If there is an rdf:resource attribute then this is a simple property 
	 *			with a URI value. 
	 *		All other attributes are qualifiers.
	 *		<li> If there are no attributes other than xml:lang, rdf:ID, or rdf:nodeID
	 *				then this is a simple 
	 *		property with an empty value. 
	 *		<li> Otherwise this is a struct, the attributes other than xml:lang, rdf:ID, 
	 *				or rdf:nodeID are fields. 
	 * </ol>
	 * 
	 * @param xmpParent the parent xmp node
	 * @param xmlNode the currently processed XML node
	 */
	private function rdf_EmptyPropertyElement(xmpParent: XMPNode, xmlNode: XML): void
	{
		var hasPropertyAttrs: Boolean = false;
		var hasResourceAttr: Boolean  = false;
		var hasNodeIDAttr: Boolean    = false;
		var hasValueAttr: Boolean     = false;
		
		// Can come from rdf:value or rdf:resource.
		var valueNode: XML = null;	
		
		if (xmlNode.children().length() > 0)
		{
			throw new XMPException(
				"Nested content not allowed with rdf:resource or property attributes",
				XMPError.BADRDF);
		}
		
		// First figure out what XMP this maps to and remember the XML node for a simple value.
		for each (var attr: XML in xmlNode.attributes())
		{
			var attrTerm: int = getRDFTermKind(attr);

			switch (attrTerm)
			{
				case RDFTERM_ID :
					// Nothing to do.
					break;

				case RDFTERM_RESOURCE :
					if (hasNodeIDAttr)
					{
						throw new XMPException(
							"Empty property element can't have both rdf:resource and rdf:nodeID",
							XMPError.BADRDF);
					}
					else if (hasValueAttr)
					{
						throw new XMPException(
								"Empty property element can't have both rdf:value and rdf:resource",
								XMPError.BADXMP);
					}

					hasResourceAttr = true;
					if (!hasValueAttr) 
					{
						valueNode = attr;
					}	
					break;

				case RDFTERM_NODE_ID:
					if (hasResourceAttr)
					{
						throw new XMPException(
								"Empty property element can't have both rdf:resource and rdf:nodeID",
								XMPError.BADRDF);
					}
					hasNodeIDAttr = true;
				break;

			case RDFTERM_OTHER:
				if (attr.localName() == "value"  &&
					attr.namespace() == XMPConst.rdf)
				{
					if (hasResourceAttr)
					{
						throw new XMPException(
								"Empty property element can't have both rdf:value and rdf:resource",
								XMPError.BADXMP);
					}
					hasValueAttr = true;
					valueNode = attr;
				}
				else if (attr.localName() != "lang"  &&
						 attr.namespace() != XMPConst.xml)
				{
					hasPropertyAttrs = true;
				}
				break;

			default:
				throw new XMPException("Unrecognized attribute of empty property element",
					XMPError.BADRDF);
			}
		}
		
		// Create the right kind of child node and visit the attributes again 
		// to add the fields or qualifiers.
		var childNode: XMPNode;
		if (hasValueAttr || hasResourceAttr)
		{
			// create a simple property
			childNode = addChildNode(xmpParent, xmlNode, XMPProperty);
			
			(childNode as XMPProperty).value = valueNode != null ? valueNode.toString() : "";
			if (hasResourceAttr)
			{
				// ! Might have both rdf:value and rdf:resource.
				(childNode as XMPProperty).uri = true;	
			}
		}
		else if (hasPropertyAttrs)
		{
			// create a struct
			childNode = addChildNode(xmpParent, xmlNode, XMPStruct);
		}
		else
		{
			// create a simple property
			childNode = addChildNode(xmpParent, xmlNode, XMPProperty);
		}
		
		for each (attr in xmlNode.attributes())
		{
			if (attr == valueNode)
			{
				// Skip the rdf:value or rdf:resource attribute holding the value.				
				continue;
			}
			
			attrTerm = getRDFTermKind (attr);

			switch (attrTerm)
			{
				case RDFTERM_ID :
				case RDFTERM_NODE_ID :
					// Ignore all rdf:ID and rdf:nodeID attributes.
					break;
					
				case RDFTERM_RESOURCE :
					addQualifierNode(childNode, attr, attr);
					break;

				case RDFTERM_OTHER :
					if (!(childNode is XMPStruct))
					{
						addQualifierNode(childNode, attr, attr);
					}
					else if (attr.localName() == "lang"  &&
							 attr.namespace() == XMPConst.xml)
					{
						addQualifierNode (childNode, attr, attr);
					}
					else
					{
						addChildNode(childNode, attr, XMPProperty);
					}
					break;

				default :
					throw new XMPException("Unrecognized attribute of empty property element",
						XMPError.BADRDF);
			}

		}		
	}


	/**
	 * 7.2.16 literalPropertyElt
	 *		start-element ( URI == propertyElementURIs, 
	 *				attributes == set ( idAttr?, datatypeAttr?) )
	 *		text()
	 *		end-element()
	 *
	 * Add a leaf node with the text value and qualifiers for the attributes.
	 * 
	 * @param xmpParent the parent xmp node
	 * @param xmlNode the currently processed XML node
	 */	
	private function rdf_LiteralPropertyElement(xmpParent: XMPNode,
			xmlNode: XML): void
	{
		if (xmlNode.hasComplexContent())
		{
			throw new XMPException("Invalid child of literal property element", XMPError.BADRDF);
		}
		
		var langQual: XML = null;

		for each (var attr: XML in xmlNode.attributes())
		{
			if (attr.localName() == "lang"  &&  attr.namespace() == XMPConst.xml)
			{
				langQual = attr;
			} 
			else if (attr.namespace() == XMPConst.rdf  &&
					 (attr.localName() == "ID"  ||  attr.localName() == "datatype"))
			{
				// Ignore all rdf:ID and rdf:datatype attributes.				
				continue;	
			}
			else
			{
				throw new XMPException(
					"Invalid attribute for literal property element", XMPError.BADRDF);
			}
		}
		
		var prop: XMPNode = addChildNode(xmpParent, xmlNode, XMPProperty);
		if (langQual != null)
		{
			addQualifierNode(prop, langQual, langQual);			
		}	
	}


	/**
	 * 7.2.17 parseTypeLiteralPropertyElt
	 *		start-element ( URI == propertyElementURIs,
	 *			attributes == set ( idAttr?, parseLiteral ) )
	 *		literal
	 *		end-element()
	 */
	private function rdf_ParseTypeLiteralPropertyElement(): void
	{
		throw new XMPException("ParseTypeLiteral property element not allowed", XMPError.BADXMP);
	}


	/**
	 * 7.2.18 parseTypeResourcePropertyElt
	 *		start-element ( URI == propertyElementURIs, 
	 *			attributes == set ( idAttr?, parseResource ) )
	 *		propertyEltList
	 *		end-element()
	 *
	 * Add a new struct node with a qualifier for the possible rdf:ID attribute. 
	 * Then process the XML child nodes to get the struct fields.
	 * 
	 * @param xmpParent the parent xmp node
	 * @param xmlNode the currently processed XML node
	 */
	private function rdf_ParseTypeResourcePropertyElement(xmpParent: XMPNode, xmlNode: XML): void
	{
		var langQual: XML = null;
		for each (var attr: XML in xmlNode.attributes())
		{
			if (attr.localName() == "lang"  &&
				attr.namespace() == XMPConst.xml)
			{
				langQual = attr;
			}
			else if (attr.namespace() == XMPConst.rdf  &&
					 (attr.localName() == "ID"  ||  attr.localName() == "parseType"))
			{
				// The caller ensured the value is "Resource".
				// Ignore all rdf:ID attributes.				
				continue;	
			} 
			else
			{
				throw new XMPException("Invalid attribute for ParseType 'Resource' property element",
					XMPError.BADRDF);
			}
		}

		var newStruct: XMPNode = addChildNode(xmpParent, xmlNode, XMPStruct);
		if (langQual != null)
		{
			addQualifierNode (newStruct, langQual, langQual.toString());
		} 
		
		rdf_PropertyElementList (newStruct, xmlNode);

		if (hasValueChild(newStruct))
		{
			fixupQualifiedNode (newStruct);
		}
	}


	/**
	 * 7.2.19 parseTypeCollectionPropertyElt
	 *		start-element ( URI == propertyElementURIs, 
	 *			attributes == set ( idAttr?, parseCollection ) )
	 *		nodeElementList
	 *		end-element()
	 */
	private function rdf_ParseTypeCollectionPropertyElement(): void
	{
		throw new XMPException("ParseTypeCollection property element not allowed", XMPError.BADXMP);
	}


	/**
	 * 7.2.20 parseTypeOtherPropertyElt
	 *		start-element ( URI == propertyElementURIs, attributes == set ( idAttr?, parseOther ) )
	 *		propertyEltList
	 *		end-element()
	 */
	private function rdf_ParseTypeOtherPropertyElement(): void
	{
		throw new XMPException("ParseType Other property element not allowed", XMPError.BADXMP);
	}


	/**
	 * @param xmpParent an XMPNode
	 * @return Returns whether the node is a struct and contains an "rdf:value"-node as first child.
	 */
	private function hasValueChild(xmpParent: XMPNode): Boolean
	{
		if (!(xmpParent is XMPStruct)  ||
			xmpParent.length == 0)
		{
			return false;
		}
 		
 		var valueName: QName = xmpParent.children.getItemAt(0).qname;
 		return valueName.localName == "value"  &&
 			   valueName.uri == XMPConst.rdf.uri;
	}


	/**
	 * The parent is an RDF pseudo-struct containing an "rdf:value" field. Fix the
	 * XMP data model. The rdf:value node must be the first child, the other
	 * children are qualifiers. The form, value, and children of the rdf:value
	 * node are the real ones. The rdf:value node's qualifiers must be added to
	 * the others.
	 * 
	 * @param xmpParent the parent xmp node
	 */
	private function fixupQualifiedNode(xmpParent: XMPNode): void
	{
		// the value node will become the property node (no matter of which type it is),
		// the children and existing qualifer stay intact. 
		var valueNode: XMPNode = xmpParent.children.getItemAt(0);

		// Move the qualifiers of the xmpParent node to the valueNode's qualifiers.
		for each (var qualifier: XMPNode in xmpParent.qualifier)
		{
			moveRdfValueQualifier(qualifier, valueNode);
		}
		
		// Change the parent's other children (except the rdf:value-node itself) 
		// into qualifiers of the value node
		for each (var child: XMPNode in xmpParent)
		{
			if (child != valueNode)
			{
				moveRdfValueQualifier(child, valueNode);
			} 	
		} 

		// overwrite the original xmpParent with the valueNode
		var parent: XMPNode = xmpParent.parent;
		if (parent is XMPArray)
		{
			// remove last array item
			(parent as XMPArray).remove(parent.length);
			(parent as XMPArray).append(valueNode);	
		}
		else
		{
			// overwrite temporary struct
			parent[xmpParent.qname] = valueNode;
		}	
	}		


	/**
	 * Moves a qualifier to another node.
	 * 
	 * @param qualifier the qualifier node
	 * @param dest the destination node
	 */ 
	private function moveRdfValueQualifier(qualifier: XMPNode, dest: XMPNode): void
	{
		if (qualifier.qname.localName == "lang"  &&
			qualifier.qname.uri == XMPConst.xml.uri)
		{
			assertNodeNotExisting(dest.qualifier, qualifier.qname,
				"Redundant xml:lang for rdf:value element");
			dest.qualifier.children.addItemAt(qualifier, 0);
		}
		else
		{
			assertNodeNotExisting(dest.qualifier, qualifier.qname);
			dest.qualifier.children.addItem(qualifier);
		} 
	}


	/**
	 * Adds a child node of the provided type. 
	 * It can as well be an array item or an "rdf:value" node.
	 * The latter has to be at the first position.
	 * 
	 * @param xmpParent the node to add a child to 
	 * @param child the XML node that provides the node name
	 * @param nodeType the type of the node to create, one of XMPProperty, XMPArray or XMPStruct.
	 * @return Returns the created child node.
	 */
	private function addChildNode(xmpParent: XMPNode, child: XML, nodeType: Class): XMPNode
	{
		// set flags for special nodes "rdf:li" and "rdf:value"
		var isArrayItem: Boolean = false;
		var isValueNode: Boolean = false;
		if (child.namespace() == XMPConst.rdf)
		{
			isArrayItem = child.localName() == "li";
			isValueNode = child.localName() == "value";
		}
			
		// do some checks
		if (isValueNode  &&  (xmp == xmpParent  ||  !(xmpParent is XMPStruct)))
		{
			throw new XMPException("Misplaced rdf:value element", XMPError.BADRDF);
		}
		else if (isArrayItem  &&  !(xmpParent is XMPArray)) 
		{
			throw new XMPException("Misplaced rdf:li element", XMPError.BADRDF);
		}


		var prop: XMPNode = new nodeType(child.name());
		if (prop is XMPProperty)
		{
			// add property value
			(prop as XMPProperty).value = child.toString();
		}
		
		// create and add property to data tree
		if (isArrayItem)
		{
			// array item
			(xmpParent as XMPArray).append(prop);
		}
		else if (isValueNode)
		{
			// rdf:value node
			assertNodeNotExisting(xmpParent, child.name());
			xmpParent.children.addItemAt(prop, 0);
		}
		else
		{
			// any other property
			var qname: QName = child.name();
			if (options.normalize  &&  XMPConst.dc_old == child.namespace())
			{
				// fix old DC namespace
				//child.setNamespace(XMPConst.dc);
				qname = new QName(XMPConst.dc.uri, child.localName());
			}
			
			assertNodeNotExisting(xmpParent, qname);
			checkAndRegisterNS(qname, child.namespace().prefix);
			xmpParent[qname] = prop;
		}
		
		return prop;
	}
	
	
	/**
	 * Adds a simple qualifier node.
	 * 
	 * @param xmpParent the parent xmp node
	 * @param qualNode the XML node representing the qualifier
	 * @param value the value of the XMPProperty node that becomes the qualifier 
	 * @return Returns the newly created qualifier node.
	 */
	private function addQualifierNode(xmpParent: XMPNode, qualNode: XML, value: String): XMPNode
	{
		assertNodeNotExisting(xmpParent.qualifier, qualNode.name());
		
		var isLang: Boolean = qualNode.localName() == "lang"  &&
			qualNode.namespace() == XMPConst.xml;
		if (!isLang)
		{
			checkAndRegisterNS(qualNode.name(), qualNode.namespace().prefix);
		}

		// normalize value of language qualifiers
		var newQual: XMPNode = new XMPProperty(null, 
			isLang ? LanguageUtils.normalizeLocale(value): value);
		xmpParent.qualifier[qualNode.name()] = newQual;
		
		return newQual;
	}		


	/**
	 * 7.2.6 propertyElementURIs
	 *			anyURI - ( coreSyntaxTerms | rdf:Description | oldTerms )
	 * 
	 * 7.2.4 oldTerms<br>
	 * rdf:aboutEach | rdf:aboutEachPrefix | rdf:bagID
	 *
	 * 7.2.2 coreSyntaxTerms<br>
	 * rdf:RDF | rdf:ID | rdf:about | rdf:parseType | rdf:resource | rdf:nodeID |
	 * rdf:datatype
	 *  
	 * @param term the term id
	 * @return Return true if the term is a property element name.
	 */
	private function isPropertyElementName(term: int): Boolean
	{
		if (term == RDFTERM_DESCRIPTION  ||  
			// old terms
			term == RDFTERM_ABOUT_EACH  ||
			term == RDFTERM_ABOUT_EACH_PREFIX  ||
			term == RDFTERM_BAG_ID)
		{
			return false;
		}
		else
		{	
			// Not a core syntax term
			return term < RDFTERM_RDF  ||
				   term > RDFTERM_DATATYPE;
		}	
	}


	/**
	 * Asserts that a node of the same QName is not already existing in a struct.
	 * If it is existing, an exception is thrown.
	 * 
 	 * @param xmpParent a node that contains named children
	 * @param qname a QName
	 * @param msg the exception error message to display if the node is already existing. 
	 */
	private function assertNodeNotExisting(
		xmpParent: XMPNode, qname: QName, msg: String = null): void
	{
		if (xmpParent != null  &&
			qname != null  &&  xmpParent.children.getItemIndex(qname) >= 0)
		{
			if (msg == null)
			{
				msg = "Duplicate property or field node '" + qname + "'";
			}
			throw new XMPException(msg, XMPError.BADRDF);
		}	
	}


	/**
	 * Checks if every property name is in a namespace.
	 * The namespace and its assigned prefix is registered with the local namespace registry.
	 * If this XMP object is serialized later, the prefixes from the source packet are used.
	 * 
	 * @param nodeName the QName of the property
	 * @parem newPrefix the prefix from the source packet to register 
	 */
	private function checkAndRegisterNS(nodeName: QName, newPrefix: String): void
	{
		if (nodeName.uri != null  &&  nodeName.uri.length > 0)
		{
			var prefix: String = xmp.getPrefix(nodeName.uri, false);
			
			if (prefix == null  &&
				newPrefix != null  &&  newPrefix != "")
			{
				// Register only if the namespace contains a prefix
				xmp.registerNamespace(nodeName.uri, newPrefix);
			}
		}
		else
		{
			throw new XMPException(
				"XML namespace required for all elements and attributes", XMPError.BADRDF);
		}
	}	

	
	/**
	 * Determines the ID for a certain RDF Term.
	 * Arranged to hopefully minimize the parse time for large XMP.
	 * 
	 * @param node an XML node 
	 * @return Returns the RDF term ID.
	 */
	private function getRDFTermKind(node: XML): int
	{
		var localName: String = node.localName();
		var ns: String = node.namespace();
		
		if (ns == XMPConst.rdf.uri)
		{
			if (localName == "li")
			{
				return RDFTERM_LI;
			}
			else if (localName == "parseType")
			{
				return RDFTERM_PARSE_TYPE;
			}
			else if (localName == "Description")
			{
				return RDFTERM_DESCRIPTION;
			}
			else if (localName == "about")
			{
				return RDFTERM_ABOUT;
			}
			else if (localName == "resource")
			{
				return RDFTERM_RESOURCE;
			}
			else if (localName == "RDF")
			{
				return RDFTERM_RDF;
			}
			else if (localName == "ID")
			{
				return RDFTERM_ID;
			}
			else if (localName == "nodeID")
			{
				return RDFTERM_NODE_ID;
			}
			else if (localName == "datatype")
			{
				return RDFTERM_DATATYPE;
			}
			else if (localName == "aboutEach")
			{
				return RDFTERM_ABOUT_EACH;
			}
			else if (localName == "aboutEachPrefix")
			{
				return RDFTERM_ABOUT_EACH_PREFIX;
			}
			else if (localName == "bagID")
			{
				return RDFTERM_BAG_ID;
			}
		}
		
		return RDFTERM_OTHER;
	}
	
	
	/**
	 * Recognizes pure whitespace nodes.
	 * 
	 * @param an XML node
	 * @return Returns true if the node is a text node that contains ONLY whitespaces. 
	 */
	private function isWSNode(xml: XML): Boolean
	{
		if (xml.nodeKind() != "text")
		{
			return false;
		}
		else
		{
			var str: String = xml.toString();
			for (var i: int = 0; i < str.length; i++)
			{
				if (WHITESPACES.indexOf(str.charCodeAt(i)) < 0)
				{
					return false;
				}
			}
			return true;
		}	
	}
}
}