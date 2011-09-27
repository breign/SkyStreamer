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
	 * Error-code constants passed in <code>XMPException</code> objects.
	 * @see XMPException
	 */
    public class XMPError
    {
		/** Unknown error */
		public static const UNKNOWN: int = 0;
		/** Thrown for XMP path expressions that cannot be resolved */
		public static const BADSYNTAX: int = 1;
		/** Thrown when something is wrong with a method parameter */
		public static const BADPARAM: int = 4;
		/** Thrown if inconsistent serializing options are provided */
		public static const BADOPTIONS: int = 103;
		/** Thrown for "index out of bounds" in XMPArrays */
		public static const BADINDEX: int = 104;
		/** Thrown for serializing problems */
		public static const BADSERIALIZE: int = 107;
		/** Thrown for XML parsing errors */
		public static const BADXML: int = 201;
		/** Thrown by the paser for RDF-specific parsing failures */
		public static const BADRDF: int = 202;
		/** Thrown by the paser for XMP-specific parsing failures */
		public static const BADXMP: int = 203;
    }
}
