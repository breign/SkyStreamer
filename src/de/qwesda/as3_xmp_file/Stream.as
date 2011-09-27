package de.qwesda.as3_xmp_file {
	import flash.filesystem.*;
	import flash.utils.*;
	
	import mx.utils.StringUtil;

	public class Stream {
		private var fileStream:FileStream	= null;
		private var byteArray:ByteArray		= null;
		
		public function Stream(source:Object) {
			if(source is FileStream)	fileStream	= source as FileStream;
			if(source is ByteArray)		byteArray	= source as ByteArray;
		}

		public function readBytes(bytes:ByteArray, offset:uint=0, length:uint=0):void {
			if(fileStream)		fileStream			.readBytes(bytes, offset, length);
			if(byteArray)		byteArray			.readBytes(bytes, offset, length);
		}
		
		public function readBoolean():Boolean {
			if(fileStream)		return fileStream	.readBoolean();
			if(byteArray)		return byteArray	.readBoolean()
			
			return false;
		}
		
		public function readByte():int {
			if(fileStream)		return fileStream	.readByte();
			if(byteArray)		return byteArray	.readByte();
			
			return 0;
		}
		
		public function readUnsignedByte():uint {
			if(fileStream)		return fileStream	.readUnsignedByte();
			if(byteArray)		return byteArray	.readUnsignedByte();
			
			return 0;
		}
		
		public function readShort():int {
			if(fileStream)		return fileStream	.readShort();
			if(byteArray)		return byteArray	.readShort();
			
			return 0;
		}
		
		public function readUnsignedShort():uint {
			if(fileStream)		return fileStream	.readUnsignedShort();
			if(byteArray)		return byteArray	.readUnsignedShort();
			
			return 0;
		}
		
		public function readInt():int {
			if(fileStream)		return fileStream	.readInt();
			if(byteArray)		return byteArray	.readInt();
			
			return 0;
		}
		
		public function readUnsignedInt():uint {
			if(fileStream)		return fileStream	.readUnsignedInt();
			if(byteArray)		return byteArray	.readUnsignedInt();
			
			return 0;
		}
		
		public function readFloat():Number {
			if(fileStream)		return fileStream	.readFloat();
			if(byteArray)		return byteArray	.readFloat();
			
			return 0;
		}
		
		public function readDouble():Number {
			if(fileStream)		return fileStream	.readDouble();
			if(byteArray)		return byteArray	.readDouble();
			
			return 0;
		}
		
		public function readMultiByte(length:uint, charSet:String):String {
			if(fileStream)		return fileStream	.readMultiByte(length, charSet);
			if(byteArray)		return byteArray	.readMultiByte(length, charSet);
			
			return null;
		}
		
		public function readUTF():String  {
			if(fileStream)		return fileStream	.readUTF();
			if(byteArray)		return byteArray	.readUTF();
			
			return null;
		}
		
		public function readUTFBytes(length:uint):String  {
			if(fileStream)		return fileStream	.readUTFBytes(length);
			if(byteArray)		return byteArray	.readUTFBytes(length);
			
			return null;
		}
		
		public function get bytesAvailable():uint  {
			if(fileStream)		return fileStream	.bytesAvailable;
			if(byteArray)		return byteArray	.bytesAvailable;
			
			return 0;
		}
		
		public function readObject():Object  {
			if(fileStream)		return fileStream	.readObject();
			if(byteArray)		return byteArray	.readObject();
			
			return null;
		}
		
		public function get objectEncoding():uint  {
			if(fileStream)		return fileStream	.objectEncoding;
			if(byteArray)		return byteArray	.objectEncoding;
			
			return 0;
		}
		
		public function set objectEncoding(version:uint):void  {
			if(fileStream)		fileStream			.objectEncoding = version;
			if(byteArray)		byteArray			.objectEncoding = version;
		}
		
		public function get position():Number  {
			if(fileStream)		return fileStream	.position;
			if(byteArray)		return byteArray	.position;
			
			return -1;
		}
		
		public function set position(value:Number):void  {
			if(fileStream)		fileStream			.position = value;
			if(byteArray)		byteArray			.position = value;
		}
		
		public function get endian():String  {
			if(fileStream)		return fileStream	.endian;
			if(byteArray)		return byteArray	.endian;
			
			return null;
		}
		
		public function set endian(type:String):void  {
			if(fileStream)		fileStream			.endian = type;
			if(byteArray)		byteArray			.endian = type;
		}
		
		public function writeBytes(bytes:ByteArray, offset:uint=0, length:uint=0):void  {
			if(fileStream)		fileStream			.writeBytes(bytes, offset, length);
			if(byteArray)		byteArray			.writeBytes(bytes, offset, length);
		}
		
		public function writeBoolean(value:Boolean):void  {
			if(fileStream)		fileStream			.writeBoolean(value);
			if(byteArray)		byteArray			.writeBoolean(value);
		}
		
		public function writeByte(value:int):void  {
			if(fileStream)		fileStream			.writeByte(value);
			if(byteArray)		byteArray			.writeByte(value);
		}
		
		public function writeShort(value:int):void  {
			if(fileStream)		fileStream			.writeShort(value);
			if(byteArray)		byteArray			.writeShort(value);
		}
		
		public function writeInt(value:int):void  {
			if(fileStream)		fileStream			.writeInt(value);
			if(byteArray)		byteArray			.writeInt(value);
		}
		
		public function writeUnsignedInt(value:uint):void  {
			if(fileStream)		fileStream			.writeUnsignedInt(value);
			if(byteArray)		byteArray			.writeUnsignedInt(value);
		}
		
		public function writeFloat(value:Number):void  {
			if(fileStream)		fileStream			.writeFloat(value);
			if(byteArray)		byteArray			.writeFloat(value);
		}
		
		public function writeDouble(value:Number):void  {
			if(fileStream)		fileStream			.writeDouble(value);
			if(byteArray)		byteArray			.writeDouble(value);
		}
		
		public function writeMultiByte(value:String, charSet:String):void  {
			if(fileStream)		fileStream			.writeMultiByte(value, charSet);
			if(byteArray)		byteArray			.writeMultiByte(value, charSet);
		}
		
		public function writeUTF(value:String):void  {
			if(fileStream)		fileStream			.writeUTF(value);
			if(byteArray)		byteArray			.writeUTF(value);
		}
		
		public function writeUTFBytes(value:String):void  {
			if(fileStream)		fileStream			.writeUTFBytes(value);
			if(byteArray)		byteArray			.writeUTFBytes(value);
		}
		
		public function writeObject(object:Object):void  {
			if(fileStream)		fileStream			.writeObject(object);
			if(byteArray)		byteArray			.writeObject(object);
		}	
		
		public function goToEnd():void  {
			if(fileStream)		fileStream			.position += fileStream.bytesAvailable;
			if(byteArray)		byteArray			.position += byteArray.bytesAvailable;
		}	
		
		public function getLineForward(dontRemoveWhiteSpaces:Boolean = false):String {
			var lines:Array = getLinesForward(1, dontRemoveWhiteSpaces);
			
			if(lines && lines.length == 1) return lines[0];
			else return "";
		}
		public function getLinesForward(count:uint, dontRemoveWhiteSpaces:Boolean = false):Array {
			if(!(fileStream || byteArray)) return [];
			
			var ret:Array			= [];
			var char:String			= "";
			var line:String			= "";
			var isEol:Boolean		= false;
			var isFirst:Boolean		= true;
			
			while (count > 0) {
				if(fileStream) {
					if(fileStream.bytesAvailable > 0){
						char = fileStream.readUTFBytes(1);
					} else isEol = true;
				} else if(byteArray) {
					if(byteArray.bytesAvailable > 0){
						char = byteArray.readUTFBytes(1);
					} else isEol = true;
				}
				
				if(char == "") {
					isEol = true;
				} else if(char == "\r") {
					isEol = true;
					
					if(fileStream) {
						if(fileStream.bytesAvailable > 0){
							char = fileStream.readUTFBytes(1);
							
							if(char != "\n" )	fileStream.position--;
						} else isEol = true;
					} else if(byteArray) {
						if(byteArray.bytesAvailable > 0){
							char = byteArray.readUTFBytes(1);
							
							if(char != "\n" )	byteArray.position--;
						} else isEol = true;
					}
				} else if(char == "\n"){
					isEol = true;
				}
				
				if(isEol){
					if(!isFirst){
						count--;
						
						if(!dontRemoveWhiteSpaces)
							line = mx.utils.StringUtil.trim(line);
						
						ret.push(line);
					}
					
					line		= "";
					isEol		= false;
				} else {
					line += char;
				}
				
				isFirst = false;
			}
			
			return ret;
		}
		
		public function getLineBackward(dontRemoveWhiteSpaces:Boolean = false):String {
			var lines:Array = getLinesBackward(1, dontRemoveWhiteSpaces);
			
			if(lines && lines.length == 1) return lines[0];
			else return "";
		}
		
		public function getLinesBackward(count:uint, dontRemoveWhiteSpaces:Boolean = false):Array {
			if(!(fileStream || byteArray)) return [];
			
			var ret:Array			= [];
			var line:String			= "";
			var char:String			= "";
			var isEol:Boolean		= false;
			var isFirst:Boolean		= true;
			
			while (count > 0) {
				if(fileStream){
					if(fileStream.position > 0){
						fileStream.position--;
						
						char = fileStream.readUTFBytes(1);
						
						fileStream.position--;
					} else isEol = true;
				} else if(byteArray){
					if(byteArray.position > 0) {
						byteArray.position--;
						
						char = byteArray.readUTFBytes(1);
						
						byteArray.position--;
					} else isEol = true;
				}
				
				if(char == "\r") {
					isEol = true;
				} else if(char == "\n"){
					isEol = true;
					
					if(fileStream){ 
						if(fileStream.position > 0){		
							fileStream.position--;
							
							char = fileStream.readUTFBytes(1);
							
							if(char == "\r" ) fileStream.position--;
						} else isEol = true;
					} else if(byteArray){
						if(byteArray.position > 0) {
							byteArray.position--;
							
							char = byteArray.readUTFBytes(1);
							
							if(char == "\r" ) byteArray.position--;
						} else isEol = true;
					}
				}
				
				if(isEol){
					if(!isFirst){
						count--;
						
						if(!dontRemoveWhiteSpaces)
							line = mx.utils.StringUtil.trim(line);
						
						ret.push(line);
					}
					
					line		= "";
					isEol		= false;
				} else {
					line = char + line;
				}
				
				isFirst = false;
			}
			
			return ret;
		}
	}
}