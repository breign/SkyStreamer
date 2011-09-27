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
	import flash.utils.Proxy;
	import flash.utils.flash_proxy;

	use namespace flash_proxy; 
	
	
	/**
	 * This class provides the convenience access to the language item of the alt-text array.
	 */
	internal class AltTextFacade extends Proxy
	{
		/** Backreference to the Alt-Text array. */
		private var altText: XMPArray;
		/** Constant for xml Namespace */
		private const xml: Namespace = XMPConst.xml;		
		
		
		/**
		 * Constructor
		 * @param array the array has to be an alt-text array!
		 */
		public function AltTextFacade(altText: XMPArray)
		{
			if (altText.getType() != XMPArray.ALT)
			{
				throw new XMPException(
					"The language interface is only available to Alt arrays.",
					XMPError.BADPARAM);
			}
			this.altText = altText;	
		}


		/**
		 * Requests an array item from an alt-text array of the provided locale.
		 * This is done with these approaches:
		 * <ol>
		 * 		<li>The alt-text array contains an exact match with the provided locale</li>
		 * 		<li>Look for a partial match, removing the country subtag</li>
		 * 		<li>Look for an x-default item</li>
		 * 		<li>Choose the first item</li>
		 * </ol>
		 * 
		 * @param locale a locale string that conforms to RFC 3066 of the language that is 
		 * 		requested. It can also be just the language part of the locale. 
		 * @return Returns the array item that best matches the requested locale.
		 */ 
		override flash_proxy function getProperty(locale: *): *
		{
			AssertParameter.onlyLocalName("locale", locale);			
			AssertParameter.notEmpty("locale", locale);
			var localStr: String = LanguageUtils.normalizeLocale(locale);

			// flag triggers the return of the first valid array item
			var isXDefault: Boolean = localStr == XMPConst.X_DEFAULT;
			var xmlLang: String;
			
			var partialMatch: XMPNode;
			 
			// loop removes more and more tags en-US-xyz --> en-US --> en
			while (localStr.length > 0)
			{
				// iterate through lang items
				partialMatch = null;
				for each (var item: XMPNode in altText)
				{
					xmlLang = LanguageUtils.normalizeLocale(item.qualifier.xml::lang.valueOf());
					if (xmlLang == null  ||  xmlLang.length == 0  ||  !(item is XMPProperty))
					{
						continue;
					}
					
					// if isXDefault flag is set, return the first valid item
					// find exact match
					if (isXDefault  ||  xmlLang == localStr)
					{
						return item;
					}
					// find FIRST partial match of requested locale + "-"
					else if (partialMatch == null  &&  xmlLang.indexOf(localStr + "-") == 0)
					{
						partialMatch = item;
					}
				}
				
				// if no alt-text item matches exactly return a partial match if availabe 
				if (partialMatch != null)
				{
					return partialMatch; 
				}
				
				// remove a subtag
				localStr = localStr.substring(0, localStr.lastIndexOf("-"));
			}
			
			// no match found	
			return null;
		}

		
		/**
		 * Appends an item with the provided locale to an alt-text array.
		 * If an item with the same locale already exists in the array, 
		 * it is replaced, but without changing its positions. If it used to be the default
		 * item, it stays the default item.
		 * 
		 * @param locale the locale of the language item that is set.
		 * @param value the localized text value.
		 */
		override flash_proxy function setProperty(locale: *, value: *): void
		{
			AssertParameter.onlyLocalName("locale", locale);
			AssertParameter.notEmpty("locale", locale);
			AssertParameter.notEmpty("value", value);
			locale = LanguageUtils.normalizeLocale(locale);
			
			// look for an existing item with the same locale and replace the value in case
			var item: XMPNode;
			for each (item in altText)
			{
				var xmlLang: String = item.qualifier.xml::lang.valueOf();
				if (locale == xmlLang  &&  item is XMPProperty)
				{
					(item as XMPProperty).value = value;
					return;
				}
			}
			
			// append a new language node;
			// in case of x-default, add it to the first position
			item = new XMPProperty(null, value);
			item.qualifier.xml::lang = locale;
			if (locale != XMPConst.X_DEFAULT)
			{
				altText.append(item);
			}
			else
			{
				altText.insert(1, item);
			}	
			altText.acceptImplicitNodes(); 
		}		
		
		
		override flash_proxy function callProperty(name:*, ... args):* 
		{
			throw new XMPException("This object does not support calling any methods",
				XMPError.BADSYNTAX); 
		}
		
		
		/**
		 * Makes the provided locale the default locale.
		 * Internally the very array item is moved to the top of the list.
		 * If there has been an x-default item, it is removed
		 * (the first item becomes the default).
		 */ 
		public function setDefault(locale: String): void
		{
			//no need to assert as parameter is string
			locale = LanguageUtils.normalizeLocale(locale);
			
			// find requested locale and move it upfront			
			for (var i:int = 1; i <= altText.length; i++)
			{
				var item: XMPNode = altText[i];
				if (locale == item.qualifier.xml::lang)
				{
					// nothing to do if i == 1
					if (i > 1)
					{
						altText.remove(i);
						altText.insert(1, item);
						
						// if locale has been moved up, 
						// remove x-default entry if existing  
						// (and if requested locale is not x-default itself)
						if (locale != XMPConst.X_DEFAULT)
						{
							for (var j: int = 1; j <= altText.length; j++)
							{
								item = altText[j];
								if (XMPConst.X_DEFAULT == item.qualifier.xml::lang)
								{
									altText.remove(j);
									break;
								}
							}
						}							
					}
					break;
				}
			}
		} 
	}
}
