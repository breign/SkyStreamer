package 
{
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MediaEvent;
	import flash.media.CameraRoll;
	import flash.media.MediaPromise;
	import flash.media.MediaType;
	
	import si.skylab.appcore.AppFunctions;
	
	public class RollUp extends Sprite{
		private var mediaSource:CameraRoll = new CameraRoll();
		
		public function RollUp() {
			this.stage.align = StageAlign.TOP_LEFT;
			this.stage.scaleMode = StageScaleMode.NO_SCALE;
			
			if( CameraRoll.supportsBrowseForImage )
			{
				AppFunctions.Log( "Browsing for image..." );
				mediaSource.addEventListener( MediaEvent.SELECT, imageSelected );
				mediaSource.addEventListener( Event.CANCEL, browseCanceled );
				
				mediaSource.browseForImage();
			}
			else
			{
				AppFunctions.Log( "Browsing in camera roll is not supported.");
			}
		}
		
		private var imageLoader:Loader; 
		private function imageSelected( event:MediaEvent ):void
		{
			AppFunctions.Log( "Image selected..." );
			
			var imagePromise:MediaPromise = event.data;
			
			imageLoader = new Loader();
			if( imagePromise.isAsync )
			{
				AppFunctions.Log( "Asynchronous media promise." );
				imageLoader.contentLoaderInfo.addEventListener( Event.COMPLETE, imageLoaded );
				imageLoader.contentLoaderInfo.addEventListener( IOErrorEvent.IO_ERROR, imageLoadFailed );
				imageLoader.loadFilePromise( imagePromise );
			}
			else
			{
				AppFunctions.Log( "Synchronous media promise." );
				imageLoader.loadFilePromise( imagePromise );
				this.addChild( imageLoader );
			}
		}
		
		private function browseCanceled( event:Event ):void
		{
			AppFunctions.Log( "Image browse canceled." );
		}
		
		private function imageLoaded( event:Event ):void
		{
			AppFunctions.Log( "Image loaded asynchronously." );
			this.addChild( imageLoader );
		}
		
		private function imageLoadFailed( event:Event ):void
		{
			AppFunctions.Log( "Image load failed." );
		}
				
	}
	
}