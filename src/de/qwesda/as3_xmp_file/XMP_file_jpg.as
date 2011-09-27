package de.qwesda.as3_xmp_file {
	import by.blooddy.crypto.MD5;
	
	import com.adobe.xmp.core.SerializeOptions;
	import com.adobe.xmp.core.XMPConst;
	import com.adobe.xmp.core.XMPMeta;
	import com.adobe.xmp.core.XMPNode;
	import com.hurlant.util.Hex;
	
	import flash.filesystem.*;
	import flash.utils.*;
	
	import mx.utils.UIDUtil;
	
	public class XMP_file_jpg extends XMP_file_base {
		private var markers:Array = [];
		private var exif:TIFF_Structure;
		public var width:int = -1;
		public var height:int = -1;
			
		public function XMP_file_jpg(fileName:String) {			
			super(fileName);
			
			if(_valid && !_isSidecarFile)
				readPacketFromFile();
		}
		
		override public function checkIfFileFormatIsValid():Boolean {
			var _filestream:FileStream = new FileStream();
			_filestream.open(_file, FileMode.READ);
			
			_valid = false;
			
			try {			
				if(_filestream.bytesAvailable > 2){
					_filestream.endian = Endian.LITTLE_ENDIAN;
					
					if(DebugLevel > 0)	trace("--- VERIFYING JPEG --- \t" + _file.nativePath);
					var SOI_Marker:JPEG_Marker;
					var EOI_Marker:JPEG_Marker;
					
					_filestream.position = 0;
					SOI_Marker = new JPEG_Marker(_filestream);
					
					_filestream.position = 0;
					_filestream.position = _filestream.bytesAvailable - 2;
					EOI_Marker = new JPEG_Marker(_filestream);
					
					if(SOI_Marker.type_nr != JPEG_Marker.TYPE_IDs.SOI || EOI_Marker.type_nr != JPEG_Marker.TYPE_IDs.EOI){
						_valid = false;
						trace("not a valid jpeg file: " + _file.nativePath)
					} else _valid = true;
				}
			} catch (e:Error) {
				trace("erorr verifying jpeg format");
			}
			
			return _valid;
		}
		override public function readPacketFromFile():Boolean {
			if(_valid){
				var _filestream:FileStream = new FileStream();
				_filestream.open(_file, FileMode.READ);
				thumbnails = [];
				_hasXmp = false;
				
				if(_filestream.bytesAvailable > 0){
					_filestream.endian = Endian.LITTLE_ENDIAN;
					
					var _binaryPacket:ByteArray;
					var thisMarker:JPEG_Marker;
					
					if(DebugLevel > 0)	trace("--- READING JPEG --- \t" + _file.nativePath);
					
					markers = [];
					
					do {
						thisMarker = new JPEG_Marker(_filestream);
						markers.push(thisMarker);
					} while (thisMarker && thisMarker.isMarker);
					
					if(markers.length < 1 || (markers[0] as JPEG_Marker).type_nr != 0xD8){
						_valid = false;
						
						return false;
					}
					
					var exif_bytes:ByteArray = new ByteArray();
					var extensions:Array = [];
					
					for each(thisMarker in markers){
						if(thisMarker.name == "http://ns.adobe.com/xap/1.0/"){
							_binaryPacket = thisMarker.getPayload(_filestream);
							_xmp = new XMPWrapper(_binaryPacket);
							
							_hasXmp = true;
						}
						if(thisMarker.description.search("Start Of Frame markers") == 0){
							_filestream.position = thisMarker.position_start + 5;
							height	= _filestream.readUnsignedShort();
							width	= _filestream.readUnsignedShort();
						}
						
						if(thisMarker.name == "http://ns.adobe.com/xmp/extension/")
							extensions.push(thisMarker.getPayload(_filestream));
							
						if(thisMarker.name == "Exif"){
							exif_bytes.writeBytes(thisMarker.getPayload(_filestream));
						}
					}
					
					if(exif_bytes.length > 0){
						var exif_stream:Stream = new Stream(exif_bytes);
						
						exif = new TIFF_Structure(exif_stream);
						var o:Object = exif.getThumbnail(exif_stream);
						if(o) thumbnails.push(o);
					}
					if(extensions.length > 0){
						var ns:Namespace = XMPConst.xmpNote;
						var needed_md5:String = _xmp.ns::HasExtendedXMP;
						
						if(needed_md5.length == 32){
							if(DebugLevel > 1)	
								trace("\n\textention md5: " + needed_md5);
							
							var extention_md5:String = "";
							var extention_length:int = 0;
							var extention_offset:int = 0;
							
							var needed_extetions:Array = [];
							var ba:ByteArray;
									
							for each(ba in extensions){
								extention_md5 		= ba.readUTFBytes(32);
								extention_length	= ba.readUnsignedInt();
								extention_offset	= ba.readUnsignedInt();
								
								if(extention_md5 == needed_md5)
									needed_extetions.push({md5:extention_md5, length:extention_length, offset:extention_offset, bytes:ba});
							}
							
							if(needed_extetions.length > 0){
								needed_extetions = needed_extetions.sortOn("offset", Array.NUMERIC);
								
								var extention_ba:ByteArray = new ByteArray();
								
								for each(ba in extensions)
									extention_ba.writeBytes(ba, 40);
								
								var extention_xmp:XMPMeta = new XMPMeta(extention_ba);
			
								for each (var node:XMPNode in extention_xmp)
									copyNode(_xmp, extention_xmp);
							}
						}
					}
					
					_filestream.close();
					
					if(DebugLevel > 0)	trace("--- READING JPEG END ---\n");
					
					return true;
				}
			}
		
			_filestream.close();
			
			return false;
		}
		private function updateInPlace(xmp:XMPMeta):Boolean {
			if(_valid){
				var _filestream:FileStream = new FileStream();
				_filestream.open(_file, FileMode.UPDATE);
				
				if(_filestream.bytesAvailable > 0){
					_filestream.endian = Endian.LITTLE_ENDIAN;
					
					var so:SerializeOptions	= new SerializeOptions();
					
					var oldPacket:ByteArray;
					var newPacket:ByteArray;
					var thisMarker:JPEG_Marker;
					
					for each (thisMarker in markers){
						if(thisMarker.name == "http://ns.adobe.com/xap/1.0/"){
							oldPacket = thisMarker.getPayload(_filestream);
							
							so.exactPacketLength = oldPacket.length;
							
							try {
								newPacket = xmp.serializeToBuffer(so);
								
								if(oldPacket.length == newPacket.length){
									if(DebugLevel > 0)	trace("--- UPDATING JPEG IN PLACE ---");
								
									_filestream.position = thisMarker.payloadPositionStart;
									_filestream.writeBytes(newPacket);
			
									if(DebugLevel > 0)	trace("--- UPDATING JPEG IN PLACE END ---");
									
									_filestream.close();
									
									return true;
								}
							}
							catch (e:Error) {
								
							}
						}
					}
				}
			}
			
			_filestream.close();
			
			return false;	
		}
		override public function writePacketToFile(xmp:XMPMeta, destFile:File = null):Boolean {
			var so:SerializeOptions	= new SerializeOptions();
			var oldPacket:ByteArray;
			var newPacket:ByteArray;
			var copyBuffer:ByteArray = new ByteArray();
			
			var thisMarker:JPEG_Marker;

			if(_valid){
				if(readPacketFromFile()){
					if(!destFile && updateInPlace(xmp)){
						return true;
					} else {
						if(DebugLevel > 0)	trace("--- REWRITING JPEG ---");
							
						var xmpNote:Namespace = XMPConst.xmpNote;
						var newFile:File 			= destFile ? destFile : new File(_file.nativePath  + "." + mx.utils.UIDUtil.createUID() + "." + _file.extension);
						
						var oldStream:FileStream	= new FileStream();
						var newStream:FileStream	= new FileStream();
						var writeXMPHere:Boolean	= false;
						var XMPWasWritten:Boolean	= false;
						
						oldStream.open(_file, FileMode.READ);
						newStream.open(newFile, FileMode.WRITE);
						
						for each(thisMarker in markers){
							writeXMPHere = false;
							
							if(!hasXmp && thisMarker.type_nr != 0xD8 && !(thisMarker.type_nr >= 0xE0 && thisMarker.type_nr <= 0xEF) && !thisMarker.type_nr <= 0xFE) 
								writeXMPHere = true;
							if(thisMarker.name == "http://ns.adobe.com/xap/1.0/") writeXMPHere = true;
							
							if(writeXMPHere && !XMPWasWritten){
								var ba_extention:ByteArray;
								var ba_chunk:ByteArray;
								var ba_main:ByteArray	= xmp.serializeToBuffer();
								
								if(ba_main.length <= 65502){
									JPEG_Marker.writeXmpMarkerToFile(newStream, 0xE1, "http://ns.adobe.com/xap/1.0/", ba_main);
								} else {
									trace("Partitioning XMP");
									
									var main_xmp:XMPMeta = new XMPMeta();
									
									main_xmp.xmpNote::HasExtendedXMP = "00001111222233334444555566667777";
									
									if(moveNodeIfNotToBig(main_xmp, xmp, "http://ns.adobe.com/tiff/1.0/"))
									if(moveNodeIfNotToBig(main_xmp, xmp, "http://ns.adobe.com/exif/1.0/"))
									if(moveNodeIfNotToBig(main_xmp, xmp, "http://ns.adobe.com/exif/1.0/aux/"))
									if(moveNodeIfNotToBig(main_xmp, xmp, "http://purl.org/dc/elements/1.1/"))
									if(moveNodeIfNotToBig(main_xmp, xmp, "http://ns.adobe.com/xap/1.0/"))
									if(moveNodeIfNotToBig(main_xmp, xmp, "http://ns.adobe.com/xap/1.0/rights/"))
									if(moveNodeIfNotToBig(main_xmp, xmp, "http://ns.adobe.com/xap/1.0/mm/"))
									if(moveNodeIfNotToBig(main_xmp, xmp, "http://ns.adobe.com/xap/1.0/bj/"))
									if(moveNodeIfNotToBig(main_xmp, xmp, "http://ns.adobe.com/xmp/1.0/DynamicMedia/"))
									if(moveNodeIfNotToBig(main_xmp, xmp, "http://ns.adobe.com/pdf/1.3/"))
									if(moveNodeIfNotToBig(main_xmp, xmp, "http://ns.adobe.com/camera-raw-settings/1.0/"))
									if(moveNodeIfNotToBig(main_xmp, xmp, "http://ns.adobe.com/photoshop/1.0/"))
									   moveNodeIfNotToBig(main_xmp, xmp);
									
									ba_extention = xmp.serializeToBuffer();
									
									var extention_md5:String = Hex.fromString(MD5.hash(ba_extention.readUTFBytes(ba_extention.length))).toUpperCase();
									var extention_length:int = ba_extention.length;
									var extention_offset:int = 0;
									trace("\nextention md5: " + extention_md5);
									
									main_xmp.xmpNote::HasExtendedXMP = extention_md5;
									ba_main = main_xmp.serializeToBuffer();
									JPEG_Marker.writeXmpMarkerToFile(newStream, 0xE1, "http://ns.adobe.com/xap/1.0/", ba_main);
									
									var chunks:Array = [];
									var chunk:ByteArray;
									var chunk_size:int;
									var chunk_offset:int = 0;
									var chunk_bytesLeft:int = ba_extention.length;
									
									do {
										chunk_size = Math.min(chunk_bytesLeft, 65400);
										chunk = new ByteArray();
										
										chunk.writeUTFBytes(extention_md5);
										chunk.writeUnsignedInt(extention_length);
										chunk.writeUnsignedInt(extention_offset);
										
										extention_offset += chunk_size;
										
										chunk.writeBytes(ba_extention, chunk_offset, chunk_size);
										chunks.push(chunk);
										
										chunk_bytesLeft	-= chunk_size;
										chunk_offset	+= chunk_size;
									} while (chunk_bytesLeft > 0)
									
									for each (ba_chunk in chunks)
										JPEG_Marker.writeXmpMarkerToFile(newStream, 0xE1, "http://ns.adobe.com/xmp/extension/", ba_chunk);
										
								}
								
								XMPWasWritten = true;
							}
							
							if(thisMarker.name != "http://ns.adobe.com/xap/1.0/" && thisMarker.name != "http://ns.adobe.com/xmp/extension/")
								newStream.writeBytes(thisMarker.getMarkerPacket(oldStream));
							
							if(thisMarker.position_next != 0)
								oldStream.position = thisMarker.position_next;
						}
						
						thisMarker = markers.pop();
						oldStream.position = thisMarker.position_start + thisMarker.length + 2;
						
						while (oldStream.bytesAvailable >= 1024*1024)	{	copyBuffer.clear();	oldStream.readBytes(copyBuffer, 0, 1024*1024);	newStream.writeBytes(copyBuffer);	}
						if(oldStream.bytesAvailable > 0)				{	copyBuffer.clear();	oldStream.readBytes(copyBuffer);												newStream.writeBytes(copyBuffer);	}
			
						oldStream.close();
						newStream.close();
						
						if(!destFile)
							(newFile as File).moveTo(_file, true);
						
						if(DebugLevel > 0)	trace("--- REWRITING JPEG END ---");
						
						return true;
					}
				}
				
				return false;
			}
			return false;
		}
		private function copyNode(dest:XMPMeta, source:XMPMeta, uri:String= ""):void{
			var ns:Namespace = uri != "" ? new Namespace(uri) : null;
			
			for each (var xmp_node:XMPNode in source){
				if(uri == "") 
					ns = new Namespace(xmp_node.qname.uri);
					
				if(xmp_node.qname.uri == uri || uri == "")
					dest.ns::[xmp_node.qname.localName] = xmp_node;
			}
		}	
		private function moveNodeIfNotToBig(dest:XMPMeta, source:XMPMeta, uri:String = ""):Boolean{
			var ns:Namespace = uri != "" ? new Namespace(uri) : null;
			var bytearray:ByteArray;
			
			for each (var xmp_node:XMPNode in source.clone()){
				if(uri == "") 
					ns = new Namespace(xmp_node.qname.uri);
					
				if(xmp_node.qname.uri == uri || uri == ""){
					dest.ns::[xmp_node.qname.localName] = xmp_node;
					
					bytearray = dest.serializeToBuffer();
					
					if(bytearray.length > 65502){
						delete dest.ns::[xmp_node.qname.localName];
					} else {
						delete source.ns::[xmp_node.qname.localName];
					}
				}
			}
			
			return true;
		}
	}
}