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
	 * Defines constants for the XMPCore library, including
	 * constants for all Adobe default namespaces (with default prefixes), 
	 * and constants for valid option values for API methods.
	 */
	public class XMPConst
	{
		// Schema Namespaces
		
		public static const dc: Namespace = 
			new Namespace("dc", "http://purl.org/dc/elements/1.1/");
		public static const xmp: Namespace = 
			new Namespace("xmp", "http://ns.adobe.com/xap/1.0/");
		public static const xmpMM: Namespace = 
			new Namespace("xmpMM", "http://ns.adobe.com/xap/1.0/mm/");
		public static const xmpRights: Namespace = 
			new Namespace("xmpRights", "http://ns.adobe.com/xap/1.0/rights/");
		public static const swf: Namespace = 
			new Namespace("swf", "http://ns.adobe.com/swf/1.0/");

		public static const pdf: Namespace =
			new Namespace("pdf", "http://ns.adobe.com/pdf/1.3/");
		public static const photoshop: Namespace =
			new Namespace("photoshop", "http://ns.adobe.com/photoshop/1.0/");
		public static const exif: Namespace =
			new Namespace("exif", "http://ns.adobe.com/exif/1.0/");
		public static const aux: Namespace =
			new Namespace("aux", "http://ns.adobe.com/exif/1.0/aux/");
		public static const tiff: Namespace =
			new Namespace("tiff", "http://ns.adobe.com/tiff/1.0/");
		public static const png: Namespace =
			new Namespace("png", "http://ns.adobe.com/png/1.0/");
		public static const jpeg: Namespace =
			new Namespace("jpeg", "http://ns.adobe.com/jpeg/1.0/");
		public static const jp2k: Namespace =
			new Namespace("jp2k", "http://ns.adobe.com/jp2k/1.0/");
		public static const crs: Namespace =
			new Namespace("crs", "http://ns.adobe.com/camera-raw-settings/1.0/");
		public static const asf: Namespace =
			new Namespace("asf", "http://ns.adobe.com/asf/1.0/");
		public static const wav: Namespace =
			new Namespace("wav", "http://ns.adobe.com/xmp/wav/1.0/");
		public static const xmpBJ: Namespace =
			new Namespace("xmpBJ", "http://ns.adobe.com/xap/1.0/bj/");
		public static const xmpNote: Namespace =
			new Namespace("xmpNote", "http://ns.adobe.com/xmp/note/");
		public static const xmpDM: Namespace =
			new Namespace("xmpDM", "http://ns.adobe.com/xmp/1.0/DynamicMedia/");
		public static const xmpT: Namespace =
			new Namespace("xmpT", "http://ns.adobe.com/xap/1.0/t/");
		public static const xmpTPg: Namespace =
			new Namespace("xmpTPg", "http://ns.adobe.com/xap/1.0/t/pg/");
		public static const xmpG: Namespace =
			new Namespace("xmpG", "http://ns.adobe.com/xap/1.0/g/");
		public static const xmpGImg: Namespace =
			new Namespace("xmpGImg", "http://ns.adobe.com/xap/1.0/g/img/");
		public static const Iptc4xmpCore: Namespace =
			new Namespace("Iptc4xmpCore", "http://iptc.org/std/Iptc4xmpCore/1.0/xmlns/");
		public static const DICOM: Namespace =
			new Namespace("DICOM", "http://ns.adobe.com/DICOM/");
		
		
		// Type Namespaces
		
		public static const pdfaSchema: Namespace =
			new Namespace("pdfaSchema", "http://www.aiim.org/pdfa/ns/schema#");
		public static const pdfaProperty: Namespace =
			new Namespace("pdfaProperty", "http://www.aiim.org/pdfa/ns/property#");
		public static const pdfaType: Namespace =
			new Namespace("pdfaType", "http://www.aiim.org/pdfa/ns/type#");
		public static const pdfaField: Namespace =
			new Namespace("pdfaField", "http://www.aiim.org/pdfa/ns/field#");
		public static const pdfaid: Namespace =
			new Namespace("pdfaid", "http://www.aiim.org/pdfa/ns/id/");
		public static const pdfaExtension: Namespace =
			new Namespace("pdfaExtension", "http://www.aiim.org/pdfa/ns/extension/");
		public static const pdfx: Namespace =
			new Namespace("pdfx", "http://ns.adobe.com/pdfx/1.3/");
		public static const pdfxid: Namespace =
			new Namespace("pdfxid", "http://www.npes.org/pdfx/ns/id/");
		public static const stFnt: Namespace =
			new Namespace("stFnt", "http://ns.adobe.com/xap/1.0/sType/Font#");
		public static const stDim: Namespace =
			new Namespace("stDim", "http://ns.adobe.com/xap/1.0/sType/Dimensions#");
		public static const stEvt: Namespace =
			new Namespace("stEvt", "http://ns.adobe.com/xap/1.0/sType/ResourceEvent#");
		public static const stRef: Namespace =
			new Namespace("stRef", "http://ns.adobe.com/xap/1.0/sType/ResourceRef#");
		public static const stVer: Namespace =
			new Namespace("stVer", "http://ns.adobe.com/xap/1.0/sType/Version#");
		public static const stJob: Namespace =
			new Namespace("stJob", "http://ns.adobe.com/xap/1.0/sType/Job#");
		public static const stMfs: Namespace =
			new Namespace("stMfs", "http://ns.adobe.com/xap/1.0/sType/ManifestItem#");


		// Internal namespaces, have to be registered WITH PREFIX.
		/** The XML namespace for XML. */
		public static const xml: Namespace = 
			new Namespace("xml", "http://www.w3.org/XML/1998/namespace");
		/** The XML namespace for RDF. */
		public static const rdf: Namespace = 
			new Namespace("rdf", "http://www.w3.org/1999/02/22-rdf-syntax-ns#");
		/** The Adobe XMP namespace. */
		public static const x: Namespace = 
			new Namespace("x", "adobe:ns:meta/");


		// Miscellaneous
		
		/** The x-default string for localized properties */
		public static const X_DEFAULT: String = "x-default";
		/** The old DC namespace */
		internal static const dc_old: Namespace = new Namespace("http://purl.org/dc/1.1/");
	}
}