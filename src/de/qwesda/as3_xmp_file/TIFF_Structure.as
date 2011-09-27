package de.qwesda.as3_xmp_file {
	import flash.filesystem.*;
	import flash.utils.*;
	
	public class TIFF_Structure {
		internal var all_idfs:Array			= [];
		
		internal var sub_idfs:Array			= [];
		internal var sub_leaf_idfs:Array	= [];
		
		internal var idf0:IDF;
		
		internal var exif_idf:IDF;
		internal var gp_idf:IDF;
		internal var gps_idf:IDF;
		internal var interop_idf:IDF;
		
		internal var endian:String = Endian.BIG_ENDIAN;

		public function TIFF_Structure(stream:Stream) {
			var read_str:String;
			var read_uint:uint;
			var read_int:int;
			
			var idf0_pos:uint;
			
			if(DebugLevel > 1)	trace("--- READING TIFF STRUCTURE ---");
		
			stream.position = 0;
			
			read_str = stream.readUTFBytes(2);	//	trace("Endian marker: " + read_str);
			if(read_str == "MM" || read_str == "II"){
				stream.endian = endian = (read_str == "II" ? Endian.LITTLE_ENDIAN : Endian.BIG_ENDIAN);
				
				read_uint = stream.readUnsignedShort();	//	trace("Endian check (42): " + read_uint);
				if(read_uint == 42){
					idf0_pos = stream.readUnsignedInt();	//	trace("IDF0 pos: " + idf0_pos);
					stream.position = idf0_pos;
					
					if(DebugLevel > 1)	trace("IDF0");
					idf0 = readIDFs(this, null, stream, idf0_pos);
				}
			}
			
			if(DebugLevel > 1)	trace("--- END READING TIFF STRUCTURE ---");
		}
		public function getThumbnail(stream:Stream):Object {
			var JPEGInterchangeFormat:uint			= getProperyAsUInt(513);
			var JPEGInterchangeFormatLength:uint	= getProperyAsUInt(514);
			var Compression:uint					= getProperyAsUInt(259);
			
			try {
				if(JPEGInterchangeFormat != uint.MAX_VALUE && JPEGInterchangeFormatLength != uint.MAX_VALUE){
					var thumb_bytes:ByteArray = new ByteArray();
					
					stream.position = JPEGInterchangeFormat;
					stream.readBytes(thumb_bytes, 0, JPEGInterchangeFormatLength);
					thumb_bytes.position = 0;
											
					return {type:(Compression == 6 || Compression == 7 ? "Jpeg" : (Compression == 1 ? "Bitmap" : "Unknown")), width:0 , height:0, bytes:thumb_bytes};
				}
			} catch (e:Error){ }
			
			return null;
		}
		protected function readIDFs(tiff:TIFF_Structure, parentIDF:IDF, stream:Stream, start_position:uint):IDF {
			function getIDFs(thisIdf:IDF, tag_nr:uint):void {
				var entry:IDF_Entry = thisIdf.getEntry(tag_nr);
				
				if(entry){
					var newIdf:IDF;
					
					for each(var offset:uint in entry.values){
						newIdf = readIDFs(tiff, thisIdf, stream, offset);
						
						if(entry.tag_nr == 34665	&& !tiff.exif_idf)		tiff.exif_idf	= newIdf;
						if(entry.tag_nr == 400		&& !tiff.gp_idf	)		tiff.gp_idf		= newIdf;
						if(entry.tag_nr == 34853	&& !tiff.gps_idf)		tiff.gps_idf	= newIdf;
						if(entry.tag_nr == 40965	&& !tiff.interop_idf)	tiff.interop_idf= newIdf;
						
						if(entry.tag_nr == 330		)	thisIdf.sub_idfs.push(newIdf);
						if(entry.tag_nr == 34954	)	thisIdf.sub_leaf_idfs.push(newIdf);
					}
				}
			}
			
			var thisIDF:IDF;
			
			for each (var idf:IDF in tiff.all_idfs){
				if(idf.position_start == start_position)
					return idf;
			}
			
			stream.position = start_position;
		
			thisIDF = new IDF();
			thisIDF.readIDF(tiff, stream, stream.position);
			
			if(thisIDF.next_idf_position)
				readIDFs(this, thisIDF, stream, thisIDF.next_idf_position);
			
			if(thisIDF.hasPropery(34665))	{	if(DebugLevel > 1)	trace("EXIF IDF"); 		getIDFs(thisIDF, 34665);	if(DebugLevel > 1)	trace("EXIF IDF END"); }	// EXIT IDF
			if(thisIDF.hasPropery(400))		{	if(DebugLevel > 1)	trace("GP IDF"); 		getIDFs(thisIDF, 400);		if(DebugLevel > 1)	trace("GP IDF END") ;}	// GlobalParametersIFD
			if(thisIDF.hasPropery(34853))	{	if(DebugLevel > 1)	trace("GPS IDF"); 		getIDFs(thisIDF, 34853);	if(DebugLevel > 1)	trace("GPS IDF END"); }	// GPS IFD
			if(thisIDF.hasPropery(40965))	{	if(DebugLevel > 1)	trace("INTEROP IDF");	getIDFs(thisIDF, 40965);	if(DebugLevel > 1)	trace("INTEROP IDF END"); }	// Interoperability IFD
			
			if(thisIDF.hasPropery(330))		{	if(DebugLevel > 1)	trace("SUB IDFS");		getIDFs(thisIDF, 330);		if(DebugLevel > 1)	trace("SUB IDFS END"); }	// SUB IDFS
			if(thisIDF.hasPropery(34954))	{	if(DebugLevel > 1)	trace("SUB LEAF IDFS");	getIDFs(thisIDF, 34954); 	if(DebugLevel > 1)	trace("SUB LEAF IDFS END"); }	// LeafSubIFD
	
			return thisIDF;
		}
		public function writeIDFs(idf:IDF, pos:uint, writeStream:Stream, readStream:Stream, offsets:Object, objectsToCopy:Array):void {
			function writeChildIdfs(_entry:IDF_Entry, _idfs:Array):void {
				_entry.values = [];
				
				for each(var _idf:IDF in _idfs){
					_entry.values.push(offsets.nextIDFOffset);
					
					writeIDFs(_idf, offsets.nextIDFOffset, writeStream, readStream, offsets, objectsToCopy);
				}
			}
			
			var oldPos:uint = writeStream.position;
			writeStream.position = pos;
			
			writeStream.writeShort(idf.entries.length);
			
			offsets.nextIDFOffset += 2 + idf.entries.length*12 + 4;
			
			if(DebugLevel > 1)	trace("--- IDF @[" + pos.toString() + " - " + offsets.nextIDFOffset.toString() + "]" + " (" + idf.entries.length + " entries) ---");
			
		//	image data stripes
			var stripe_offsets:IDF_Entry		= idf.getEntry(273);
			var stripe_bytes_counts:IDF_Entry	= idf.getEntry(279);
			var i:int;
			
			if(stripe_offsets && stripe_bytes_counts && stripe_offsets.values.length && stripe_bytes_counts.values.length){
				for (i = 0; i < stripe_bytes_counts.values.length; i++){
					objectsToCopy.push({oldPos:stripe_offsets.values[i], newPos:offsets.imageDataOffset, length:stripe_bytes_counts.values[i]});
					stripe_offsets.values[i]	= offsets.imageDataOffset;
					offsets.imageDataOffset		+= stripe_bytes_counts.values[i];
				}
			}
		//	image data stripes end
		
		//	image data tiles
			var tile_offsets:IDF_Entry			= idf.getEntry(324);
			var tile_bytes_counts:IDF_Entry		= idf.getEntry(325);
			
			if(tile_offsets && tile_bytes_counts && tile_offsets.values.length && tile_bytes_counts.values.length){
				for (i = 0; i < tile_bytes_counts.values.length; i++){
					objectsToCopy.push({oldPos:tile_offsets.values[i], newPos:offsets.imageDataOffset, length:tile_bytes_counts.values[i]});
					tile_offsets.values[i]		= offsets.imageDataOffset;
					offsets.imageDataOffset 	+= tile_bytes_counts.values[i];
				}
			}
		//	image data tiles end
		
		// 	child idfs	
			for each (var entry:IDF_Entry in idf.entries){
				if(entry.tag_nr == 34665)	{	if(DebugLevel > 1)	trace("EXIF IDF"); 		writeChildIdfs(entry, [exif_idf]); 	if(DebugLevel > 1)	trace("EXIF IDF END"); 	   	}
				if(entry.tag_nr == 400)		{	if(DebugLevel > 1)	trace("GP IDF"); 		writeChildIdfs(entry, [gp_idf]);		if(DebugLevel > 1)	trace("GP IDF END"); 			   	}
				if(entry.tag_nr == 34853)	{	if(DebugLevel > 1)	trace("GPS IDF"); 		writeChildIdfs(entry, [gps_idf]);		if(DebugLevel > 1)	trace("GPS IDF END"); 		   	}
				if(entry.tag_nr == 40965)	{	if(DebugLevel > 1)	trace("INTEROP IDF");	writeChildIdfs(entry, [interop_idf]);	if(DebugLevel > 1)	trace("INTEROP IDF END");	  }
				
				if(entry.tag_nr == 330)		{	if(DebugLevel > 1)	trace("SUB IDFS");		writeChildIdfs(entry, idf.sub_idfs);		if(DebugLevel > 1)	trace("SUB IDFS END");		    }
				if(entry.tag_nr == 34954)	{	if(DebugLevel > 1)	trace("SUB LEAF IDFS");	writeChildIdfs(entry, idf.sub_leaf_idfs);	if(DebugLevel > 1)	trace("SUB LEAF IDFS END"); }

				entry.writeIDF_Entry(writeStream, writeStream.position, offsets.valueOffset);
				offsets.valueOffset += entry.value_length > 4 ? entry.value_length : 0;
			}
		// 	child idfs end
			
			writeStream.writeUnsignedInt(0);
			
			if(DebugLevel > 1)	trace("--- IDF @[" + pos.toString() + " - " + offsets.nextIDFOffset.toString() + "]" + " end ---");
						
			writeStream.position = oldPos;
		}
		public function getIDFLength():uint {
			var len:uint = 0;
			var idf:IDF
			
			for each(idf in all_idfs)
				len += idf.getIDFLength();
			
			return len;
		}
		public function getValueLength():uint {
			var len:uint = 0;
			var idf:IDF;
			
			for each(idf in all_idfs)
				len += idf.getValueLength();
			
			return len;
		}
		public function hasPropery(tag_nr:uint):Boolean {
			for each(var idf:IDF in all_idfs){
				for each(var entry:IDF_Entry in idf.entries)
					if(entry.tag_nr == tag_nr)
						return true;
			}
			
			return false;
		}
		public function getPropery(tag_nr:uint):IDF_Entry {
			for each(var idf:IDF in all_idfs){
				for each(var entry:IDF_Entry in idf.entries)
					if(entry.tag_nr == tag_nr)
						return entry;
			}
			
			return null;
		}
		public function getProperyAsInt(tag_nr:uint):int {
			for each(var idf:IDF in all_idfs){
				for each(var entry:IDF_Entry in idf.entries){
					if(entry.tag_nr == tag_nr){
						if(entry.values.length > 0 && entry.values[0] is int)
							return entry.values[0] as int;
					}
				}
			}
			
			return int.MAX_VALUE;
		}
		public function getProperyAsUInt(tag_nr:uint):uint {
			for each(var idf:IDF in all_idfs){
				for each(var entry:IDF_Entry in idf.entries){
					if(entry.tag_nr == tag_nr){
						if(entry.values.length > 0 && entry.values[0] is uint)
							return entry.values[0] as uint;
					}
				}
			}
			
			return uint.MAX_VALUE;
		}
	}
}