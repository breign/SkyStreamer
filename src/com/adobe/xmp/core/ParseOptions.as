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
     * Encapsulates a set of options that configure the parsing process
	 * for the <code>XMPMeta</code> constructor. For example: 
	 * <code>new XMPMeta(xmlObject, parseOptionsObject)</code>.
     * @see XMPMeta 
     */
    public final class ParseOptions
    {
    	/** When true, perform the normalization post-processing steps after parsing. 
    	 *  Currently the only such step is "migrate audio copyrights". 
    	 *  @see  Normalization */
    	public var normalize: Boolean = true;
		
    	/** When true, ignore leading and trailing whitespaces of properties during parsing. 
		 *  Setting this to false significantly impacts parsing performance. */ 
    	public var ignoreWhitespaces: Boolean = true;


    	/**
    	 * Creates a parse-options object.
		 * @param normalize The normalize flag value.
		 * @param ignoreWhitespaces The whitespace flag value.
		 * @return The new object.
    	 */
    	public function ParseOptions(
    		normalize: Boolean = true,
    		ignoreWhitespaces: Boolean = true)
    	{
    		this.normalize = normalize;
    		this.ignoreWhitespaces = ignoreWhitespaces;
    	}
    }
}