package si.skylab.radio.playlist.types.m3u {
	import flash.utils.getTimer;
	
	import si.skylab.appcore.AppFunctions;
	import si.skylab.radio.playlist.error.ParseError;
	import si.skylab.radio.playlist.types.FileExtensions;
	import si.skylab.radio.playlist.types.FileHeader;

	/**
	 * M3UParser -- Parses a M3U file
	 * 
	 * @description: Parses a M3U file and returns an M3UFile Object
	 * 
	 * More information on the M3U format
	 * @see http://hanna.pyxidis.org/tech/m3u.html
	 * @see http://en.wikipedia.org/wiki/M3U
	 * @see http://forums.winamp.com/showthread.php?threadid=65772
	 * @see http://schworak.com/programming/music/playlist_m3u.asp
	 * 
	 * File Extended M3U
	 * 
	 * #EXTM3U
	 * #EXTINF:233,Everclear - So Much For The Afterglow
	 * Alternative\everclear_SMFTA.mp3
	 * #EXTINF:227,Weird Al - Everything You Know Is Wrong
	 * Comedy\Weird_Al_Everything_You_Know_Is_Wrong.mp3
	 * #EXTINF:187,Weird Al Yankovic - This is the Life
	 * Weird_Al_This_Is_The_Life.mp3
	 * #EXTINF:129,Weird Al: Bad Hair Day - Gump
	 * http://www.site.com/~user/gump.mp3
	 * #EXTINF:-1,My Cool Stream
	 * http://www.site.com:8000/listen.pls
	 * 		
	 * @author Sidney de Koning, sidney@funky-monkey.nl
	 */
	public class M3UParser {

		private static var EMPTY_MARKER : String 	= "";
		private static var EXT_INFO_MARKER : String = "#EXTINF:";
		//
		private static var _parsedFile : Array;

		public static function parse(data : String) : Array {
			
			var beginDuration:uint = getTimer();
			// Handle specific parsing of M3U files
			if (FileHeader.checkHeader(data, FileExtensions.M3U) ) {
				
				_parsedFile = new Array();
				
				var pattern : RegExp = /\r?\n/;
				var lines : Array = data.split(pattern);
				
				// Remove FileHeader.M3U_FILE from Array
				// because we already know its an M3U file so we dont need it anymore			
				lines = lines.slice(1, lines.length);
				
				for (var i : Number = 0;i < lines.length; i++) {
					
					// do the actual parsing, loop through the complete string and search for specific elements
					if( lines[i] != EMPTY_MARKER ) {
						
						// Get the result from EXT_INFO_MARKER untill end of line
						var extInfoIndex : int = lines[i].indexOf(EXT_INFO_MARKER);
	
						if(extInfoIndex != -1) {
							
							// We are now at the #EXT_INFO line, we have content for first line				
							var extInfoIndexMarker : String = lines[i].substr(0, EXT_INFO_MARKER.length);
							
							var time:Array = lines[i].split(",");	// result: #EXTINF:321 :: Example title		
							var length:Number 	= time[0].substr(extInfoIndexMarker.length, time[0].length);
							var title:String 	= time[1];
							
							var m3uFile : M3UFile = new M3UFile();
							m3uFile.title 	= title;
							m3uFile.length 	= length;
							
							// slice off extinfo entry
							lines = lines.slice(0, lines.length);
							m3uFile.file = lines[i+1];
							lines = lines.slice(0, lines.length);
							_parsedFile.push(m3uFile);
						}					
					}
				}
			} else {
				throw new ParseError("Specified file is not a M3U file, make sure you pass through the correct file");
			}
			var endDuration:uint = getTimer();
			AppFunctions.Log("Parse Time: " + uint(endDuration - beginDuration) / 1000  + " seconds.");
			
			return _parsedFile;
		}
	}
}	 