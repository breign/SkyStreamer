package si.skylab.radio.playlist.types.pls {
	import si.skylab.radio.playlist.error.ParseError;
	import si.skylab.radio.playlist.types.FileExtensions;
	import si.skylab.radio.playlist.types.FileHeader;

	/**
	 * PLSParser -- Parses a PLS file
	 * 
	 * @description: Parses a PLS file and returns an PLSFile Object
	 * @mimetype: 	audio/x-mpegurl
	 * 
	 * More information on the M3U format
	 * @see http://en.wikipedia.org/wiki/PLS_(file_format)
	 * @see http://forums.winamp.com/showthread.php?threadid=65772
	 * 
	 * FIXME:
	 * 
	 * -- Somehow cant get the value of LengthN= out
	 * 		
	 * @author Sidney de Koning, sidney@funky-monkey.nl
	 */
	public class PLSParser {

		private static const NEEDLE_NO_OF_ENTRIES:String 	= "NumberOfEntries=";		private static const NEEDLE_FILE:String 			= "File";		private static const NEEDLE_TITLE:String 			= "Title";		private static const NEEDLE_LENGTH:String 			= "Length";		private static const NEEDLE_NEWLINE:String 			= "\n";
		//
		private static var _parsedFile:Array;
		
		public static function parse( data:String ):Array {
			

//			if (FileHeader.checkHeader( data , FileExtensions.PLS ) ) 
//			{	
				_parsedFile = new Array( );
				// do the actual parsing, loop through the complete string and search for specific elements
				// return an Array with file objects or custom PLS Objects				
				var noOfEntriesPos:int = data.search( NEEDLE_NO_OF_ENTRIES );
				
				if(noOfEntriesPos != -1) 
				{
					var noOfEntriesMarker:int = data.indexOf( NEEDLE_NEWLINE , noOfEntriesPos );
					
					var noOfEntries:String = data.substring( noOfEntriesPos + NEEDLE_NO_OF_ENTRIES.length , noOfEntriesMarker );					var entriesLength:int = int( noOfEntries );
					
					for (var i:Number = 1; i < entriesLength +1 ; i++ ) {
						
						var fileNeedle:String 		= NEEDLE_FILE + i + "=";
						var titleNeedle:String 		= NEEDLE_TITLE + i + "=";
						var lengthNeedle:String 	= NEEDLE_LENGTH + i + "=";
						
						var filePosition:Number 		= data.search( fileNeedle );				
						var secondFilePosition:Number 	= data.search( fileNeedle );
						var titlePosition:Number 		= data.search( titleNeedle );
						var lengthPosition:Number 		= data.search( lengthNeedle );
				
						var fileEntry:String = data.substring( filePosition + fileNeedle.length , titlePosition-1 );
						var titleEntry:String = data.substring( titlePosition + titleNeedle.length , lengthPosition-1 );
						
						// FIXME -- Somehow cant get the value of Length= out
						var lengthEntry:String = data.substring( lengthPosition + lengthNeedle.length , secondFilePosition -1);
						
						var plsFile: PLSFile = new PLSFile();
						plsFile.title = titleEntry;						plsFile.file = fileEntry;						plsFile.length = int(lengthEntry);
						
						_parsedFile.push( plsFile );						
					}
				}
				
//			} 
//			else 
//			{
//				throw new ParseError( "Specified file is not a PLS file, make sure you pass through the correct file" );
//			}
			
			return _parsedFile;
		}
	}
}
