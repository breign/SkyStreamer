package de.qwesda.as3_xmp_file {
	import flash.utils.*;
	
	public class IDF {
		internal var sub_idfs:Array			= [];
		internal var sub_leaf_idfs:Array	= [];
		
		public var entries:Array	= [];
		
		public var next_idf_position:uint;
		
		public var position_start:uint = 0;
		public var position_next:uint = 0;
		
		public function get entry_count():uint {
			return entries.length;
		}
		public function get length():uint {
			return 2 + entry_count*12;
		}
		
		public function IDF() {
		}
		public function readIDF(tiff:TIFF_Structure, stream:Stream, _position_start:uint):void {
			var idf_entry:IDF_Entry;
			
			tiff.all_idfs.push(this);
			
			var entry_count:uint = 0;
			
			position_start		= stream.position = _position_start;
			entry_count			= stream.readUnsignedShort();
			position_next		= position_start + 2 + entry_count * 12 + 4;
			
			stream.position		= position_next - 4;
			next_idf_position	= stream.readUnsignedInt();
			stream.position		= position_start + 2;
			
			if(DebugLevel > 1)	trace("--- IDF @[" + position_start.toString() + " - " + position_next.toString() + "]" + (next_idf_position > 0 ? " next IDF @0x" + next_idf_position.toString(16) : "") + " (" + entry_count + " entries) ---")
			
			for (var i:uint = entry_count; i > 0; i--){
				var entry:IDF_Entry = new IDF_Entry();
				entry.readIDF_Entry(stream);
				entries.push(entry);
			}
		}
		
		public function addIDF_Entry(_tag_nr:uint, _type_nr:uint, _value_count:uint, _values:Object):void {
			var entry:IDF_Entry = new IDF_Entry();
			entry.createIDF_Entry(_tag_nr, _type_nr, _value_count, _values);
			entries.push(entry);
		}
		public function getIDFLength():uint {
			return (2 + entry_count * 12 + 4);
		}
		public function getValueLength():uint {
			var len:uint = 0;
			
			for each(var entry:IDF_Entry in entries)
				if(entry.value_length > 4)
					len += entry.value_length;
			
			return len;
		}
		public function hasPropery(tag_nr:uint):Boolean {
			for each(var entry:IDF_Entry in entries)
				if(entry.tag_nr == tag_nr)
					return true;
			
			return false;
		}
		public function getEntry(tag_nr:uint):IDF_Entry {
			for each(var entry:IDF_Entry in entries)
				if(entry.tag_nr == tag_nr)
					return entry;
			
			return null;
		}
		public function getValues(tag_nr:uint):Array {
			for each(var entry:IDF_Entry in entries)
				if(entry.tag_nr == tag_nr){
					return entry.values;
				}
			
			return [];
		}
		public function getPropery(tag_nr:uint):Object {
			for each(var entry:IDF_Entry in entries)
				if(entry.tag_nr == tag_nr){
					return entry.value;
				}
			
			return null;
		}
		public function getProperyAsUint(tag_nr:uint):uint {
			for each(var entry:IDF_Entry in entries)
				if(entry.tag_nr == tag_nr){
					if(entry.values.length > 0)
						return entry.values[0];
				}
			
			return uint.MAX_VALUE;
		}
	}
}