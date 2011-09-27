package de.qwesda.as3_xmp_file {
	import com.adobe.xmp.core.ParseOptions;
	import com.adobe.xmp.core.XMPMeta;
	import com.adobe.xmp.core.XMPNode;
	
	import flash.filesystem.*;
	import flash.utils.ByteArray;
	
	import mx.utils.UIDUtil;

	public class XMPWrapper extends XMPMeta	{
		public function XMPWrapper(source:Object=null, options:ParseOptions=null) {
			try {
				super(source, options);
			} 
			catch(e:Error) {
				attemptRepair(source, options);
			}
		}
		
		public function attemptRepair(source:Object, options:ParseOptions):void {
			if(source is String || source is ByteArray){
				trace("xmp packet brocken - attempting repair ...");
				
				var str:String;
				
				if(source is ByteArray){(source as ByteArray).position = 0;	str = (source as ByteArray).readUTFBytes((source as ByteArray).length);	}
				else 					str = source as String;
				
				str = str.replace(/ about=/g, " rdf:about=");
				
				try {
					var new_paket:XMPMeta = new XMPMeta(str, options);
					
					for each(var node:XMPNode in new_paket){
						var ns:Namespace = new Namespace(node.qname.uri);
						this.ns::[node.qname.localName] = node;
					}
					
					trace("succeeded");
				} 
				catch(e:Error) {
					dumpPacket(source);
					trace("failed");
				}
				
			}
		}
		public function dumpPacket(source:Object):void {
			if(source is String || source is ByteArray){
				trace("dumping brocken xmp packet ...");
					
				var file:File			= new File(File.desktopDirectory.nativePath + "/brocken_packages/"+ mx.utils.UIDUtil.createUID() + "xmp_dump.txt");
				var stream:FileStream	= new FileStream();
				
				stream.open(file, FileMode.WRITE);
				
				if(source is String)	stream.writeUTFBytes(source as String);
				if(source is ByteArray)	stream.writeBytes(source as ByteArray);
				
				stream.close();
			}
		}
	}
}