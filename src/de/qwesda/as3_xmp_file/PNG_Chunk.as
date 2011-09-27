package de.qwesda.as3_xmp_file {
	import flash.filesystem.*;
	import flash.utils.*;
	
	public class PNG_Chunk {
		public var length:uint			= 0;
		public var type:String			= "....";
		public var crc:uint				= 0;
		
		public var position_start:uint 	= 0;
		
		public function get payloadPositionStart():uint {	return position_start + 4 + 4;	}
		public function get payloadLength():uint 		{	return length;					}
		public function get chunkLength():uint 			{	return length + 4 + 4 + 4;		}
		
		public function get isInvalid():Boolean			{	return type == "....";			}
		
		public function get isCritical():Boolean		{	return type.charAt(0).toUpperCase() == type.charAt(0);		}
		public function get isPublic():Boolean 			{	return type.charAt(1).toUpperCase() == type.charAt(1);		}
		public function get isReserved():Boolean 		{	return type.charAt(2).toUpperCase() == type.charAt(2);		}
		public function get isNotSafeToCopy():Boolean 	{	return type.charAt(3).toUpperCase() == type.charAt(3);		}
		
		public function PNG_Chunk(stream:FileStream = null) {
			if(!stream) return ;
			
			try {
				position_start	=	 stream.position;
				stream.endian	= Endian.BIG_ENDIAN;
				
				length	= stream.readUnsignedInt();
				type 	= stream.readUTFBytes(4);
				
				stream.position += length;
				
				crc		= stream.readUnsignedInt();
				
				if(DebugLevel > 1)	{
					var dbg_str:String = 
						"R\t@" + position_start.toString() + 
						"\t" + type + 
						"\tcrc: 0x" + crc.toString(16).toUpperCase() + 
						" " + (isCritical		? "critical "			: "ancillary") +
						" " + (isPublic 		? "public " 			: "private") +
						" " + (isReserved		? "reserved  "			: "unreserved") +
						" " + (isNotSafeToCopy	? "not save to copy"	: "save to copy    ") +
						"";
						
					trace(dbg_str);
				}
			} catch (e:Error) {
				type = "....";
			}
		}
	}
}