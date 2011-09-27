package si.skylab.radio
{
	public class SKYConfig
	{
		/**
		 * SKY radio lists
		 */ 
		public static const SKYPlaylists:Array = [
			"http://listen.di.fm/public3/list"
			,"http://listen.sky.fm/public3/list"
			,"http://listen.jazzradio.com/public3/list"
		];
		
		public static const SKYPlaylist:Array 	= ["http://skylab.si/b/skystreamer/sky.php"];
		public static const DIPlaylist:Array  	= ["http://skylab.si/b/skystreamer/di.php"];
		public static const JAZZPlaylist:Array 	= ["http://skylab.si/b/skystreamer/jazz.php"];
		
		public static const btn:Object = {h:50,w:80};
		public static const ListColors:Array = [0x65A9E1,0xFF6FC9,0xAEE983];
	}
}