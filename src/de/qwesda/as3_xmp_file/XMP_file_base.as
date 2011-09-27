package de.qwesda.as3_xmp_file {
	import com.adobe.xmp.core.SerializeOptions;
	import com.adobe.xmp.core.XMPMeta;
	
	import flash.filesystem.*;
	import flash.utils.*;
	
	public class XMP_file_base {
		protected	var _valid:Boolean 	= false;
		protected	var _hasXmp:Boolean = false;
		protected	var _hasSidecarFile:Boolean = false;
		protected	var _isSidecarFile:Boolean = false;
		protected	var _hasThumb:Boolean = false;
		protected	var _xmp:XMPWrapper = null;
		internal	var _xmp_was_read:Boolean = false;
		
		internal	var thumbnails:Array	= [];
//		internal	var thumbnail:Object	= null;
		
		protected	var _file:File;
		
		public function get xmp():XMPWrapper			{	return _xmp;			}
		public function get hasXmp():Boolean			{	return _hasXmp;			}
		public function get hasThumb():Boolean			{	return thumbnails.length > 0;	}
		public function get hasSidecarFile():Boolean	{	return _hasSidecarFile;	}
		public function get isSidecarFile():Boolean		{	return _isSidecarFile;	}
		public function get valid():Boolean				{	return _valid;			}
		
		public function XMP_file_base(fileName:String) {
			_file	= new File(fileName);
			_xmp	= new XMPWrapper();
				
			if(_file && _file.exists){
				
				var sidecarFilenamename:String = _file.nativePath.substr(0, -_file.extension.length) + "xmp";
				var _sidecarFile:File = new File(sidecarFilenamename);
				
				_isSidecarFile = _hasSidecarFile = _sidecarFile.exists;
				
				if(_hasSidecarFile)	
					readFromSidecarFile();
					
				_valid = checkIfFileFormatIsValid();
			}
		}
		
		public function checkIfFileFormatIsValid():Boolean {
			return false;
		}
		
		public function writePacketToFile(xmp:XMPMeta, destFile:File = null):Boolean {
			saveSidecarFile();
			
			return false;
		}
		
		public function readPacketFromFile():Boolean {
			readFromSidecarFile();
			
			return false;
		}
		
		public function readFromSidecarFile():void {
			if(_file){
				_isSidecarFile = true;
				
				var fileName:String		= _file.nativePath.substr(0, -_file.extension.length);
				
				var sidecarFilenamename:String = _file.nativePath.substr(0, -_file.extension.length) + "xmp";
				var _sidecarFile:File	= new File(sidecarFilenamename);
				
				if(_sidecarFile.exists){
					var stream:FileStream	= new FileStream();
					
					var string:String		= "";
					
					stream.open(_sidecarFile, FileMode.READ);
					string = stream.readUTFBytes(stream.bytesAvailable);
					stream.close();
					
					_xmp = new XMPWrapper(string);
				}
			}
		}
		public function saveSidecarFile():void {
			if(_file){
				var fileName:String		= _file.nativePath.substr(0, -_file.extension.length);
				
				var sidecarFilenamename:String = _file.nativePath.substr(0, -_file.extension.length) + "xmp";
				var _sidecarFile:File	= new File(sidecarFilenamename);
				
				if(_xmp){
					var stream:FileStream	= new FileStream();
					
					var so:SerializeOptions	= new SerializeOptions(); so.padding = 0;
					var ba:ByteArray		= _xmp.serializeToBuffer(so);
					
					stream.open(_sidecarFile, FileMode.WRITE);
					stream.writeBytes(ba);
					stream.close();
				}
			}
		}
	}
}