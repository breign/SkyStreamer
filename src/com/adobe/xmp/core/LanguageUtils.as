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
	 * Utility functions for working with language locales.
	 */
	public class LanguageUtils
	{
		/**
		 * Normalizes an <code>xml:lang</code> value so that comparisons are effectively 
		 * case-insensitive as required by RFC 3066 (which superceeds RFC 1766). The
		 * normalization rules are:
		 * <ul>
		 * <li> The primary subtag is lower case, the suggested practice of ISO 639.
		 * <li> All 2-letter secondary subtags are upper case, the suggested
		 * practice of ISO 3166.
		 * <li> All other subtags are lower case.
		 * <li> The separator is a dash, not an underscore
		 * </ul>
		 * 
		 * @param value The raw value.
		 * @return The normalized value.
		 */
		public static function normalizeLocale(value: String): String
		{
			if (value == null)
			{
				return null;
			}
			
			// convert to lower case, but don't normalize x-default
			value = value.toLowerCase();
			if (value == XMPConst.X_DEFAULT)
			{
				return value;
			}	
			
			var subTag: int = 1;
			var result: String = "";
	
			for (var i: int = 0; i < value.length; i++)
			{
				switch (value.charAt(i))
				{
					case '-':
					case '_':
						// move to next subtag and convert underscore to hyphen
						result += '-';
						subTag++;
						break;
					case ' ':
						// remove spaces
						break;
					default:
						// convert second subtag to uppercase, all other to lowercase
						if (subTag != 2)
						{
							result += value.charAt(i);
						}
						else
						{
							result += value.charAt(i).toUpperCase();
						}
					}
			}

			return result;
		}
	}
}