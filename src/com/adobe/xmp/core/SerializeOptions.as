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
	 * Encapsulates a set of options that configure the serialization process
	 * for the <code>XMPMeta</code> serialization methods. For example: 
	 * <code>XMPMeta.serializeToBuffer(serializeOptionsObject)</code>.
     * @see XMPMeta 
     */
    public final class SerializeOptions
    {
        /** Encoding UTF-8 (default) */
        public static const UTF8: int = 0;
        /** Encoding UTF-16 LE */
        public static const UTF16LE: int = 1;
        /** Encoding UTF-16 BE */
        public static const UTF16BE: int = 2;
    	


        /**
         * The encoding used for <code>XMPMeta.serializeToBuffer()</code>.
         * One of the constants <code>UTF8</code> (default), <code>UTF16LE</code>,
		 * or <code>UTF16BE</code>.   
         */
		public var encoding: int = UTF8; 
        
        
        /** 
         * The overall length of the serialized packet:
         * <ul>
         * 		<li><code>XMPMeta.serialize()</code>, determines the resulting String length.</li>
         * 		<li><code>XMPMeta.serializeToBuffer()</code>, determines the byte length of the 
		 * 				resulting ByteArray.</li>
         * </ul> 
         * If set to a value greater than zero, the serialization method computes the actual.  
         * amount of padding needed to achieve this length, and ignores the <code>padding</code> 
		 * value. The method throws an exception if the unpadded XMP Packet exceeds this length.
         */
        public var exactPacketLength: int = 0;


        /** 
         * The amount of padding to be added if a writeable XMP Packet is created. 
         * If the packet wrapper is omitted, the padding is also omitted, and this
		 * value is ignored.
         */
        public var padding: int = 2048;


        /** 
         * When true, the XMP Packet wrapper ("&lt;?xpacket ... ?&gt;") is omitted.
         * The wrapper also contains the padding. If the packet wrapper is omitted, 
		 * the padding is also omitted, regardless of the <code>padding</code> value.
         */
        public var omitPacketWrapper: Boolean = false;
        
        
        /** 
         * The number of levels of indentation to be used for the outermost XML element in the
         * serialized RDF. This is convenient when embedding the RDF in other text. Default is 0.
         */
        public var baseIndent: int = 0;
        
        
        /** 
         * The string to be used as a line terminator. Default is a linefeed, U+000A, 
         * the standard XML newline character.
         */
        public var newline: String = "\n";
        
        
        /** 
         * The string to be used for each level of indentation in the serialized
         * RDF. Defaults is two ASCII spaces, U+0020.
         */
        public var indent: String = "  ";
        
        
        /** 
         * When true, the XMP Toolkit version attribute is omitted.
         * This is helpful for comparison unit tests.
         */
        public var omitVersionAttribute: Boolean = false;
        

		/**
		 * When true, alt-text arrays are checked during serialization to see 
		 * if they contain an item with the <code>xml:lang="x-default"</code> language-qualifier.
		 * If the element already exists, nothing is changed. If the first item has another locale,
		 * it is duplicated, but with "x-default" as the language-qualifier value.
		 */ 
		public var addXDefault: Boolean = true; 
		
        
        /** 
		 * Retrieves the ActionScript Streams encoding label for this object's encoding type. 
         * @return The label string.
         */
        public function get encodingLabel(): String
        {
            switch (encoding)
            {
            	case UTF16LE:  return "unicode";
            	case UTF16BE:  return "unicodeFFFE";
            	default: return "utf-8";
            }
        }
        
        
        /**
		 * Reports the size of one character in the serialized packet, according
		 * to the encoding type.
         * @return The character size.
         */
        public function get charSize(): int
        {
        	return encoding == UTF8 ? 1 : 2;
        }
    }
}