package de.qwesda.as3_xmp_file {
	import flash.filesystem.FileStream;
	import flash.utils.*;
	
	public class PSD_Image_Resource_Header {
		public var position_start:uint	= 0;
		public var position_next:uint	= 0;
		public var payload_offset:uint	= 0;
		
		public var type_nr:uint			= 0;
		public var length:uint			= 0;
		public var name:String			= "";
		public var nameInByteCode:String= "";	
		public var name_length:uint		= 0;	// including \0\0?
		public var valid:Boolean		= false;
		
		public function PSD_Image_Resource_Header(fileStream:FileStream) {
			position_start	= fileStream.position;
					
			if(fileStream.bytesAvailable > 12 && fileStream.readUTFBytes(4) == "8BIM"){	//		AppFunctions.Log("8BIM marker found");
				type_nr = fileStream.readUnsignedShort();
				
				name = "";
				var charCode:uint = 0;
				nameInByteCode = "0x";
				do {
					charCode		= fileStream.readByte();
					nameInByteCode	+= (nameInByteCode != "0x" ? " " : "") + ((charCode < 1 ? "0" : "") + charCode < 16 ? "0" : "") + charCode.toString(16);
					
					if(charCode >= 32)
						name		= name != "" ? name + String.fromCharCode(charCode) : String.fromCharCode(charCode);
				} while (!(charCode == 0 && fileStream.position%2 == 0) && nameInByteCode != "0x03 58 4d 50");
				//                                                         ^
				// Stupid hack for messed up files created by PS CS3 ... the psir-name is offset by 1 byte ...
				// Get your fucking code straight adobe ... you get paid for it - we don't!
				
				name_length 	= fileStream.position - position_start - 6;
				
				length 			= fileStream.readUnsignedInt();			
				position_next	= fileStream.position + length + (length%2 == 1 ? 1: 0);
				payload_offset	= fileStream.position - position_start;
				
				var dbg_str:String = "\t@0x" + position_start.toString(16) + "\t0x" + (type_nr < 0x1000 ? "0" : "") + type_nr.toString(16).toUpperCase() + " " + (name != "" ? (" \"" + name + "\"") : " \"\"") + " (" + length + ")\t" + description;
				trace(dbg_str);
				
				valid = true;
			}
						
			fileStream.position = position_next;
		}
		public function get total_length():uint {
			return payload_offset + length + (length%2 == 1 ? 1: 0);
		}
		public function getPayload(fileStream:FileStream):ByteArray {
			var ba:ByteArray = new ByteArray();
				
			if(valid){
				var pos:uint = fileStream.position;
				
				fileStream.position = position_start + payload_offset;
				fileStream.readBytes(ba, 0, length);
				
				fileStream.position = pos;
			}
			
			return ba;
		}
		public function get description():String{
			switch (type_nr){
				case 0x03E8 : return "(Obsolete—Photoshop 2.0 only) Contains five 2-byte values: number channels, rows, columns, depth, and mode";
				case 0x03E9 : return "Macintosh print manager print info record";
				case 0x03EB : return "(Obsolete—Photoshop 2.0 only) Indexed color table";
				case 0x03ED : return "ResolutionInfo structure";
				case 0x03EE : return "Names of the alpha channels as a series of Pascal strings.";
				case 0x03EF : return "DisplayInfo structure";
				case 0x03F0 : return "The caption as a Pascal string.";
				case 0x03F1 : return "Border information";
				case 0x03F2 : return "Background color.";
				case 0x03F3 : return "Print flags";
				case 0x03F4 : return "Grayscale and multichannel halftoning information";
				case 0x03F5 : return "Color halftoning information";
				case 0x03F6 : return "Duotone halftoning information";
				case 0x03F7 : return "Grayscale and multichannel transfer function";
				case 0x03F8 : return "Color transfer functions";
				case 0x03F9 : return "Duotone transfer functions";
				case 0x03FA : return "Duotone image information";
				case 0x03FB : return "Two bytes for the effective black and white values for the dot range";
				case 0x03FC : return "(Obsolete)";
				case 0x03FD : return "EPS options";
				case 0x03FE : return "Quick Mask information";
				case 0x03FF : return "(Obsolete)";
				case 0x0400 : return "Layer state information";
				case 0x0401 : return "Working path (not saved)";
				case 0x0402 : return "Layers group information";
				case 0x0403 : return "(Obsolete)";
				case 0x0404 : return "IPTC-NAA record";
				case 0x0405 : return "Image mode for raw format files";
				case 0x0406 : return "JPEG quality. Private.";
				case 0x0408 : return "(Photoshop 4.0) Grid and guides information";
				case 0x0409 : return "(Photoshop 4.0) Thumbnail resource for Photoshop 4.0 only";
				case 0x040A : return "(Photoshop 4.0) Copyright flag";
				case 0x040B : return "(Photoshop 4.0) URL";
				case 0x040C : return "(Photoshop 5.0) Thumbnail resource";
				case 0x040D : return "(Photoshop 5.0) Global Angle";
				case 0x040E : return "(Photoshop 5.0) Color samplers resource";
				case 0x040F : return "(Photoshop 5.0) ICC Profile";
				case 0x0410 : return "(Photoshop 5.0) Watermark";
				case 0x0411 : return "(Photoshop 5.0) ICC Untagged Profile";
				case 0x0412 : return "(Photoshop 5.0) Effects visible";
				case 0x0413 : return "(Photoshop 5.0) Spot Halftone";
				case 0x0414 : return "(Photoshop 5.0) Document-specific IDs seed number";
				case 0x0415 : return "(Photoshop 5.0) Unicode Alpha Names";
				case 0x0416 : return "(Photoshop 6.0) Indexed Color Table Count";
				case 0x0417 : return "(Photoshop 6.0) Transparency Index.";
				case 0x0419 : return "(Photoshop 6.0) Global Altitude";
				case 0x041A : return "(Photoshop 6.0) Slices";
				case 0x041B : return "(Photoshop 6.0) Workflow URL";
				case 0x041C : return "(Photoshop 6.0) Jump To XPEP";
				case 0x041D : return "(Photoshop 6.0) Alpha Identifiers";
				case 0x041E : return "(Photoshop 6.0) URL List";
				case 0x0421 : return "(Photoshop 6.0) Version Info";
				case 0x0422 : return "(Photoshop 7.0) EXIF data 1";
				case 0x0423 : return "(Photoshop 7.0) EXIF data 3";
				case 0x0424 : return "(Photoshop 7.0) XMP metadata";
				case 0x0425 : return "(Photoshop 7.0) Caption digest";
				case 0x0426 : return "(Photoshop 7.0) Print scale";
				case 0x0428 : return "(Photoshop CS) Pixel Aspect Ratio";
				case 0x0429 : return "(Photoshop CS) Layer Comps";
				case 0x042A : return "(Photoshop CS) Alternate Duotone Colors";
				case 0x042B : return "(Photoshop CS) Alternate Spot Colors";
				case 0x0BB7 : return "Name of clipping path";
				case 0x2710 : return "Print flags information";
				
				default		: if(type_nr >= 0x07D0 && 0x07D0 <= 0x0BB6)	return "Path Information (saved paths)";
			}
			
			return "Unknown";
		}
	}
}