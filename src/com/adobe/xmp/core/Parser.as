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
	 * Parses the metadata in the RDF/XML form from the input buffer -- 
	 * either a String, a ByteBuffer or XML object.
	 */
	internal class Parser
	{
		/** qname x:xmpmeta */		
		private static const xmpmeta: QName = new QName(XMPConst.x, "xmpmeta"); 
		/** qname x:xapmeta */		
		private static const xapmeta: QName = new QName(XMPConst.x, "xapmeta"); 
		/** qname rdf:RDF */		
		private static const rdfRDF: QName = new QName(XMPConst.rdf, "RDF"); 
		/** reg exp to find the r/w flag */
		private static const rwFlagExpr: RegExp = /<\?xpacket end=['"](r|w)['"]\?>/;
		
		/** the resulting XMP metadata object */
		private var xmp: XMPMeta;
		
		
		/**
		 * Parses the xmpPacket into an XMPMeta object.
		 * @param xmpPacket	the packet can be either a String, a ByteArray or an XML object. 
		 *        All other objects are converted to a String.
		 * @param xmp the XMPMeta object the parsing result goes into.
		 * @param options the options for the parser.
		 */ 
		internal function parse(xmpPacket: Object, xmp: XMPMeta, 
			options: ParseOptions = null): void 
		{
			try
			{
				this.xmp = xmp;
				if (options == null)
				{
					options = new ParseOptions();
				}
				XML.ignoreComments = true;
				XML.ignoreWhitespace = options.ignoreWhitespaces;
				
				var xmpPacketStr: String; 			
				var input: XML;
				if (xmpPacket is ByteArray)
				{
					// determine encoding of array and set reading position
					var ba: ByteArray = xmpPacket as ByteArray;
					var encoding: String = determineEncoding(ba);
					if( encoding == "utf-8" )
					{
						// find r/w flag in UTF-8 ByteArray 
						findReadWriteFlagUTF8(ba);
						input = new XML(ba);
					}
					else
					{
						xmpPacketStr = ba.readMultiByte(ba.bytesAvailable, encoding);
						findReadWriteFlag(xmpPacketStr);
						input = new XML(xmpPacketStr);
					}
				}
				else if (xmpPacket is XML)
				{
					// the input is already an XML object
					input = xmpPacket as XML;
				}
				else
				{
					// use the toString() method
					xmpPacketStr = xmpPacket.toString();	
					findReadWriteFlag(xmpPacketStr);
					input = new XML(xmpPacketStr);
				}
			}
			catch (e: Error)
			{
				throw new XMPException("XML data is not well-formed.", XMPError.BADXML);				
			}

			try
			{
				input = findRootNode(input);
				
				new RDFXMLParser().parse(input, xmp, options);
				
				if (options.normalize)
				{
					Normalization.process(xmp);
				}				
			}
			catch (e: XMPException)
			{
				throw e;
			}
			catch (e: Error)
			{
				throw new XMPException("Unknown Error: " + e.message, XMPError.UNKNOWN);				
			}
		}
		
		
		
		/**
		 * Detects the encoding of the byte buffer, stores and returns it. 
		 * Only UTF-8, UTF-16LE/BE are recognized.
		 * <em>Note:</em> UTF-32 flavors are not supported by AS3.
		 *
		 * @return Returns the encoding string, either "utf-8", "unicode" or "unicodeFFFE".
		 */
		private function determineEncoding(buffer: ByteArray): String
		{
			buffer.position = 0;
			
			// needs two bytes at maximum to determine encoding
			if (buffer.length < 2)
			{
				// only one byte length must be UTF-8
				return "utf-8";
			}
			else if (buffer[0] == 0)
			{
				// Only case is:
				//   00 nn -- -- - Big endian UTF-16
				return "unicodeFFFE";
			} 
			else if ((buffer[0] & 0xFF) < 0x80)
			{
				// These cases are:
				//   nn mm -- -- - UTF-8, includes EF BB BF case
				//   nn 00 -- -- - Little endian UTF-16
		
				if (buffer[1] != 0)
				{
					return "utf-8";
				}
				else 
				{
					return "unicode";
				}
			}
			else
			{
				// These are the cases where a BOM is the first char:
				//   EF BB BF -- - UTF-8
				//   FE FF -- -- - Big endian UTF-16
				//   FF FE -- -- - Little endian UTF-16
		
				if ((buffer[0] & 0xFF) == 0xEF)
				{
					buffer.position = 3;
					return "utf-8";
				}
				else if ((buffer[0] & 0xFF) == 0xFE)
				{
					buffer.position = 2;
					return "unicodeFFFE"; // UTF-16 BE 
				}
				else
				{
					buffer.position = 2;
					return "unicode"; // UTF-16 LE
				}
			}
		}
		
		
		/**
		 * Find the XML node that is the root of the XMP data tree (rdf:RDF). 
		 * Generally this will be an outer node, but it could be anywhere 
		 * if a general XML document is parsed (e.g. SVG). <br>
		 * The XML parser normally picks the first rdf:RDF-node. 
		 * If there are several rdf:RDF-nodes, the one embraced by &lt;x:xmpmeta&gt; is picked.
		 * <p>
		 * Pick the first x:xmpmeta among multiple root candidates. If there aren't
		 * any, pick the first bare rdf:RDF if that is allowed. The returned root is
		 * the rdf:RDF child if an x:xmpmeta element was chosen. The search is
		 * breadth first, so a higher level candiate is chosen over a lower level
		 * one that was textually earlier in the serialized XML.
		 * 
		 * @param root the root of the xml document
		 * @param xmpmetaPassed needed for recursion. 
		 * The xmpmeta or xapmeta has been passed already (True), don't look further for that tag
		 * @return Returns the first &lt;rdf:RDF&gt;-node or <code>null</null>
		 */
		internal function findRootNode(root: XML, xmpmetaPassed: Boolean = false): XML
		{
			// 1. rdf:RDF is already root node
			if (root.localName() == "RDF"  &&  root.namespace().uri == XMPConst.rdf.uri)
			{
				return root;
			}
			
			// 2. look for x:xmpmeta or x:xapmeta node
			if (!xmpmetaPassed)
			{
				var xmpmetaNodes: XMLList = root.descendants(xmpmeta);
				if (xmpmetaNodes.length() == 0)
				{
					xmpmetaNodes = root.descendants(xapmeta);
				}
				if (xmpmetaNodes.length() > 0)
				{
					// walk recursively into the x:x(m|a)pmeta node,
					// but omit further check for xmpmeta-tags
					return findRootNode(xmpmetaNodes[0], true);
				}
			}	
			
			// 3. look for the rdf:RDF node
			var rdfNodes: XMLList = root.descendants(rdfRDF);
			return rdfNodes.length() > 0 ?
				rdfNodes[0] :
				null;
		}
		
		
		/**
		 * Reads the read/write flag from the closing tag of the xmp packet,
		 * <code>&lt;?xpacket end="r/w"?&gt;</code> and 
		 * set <code>XMPMeta#readOnly</code> accordingly. 
		 * 
		 * @param xmpPacket a string containing an xmp packet
		 */
		internal function findReadWriteFlag(xmpPacket: String): void
		{
			if (xmpPacket.length >= 19)
			{
				// fast path
				var endTag: String = xmpPacket.substr(xmpPacket.length - 19);
				var result: Array = endTag.match(rwFlagExpr);
				/* This path would only be needed if an XMP packet with packet wrapper
				   would be embedded in a bigger XML file. And only to read the r/w flag.
				if (result == null)
				{
					// slow path
					result = xmpPacket.match(rwFlagExpr);
					if (result != null)
						AppFunctions.Log("Jetzt");
				}
				*/
				
				if (result != null)
				{
					xmp.readOnly =  result[1] == "r";
				}
			}
		}
		
		
		internal function findReadWriteFlagUTF8 (xmpPacket: ByteArray): void
		{
			if (xmpPacket.length >= 19)
			{
				xmpPacket.position = xmpPacket.length - 19;
				var packetStr: String = xmpPacket.readUTFBytes(19);

				// fast path
				var result: Array = packetStr.match(rwFlagExpr);
				/* See comment in findReadWriteFlag().
				if (result == null)
				{
					// slow path
					xmpPacket.position = 0;
					packetStr = xmpPacket.readUTFBytes(xmpPacket.length);
					result = packetStr.match(rwFlagExpr);
					if (result != null)
						AppFunctions.Log("Jetzt");
				}
				*/
				
				if (result != null)
				{
					xmp.readOnly =  result[1] == "r";
				}
			}
		}
	}	
}