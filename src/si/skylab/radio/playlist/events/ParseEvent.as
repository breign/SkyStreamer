package si.skylab.radio.playlist.events {	import flash.events.Event;	
	/**
	 * ParseEvent -- event class
	 * 
	 * @description -- When dispatched contains the extension of the succesfully parsed file aswell as the data in File Objects 
	 * 	 * @author Sidney de Koning, sidney@funky-monkey.nl	 */	public class ParseEvent extends Event {
		public static const BEGIN_FILE_PARSE:String = "ParseEvent.BEGIN_FILE_PARSE";		public static const FILE_PARSED:String 		= "ParseEvent.FILE_PARSED";
		public static const STRING_PARSED:String 		= "ParseEvent.STRING_PARSED";		private var _extension:String;
		private var _parsedFiles:Array;

		
		public function ParseEvent(eType:String, pParsedFile:Array, pExtension:String, pBubbles:Boolean = false, eCancelable:Boolean = false) {
			super( eType , pBubbles , eCancelable );
			
			_parsedFiles= pParsedFile;
			_extension 	= pExtension;
		}

		
		public function get fileData():Array {
			return _parsedFiles;
		}

		
		public function get extension():String {
			return _extension;
		}

		
		/**
		 * @method clone
		 * @return Event
		 */
		override public function clone():Event {
			return new ParseEvent( type , fileData , extension , bubbles , cancelable );
		}

		
		/**
		 * @method toString
		 * @return String
		 */
		override public function toString():String {
			return formatToString( "ParseEvent" , "type" , "fileData" , "extension" , "bubbles" , "cancelable" , "eventPhase" );
		}
	}}