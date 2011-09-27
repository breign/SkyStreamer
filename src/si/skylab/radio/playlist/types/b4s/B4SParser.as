package si.skylab.radio.playlist.types.b4s {
	import si.skylab.radio.playlist.error.ParseError;
	import si.skylab.radio.playlist.types.FileExtensions;
	import si.skylab.radio.playlist.types.FileHeader;

	/**
	 * B4SParser -- Parses a B4S file
	 * 
	 * @description: Parses a B4S file and returns an B4SFile Object
	 * 
	 * More information on the B4S format
	 * @see http://gonze.com/playlists/playlist-format-survey.html#B4S
	 * 
	 * 		
	 * @author Sidney de Koning, sidney@funky-monkey.nl
	 */
	public class B4SParser {

		public function parse( data:String ):void {
			// Handle specific parsing of PLS files
			if (FileHeader.checkHeader( data , FileExtensions.B4S ) ) {
				
				// do the actual parsing, loop through the complete string and search for specific elements
			} 
			else 
			{
				throw new ParseError( "Specified file is not a B4S file, make sure you pass through the correct file" );
			}
		}
	}
}
