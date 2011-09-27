package de.qwesda.as3_xmp_file {
	
	import flash.filesystem.*;
	import flash.utils.*;
	/**
	 * example
	 * 
	 * 				
	 *				var file2:XMP_file = new XMP_file(File.desktopDirectory.nativePath+"/luck.jpg");
	 *				if(file2.file.exists){
	 *					AppFunctions.Log("\t\ttrue");
	 *					AppFunctions.Log(file2.xmp.dumpObject());
	 *				}			
	 *				file2 = new XMP_file(File.desktopDirectory.nativePath+"/luck2.jpg");
	 *				if(file2.file.exists){
	 *					AppFunctions.Log("\t\ttrue");
	 *					AppFunctions.Log(file2.xmp.dumpObject());
	 *				}			
	 *				file2 = new XMP_file(File.desktopDirectory.nativePath+"/luck2.jpg");
	 *				if(file2.file.exists){
	 *					AppFunctions.Log(file2.xmp.dumpObject());
	 *					//this is how we add XML metadata inside
	 *					var dc_exif:Namespace = XMPConst.jpeg;
	 *					file2.xmp.dc_exif::title = "QWE";
	 *					//this is how we add|change IDF metadata inside
	 *					
	 *					file2.save();
	 *				}
	 *				file2 = new XMP_file(File.desktopDirectory.nativePath+"/luck2.jpg");
	 *				if(file2.file.exists){
	 *					AppFunctions.Log("\t\ttrue");
	 *					AppFunctions.Log(file2.xmp.dumpObject());
	 *				}			
	 *
	 * 
	 */ 
	public class XMP_file {
		internal	var _file:File;
		internal	var _xmpFile:XMP_file_base;
		
		private		var _isSidecarFile:Boolean = false;
		
		static private 	var _supportedFiles:Array = ["tif", "tiff", "dng", "jpeg", "jpg", "psd", "pdf"];	// ["tif", "tiff", "dng", "xmp", "jpeg", "jpg", "psd", "indt", "indd"];
		
		public function get xmp():XMPWrapper			{	return _xmpFile ? _xmpFile.xmp			: null;		}
		public function get hasXmp():Boolean			{	return _xmpFile ? _xmpFile.hasXmp		: false;	}
		public function get hasThumb():Boolean			{	return _xmpFile ? _xmpFile.hasThumb		: false;	}
		public function get valid():Boolean				{	return _xmpFile ? _xmpFile.valid		: false;	}
		public function get file():File					{	return _file;	}
		public function get xmpFile():XMP_file_base	{	return _xmpFile;	}
		
		[Bindable]
		public function get thumbnails():Array			{	return _xmpFile ? _xmpFile.thumbnails	: [];		}
		public function set thumbnails(val:Array):void	{	}
	
		public function get fileName():String			{	return _file ? _file.name :	"{undefined}"; }
		public function get filePath():String			{	return _file ? _file.nativePath :	"{undefined}"; }
		public function get isSidecarFile():Boolean		{	return _isSidecarFile;		}
		
		static public function getSupportedFileExtentions():Array {
			return _supportedFiles;
		}
		static public function isSupported(file:File):Boolean {
			if(file && file.exists && file.extension != null) {
				for each(var ext:String in _supportedFiles)
					if(ext == file.extension.toLowerCase())
						return true;
			}
			
			return false;
		}
		
		public function XMP_file(fileName:String) {
			_file = new File(fileName);
			
			if(_file && _file.exists && !_file.isDirectory){
				switch (_file.extension.toLowerCase()) {
					case "tif"	:
					case "tiff"	:	//_xmpFile = new as3_xmp_file_tiff(fileName);	break;
					case "dng"	:	_xmpFile = new XMP_file_tiff(fileName);	break;
		//			case "xmp"	:	_xmpFile = new Aas3_xmp_file_xmp(fileName);	break;
					case "jpeg"	:
					case "jpg"	:	_xmpFile = new XMP_file_jpg(fileName);	break;
					case "png"	:	_xmpFile = new XMP_file_png(fileName);	break;
					case "psd"	:	_xmpFile = new XMP_file_psd(fileName);	break;
		//			case "indt"	:
		//			case "indd"	:	_xmpFile = new as3_xmp_file_indd(fileName);	break;
					case "pdf"	:	_xmpFile = new XMP_file_pdf(fileName);	break;
					default		:	_xmpFile = new XMP_file_base(fileName);	break;
					
					
				}
			}
		}
		
		public function save():void {
			if(_xmpFile)
				_xmpFile.writePacketToFile(xmp);
		}
		
		public function saveToNewFile(newFile:File):void {
			if(_xmpFile)
				_xmpFile.writePacketToFile(xmp, newFile);
		}
		
		public function readFromSidecarFile():void {
			if(_xmpFile)
				_xmpFile.readFromSidecarFile();
		}
		public function saveSidecarFile():void {
			if(_xmpFile)
				_xmpFile.saveSidecarFile();
		}
		public function saveAsSidecarFile():void {
			if(_xmpFile){
				_xmpFile.saveSidecarFile();
				
				_isSidecarFile = true;
			}
		}
	}
}