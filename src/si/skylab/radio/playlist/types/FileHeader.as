package si.skylab.radio.playlist.types {
	/**
	 * FileHeader -- Constants
	 * 
	 * @description: Constants to check file headers for parsing
	 * 		
	 * @author Sidney de Koning, sidney@funky-monkey.nl
	 */
	public class FileHeader 
	{
		// CONSTANTS AND STATICS
		public static const PLS_FILE:String = "[playlist]";		public static const B4S_FILE:String = "[b4s]";		public static const M3U_FILE:String = "#EXTM3U";
		//
		/**
		 * @method checkHeader
		 * @param head checks the
		 * @param extension
		 * @description Does aditional check to see if File is indeed a File by checking its header
		 * @return true if check is passed and file is indeed specified file
		 */
		public static function checkHeader( head:String, extension:String ):Boolean {
			
			var headerCheck:Boolean = false;
			
			switch(extension) {
				
				case FileExtensions.PLS:
					if(head.indexOf(PLS_FILE) != -1) {
						headerCheck = true;
					}
					break;
				case FileExtensions.M3U:
					if(head.indexOf(M3U_FILE) != -1) {
						headerCheck = true;
					}
					break;
				case FileExtensions.B4S:
					if(head.indexOf(B4S_FILE) != -1) {
						headerCheck = true;
					}
					break;
			}
			return headerCheck;
		}
	}
}
