package si.skylab.appcore
{
	import by.blooddy.crypto.SHA256;
	
	import flash.data.EncryptedLocalStore;
	import flash.desktop.NativeApplication;
	import flash.desktop.SystemIdleMode;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	import flash.system.Capabilities;
	import flash.system.System;
	import flash.utils.ByteArray;

	public final class AppMobileMaster
	{
		public function AppMobileMaster()
		{
			AppMobileMaster.UAIDGet();
			AppFunctions.Log("My fingerprint: "+AppMobileMaster.UAID);
			
			NativeApplication.nativeApplication.systemIdleMode = SystemIdleMode.KEEP_AWAKE;
			
		}
		public static function SendPlainData(url:String, _vars:URLVariables, completeFunction:Function=null, errorFunction:Function=null):void {
			var request:URLRequest = new URLRequest(url);
			var loader:URLLoader = new URLLoader();
			loader.dataFormat = URLLoaderDataFormat.VARIABLES;
			request.data = _vars;
			request.method = URLRequestMethod.POST;
			if (completeFunction!=null) loader.addEventListener(Event.COMPLETE, completeFunction);
			if (errorFunction!=null) loader.addEventListener(IOErrorEvent.IO_ERROR, errorFunction);
			loader.load(request);
		}	
		/**
		 * APP fingerprint, 256bytes hex, universally unique for every installation instance
		 */ 
		public static var UAID:String = "";
		private static var fileLocation:String = "app.bytes";
		
		public static function UAIDGet():void {
			//calculate if will be needed
			var uaid:String = SHA256.hash(new Date().toString()+Capabilities.version+Capabilities.cpuArchitecture+Capabilities.os+Capabilities.serverString+System.vmVersion+Math.random().toString());
			var bytes:ByteArray = new ByteArray();
			if (EncryptedLocalStore.isSupported) {
				bytes = EncryptedLocalStore.getItem("UAID");
				if (bytes!=null) {
					//return !
					UAID = bytes.readUTFBytes(bytes.length);
					return;
				} else {
					bytes = new ByteArray();
					bytes.writeUTFBytes(uaid);
					EncryptedLocalStore.setItem("UAID", bytes);
					UAID = uaid;
				} 
			} else {
				var myFile:File = File.applicationStorageDirectory.resolvePath(fileLocation);
				var fileStream:FileStream = new FileStream();
				if (myFile.exists) {
					//return !
					fileStream.open(myFile, FileMode.READ);
					var data:String = fileStream.readUTFBytes(myFile.size);
					fileStream.close();
					UAID = data;	
					return;
				} else {
					fileStream.open(myFile, FileMode.WRITE);
					fileStream.writeUTFBytes(uaid);
					fileStream.close();					
				}
				UAID = uaid;
			}
		}
		
		private static var dataLocation:String = "app.data";
		public static function SaveData(data:Object):void {
			if (data==null) data = "";
			AppFunctions.Log("Saving Data: "+data.toString());
			var bytes:ByteArray = new ByteArray();
			bytes = new ByteArray();
			bytes.writeObject(data);
			if (EncryptedLocalStore.isSupported) {
				EncryptedLocalStore.setItem("DATA", bytes);
			} else {
				var myFile:File = File.applicationStorageDirectory.resolvePath(dataLocation);
				var fileStream:FileStream = new FileStream();
				fileStream.open(myFile, FileMode.WRITE);
				fileStream.writeBytes(bytes);
				fileStream.close();					
			}
			AppFunctions.Log("DataSaved!");
		}
		public static function ReadData():Object {
			var bytes:ByteArray = new ByteArray();
			var obj:Object = null;
			if (EncryptedLocalStore.isSupported) {
				bytes = EncryptedLocalStore.getItem("DATA");
				return bytes.readObject();
			} else {
				var myFile:File = File.applicationStorageDirectory.resolvePath(dataLocation);
				if (!myFile.exists) return null;
				var fileStream:FileStream = new FileStream();
				fileStream.open(myFile, FileMode.READ);
				obj = fileStream.readObject(); 
				fileStream.close();
				return obj;
			}
		}
	}
}