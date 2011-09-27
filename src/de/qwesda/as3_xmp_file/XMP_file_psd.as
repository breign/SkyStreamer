package de.qwesda.as3_xmp_file {
	import com.adobe.xmp.core.SerializeOptions;
	import com.adobe.xmp.core.XMPMeta;
	
	import flash.filesystem.*;
	import flash.utils.*;
	
	import mx.collections.*;
	import mx.utils.UIDUtil;
	
	public class XMP_file_psd extends XMP_file_base {
		private var photoshopImageResources:Array	= [];
		private var imageResourcesLengthPos:uint	= 0;
		
		public var width:int						= -1;
		public var height:int						= -1;
			
		public function XMP_file_psd(fileName:String) {		
			super(fileName);
			
			if(_valid && !_isSidecarFile){
				readPacketFromFile();
			}
			
			if(!_valid)
				trace("XMP resource is not valid ... ");
		}
		
		public function getThumbnail(stream:ByteArray):Object {			
			return null;
		}
		
		override public function checkIfFileFormatIsValid():Boolean {
			_valid = false;
			
			if(DebugLevel > 0)	trace("--- VERIFIING PSD --- \t" + _file.nativePath);
			
			try {
				var _filestream:FileStream = new FileStream();
				_filestream.open(_file, FileMode.READ);
				_filestream.endian = Endian.BIG_ENDIAN;
				
				var signature:String			= _filestream.readUTFBytes(4);
				var version:int					= _filestream.readUnsignedShort();
				var zeros:String				= _filestream.readUTFBytes(6);
				var numberOfChannels:int		= _filestream.readUnsignedShort();
				var imageHeightInPixels:int		= _filestream.readUnsignedInt();
				var imageWidthInPixels:int		= _filestream.readUnsignedInt();
				var numberOfBitsPerChannel:int	= _filestream.readUnsignedShort();
				var colorMode:int				= _filestream.readUnsignedShort();
				
				var colorModeData:String		= _filestream.readUTFBytes(4);
				
				var imageResourcesLength:int	= _filestream.readUnsignedInt();
				
				var photoshopImageResource:PSD_Image_Resource_Header;
				
				_filestream.close();
				
				if(signature == "8BPS" && imageHeightInPixels > 0 && imageHeightInPixels > 0 && imageResourcesLength > 0)
					_valid = true;
			} catch (e:Error) { }
			
			
			return _valid;
		}
		
		override public function readPacketFromFile():Boolean {
			if(_valid){
				thumbnails				= [];
				photoshopImageResources	= [];
				imageResourcesLengthPos	= 0;
				
				try {
					var _filestream:FileStream = new FileStream();
					_filestream.open(_file, FileMode.READ);
					_filestream.endian = Endian.BIG_ENDIAN;
					
					var signature:String			= _filestream.readUTFBytes(4);
					var version:int					= _filestream.readUnsignedShort();
					var zeros:String				= _filestream.readUTFBytes(6);
					var numberOfChannels:int		= _filestream.readUnsignedShort();
					var imageHeightInPixels:int		= _filestream.readUnsignedInt();
					var imageWidthInPixels:int		= _filestream.readUnsignedInt();
					var colorMode:int				= _filestream.readUnsignedShort();
					var numberOfBitsPerChannel:int	= _filestream.readUnsignedShort();
					var colorModeDataLength:int		= _filestream.readUnsignedInt();
					var colorModeData:String		= _filestream.readUTFBytes(colorModeDataLength);
					
					imageResourcesLengthPos			= _filestream.position;
					var imageResourcesLength:int	= _filestream.readUnsignedInt();
					
					var photoshopImageResource:PSD_Image_Resource_Header;
					
					do {
						photoshopImageResource = new PSD_Image_Resource_Header(_filestream);
						
						if(photoshopImageResource.valid)
							photoshopImageResources.push(photoshopImageResource);
					} while (photoshopImageResource.valid);
					
					height	= imageHeightInPixels;
					width	= imageHeightInPixels;
					
					for each (photoshopImageResource in photoshopImageResources) {
						if(photoshopImageResource.type_nr == 0x0424) {
							if(!photoshopImageResource.valid)
								_valid = false;
							
							try {
								var binaryPacket:ByteArray = photoshopImageResource.getPayload(_filestream);
								_xmp = new XMPWrapper(binaryPacket);
							} catch (e:Error) {
								_valid = false;
							}
							break ;
						}
					}
					
					_filestream.close();
					
					return true;
				} catch (e:Error) { }
			}
			
			return false;
		}
		private function updateInPlace(xmp:XMPMeta):Boolean {
			if(_valid){
				var so:SerializeOptions	= new SerializeOptions();	
				var updateStream:FileStream = new FileStream();
				
				var oldPacket:ByteArray;
				var newPacket:ByteArray;
				
				updateStream.open(_file, FileMode.UPDATE);
				updateStream.endian = Endian.BIG_ENDIAN;
				
				var stream:Stream = new Stream(updateStream);
				
				var photoshopImageResource:PSD_Image_Resource_Header;
				for each (photoshopImageResource in photoshopImageResources) {
					if(photoshopImageResource.type_nr == 0x0424) {
						oldPacket = photoshopImageResource.getPayload(updateStream);
						
						try {
							newPacket = xmp.serializeToBuffer(so);
							
							if(oldPacket.length > newPacket.length) {
								so.padding = so.padding + oldPacket.length - newPacket.length;
								newPacket = xmp.serializeToBuffer(so);
							}
							
							if(oldPacket.length == newPacket.length){
								if(DebugLevel > 0)	trace("--- UPDATING PSD IN PLACE ---");
							
								updateStream.position = photoshopImageResource.position_start + photoshopImageResource.payload_offset;
								updateStream.writeBytes(newPacket);
		
								if(DebugLevel > 0)	trace("--- UPDATING PSD IN PLACE END ---");
								
								updateStream.close();
								
								return true;
							}
						}
						catch (e:Error) {
							
						}
						
						break ;
					}
				}
				
				updateStream.close();
			}
			
			return false;	
		}
		override public function writePacketToFile(xmp:XMPMeta, destFile:File = null):Boolean {
			var success:Boolean = false;
			var so:SerializeOptions	= new SerializeOptions(); so.padding	= 34 * 1024;
			
			var oldPacket:ByteArray;
			var newPacket:ByteArray;
			
			var copyBuffer:ByteArray = new ByteArray();
			
			if(_valid){
				if(readPacketFromFile()){
					if(!destFile && updateInPlace(xmp)){
						return true;
					} else if(imageResourcesLengthPos > 0){
						if(DebugLevel > 0)	trace("--- REWRITING PSD ---");
						
						var newFile:File				= destFile ? destFile : new File(_file.nativePath  + "." + mx.utils.UIDUtil.createUID() + "." + _file.extension);
												
						var oldFileStream:FileStream	= new FileStream();
						var newFileStream:FileStream	= new FileStream();
						
						oldFileStream.endian = Endian.BIG_ENDIAN;
						newFileStream.endian = Endian.BIG_ENDIAN;
				
						oldFileStream.open(_file,	FileMode.READ);
						newFileStream.open(newFile,	FileMode.WRITE);
						
						newPacket = xmp.serializeToBuffer(so);
						
						var photoshopImageResource:PSD_Image_Resource_Header;
						for each (photoshopImageResource in photoshopImageResources) {
							if(photoshopImageResource.type_nr == 0x0424) {
								oldFileStream.readBytes(copyBuffer, 0, photoshopImageResource.position_start);
								newFileStream.writeBytes(copyBuffer);
								
								newFileStream.writeUTFBytes("8BIM");
								newFileStream.writeShort(0x0424);
								newFileStream.writeShort(0);
								newFileStream.writeUnsignedInt(newPacket.length);
								newFileStream.writeBytes(newPacket);
								
								oldFileStream.position += 8;
								
								if(newPacket.length%2 != 0)
									newFileStream.writeByte(0);
								
								oldFileStream.position = photoshopImageResource.position_next;
								
								while (oldFileStream.bytesAvailable > 1024*1024){	copyBuffer.clear();	oldFileStream.readBytes(copyBuffer, 0, 1024*1024);  newFileStream.writeBytes(copyBuffer);	}
								if(oldFileStream.bytesAvailable > 0)			{	copyBuffer.clear();	oldFileStream.readBytes(copyBuffer); 					          newFileStream.writeBytes(copyBuffer);	}
								
								success = true;
								
								var fileSizeDiff:int = newFileStream.position - oldFileStream.position;
								
								oldFileStream.position = imageResourcesLengthPos;
								newFileStream.position = imageResourcesLengthPos;
								
								var oldImageResourcesLength:uint = oldFileStream.readUnsignedInt();
								var newImageResourcesLength:uint = oldImageResourcesLength + fileSizeDiff;
							//	newImageResourcesLength += newPacket.length%2;
								
								newFileStream.writeUnsignedInt(newImageResourcesLength);
								
								break ;
							}
						}
						
						newFileStream.close();
						oldFileStream.close();
						
						if(!destFile)
							(newFile as File).moveTo(_file, true);
						
						if(DebugLevel > 0)	trace("--- REWRITING PSD END ---");
					}
				}
			}
			
			return success;
		}
	}
}