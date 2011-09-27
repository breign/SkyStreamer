package de.qwesda.as3_xmp_file {
	public class PDF_CrossReferenceTable {
		public var position_start:uint 	= 0;
		public var _valid:Boolean	 	= false;
		
		public function PDF_CrossReferenceTable(stream:Stream = null) {
			if(stream){
				var line:String = "";
				
				line = stream.getLineForward();
				
				if(line == "xref"){
					line = stream.getLineForward();
					
					if(line.length == 20){
						var crossReferenceEntry:Array			= line.split(3);
						
						if(crossReferenceEntry.length == 3){
							var crossReferenceEntryOffset:int		= parseInt(crossReferenceEntry[0]);
							var crossReferenceEntryGeneration:int	= parseInt(crossReferenceEntry[1]);
							var crossReferenceEntryStatus:String	= crossReferenceEntry[2];
							
							if(crossReferenceEntryOffset > 0 && crossReferenceEntryGeneration > 0){
								var currentPosition:int = stream.position;
								
								
								
								stream.position = currentPosition;
							}
						}
					}
					
					while (stream.bytesAvailable > 0 && line != "trailer" && line != "%%EOF"){
						
					}
				}
			}
		}

	}
}