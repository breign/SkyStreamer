/**
 * retrieves and parses SKY list of playlists
 * @author benjamin, 28.1.11
 */ 
package si.skylab.radio
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	import si.skylab.appcore.AppFunctions;

	public class SKYList extends EventDispatcher
	{
		private var lists:Array = [];
		private var names:Array = [];
		private var i:int = 0;
		private var j:int = 0;
		
		public function SKYList(Lists:Array, _GET:String="") {
			for (i=0; i<Lists.length; i++) {
				var loader : URLLoader = new URLLoader();
				loader.addEventListener(Event.COMPLETE, Loaded);
				loader.addEventListener(ProgressEvent.PROGRESS, onProgress);
				loader.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
				loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
				loader.addEventListener(HTTPStatusEvent.HTTP_STATUS, httStatus);
				
				loader.load( new URLRequest(Lists[i]+_GET) );
			}
		}
		private function Loaded( e : Event ):void {
			var value:String=e.currentTarget.data;
			//AppFunctions.Log("====== PLS# " + value + " ======");
			var tmp:Array = value.split("<br/>");
			var o:Object, obj:Object = new Object();
			var pls:Array = [];
			for each (o in tmp) {
				pls = String(o).split(", ");
				if (String(pls[1]) != "undefined" && String(pls[1]) != "") {
					names.push(String(pls[0]));
					lists.push(String(pls[1]));
				} 	
			}
			j++;
			if (j==i) {
				
				/**
				 * sort 2 arrays on names
				 */ 
				var temp:Array = [];
				
				for(var a:int=0; a<names.length; a++){
					obj = {};
					obj.names = names[a];
					obj.lists = lists[a];
					temp.push(obj);
				}
				
				temp.sortOn("names",Array.CASEINSENSITIVE);
				
				for(a=0; a<names.length; a++){
					names[a] = temp[a].names;
					lists[a] = temp[a].lists;
				}
				
				dispatchEvent(new Event("SKYList.COMPLETE"));
			} 
		}
		
		public function get Channels():Object {
			return {names:this.names, lists:this.lists};
		}
		
		private function httStatus( e : HTTPStatusEvent ):void {
			AppFunctions.Log(e.status);
		}
		
		private function onProgress( e : Event ):void {
			AppFunctions.Log(e);
		}
		
		private function onIOError( e : IOErrorEvent ):void {
			AppFunctions.Log("IOErrorEvent "+e.text);
			dispatchEvent(new Event("SKYList.ERROR"));
		}
		
		private function onSecurityError( e : Event ):void {
			AppFunctions.Log(e);
		}
		
	}
}