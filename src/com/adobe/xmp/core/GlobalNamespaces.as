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
	 * Stores the library global prefix-namespaces pairs. The registry is preset with the 
	 * known default namespaces. The class is used by the namespaces functions of XMPMeta.
	 * <em>Note:</em> The registered namespaces and prefixes are only used for serialization and for
	 * <code>XMPMeta#dumpObject()</code>.
	 */
	internal class GlobalNamespaces
	{
		/** registry to store the global namespaces */
		private static var _namespaces: NamespaceRegistry = null;
		

		/**
		 * @param ns a namespace uri
		 * @return Returns the registered prefix for a known namespace uri, 
		 * 		   or <code>null</code> for an unknown one.
		 */ 
		internal static function getPrefix(ns: String): String
		{
			return namespaces.getPrefix(ns);	
		}


		/**
		 * @param prefix a namespace prefix
		 * @return Returns the registered namespace uri for a known prefix, 
		 * 		   or <code>null</code> for an unknown one.
		 */ 
		internal static function getNamespace(prefix: String): String
		{
			return namespaces.getNamespace(prefix);	
		}


		/**
		 * @return Returns an array of all registered namespaces.
		 * 		   The contained <code>Namespace</code> objects contain both uri and prefix.
		 */
		internal static function getNamespaces(): Array
		{
			return namespaces.getNamespaces();	
		}
		
		
		/**
		 * Registers a new namespace-prefix pair.
		 * 
		 * @param ns a namespace uri
		 * @param prefix the proposed prefix.
		 * @return Returns a Namespace the registered <code>Namespace</code> for immediate use.
		 */
		internal static function register(ns: String, prefix: String): Namespace
		{
			return namespaces.register(ns, prefix); 
		}


		/**
		 * Removes a namespace-prefix pair from the registry.
		 */ 
		internal static function unregister(ns: String): void
		{
			return namespaces.unregister(ns); 
		}
		
		
		/**
		 * Deregisters all global namespaces and frees the static memory with that.
		 */
		internal static function unregisterAll(): void
		{
			_namespaces = null;
		}
		
		
		/**
		 * Fill the global namespace registry with the known default namespaces.
		 */
		private static function registerDefaultNamespaces(): void
		{
			_namespaces.register(XMPConst.xml.uri, XMPConst.xml.prefix);
			_namespaces.register(XMPConst.rdf.uri, XMPConst.rdf.prefix);
			
			_namespaces.register(XMPConst.dc.uri, XMPConst.dc.prefix);
			_namespaces.register(XMPConst.xmp.uri, XMPConst.xmp.prefix);
			_namespaces.register(XMPConst.pdf.uri, XMPConst.pdf.prefix);
			_namespaces.register(XMPConst.photoshop.uri, XMPConst.photoshop.prefix);
			_namespaces.register(XMPConst.exif.uri, XMPConst.exif.prefix);
			_namespaces.register(XMPConst.aux.uri, XMPConst.aux.prefix);
			_namespaces.register(XMPConst.tiff.uri, XMPConst.tiff.prefix);
			_namespaces.register(XMPConst.png.uri, XMPConst.png.prefix);
			_namespaces.register(XMPConst.jpeg.uri, XMPConst.jpeg.prefix);
			_namespaces.register(XMPConst.jp2k.uri, XMPConst.jp2k.prefix);
			_namespaces.register(XMPConst.crs.uri, XMPConst.crs.prefix);
			_namespaces.register(XMPConst.asf.uri, XMPConst.asf.prefix);
			_namespaces.register(XMPConst.wav.uri, XMPConst.wav.prefix);
			_namespaces.register(XMPConst.swf.uri, XMPConst.swf.prefix);
			
			_namespaces.register(XMPConst.xmpRights.uri, XMPConst.xmpRights.prefix);
			_namespaces.register(XMPConst.xmpMM.uri, XMPConst.xmpMM.prefix);
			_namespaces.register(XMPConst.xmpBJ.uri, XMPConst.xmpBJ.prefix);
			_namespaces.register(XMPConst.xmpNote.uri, XMPConst.xmpNote.prefix);

			_namespaces.register(XMPConst.xmpDM.uri, XMPConst.xmpDM.prefix);
			_namespaces.register(XMPConst.xmpT.uri, XMPConst.xmpT.prefix);
			_namespaces.register(XMPConst.xmpTPg.uri, XMPConst.xmpTPg.prefix);
			_namespaces.register(XMPConst.xmpG.uri, XMPConst.xmpG.prefix);
			_namespaces.register(XMPConst.xmpGImg.uri, XMPConst.xmpGImg.prefix);

			_namespaces.register(XMPConst.stFnt.uri, XMPConst.stFnt.prefix);
			_namespaces.register(XMPConst.stDim.uri, XMPConst.stDim.prefix);
			_namespaces.register(XMPConst.stEvt.uri, XMPConst.stEvt.prefix);
			_namespaces.register(XMPConst.stRef.uri, XMPConst.stRef.prefix);
			_namespaces.register(XMPConst.stVer.uri, XMPConst.stVer.prefix);
			_namespaces.register(XMPConst.stJob.uri, XMPConst.stJob.prefix);
			_namespaces.register(XMPConst.stMfs.uri, XMPConst.stMfs.prefix);

			_namespaces.register(XMPConst.Iptc4xmpCore.uri, XMPConst.Iptc4xmpCore.prefix);
			_namespaces.register(XMPConst.DICOM.uri, XMPConst.DICOM.prefix);
			_namespaces.register(XMPConst.pdfaSchema.uri, XMPConst.pdfaSchema.prefix);
			_namespaces.register(XMPConst.pdfaProperty.uri, XMPConst.pdfaProperty.prefix);
			_namespaces.register(XMPConst.pdfaType.uri, XMPConst.pdfaType.prefix);
			_namespaces.register(XMPConst.pdfaField.uri, XMPConst.pdfaField.prefix);
			_namespaces.register(XMPConst.pdfaid.uri, XMPConst.pdfaid.prefix);
			_namespaces.register(XMPConst.pdfaExtension.uri, XMPConst.pdfaExtension.prefix);

			_namespaces.register(XMPConst.pdfx.uri, XMPConst.pdfx.prefix);
			_namespaces.register(XMPConst.pdfxid.uri, XMPConst.pdfxid.prefix);
			
			// Omitted Namespaces:
			// album, bmsp, creatorAtom
		}
		
		
		/**
		 * @return Creates and returns a singleton instance of the global namespace registry.
		 */ 		
		private static function get namespaces(): NamespaceRegistry
		{
			if (_namespaces == null)
			{
				_namespaces = new NamespaceRegistry();
				registerDefaultNamespaces();
			}
			return _namespaces;
		}
	}
}