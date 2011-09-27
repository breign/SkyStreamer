package de.qwesda.as3_xmp_file {
	import flash.filesystem.FileStream;
	import flash.utils.*;
	
	public class INDD_Contiguous_Object {
		public var position_start:uint	= 0;
		public var position_next:uint	= 0;
		
		public var guid:String			= "";
		public var object_id:uint		= 0;
		public var class_id:uint		= 0;
		public var length:uint			= 0;
		public var checksum:uint		= 0;
		public var packet_start:String	= "";
		
		public var valid:Boolean		= false;
		
		public function INDD_Contiguous_Object(fileStream:FileStream) {
			position_start	= fileStream.position;
			
			guid = getGUID(fileStream);
			if(guid == "DE393979-5188-4b6c-8E63-EEF8AEE0DD38" || guid == "FDCEDB70-F786-4b4f-A4D3-C728B3417106"){
				valid = true;
				
				object_id		= fileStream.readUnsignedInt();
				class_id		= fileStream.readUnsignedInt();
				length			= fileStream.readUnsignedInt();
				checksum		= fileStream.readUnsignedInt();
				
				position_next	= fileStream.position + length;
				fileStream.readUTFBytes(4);
				packet_start	= fileStream.readUTFBytes(16);
			}
						
			fileStream.position = position_next;
		}
		private function getGUID(fileStream:FileStream):String {
			var uuid:String = "";
			var char:uint = 0;
			
			for (var i:uint = 0; i < 16; i++){
				if(i == 4 || i == 6 || i == 8 || i == 10) uuid += "-";
				char = fileStream.readUnsignedByte();
				uuid += (char < 0x10 ? "0" : "") + (i == 6 || i == 7 ? char.toString(16).toLowerCase() : char.toString(16).toUpperCase());
			}
			
			return uuid;
		}
		public function getPayload(fileStream:FileStream):ByteArray {
			var ba:ByteArray = new ByteArray();
				
			if(valid){
				var pos:uint = fileStream.position;
				
				fileStream.position = position_start + 32;
				
				var len:uint = fileStream.readUnsignedInt();
				fileStream.readBytes(ba, 0, len);
				
				fileStream.position = pos;
			}
			
			return ba;
		}
	}
}