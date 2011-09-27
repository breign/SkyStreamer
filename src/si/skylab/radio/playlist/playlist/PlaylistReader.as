package si.skylab.radio.playlist.playlist {
	import flash.events.*;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.utils.getQualifiedClassName;
	
	import si.skylab.appcore.AppFunctions;
	import si.skylab.radio.playlist.events.ParseEvent;
	import si.skylab.radio.playlist.types.m3u.M3UParser;
	import si.skylab.radio.playlist.types.pls.PLSParser;
	
	/**
	 * PlaylistReader -- Reads in a PLS, M3U or XSPF
	 * 
	 * @description: Reads in playlist formats async manner
	 * 
	 * TODO: 
	 * 		- Add support for B4S  -- WinAmp3 XML Based playlist format
	 * 		- Add support for XSPF -- WinAmp3 XML Based playlist format
	 * 
	 * NOTES:
	 * 
	 * If you want to use the FireLog Logger, go to http://www.funky-monkey.nl/blog/
	 * 
	 * @see For complete documentation either go to http://code.gogle.com/p/as3plsreader/ 
	 * or checkout the source package and test package
	 * 
	 * @author Sidney de Koning, sidney@funky-monkey.nl
	 * @version 1.0.5
	 */
	public class PlaylistReader extends EventDispatcher {
		
		private var _file : File;
		private var _fileStream : FileStream;
		private var _fileData : String;	
		
		private var _StringOrFile:String = "";
		
		public function PlaylistReader( StringOrFile:String="File" ) {
			this._StringOrFile = StringOrFile;
		}
		
		/**
		 * @method source
		 * @description sets a File object to be parsed
		 * @param value:* - the location of the File object
		 */
		public function set source( value : Object ) : void {
			if (this._StringOrFile == "File") {
				_file = File(value);
				switch(extension.toUpperCase( )) {
					case "PLS":
						// Handle loading of PLS files
						loadPlaylist( );
						break;
					case "M3U":
						loadPlaylist( );
						// Handle loading of M3U files
						break;
					case "XSPF":
						// Handle loading of XSPF files
						break;
				}
			} else {
				doFileParse();
			}
		}
		
		private function loadPlaylist() : void {
			if (this._StringOrFile == "File") {
				
				// Open stream for string data
				_fileStream = new FileStream( );
				_fileStream.addEventListener( Event.COMPLETE, handleFileReadComplete );
				_fileStream.addEventListener( Event.OPEN, handleFileOpenComplete );
				_fileStream.addEventListener( ProgressEvent.PROGRESS, handleProgress );
				_fileStream.addEventListener( IOErrorEvent.IO_ERROR, handleIOError );
				//			
				_fileStream.openAsync( _file, FileMode.READ );
			}
		}
		
		private function handleFileReadComplete(evt : Event) : void {
			if (this._StringOrFile == "File") {
				doFileParse( );
			}
		}
		
		private function doFileParse() : void {
			if (this._StringOrFile == "File") {
				
				_fileData = _fileStream.readMultiByte( _fileStream.bytesAvailable, File.systemCharset );
				
				var fileObj : Array;
				switch(extension.toUpperCase( )) {
					case "PLS":
						// Handle specific parsing of PLS files
						fileObj = PLSParser.parse( _fileData.toString( ) );
						break;
					case "M3U":
						// Handle specific parsing of M3U files
						fileObj = M3UParser.parse( _fileData.toString( ) );
						break;
					case "XSPF":
						// Handle specific parsing of XSPF files
						fileObj = PLSParser.parse( _fileData as XML );
						break;
				}
				
				AppFunctions.Log( "File parsed, now dispatch a ParseEvent.FILE_PARSED" );
				dispatchEvent( new ParseEvent( ParseEvent.FILE_PARSED, fileObj, extension ) );
			} else {
				fileObj = PLSParser.parse( this._StringOrFile );
				AppFunctions.Log( "String parsed, now dispatch a ParseEvent.STRING_PARSED" );
				dispatchEvent( new ParseEvent( ParseEvent.STRING_PARSED, fileObj, "PLS" ) );
			}
		}
		
		private function handleFileOpenComplete(evt : Event) : void {
		}
		
		private function handleProgress(evt : ProgressEvent) : void {
			AppFunctions.Log( _fileStream.position + " :: " + _fileStream.bytesAvailable );
		}
		
		private function handleIOError(ioError : IOErrorEvent) : void {
			// POSSIBLE SCENARIOS:
			// The file does not exist; you do not have adequate permissions to open the file; 
			// you are opening a file for read access, and you do not have read permissions; 
			// or you are opening a file for write access, and you do not have write permissions.
		}
		
		/**
		 * @method extension
		 * @description returns the extension of the File object
		 */
		public function get extension() : String {
			return _file.extension;			
		}
		
		override public function toString() : String {
			return "[" + getQualifiedClassName( this ).match( "[^:]*$" )[0] + "]";
		}
	}
}
