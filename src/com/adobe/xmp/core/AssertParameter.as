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
	 * Contains assert utilities for method parameters.
	 */
	internal class AssertParameter
	{
		/**
		 * Checks whether a string is neither <code>null</code> nor empty.
		 */
		public static function notEmpty(param: String, value: String): void
		{
			if (value == null  ||  value.length == 0)
			{
				throw new XMPException("The parameter '" + param + "' must not be empty.", 
					XMPError.BADPARAM);
			}
		}


		/**
		 * Checks if a QName contains only a local name that must not be number.
		 */
		public static function onlyLocalName(param: String, value: *): void
		{
			if (value is QName  &&
				(value as QName).uri != null  &&  
				(value as QName).uri.length > 0)
				{
					throw new XMPException (
						"The parameter '" + param + "' must not be in a namespace.", XMPError.BADSYNTAX);
				}
			
			if ( ! isNaN(parseInt(value)) )
			{
				throw new XMPException (
					"The parameter '" + param + "' must be a String.", XMPError.BADSYNTAX);
			} 
		}
	}
}