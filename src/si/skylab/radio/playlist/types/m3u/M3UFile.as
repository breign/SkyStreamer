package si.skylab.radio.playlist.types.m3u {
	import si.skylab.radio.playlist.types.IPlayable;

	/**
	 * 
	 * M3U File - Same properties as one entry in a M3U playlist
	 * 
	 * @author Sidney de Koning, sidney@funky-monkey.nl
	 */
	public class M3UFile implements IPlayable {

		private var _url:String;
		private var _length:Number;
		private var _title:String;
		
		public function M3UFile() {
			// does notting
		}

		public function set file(pValue:String):void {
			_url = (pValue == "" || pValue == null) ? "" : pValue;		}

		public function set title(pValue:String):void {
			_title = (pValue == "" || pValue == null) ? "" : pValue;		}

		public function set length(pValue:Number):void {
			(pValue == -1) ? _length = -1 : _length = pValue;		}

		public function get file():String {
			return _url;
		}

		public function get length():Number {
			return _length;
		}

		public function get title():String {
			return _title;
		}

		public function get isStream():Boolean {
			return (_length == -1) ? true : false;
		}
	}
}
