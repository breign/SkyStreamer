package de.qwesda.as3_xmp_file {
	import com.adobe.xmp.core.XMPMeta;
	
	import flash.filesystem.*;
	import flash.utils.*;
	
	public class XMP_file_png extends XMP_file_base {
		internal var chunks:Array = [];
		
		public function XMP_file_png(fileName:String) {		
			super(fileName);
			
			if(_valid && !_isSidecarFile){
				readPacketFromFile();
			}
		}
		
		public function getThumbnail(stream:ByteArray):Object {			
			return null;
		}
		
		override public function checkIfFileFormatIsValid():Boolean {
			var _filestream:FileStream = new FileStream();
			_filestream.open(_file, FileMode.READ);
			
			_valid = false;
			
			if(_filestream.bytesAvailable > 0){
				_filestream.endian = Endian.LITTLE_ENDIAN;
				
				if(DebugLevel > 0)	trace("--- VERIFYING PNG --- \t" + _file.nativePath);
				
				if(_filestream.readUnsignedInt() == 2303741511 && _filestream.readUnsignedInt() == 218765834)
					_valid = true;
			}
			
			return _valid;
		}
		
		override public function readPacketFromFile():Boolean {
			if(_valid){
				thumbnails	= [];
				chunks		= [];
				
				var readStream:FileStream = new FileStream();
				readStream.open(_file, FileMode.READ);
				readStream.endian = Endian.BIG_ENDIAN;
				
				if(DebugLevel > 0)	trace("--- READING PNG --- \t" + _file.nativePath);
				
				// QUICK HEADER CHECK
				if(readStream.readUnsignedInt() == 2303741511 && readStream.readUnsignedInt() == 218765834){
					var thisChunk:PNG_Chunk = new PNG_Chunk(readStream);
					
					do {
						thisChunk = new PNG_Chunk(readStream);
					} while (!thisChunk.isInvalid)
				}
				
				readStream.close();
				
				if(DebugLevel > 0)	trace("--- READING PNG END ---");
				
				return true;
			}
			
			return false;
		}
		private function updateInPlace(xmp:XMPMeta):Boolean {
			if(_valid){
			}
			
			return false;	
		}
		override public function writePacketToFile(xmp:XMPMeta, destFile:File = null):Boolean {			
			if(_valid){
			}
			
			return false;
		}
	}
}