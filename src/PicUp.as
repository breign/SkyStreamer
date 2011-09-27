package
{
	import com.adobe.xmp.core.XMPConst;
	
	import de.qwesda.as3_xmp_file.IDF_Entry;
	import de.qwesda.as3_xmp_file.XMP_file;
	
	import flash.desktop.NativeApplication;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.MediaEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.media.CameraUI;
	import flash.media.MediaPromise;
	import flash.media.MediaType;
	import flash.net.URLRequest;
	import flash.net.URLVariables;
	import flash.system.Capabilities;
	import flash.utils.ByteArray;
	import flash.utils.IDataInput;
	
	import si.skylab.appcore.AppFunctions;
	import si.skylab.appcore.AppMobileMaster;
	
	public class PicUp extends Sprite
	{
		private var cameraUI:CameraUI = new CameraUI();
		private var dataSource:IDataInput;
		private var eventSource:IEventDispatcher;
		private const serverURL:String = "http://skylab.si/b/skystreamer/upload.php";
		private var metadata:URLVariables = new URLVariables(); //some metadata to be sent along with the image
		private var tempDir:File;
		
		public function PicUp(_metadata:URLVariables=null)
		{
			if( CameraUI.isSupported )
			{
				metadata = _metadata;
				AppFunctions.Log( "Initializing camera..." );
				cameraUI.addEventListener( MediaEvent.COMPLETE, imageSelected );
				cameraUI.addEventListener( Event.CANCEL, canceled );
				cameraUI.addEventListener( ErrorEvent.ERROR, mediaError );
				cameraUI.launch( MediaType.IMAGE );
			}
			else
			{
				AppFunctions.Log( "CameraUI is not supported.");
			}
			
		}
		
		private function imageSelected( event:MediaEvent ):void
		{
			AppFunctions.Log( "Media selected..." );
			var imagePromise:MediaPromise = event.data;
			
			if( imagePromise.file != null && false)
			{
				imagePromise.file.upload( new URLRequest( serverURL ) );
			}
			else
			{
				dataSource = imagePromise.open();
				
				if( imagePromise.isAsync )
				{
					AppFunctions.Log( "Asynchronous media promise." );
					var eventSource:IEventDispatcher = dataSource as IEventDispatcher;				
					eventSource.addEventListener( Event.COMPLETE, onMediaLoaded );				
				}
				else
				{
					AppFunctions.Log( "Synchronous media promise." );
					readMediaData();
				}
			}
		}
		
		private function onMediaLoaded( event:Event ):void
		{
			AppFunctions.Log("Media load complete");
			readMediaData();
		}
		
		private function canceled( event:Event ):void
		{
			AppFunctions.Log( "Media select canceled" );
			//cameraUI.launch( MediaType.IMAGE );  //Upload another image
			return;
		}
		
		private function readMediaData():void
		{
			var imageBytes:ByteArray = new ByteArray();
			dataSource.readBytes( imageBytes );
			
			tempDir = File.createTempDirectory();
			var now:Date = new Date();
			var filename:String = "IMG" + AppFunctions.DateFormat(now,"yyyyMMdd_HHmmss") + ".jpg";
			var temp:File = tempDir.resolvePath( filename );
			var stream:FileStream = new FileStream();
			stream.open( temp, FileMode.WRITE );
			stream.writeBytes( imageBytes );
			stream.close();
			
			var pic:XMP_file = new XMP_file(temp.nativePath);
			if(pic.file.exists){
				var dc_exif:Namespace = XMPConst.jpeg;
				for (var i:Object in metadata) {
					pic.xmp.dc_exif::[i] = metadata[i];
				}
				dc_exif = XMPConst.dc;
				pic.xmp.dc_exif::date = AppFunctions.DateFormat(now);
				pic.xmp.dc_exif::uaid = AppMobileMaster.UAID;
				pic.xmp.dc_exif::os   = Capabilities.os;
				pic.xmp.dc_exif::app  = NativeApplication.nativeApplication.applicationID;
				pic.save();
			}
			/*
			pic = new XMP_file(temp.nativePath);
			if(pic.file.exists){
				AppFunctions.Log("\t\ttrue");
				AppFunctions.Log(pic.xmp.dumpObject());
			}			
			*/
			temp.addEventListener( Event.COMPLETE, uploadComplete );
			temp.addEventListener( IOErrorEvent.IO_ERROR, ioError );
			
			try
			{
				temp.upload( new URLRequest( serverURL ) );
			}
			catch( e:Error )
			{
				AppFunctions.Log( e );
				removeTempDir();
				cameraUI.launch( MediaType.IMAGE );
			}
		}
		
		private function uploadComplete( event:Event ):void
		{
			AppFunctions.Log( "Upload successful." );
			removeTempDir();
		}
		
		private function removeTempDir():void
		{
			tempDir.deleteDirectory( true );
			tempDir = null;
		}
		
		private function ioError( error:IOErrorEvent ):void
		{
			AppFunctions.Log( "Upload failed: " + error.text );
			removeTempDir();
			cameraUI.launch( MediaType.IMAGE );
		}
		
		private function mediaError( error:ErrorEvent ):void
		{
			AppFunctions.Log( "Error:" + error.text );
			cameraUI.launch( MediaType.IMAGE );
		}
		
	}
}