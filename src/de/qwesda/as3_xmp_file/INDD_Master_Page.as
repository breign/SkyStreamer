package de.qwesda.as3_xmp_file {
	import flash.filesystem.FileStream;
	import flash.utils.*;
	
	public class INDD_Master_Page {
		public var position_start:uint	= 0;
		public var position_next:uint	= 0;
		
		public var guid:String			= "";
		public var type:String			= "";
		public var endian:String		= null;
		public var sequence_nr1:uint	= 0;
		public var sequence_nr2:uint	= 0;
		public var pages_count:uint		= 0;
		
		public var valid:Boolean		= false;
		
		public function INDD_Master_Page(fileStream:FileStream) {
			position_start	= fileStream.position;
			
			guid = getGUID(fileStream);
			if(guid == "0606EDF5-D81D-46e5-BD31-EFE7FE74B71D" ){
				valid = true;
				
				type			= fileStream.readUTFBytes(8);
				endian			= fileStream.readUnsignedByte() == 2 ? Endian.BIG_ENDIAN : Endian.LITTLE_ENDIAN;
				
				fileStream.position += 239;
				
				sequence_nr1	= fileStream.readUnsignedInt();
				sequence_nr2	= fileStream.readUnsignedInt();
				
				fileStream.position += 8;
				
				pages_count		= fileStream.readUnsignedInt();
				
				fileStream.position += 3812;
				position_next = fileStream.position;
				
				var dbg_str:String = "\t@0x" + position_start.toString(16) + "\t" + type + " 0x" + sequence_nr1.toString(16) + sequence_nr2.toString(16) + " -> 0x" + (pages_count * 4096).toString(16);
				AppFunctions.Log(dbg_str)
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
	}
}