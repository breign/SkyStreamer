package de.qwesda.as3_xmp_file {
	import com.adobe.xmp.core.SerializeOptions;
	import com.adobe.xmp.core.XMPMeta;
	
	import flash.filesystem.*;
	import flash.utils.*;
	
	import mx.utils.UIDUtil;
	
	public class XMP_file_tiff extends XMP_file_base {
		private var tiffStructure:TIFF_Structure;
			
		public function XMP_file_tiff(fileName:String) {		
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
				
				if(DebugLevel > 0)	trace("--- VERIFIING TIFF --- \t" + _file.nativePath);
				
				var read_str:String = _filestream.readUTFBytes(2);	//	trace("Endian marker: " + read_str);
				if(read_str == "MM" || read_str == "II"){
					_filestream.endian = (read_str == "II" ? Endian.LITTLE_ENDIAN : Endian.BIG_ENDIAN);
					
					var read_uint:uint = _filestream.readUnsignedShort();	//	trace("Endian check (42): " + read_uint);
					if(read_uint == 42)
						_valid = true;
				}
			}
			
			return _valid;
		}
		
		override public function readPacketFromFile():Boolean {
			if(_valid){
				thumbnails = [];
				
				var _filestream:FileStream = new FileStream();
				_filestream.open(_file, FileMode.READ);
				
				var stream:Stream = new Stream(_filestream);
				tiffStructure = new TIFF_Structure(stream);
				
				for each(var idf:IDF in tiffStructure.all_idfs){
					if(idf.hasPropery(700)){
						var xmp_entry:IDF_Entry		= idf.getEntry(700);
						
						if(xmp_entry.byteArray){
							_xmp = new XMPWrapper(xmp_entry.byteArray);
							_hasXmp = true;
						}
					}
					if(idf.getProperyAsUint(254) == 1){
						var ba:ByteArray = new ByteArray();
						
						var offsets:Array = idf.getValues(273);
						var lengths:Array = idf.getValues(279);
						
						if(offsets && lengths && offsets.length > 0 && offsets.length == lengths.length){
							for (var i:int = 0; i < offsets.length; i++){
								var offset:uint = offsets[i];
								var length:uint = lengths[i];
								
								stream.position = offset;
								stream.readBytes(ba, 0, length);
							}
							
							thumbnails.push({type:(idf.getProperyAsUint(259) == 7 ? "Jpeg" : idf.getProperyAsUint(259) == 1 ? "Bitmap" : "unknown"), width:idf.getProperyAsUint(256) , height:idf.getProperyAsUint(257) , bytes:ba});
						}
					}
				}
				
				_filestream.close();
				
				return true;
			}
			
			return false;
		}
		private function updateInPlace(xmp:XMPMeta):Boolean {
			if(_valid){
				var idf:IDF;
				var so:SerializeOptions	= new SerializeOptions();			
				var newPacket:ByteArray;
				
				var updateStream:FileStream = new FileStream();
				
				updateStream.open(_file, FileMode.UPDATE);
				updateStream.endian = tiffStructure.endian;
				
				var stream:Stream = new Stream(updateStream);
				
				for each(idf in tiffStructure.all_idfs){
					if(idf.hasPropery(700)){
						var xmp_entry:IDF_Entry = idf.getEntry(700);
						var old_length:uint 	= xmp_entry.value_count;
						
						so.exactPacketLength	= old_length;
						
						try {
							newPacket = xmp.serializeToBuffer(so);
							
							if(old_length == xmp_entry.value_length){
								if(DebugLevel > 0)	trace("--- UPDATING TIFF IN PLACE ---");

								xmp_entry.replaceValues(stream, newPacket);
		
								if(DebugLevel > 0)	trace("--- UPDATING TIFF IN PLACE END ---");
								
								updateStream.close();
				
								return true;
							}
						}
						catch (e:Error) {
							
						}
						
						updateStream.close();
						
						return false;
					}
				}
				
				updateStream.close();
			}
			
			return false;	
		}
		override public function writePacketToFile(xmp:XMPMeta, destFile:File = null):Boolean {
			var so:SerializeOptions	= new SerializeOptions();
			var oldPacket:ByteArray;
			var newPacket:ByteArray;
			var copyBuffer:ByteArray = new ByteArray();
			
			if(_valid){
				if(readPacketFromFile()){
					if(!destFile && updateInPlace(xmp)){
						return true;
					} else {
						if(DebugLevel > 0)	trace("--- REWRITING TIFF ---");
						
						var newFile:File 				= destFile ? destFile : new File(_file.nativePath  + "." + mx.utils.UIDUtil.createUID() + "." + _file.extension);
						
						var oldFileStream:FileStream	= new FileStream();
						var newFileStream:FileStream	= new FileStream();
						
						oldFileStream.endian = tiffStructure.endian;
						newFileStream.endian = tiffStructure.endian;
				
						oldFileStream.open(_file, FileMode.READ);
						newFileStream.open(newFile, FileMode.WRITE);
						
						var oldStream:Stream			= new Stream(oldFileStream);
						var newStream:Stream			= new Stream(newFileStream);
						
					//	write tiff header	
						newFileStream.writeUTFBytes(tiffStructure.endian == Endian.BIG_ENDIAN ? "MM" : "II");
						newFileStream.writeShort(42);
						newFileStream.writeUnsignedInt(8);
					//	write tiff header end
						
						var xmp_entry:IDF_Entry = tiffStructure.getPropery(700);
						var xmp_ba:ByteArray	= xmp.serializeToBuffer();
						
						if(xmp_entry){	xmp_entry.byteArray = xmp_ba;	xmp_entry.value_count = xmp_ba.length;	}
						else 			tiffStructure.idf0.addIDF_Entry(700, 1, xmp_ba.length, xmp_ba);
						
						var value_offset:uint		= 8 + tiffStructure.getIDFLength();
						var img_data_offset:uint	= value_offset + tiffStructure.getValueLength();
						var objectsToCopy:Array		= [];
						
						tiffStructure.writeIDFs(tiffStructure.idf0, 8, newStream, oldStream, {nextIDFOffset:8, valueOffset:value_offset, imageDataOffset:img_data_offset}, objectsToCopy);
						
						for each(var objectToCopy:Object in objectsToCopy){
							if(DebugLevel > 0)	trace("--- copying image data from " + objectToCopy.oldPos + " to " + objectToCopy.newPos + " length " + objectToCopy.length + " ---");
							
							oldFileStream.position = objectToCopy.oldPos;
							newFileStream.position = objectToCopy.newPos;
							
							while (objectToCopy.length >= 1024*1024){	copyBuffer.clear();	oldFileStream.readBytes(copyBuffer, 0, 1024*1024);           newFileStream.writeBytes(copyBuffer);	objectToCopy.length -= 1024*1024; }
							if(objectToCopy.length > 0)				{	copyBuffer.clear();	oldFileStream.readBytes(copyBuffer, 0, objectToCopy.length);	newFileStream.writeBytes(copyBuffer);	}
						}
						
						oldFileStream.close();
						newFileStream.close();
						
						if(!destFile)
							(newFile as File).moveTo(_file, true);
						
						if(DebugLevel > 0)	trace("--- REWRITING TIFF END ---");
						
						return true;
					}
				}
			}
			
			return false;
		}
	}
}