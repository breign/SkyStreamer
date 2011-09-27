package si.skylab.radio {
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	import mx.utils.ObjectUtil;
	
	import si.skylab.appcore.AppFunctions;
	import si.skylab.radio.playlist.events.ParseEvent;
	import si.skylab.radio.playlist.playlist.PlaylistReader;
	import si.skylab.radio.playlist.types.IPlayable;
	
	public final class SKYPlaylistLoader extends EventDispatcher {
		
		private var _url:String = ""; //AAC http://listen.di.fm/public1/trance.pls
		private var urls:Array = [];
		
		public function SKYPlaylistLoader(_url:String="http://listen.di.fm/public3/trance.pls"):void {
			
			this._url = _url;
			
			var loader : URLLoader = new URLLoader();
			loader.addEventListener(Event.COMPLETE, plsLoaded);
			loader.addEventListener(ProgressEvent.PROGRESS, onProgress);
			loader.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
			loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
			loader.addEventListener(HTTPStatusEvent.HTTP_STATUS, httStatus);
			
			loader.load(new URLRequest(_url));
		}
		
		private function plsLoaded_FILE( e : Event ):void {
			
			var value:String=e.currentTarget.data;
			
			// Create a new file from string data
			var plsFile:File=File.desktopDirectory;
			plsFile.url+= "/playlist.pls";
			AppFunctions.Log("url: " + plsFile.url);
			AppFunctions.Log("nativePath: " + plsFile.nativePath);
			var fs : FileStream = new FileStream();
			fs.open(plsFile, FileMode.WRITE);
			fs.writeUTFBytes(value);
			fs.close();
			
			AppFunctions.Log("====== PLS# " + plsFile + " ======");
			// instanciate new PlayListReader object with file reference
			var pls : PlaylistReader = new PlaylistReader();
			pls.addEventListener(ParseEvent.FILE_PARSED, parsedPlaylist, false, 0, true);
			pls.source=plsFile;
		}
		
		private function plsLoaded( e : Event ):void {
			
			var value:String=e.currentTarget.data;
			// instanciate new PlayListReader object with file reference
			var pls : PlaylistReader = new PlaylistReader(value);
			pls.addEventListener(ParseEvent.STRING_PARSED, parsedPlaylist, false, 0, true);
			pls.source=value;
		}
		
		private function parsedPlaylist( evt:ParseEvent ):void {
			
			var m3uFile:Array=evt.fileData as Array;
			AppFunctions.Log( "file with extension " + evt.extension.toString( ) + " succesfully parsed." );
			AppFunctions.Log( "====== M3U FILE   " + ObjectUtil.toString(m3uFile) + " ======" );
			
			for (var i:int = 0; i < m3uFile.length; ++i) {
				/*
				AppFunctions.Log( "====== M3U Item no# " + (i + 1) + " of " + m3uFile.length + " ======" );
				AppFunctions.Log( "** file   : " + IPlayable(m3uFile[i]).file );
				AppFunctions.Log( "** title  : " + IPlayable(m3uFile[i]).title );
				AppFunctions.Log( "** length : " + IPlayable(m3uFile[i]).length );
				AppFunctions.Log( "** isStream: " + IPlayable(m3uFile[i]).isStream );
				*/
				this.urls.push( IPlayable(m3uFile[i]).file );
			}
			dispatchEvent(new Event("SKYPlaylistLoader.COMPLETE"));
			
		}
		public function get Urls():Array {
			return this.urls.sortOn("names",Array.CASEINSENSITIVE);
		}

		private function httStatus( e : HTTPStatusEvent ):void {
			AppFunctions.Log(e.status);
		}
		
		private function onProgress( e : Event ):void {
			AppFunctions.Log(e);
		}
		
		private function onIOError( e : IOErrorEvent ):void {
			AppFunctions.Log(e.text);
		}
		
		private function onSecurityError( e : Event ):void {
			AppFunctions.Log(e);
		}
	}
}
