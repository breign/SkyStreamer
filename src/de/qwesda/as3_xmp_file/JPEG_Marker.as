package de.qwesda.as3_xmp_file {
	import flash.filesystem.*;
	import flash.utils.*;
	
	public class JPEG_Marker {
		public var type_nr:uint		= 0;
		public var length:uint		= 0;
		public var nameLength:uint	= 0;
		public var isMarker:Boolean	= false;
		public var name:String		= "";
		
		public var position_start:uint 	= 0;
		public var position_next:uint 	= 0;
		
		public function get payloadPositionStart():uint {	return position_start + 2 + 2 + nameLength;	}
		public function get payloadLength():uint 		{	return (length > 2 + nameLength) ? length - 2 - nameLength : 0;	}
		
		public function JPEG_Marker(fileStream:FileStream = null) {
			if(!fileStream) return ;
			
			try {
				
				position_start	= fileStream.position;
				fileStream.endian = Endian.BIG_ENDIAN;
				
				if(fileStream.readUnsignedByte() == 0xFF){	// Marker Found
					isMarker	= true;
					type_nr		= fileStream.readUnsignedByte();
					
					if(!isStandalone && isKnownMarker()){
						length			= fileStream.readUnsignedShort();
						
						var char:String = "";
						
						do {
							char = fileStream.readUTFBytes(1);
							name += char;
							nameLength++;
						} while (char != "");
						if(name == "Exif") nameLength++;
						
						position_next 	= position_start + 2 + length;
					} else position_next = position_start + 2;
				}
				
				if(DebugLevel > 1)	{
					var dbg_str:String = 
						"R\t@" + position_start.toString() + 
						"\t0xFF" + (type_nr < 10 ? "0" : "") + 
						type_nr.toString(16).toUpperCase() + " " + 
						id + "\t" + 
						"(" + length + ")\t" + 
						description + " " +
						((type_nr >= 0xE0 && type_nr <= 0xEF) ? "\"" + name + "\" (" + nameLength + ") " : "");
						
						if(id == "COM")
							dbg_str += ":\n\t\t\t\t\t" + name + getMarkerPacketAsString(fileStream);
						trace(dbg_str)
				}
				fileStream.position = position_next;
			} catch (e:Error){
				trace("read JPEG_Marker error;")
			}
		}
		static public function writeXmpMarkerToFile(fileStream:FileStream, type_nr:uint, name:String, payload:ByteArray):void {
			fileStream.endian	= Endian.BIG_ENDIAN;
			var position_start:uint	= fileStream.position;
			
			if(!((type_nr >= 0xD0 && type_nr <= 0xD9) || type_nr == 0x01)){
				var nameLength:int	= name.length + 1;
				
				var length:int = nameLength + payload.length + 2;
				
				if(length < 65535 - 2){
					fileStream.writeByte(0xFF);
					fileStream.writeByte(type_nr);
					fileStream.writeShort(length);
					fileStream.writeUTFBytes(name);
					fileStream.writeByte(0);
					fileStream.writeBytes(payload);
				}
			} else {
				fileStream.writeShort(0xFF);
				fileStream.writeShort(type_nr);
			}
			
			if(DebugLevel > 1)	{
				var dbg_str:String = 
					"W\t@" + position_start.toString() + 
					"\t0xFF" + (type_nr < 10 ? "0" : "") + 
					type_nr.toString(16).toUpperCase() + " " + 
					get_id(type_nr) + "\t" + 
					"(" + length + ")\t" + 
					get_description(type_nr) + " " +
					((type_nr >= 0xE0 && type_nr <= 0xEF) ? "\"" + name + "\" (" + nameLength + ") " : "");
				trace(dbg_str)
			}
		}
		
		public function getMarkerPacket(fileStream:FileStream):ByteArray {
			var ba:ByteArray = new ByteArray();
				
			var pos:uint = fileStream.position;
			fileStream.position = position_start;
			
			if(!isStandalone)	fileStream.readBytes(ba, 0, length + 2);
			else 				fileStream.readBytes(ba, 0, 2);
				
			fileStream.position = pos;
			
			return ba;
		}
		public function getMarkerPacketAsString(fileStream:FileStream):String {
			var ret:String = "";
				
			var pos:uint = fileStream.position;
			fileStream.position = payloadPositionStart;
			
			if(!isStandalone)	ret = fileStream.readUTFBytes(payloadLength);
				
			fileStream.position = pos;
			
			return ret;
		}
		public function getPayload(fileStream:FileStream):ByteArray {
			var ba:ByteArray = new ByteArray();
				
			if(!isStandalone){
				var pos:uint = fileStream.position;
				
				fileStream.position = payloadPositionStart;
				fileStream.readBytes(ba, 0, length - (2 + nameLength));
				
				fileStream.position = pos;
			}
			
			return ba;
		}
		
		public function get isStandalone():Boolean {
			return (type_nr >= 0xD0 && type_nr <= 0xD9) || type_nr == 0x01;
		}
		
		public static const TYPE_IDs:Object = {
			 SOF_0: 0xC0,
			 SOF_1: 0xC1,
			 SOF_2 : 0xC2,
			 SOF_3 : 0xC3,
			 SOF_5 : 0xC5,
			 SOF_6 : 0xC6,
			 SOF_7 : 0xC7,
			 JPG   : 0xC8,
			 SOF_9 : 0xC9,
			 SOF_10: 0xCA,
			 SOF_11: 0xCB,
			 SOF_13: 0xCD,
			 SOF_14: 0xCE,
			 SOF_15: 0xCF,
			 DHT   : 0xC4,
			 DAC   : 0xCC,
			 RST_0 : 0xD0,
			 RST_1 : 0xD1,
			 RST_2 : 0xD2,
			 RST_3 : 0xD3,
			 RST_4 : 0xD4,
			 RST_5 : 0xD5,
			 RST_6 : 0xD6,
			 RST_7 : 0xD7,
			 SOI   : 0xD8,
			 EOI   : 0xD9,
			 SOS   : 0xDA,
			 DQT   : 0xDB,
			 DNL   : 0xDC,
			 DRI   : 0xDD,
			 DHP   : 0xDE,
			 EXP   : 0xDF,
			 APP_0 : 0xE0,
			 APP_1 : 0xE1,
			 APP_2 : 0xE2,
			 APP_3 : 0xE3,
			 APP_4 : 0xE4,
			 APP_5 : 0xE5,
			 APP_6 : 0xE6,
			 APP_7 : 0xE7,
			 APP_8 : 0xE8,
			 APP_9 : 0xE9,
			 APP_10: 0xEA,
			 APP_11: 0xEB,
			 APP_12: 0xEC,
			 APP_13: 0xED,
			 APP_14: 0xEE,
			 APP_15: 0xEF,
			 JPG_0 : 0xF0,
			 JPG_1 : 0xF1,
			 JPG_2 : 0xF2,
			 JPG_3 : 0xF3,
			 JPG_4 : 0xF4,
			 JPG_5 : 0xF5,
			 JPG_6 : 0xF6,
			 JPG_7 : 0xF7,
			 JPG_8 : 0xF8,
			 JPG_9 : 0xF9,
			 JPG_10: 0xFA,
			 JPG_11: 0xFB,
			 JPG_12: 0xFC,
			 JPG_13: 0xFD,
			 COM   : 0xFE
		}
		
		public function get id():String{
			return get_id(type_nr);
		}
		static public function get_id(type_nr:uint):String{
			switch (type_nr){
				case 0xC0 :	return "Sof_0";
				case 0xC1 :	return "Sof_1";
				case 0xC2 :	return "Sof_2";
				case 0xC3 :	return "Sof_3";
				case 0xC5 :	return "Sof_5";
				case 0xC6 :	return "Sof_6";
				case 0xC7 :	return "Sof_7";
				case 0xC8 :	return "JPG";
				case 0xC9 :	return "Sof_9";
				case 0xCA :	return "Sof_10";
				case 0xCB :	return "Sof_11";
				case 0xCD :	return "Sof_13";
				case 0xCE :	return "Sof_14";
				case 0xCF :	return "Sof_15";
				case 0xC4 :	return "DHT";
				case 0xCC :	return "DAC";
				case 0xD0 :	return "RST_0";
				case 0xD1 :	return "RST_1";
				case 0xD2 :	return "RST_2";
				case 0xD3 :	return "RST_3";
				case 0xD4 :	return "RST_4";
				case 0xD5 :	return "RST_5";
				case 0xD6 :	return "RST_6";
				case 0xD7 :	return "RST_7";
				case 0xD8 :	return "SOI";
				case 0xD9 :	return "EOI";
				case 0xDA :	return "SOS";
				case 0xDB :	return "DQT";
				case 0xDC :	return "DNL";
				case 0xDD :	return "DRI";
				case 0xDE :	return "DHP";
				case 0xDF :	return "EXP";
				case 0xE0 :	return "APP_0";
				case 0xE1 :	return "APP_1";
				case 0xE2 :	return "APP_2";
				case 0xE3 :	return "APP_3";
				case 0xE4 :	return "APP_4";
				case 0xE5 :	return "APP_5";
				case 0xE6 :	return "APP_6";
				case 0xE7 :	return "APP_7";
				case 0xE8 :	return "APP_8";
				case 0xE9 :	return "APP_9";
				case 0xEA :	return "APP_10";
				case 0xEB :	return "APP_11";
				case 0xEC :	return "APP_12";
				case 0xED :	return "APP_13";
				case 0xEE :	return "APP_14";
				case 0xEF :	return "APP_15";
				case 0xF0 :	return "JPG_0";
				case 0xF1 :	return "JPG_1";
				case 0xF2 :	return "JPG_2";
				case 0xF3 :	return "JPG_3";
				case 0xF4 :	return "JPG_4";
				case 0xF5 :	return "JPG_5";
				case 0xF6 :	return "JPG_6";
				case 0xF7 :	return "JPG_7";
				case 0xF8 :	return "JPG_8";
				case 0xF9 :	return "JPG_9";
				case 0xFA :	return "JPG_10";
				case 0xFB :	return "JPG_11";
				case 0xFC :	return "JPG_12";
				case 0xFD :	return "JPG_13";
				case 0xFE :	return "COM";
			}
			
			return "Unknown";
		}
		public function isKnownMarker():Boolean{
			return type_nr >= 0xC0 && type_nr <= 0xFE;
		}
		public function get description():String{
			return get_description(type_nr);
		}
		static public function get_description(type_nr:uint):String{
			switch (type_nr){
				case 0xC0 :	return "Start Of Frame markers, non-differential, Huffman coding - Baseline DCT";
				case 0xC1 :	return "Start Of Frame markers, non-differential, Huffman coding - Extended sequential DCT";
				case 0xC2 :	return "Start Of Frame markers, non-differential, Huffman coding - Progressive DCT";
				case 0xC3 :	return "Start Of Frame markers, non-differential, Huffman coding - Lossless (sequential)";
				case 0xC5 :	return "Start Of Frame markers, differential, Huffman coding Differential sequential DCT";
				case 0xC6 :	return "Start Of Frame markers, differential, Huffman coding Differential progressive DCT";
				case 0xC7 :	return "Start Of Frame markers, differential, Huffman coding Differential lossless (sequential)";
				case 0xC8 :	return "Start Of Frame markers, non-differential, arithmetic coding - Reserved for JPEG extensions";
				case 0xC9 :	return "Start Of Frame markers, non-differential, arithmetic coding - Extended sequential DCT";
				case 0xCA :	return "Start Of Frame markers, non-differential, arithmetic coding - Progressive DCT";
				case 0xCB :	return "Start Of Frame markers, non-differential, arithmetic coding - Lossless (sequential)";
				case 0xCD :	return "Start Of Frame markers, differential, arithmetic coding - Differential sequential DCT";
				case 0xCE :	return "Start Of Frame markers, differential, arithmetic coding - Differential progressive DCT";
				case 0xCF :	return "Start Of Frame markers, differential, arithmetic coding - Differential lossless (sequential)";
				case 0xC4 :	return "Huffman table specification - Define Huffman table(s)";
				case 0xCC :	return "Arithmetic coding conditioning specification - Define arithmetic coding conditioning(s)";
				case 0xD0 :	return "Restart interval termination - Restart with modulo 8 count 0";
				case 0xD1 :	return "Restart interval termination - Restart with modulo 8 count 1";
				case 0xD2 :	return "Restart interval termination - Restart with modulo 8 count 2";
				case 0xD3 :	return "Restart interval termination - Restart with modulo 8 count 3";
				case 0xD4 :	return "Restart interval termination - Restart with modulo 8 count 4";
				case 0xD5 :	return "Restart interval termination - Restart with modulo 8 count 5";
				case 0xD6 :	return "Restart interval termination - Restart with modulo 8 count 6";
				case 0xD7 :	return "Restart interval termination - Restart with modulo 8 count 7";
				case 0xD8 :	return "Start of image";
				case 0xD9 :	return "End of image";
				case 0xDA :	return "Start of scan";
				case 0xDB :	return "Define quantization table";
				case 0xDC :	return "Define number of lines";
				case 0xDD :	return "Define restart interval";
				case 0xDE :	return "Define hierarchical progression";
				case 0xDF :	return "Expand reference component";
				case 0xE0 :	return "Application segment 0";
				case 0xE1 :	return "Application segment 1";
				case 0xE2 :	return "Application segment 2";
				case 0xE3 :	return "Application segment 3";
				case 0xE4 :	return "Application segment 4";
				case 0xE5 :	return "Application segment 5";
				case 0xE6 :	return "Application segment 6";
				case 0xE7 :	return "Application segment 7";
				case 0xE8 :	return "Application segment 8";
				case 0xE9 :	return "Application segment 9";
				case 0xEA :	return "Application segment 10";
				case 0xEB :	return "Application segment 11";
				case 0xEC :	return "Application segment 12";
				case 0xED :	return "Application segment 13";
				case 0xEE :	return "Application segment 14";
				case 0xEF :	return "Application segment 15";
				case 0xF0 :	return "JPEG extensions segment 0";
				case 0xF1 :	return "JPEG extensions segment 1";
				case 0xF2 :	return "JPEG extensions segment 2";
				case 0xF3 :	return "JPEG extensions segment 3";
				case 0xF4 :	return "JPEG extensions segment 4";
				case 0xF5 :	return "JPEG extensions segment 5";
				case 0xF6 :	return "JPEG extensions segment 6";
				case 0xF7 :	return "JPEG extensions segment 7";
				case 0xF8 :	return "JPEG extensions segment 8";
				case 0xF9 :	return "JPEG extensions segment 9";
				case 0xFA :	return "JPEG extensions segment 10";
				case 0xFB :	return "JPEG extensions segment 11";
				case 0xFC :	return "JPEG extensions segment 12";
				case 0xFD :	return "JPEG extensions segment 13";
				case 0xFE :	return "Comment";
			}
			
			return "Unknown";
		} 

	}
}