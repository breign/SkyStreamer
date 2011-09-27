package 
{
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.TimerEvent;
	import flash.filters.GlowFilter;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundLoaderContext;
	import flash.media.SoundTransform;
	import flash.net.URLRequest;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	
	import si.skylab.appcore.AppFunctions;
	
	public class SKYPlayer extends Sprite
	{
		//we pass multiple source urls for one stream 
		private var url:Array = [];
		
		private static var s:Sound;
		private var req:URLRequest; //http://u10.di.fm:80/di_trance_aac  -  problematic?! ");
		private var context:SoundLoaderContext;
		//current song / strem
		public var song:SoundChannel;
		//volume & stuff
		public var trans:SoundTransform = null;
		//retaining our playing status
		public static var isPlaying:Boolean = false;
		//retaining current channel for getting in/out of player
		public static var currentChannel:String;
		public static var currentName:String;
		public static var currentVolume:Number = -1;
		
		//track used sources for failover
		private var src:String = ""; 
		public static var SourcesUsed:Dictionary = new Dictionary();
		
		public function SKYPlayer():void {
			AppFunctions.Log("SKYPlayer instance created");
		}
		
		public function Play(_urls:Array,cb:String,cn:String):void {
			this.url 		= _urls;
			currentChannel	= cb;
			currentName		= cn;
			
			//prepair channel source control
			if (SourcesUsed[currentName]==null) SourcesUsed[currentName] = new Dictionary();
				
			//try to stop last stream
			if (s!=null) {
				try {
					s.close();
				} catch (e:Error) {
					AppFunctions.Log("ERROR @s.close();");
				}
			}
			
			if (song!=null) {
				try {
					_fadeOutSong(song);
				} catch (e:Error) {
					//play new stream
					_playStream();
					AppFunctions.Log("ERROR @_fadeOutSong(song);");
				}
			} else {
				//play new stream
				_playStream();
			}
			
		}
		
		public function Mute():void {
			if (!trans) return;
			trans.volume = 0;
			song.soundTransform = trans;
		}
		
		public function UnMute():void {
			if (!trans) return;
			trans.volume = 1; //last volume
			song.soundTransform = trans;
		}
		
		public function Stop():void {
			//stop stream
			if (s!=null) {
				try {
					s.close();
				} catch (e:Error) {null;}
			}
			if (song!=null) {
				try {
					song.stop();
				} catch (e:Error) {null;}
			}
			
			//stop equalizing
			equalizeStop();
		}
		
		/**
		 * make a connection and start playing stream
		 */ 
		private function _playStream():void {
			src = _findInternetSource(this.url);
			if (src == "") {
				//no valid source found!
				dispatchEvent(new Event("SKYPlayer.NO_SAFE_SOURCE"));
				return;
			}
			AppFunctions.Log("Will Play: "+src);
			//try to use :80 source as preferred
			req 	= new URLRequest(src);
			
			s		= new Sound();
			s.addEventListener(Event.COMPLETE, 			completeHandler);
			s.addEventListener(Event.ID3, 				id3Handler);
			s.addEventListener(IOErrorEvent.IO_ERROR, 	ioErrorHandler);
			s.addEventListener(ProgressEvent.PROGRESS, 	progressHandler);
			
			context = new SoundLoaderContext(15000,false);
			
			s.load(req, context);
			song = s.play();
			
			if (!trans) trans = new SoundTransform(1,0);
			trans.volume = currentVolume/100;
			song.soundTransform = trans;
		}
		
		private function _fadeOutSong(song:SoundChannel,playNext:Boolean=true):void {
			AppFunctions.Log("Fading out...");
			var t:Timer = new Timer(100);
			var ctrans:SoundTransform = new SoundTransform(song.soundTransform.volume,0);
			t.addEventListener(TimerEvent.TIMER, function(evt:Event):void {
				var vol:Number = ctrans.volume;
				vol -= .04;
				if (vol <= 0) {
					AppFunctions.Log("Will stop after _fadeOutSong");
					song.stop();
					t.stop();
					evt.currentTarget.removeEventListener(evt.type, arguments.callee);
				} else {
					ctrans.volume = vol;
					song.soundTransform = ctrans;
				}
				//AppFunctions.Log(vol);
			});
			t.start();
			
			//play new stream
			if (playNext) _playStream();
		}
		
		/**
		 * @TODO
		 * try other sources
		 */ 
		private function completeHandler(event:Event):void {
			AppFunctions.Log("completeHandler, stream has finished playing: " + event);
			isPlaying = false;
			//stop equalizing
			equalizeStop();
		}
		
		private function id3Handler(event:Event):void {
			AppFunctions.Log("id3Handler: " + event);
		}
		
		private function ioErrorHandler(event:Event):void {
			AppFunctions.Log("ioErrorHandler: " + event);
			AppFunctions.Log("SourcesUsed[" + currentName + "]" + src);
			isPlaying = false;
			//stop equalizing
			equalizeStop();
			//mark erroneous source
			SourcesUsed[currentName][src] = "error";
		}
		
		private function progressHandler(event:ProgressEvent):void {
		//	AppFunctions.Log("progressHandler: " + event);
			isPlaying = true;
			//start equalizing
			dispatchEvent(new Event("SKYPlayer.PLAYING"));
		}
				
		private function equalizeStop():void {
			isPlaying = false;
//			ControlBar.SKY.selected = false;
//			ControlBar.SKY.filters = [];
//			ControlBar.SKY.setStyle("icon", AssetEmbedder.ico_sky);
//			ControlBar.SKY.setStyle("skin", ButtonSkin);
//			ControlBar.SKY.toolTip = AppVars.CurrentLanguage.icons["sky.toolTip"];
//			if (ControlBar.SKY.contains(e)) ControlBar.SKY.removeChild(e);
		}
		
		/**
		 * resets channel source control
		 */ 
		public function SourcesUsedReset(channelName:String=""):void {
			SourcesUsed[channelName] = null;
		}
		
		/**
		 * helper function tries to return safe (not erroneous) source at :80 port preferably
		 * it uses SourcesUsed[currentName] for source control
		 */ 
		private function _findInternetSource(sources:Array):String {
			var src:String = "";
			//return safe :80
			for each (src in sources) {
				if (SourcesUsed[currentName][src] == 'error') {
					continue;
				} else {
					if (src.indexOf(":80/")>-1) return src;
				}
			}
			//return safe :any
			for each (src in sources) {
				if (SourcesUsed[currentName][src] == 'error') {
					continue;
				} else {
					return src;
				}
			}
			//no safe sources, give up!
			return "";
		}
	}
}
