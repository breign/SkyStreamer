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
 * Contains normalization routines that are applied to parsed XMP data 
 * when the <code>normalize</code> flag in the parsing options is set.
 * @see ParseOptions#normalize
 */ 	
internal class Normalization
{
	/**
	 * Main entry for all normalization steps.
	 */
	internal static function process(xmp: XMPMeta): void
	{
		migrateAudioCopyright(xmp);
	} 
	
	
	/**
	 * The initial support for WAV files mapped a legacy ID3 audio copyright
	 * into a new <code>xmpDM:copyright</code> property. This is special-case code to migrate
	 * that into <code>dc:rights['x-default']</code>, using these rules:
	 * 
	 * <pre>
	 * 1. If there is no dc:rights array, or an empty array -
	 *    Create one with dc:rights['x-default'] set from double linefeed and xmpDM:copyright.
	 * 
	 * 2. If there is a dc:rights array but it has no x-default item -
	 *    Create an x-default item as a copy of the first item then apply rule #3.
	 * 
	 * 3. If there is a dc:rights array with an x-default item, 
	 *    Look for a double linefeed in the value.
	 *     A. If no double linefeed, compare the x-default value to the xmpDM:copyright value.
	 *         A1. If they match then leave the x-default value alone.
	 *         A2. Otherwise, append a double linefeed and 
	 *             the xmpDM:copyright value to the x-default value.
	 *     B. If there is a double linefeed, compare the trailing text to the xmpDM:copyright value.
	 *         B1. If they match then leave the x-default value alone.
	 *         B2. Otherwise, replace the trailing x-default text with the xmpDM:copyright value.
	 * 
	 * 4. In all cases, delete the xmpDM:copyright property.
	 * </pre>
	 * 
	 * @param xmp The metadata object.
	 */
	private static function migrateAudioCopyright (xmp: XMPMeta): void
	{
		try 
		{
			const xmpDM: Namespace = XMPConst.xmpDM;
			const dc: Namespace = XMPConst.dc;
			const xml: Namespace = XMPConst.xml;
			
			var dmCopyright: XMPNode = xmp.xmpDM::copyright;
			if (dmCopyright.exists())
			{
				var dmValue: String = dmCopyright.toString();
				const doubleLF: String  = "\n\n";
				
				var dcRights: XMPNode = xmp.dc::rights;
				
				if (dcRights == null  ||  dcRights.length == 0) 
				{
					// 1. No dc:rights array, create from double linefeed and xmpDM:copyright.
					xmp.dc::rights.lang[XMPConst.X_DEFAULT] = doubleLF + dmValue;		
				}
				else
				{
					// find x-default item
					var index: int = -1;
					for (var i: int = 1; i <= xmp.dc::rights.length; i++)
					{
						if (xmp.dc::rights[i].qualifier.xml::lang == XMPConst.X_DEFAULT)
						{
							index = i;		
						}
					}  
					
					if (index < 0)
					{
						// 2. No x-default item, create from the first item.
						xmp.dc::rights.lang[XMPConst.X_DEFAULT] = xmp.dc::rights[1];
						index = 1; 
					}
								
					// 3. Look for a double linefeed in the x-default value.
					var defaultNode: XMPProperty = xmp.dc::rights[index];
					var defaultValue: String = defaultNode.value;
					var lfPos: int = defaultValue.indexOf(doubleLF);
					
					if (lfPos < 0)
					{
						// 3A. No double LF, compare whole values.
						if (dmValue != defaultValue)
						{
							// 3A2. Append the xmpDM:copyright to the x-default item.
							defaultNode.value = defaultValue + doubleLF + dmValue;
						}
					}
					else
					{
						// 3B. Has double LF, compare the tail.
						if (defaultValue.substring(lfPos + 2) != dmValue)
						{
							// 3B2. Replace the x-default tail.
							defaultNode.value = defaultValue.substring(0, lfPos + 2) + dmValue;
						}
					}
				}
				
				// 4. Get rid of the xmpDM:copyright.
				delete xmp.xmpDM::copyright;
			}	
		}
		catch (e: XMPException)
		{
			// Don't let failures (like a bad dc:rights form) stop other cleanup.
		}
	}		
}
}