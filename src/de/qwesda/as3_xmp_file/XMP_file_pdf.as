package de.qwesda.as3_xmp_file {
	import com.adobe.xmp.core.XMPMeta;
	
	import flash.filesystem.*;
	import flash.utils.*;
	
	import mx.collections.*;
	import mx.utils.*;
	
	public class XMP_file_pdf extends XMP_file_base {
		private var pdfVersionMajor:int	= -1;
		private var pdfVersionMinor:int	= -1;
				
		public function XMP_file_pdf(fileName:String) {		
			super(fileName);
			
			if(_valid && !_isSidecarFile){
				readPacketFromFile();
			}
		}
		
		public function getThumbnail(stream:ByteArray):Object {			
			return null;
		}
		
		override public function checkIfFileFormatIsValid():Boolean {
			_valid = false;
			
			if(DebugLevel > 0)	trace("--- VERIFIING PDF --- \t" + _file.nativePath);
			
			try {
				var _filestream:FileStream = new FileStream();
				_filestream.open(_file, FileMode.READ);
				_filestream.endian = Endian.BIG_ENDIAN;
				
				var stream:Stream	= new Stream(_filestream);
				
				var headerFound:Boolean = false;
				var eofFound:Boolean	= false;
				pdfVersionMajor			= -1;
				pdfVersionMinor			= -1;
				
				var line:String = "";
				
				do {
					line = stream.getLineForward();
					
					if(line.substr(0, 5) == "%PDF-"){
						headerFound = true;
						
						var versionStr:String	= line.substr(5);
						var versionArr:Array	= versionStr.split(".");
						
						if(versionArr.length == 2){
							pdfVersionMajor = parseInt(versionArr[0]);
							pdfVersionMinor = parseInt(versionArr[1]);
						}
					}
				} while (!headerFound && stream.position < 1024);
				
				stream.goToEnd();
				
				do {
					line = stream.getLineBackward();
					
					if(line == "%%EOF"){
						eofFound = true;
					}
				} while (!eofFound && stream.bytesAvailable < 1024);
				
				_valid = headerFound && eofFound && 
							pdfVersionMajor == 1 && 
							pdfVersionMinor >= 1 && pdfVersionMinor <= 7;
				
				_filestream.close();
			} catch (e:Error) { }
			
			
			return _valid;
		}
		
		override public function readPacketFromFile():Boolean {
			if(_valid){
				var _filestream:FileStream = new FileStream();
				_filestream.open(_file, FileMode.READ);
				_filestream.endian = Endian.BIG_ENDIAN;
				
				var stream:Stream	= new Stream(_filestream);
				var line:String		= "";
				
				var xRefPos:int		= -1;
				
				stream.goToEnd();
				
				// find xRefPos
				do {
					line = stream.getLineBackward();
					
					if(line == "startxref"){
						line = stream.getLineForward();
						line = stream.getLineForward();
						
						xRefPos = parseInt(line);
						
						break ;
					}
				} while (stream.bytesAvailable < 1024 * 10);
				
				// read xRefPos
				if(xRefPos > 0){
					stream.position = xRefPos;
				}
				
				_filestream.close();
			}
			
			return false;
		}
		private function updateInPlace(xmp:XMPMeta):Boolean {
			if(_valid){
			}
			
			return false;	
		}
		override public function writePacketToFile(xmp:XMPMeta, destFile:File = null):Boolean {
			
			return false;
		}
	}
}