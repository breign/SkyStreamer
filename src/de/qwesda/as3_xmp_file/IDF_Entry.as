package de.qwesda.as3_xmp_file {
	import flash.utils.*;
	
	public class IDF_Entry {
		public var tag_nr:uint			= 0;
		public var type_nr:uint			= 0;
		public var value_count:uint		= 0;
		public var value_offset:uint	= 0;
		
		public var values:Array			= [];
		public var byteArray:ByteArray	= null;
		
		public var position_start:uint = 0;
		
		public function IDF_Entry() {
			
		}
		public  function writeIDF_Entry(stream:Stream, _position:uint, _offset:uint):void {
			if(_position >= 8 && _offset >= 8){					
				stream.position = position_start = _position;
				
				stream.writeShort(tag_nr);
				stream.writeShort(type_nr);
				
				if(type_nr == 1 || type_nr == 2 || type_nr == 7)	value_count = (byteArray ? byteArray.length : 0);
				else 												value_count	= values.length;
				
				stream.writeUnsignedInt(value_count);
				
				if(value_length > 4){
					stream.writeUnsignedInt(_offset);
					stream.position = value_offset = _offset;
				}
				
				if(type_nr == 1 || type_nr == 2 || type_nr == 7) {
					if(byteArray){
						stream.writeBytes(byteArray);
					}
				} else {
					for (var i:int = 0; i < value_count; i++){
						var thisValue:Object = values[i];
						
						switch (type_nr){
							case  3 :	stream.writeShort		(thisValue as int);						break;	// SHORT
							case  4 :	stream.writeUnsignedInt	(thisValue as uint);					break;	// LONG
							case  5 :	stream.writeUnsignedInt	(thisValue.numerator as uint);
										stream.writeUnsignedInt	(thisValue.denominator as uint);		break;	// RATIONAL
							case  6 :	stream.writeByte		(thisValue as int);						break;	// SBYTE
							case  8 :	stream.writeShort		(thisValue as int);						break;	// SSHORT
							case  9 :	stream.writeInt			(thisValue as int);						break;	// SLONG
							case 10 :	stream.writeInt			(thisValue.numerator as int);
										stream.writeInt			(thisValue.denominator as int);			break;	// SRATIONAL
							case 11 :	stream.writeFloat		(thisValue as Number);					break;	// FLOAT
							case 12 :	stream.writeDouble		(thisValue as Number);					break;	// DOUBLE
							case 13 :	stream.writeUnsignedInt	(thisValue as uint);					break;	// IDF
						}
					}
				}
				
				if(DebugLevel > 1)	{
					var dbg_str:String = "\t@" + position_start.toString() + "\t" + tag_nr + "\t" + tag + " (" + type + (value_count > 1 ? "x" + value_count : "") + ") " + (value_offset > 0 ? " @" + value_offset.toString() : "") +  ": ";
					if(type_nr == 1 || type_nr == 2 || type_nr == 7){ 
						byteArray.position = 0;
						dbg_str += byteArray.readUTFBytes(Math.min(byteArray.bytesAvailable, 100));
						trace(dbg_str);
					} else {
						for each (var value:Object in values) dbg_str += (type_nr == 5 || type_nr == 10 ? value.numerator + "/" + value.denominator : value)+ ", ";
						trace(dbg_str.substr(0, dbg_str.length -2));
					}
				}
				
				stream.position = position_start + 12;
			}
		}
		public function replaceValues(stream:Stream, _values:Object):void {
			if(position_start >= 8){
				stream.position = position_start = position_start;
				
				tag_nr		= stream.readUnsignedShort();
				type_nr		= stream.readUnsignedShort();
				
				if(type_nr == 2 || type_nr == 1 || type_nr == 7)	value_count = (_values is ByteArray) ? (_values as ByteArray).length : 0;
				else 												value_count = _values.length;
				
				if(stream.readUnsignedInt() == value_length){
					if(value_length > 4){
						value_offset = stream.readUnsignedInt();
						stream.position = value_offset;
					}
					
					if(type_nr == 2 || type_nr == 1 || type_nr == 7 && _values is ByteArray) {
						byteArray = _values as ByteArray;	_values = [];
						if(byteArray){
							stream.position = 0;	stream.writeUTFBytes(stream.endian == Endian.BIG_ENDIAN ? "MM" : "II");
							stream.position = value_offset;
							stream.writeBytes(byteArray);
						}
					} else {
						values = _values as Array;			byteArray = null;
						for (var i:int = 0; i < value_count; i++){
							var thisValue:Object = values[i];
							
							switch (type_nr){
								case  3 :	stream.writeShort		(thisValue as int);						break;	// SHORT
								case  4 :	stream.writeUnsignedInt	(thisValue as uint);					break;	// LONG
								case  5 :	stream.writeUnsignedInt	(thisValue.numerator as uint);
											stream.writeUnsignedInt	(thisValue.denominator as uint);		break;	// RATIONAL
								case  6 :	stream.writeByte		(thisValue as int);						break;	// SBYTE
								case  8 :	stream.writeShort		(thisValue as int);						break;	// SSHORT
								case  9 :	stream.writeInt			(thisValue as int);						break;	// SLONG
								case 10 :	stream.writeInt			(thisValue.numerator as int);
											stream.writeInt			(thisValue.denominator as int);			break;	// SRATIONAL
								case 11 :	stream.writeFloat		(thisValue as Number);					break;	// FLOAT
								case 12 :	stream.writeDouble		(thisValue as Number);					break;	// DOUBLE
								case 13 :	stream.writeUnsignedInt	(thisValue as uint);					break;	// IDF
							}
						}
					}
				}
			}
		}
		public function createIDF_Entry(_tag_nr:uint, _type_nr:uint, _value_count:uint, _values:Object):void {
			tag_nr		= _tag_nr;
			type_nr		= _type_nr;
			value_count	= _value_count;
			
			if(type_nr == 1 || type_nr == 2 || type_nr == 7)	byteArray	= _values as ByteArray;
			else 												values		= _values as Array;
		}
		public function readIDF_Entry(stream:Stream):void {
			var position_next:uint	= 0;
			
			position_start	= stream.position;
			position_next	= position_start + 12;
			
			tag_nr		= stream.readUnsignedShort();
			type_nr		= stream.readUnsignedShort();
			value_count	= stream.readUnsignedInt();
			
			var i:int;
			
			value_offset = 0;
			
			if(value_length > 4){
				value_offset = stream.readUnsignedInt();
				stream.position = value_offset;
			}
			
			if(type != "ERROR"){
				if(type_nr == 1 || type_nr == 2 || type_nr == 7) {	
					byteArray = new ByteArray(); stream.readBytes(byteArray, 0, value_count);	
				} else for (i = value_count; i > 0; i--){
					switch (type_nr){
						case  3 : values.push(stream.readUnsignedShort());				break;
						case  4 : values.push(stream.readUnsignedInt());				break;
						case  5 : values.push({	numerator:stream.readUnsignedInt(),
												denominator:stream.readUnsignedInt()});	break;
						case  6 : values.push(stream.readByte());						break;
						case  8 : values.push(stream.readShort());						break;
						case  9 : values.push(stream.readInt());						break;
						case 10 : values.push({	numerator:stream.readInt(),
												denominator:stream.readInt()});			break;
						case 11 : values.push(stream.readFloat());						break;
						case 12 : values.push(stream.readDouble());						break;
						case 13 : values.push(stream.readInt());						break;
					}
				}
				
		
				if(DebugLevel > 1)	{
					var dbg_str:String = "\t@" + position_start.toString() + "\t" + tag_nr + "\t" + tag + " (" + type + (value_count > 1 ? "x" + value_count : "") + ") " + (value_offset > 0 ? " @" + value_offset.toString() : "") +  ": ";
					if(type_nr == 1 || type_nr == 2 || type_nr == 7){ 
						byteArray.position = 0;
						dbg_str += byteArray.readUTFBytes(Math.min(byteArray.bytesAvailable, 100));
						trace(dbg_str);
					} else {
						for each (var value:Object in values) dbg_str += (type_nr == 5 || type_nr == 10 ? value.numerator + "/" + value.denominator : value)+ ", ";
						trace(dbg_str.substr(0, dbg_str.length -2));
					}
				}
			}
			
			stream.position = position_next;
		}
		public function get value():Object {
			if(tag_nr == 1 || tag_nr == 2 || tag_nr == 7) return byteArray;
			else if(values.length == 1) return values[0];
			else return values;
		}
		public function get type():String{
			switch (type_nr){
				case  1 : return "BYTE";
				case  2 : return "ASCII";
				case  3 : return "SHORT";
				case  4 : return "LONG";
				case  5 : return "RATIONAL";
				case  6 : return "SBYTE";
				case  7 : return "UNDEFINED";
				case  8 : return "SSHORT";
				case  9 : return "SLONG";
				case 10 : return "SRATIONAL";
				case 11 : return "FLOAT";
				case 12 : return "DOUBLE";
				case 13 : return "IDF";
			}
			
			return "ERROR";
		}
		public function get value_length():uint{
			return type_length * value_count;
		}
		public function get type_length():uint{
			switch (type_nr){
				case  1 : return 1;
				case  2 : return 1;
				case  3 : return 2;
				case  4 : return 4;
				case  5 : return 8;
				case  6 : return 1;
				case  7 : return 1;
				case  8 : return 2;
				case  9 : return 4;
				case 10 : return 8;
				case 11 : return 4;
				case 12 : return 8;
				case 13 : return 4;
			}
			
			return 0;
		}
		public function get tag():String{
			switch (tag_nr){
				case 1		: return "Interoperability Index";
				case 2		: return "Interoperability Version";
				case 254	: return "NewSubfileType";
				case 255	: return "SubfileType";
				case 256	: return "ImageWidth";
				case 257	: return "ImageLength";
				case 258	: return "BitsPerSample";
				case 259	: return "Compression";
				case 262	: return "PhotometricInterpretation";
				case 263	: return "Threshholding";
				case 264	: return "CellWidth";
				case 265	: return "CellLength";
				case 266	: return "FillOrder";
				case 269	: return "DocumentName";
				case 270	: return "ImageDescription";
				case 271	: return "Make";
				case 271	: return "Make";
				case 272	: return "Model";
				case 272	: return "Model";
				case 273	: return "StripOffsets";
				case 274	: return "Orientation";
				case 277	: return "SamplesPerPixel";
				case 278	: return "RowsPerStrip";
				case 279	: return "StripByteCounts";
				case 280	: return "MinSampleValue";
				case 281	: return "MaxSampleValue";
				case 282	: return "XResolution";
				case 283	: return "YResolution";
				case 284	: return "PlanarConfiguration";
				case 285	: return "PageName";
				case 286	: return "XPosition";
				case 287	: return "YPosition";
				case 288	: return "FreeOffsets";
				case 289	: return "FreeByteCounts";
				case 290	: return "GrayResponseUnit";
				case 291	: return "GrayResponseCurve";
				case 292	: return "T4Options";
				case 293	: return "T6Options";
				case 296	: return "ResolutionUnit";
				case 297	: return "PageNumber";
				case 301	: return "TransferFunction";
				case 305	: return "Software";
				case 306	: return "DateTime";
				case 315	: return "Artist";
				case 316	: return "HostComputer";
				case 317	: return "Predictor";
				case 318	: return "WhitePoint";
				case 319	: return "PrimaryChromaticities";
				case 320	: return "ColorMap";
				case 321	: return "HalftoneHints";
				case 322	: return "TileWidth";
				case 323	: return "TileLength";
				case 324	: return "TileOffsets";
				case 325	: return "TileByteCounts";
				case 326	: return "BadFaxLines";
				case 327	: return "CleanFaxData";
				case 328	: return "ConsecutiveBadFaxLines";
				case 330	: return "SubIFDs";
				case 332	: return "InkSet";
				case 333	: return "InkNames";
				case 334	: return "NumberOfInks";
				case 336	: return "DotRange";
				case 337	: return "TargetPrinter";
				case 338	: return "ExtraSamples";
				case 339	: return "SampleFormat";
				case 340	: return "SMinSampleValue";
				case 341	: return "SMaxSampleValue";
				case 342	: return "TransferRange";
				case 343	: return "ClipPath";
				case 344	: return "XClipPathUnits";
				case 345	: return "YClipPathUnits";
				case 346	: return "Indexed";
				case 347	: return "JPEGTables";
				case 351	: return "OPIProxy";
				case 400	: return "GlobalParametersIFD";
				case 401	: return "ProfileType";
				case 402	: return "FaxProfile";
				case 403	: return "CodingMethods";
				case 404	: return "VersionYear";
				case 405	: return "ModeNumber";
				case 433	: return "Decode";
				case 434	: return "DefaultImageColor";
				case 512	: return "JPEGProc";
				case 513	: return "JPEGInterchangeFormat";
				case 514	: return "JPEGInterchangeFormatLength";
				case 515	: return "JPEGRestartInterval";
				case 517	: return "JPEGLosslessPredictors";
				case 518	: return "JPEGPointTransforms";
				case 519	: return "JPEGQTables";
				case 520	: return "JPEGDCTables";
				case 521	: return "JPEGACTables";
				case 529	: return "YCbCrCoefficients";
				case 530	: return "YCbCrSubSampling";
				case 531	: return "YCbCrPositioning";
				case 532	: return "ReferenceBlackWhite";
				case 559	: return "StripRowCounts";
				case 700	: return "XMP";
				case 32773	: return "PackBits";
				case 32781	: return "ImageID";
				case 32932	: return "Wang Annotation";
				case 33421	: return "CFARepeatPatternDim";
				case 33422	: return "CFAPattern";
				case 33423	: return "BatteryLevel";
				case 33432	: return "Copyright";
				case 33434	: return "ExposureTime";
				case 33437	: return "FNumber";
				case 33445	: return "MD FileTag";
				case 33446	: return "MD ScalePixel";
				case 33447	: return "MD ColorTable";
				case 33448	: return "MD LabName";
				case 33449	: return "MD SampleInfo";
				case 33450	: return "MD PrepDate";
				case 33451	: return "MD PrepTime";
				case 33452	: return "MD FileUnits";
				case 33550	: return "ModelPixelScaleTag";
				case 33723	: return "IPTC";
				case 33723	: return "IPTC/NAA";
				case 33918	: return "INGR Packet Data Tag";
				case 33919	: return "INGR Flag Registers";
				case 33920	: return "IrasB Transformation Matrix";
				case 33922	: return "ModelTiepointTag";
				case 34016	: return "Site";
				case 34017	: return "ColorSequence";
				case 34018	: return "IT8Header";
				case 34019	: return "RasterPadding";
				case 34020	: return "BitsPerRunLength";
				case 34021	: return "BitsPerExtendedRunLength";
				case 34022	: return "ColorTable";
				case 34023	: return "ImageColorIndicator";
				case 34024	: return "BackgroundColorIndicator";
				case 34025	: return "ImageColorValue";
				case 34026	: return "BackgroundColorValue";
				case 34027	: return "PixelIntensityRange";
				case 34028	: return "TransparencyIndicator";
				case 34029	: return "ColorCharacterization";
				case 34030	: return "HCUsage";
				case 34031	: return "TrapIndicator";
				case 34032	: return "CMYKEquivalent";
				case 34033	: return "Reserved";
				case 34034	: return "Reserved";
				case 34035	: return "Reserved";
				case 34264	: return "ModelTransformationTag";
				case 34377	: return "Photoshop";
				case 34665	: return "Exif IFD";
				case 34675	: return "ICC Profile";
				case 34675	: return "InterColorProfile";
				case 34732	: return "ImageLayer";
				case 34735	: return "GeoKeyDirectoryTag";
				case 34736	: return "GeoDoubleParamsTag";
				case 34737	: return "GeoAsciiParamsTag";
				case 34850	: return "ExposureProgram";
				case 34852	: return "SpectralSensitivity";
				case 34853	: return "GPS IFD";
				case 34855	: return "ISOSpeedRating";
				case 34856	: return "OEC";
				case 34857	: return "Interlace";
				case 34858	: return "TimeZoneOffset";
				case 34859	: return "SelfTimeMode";
				case 34908	: return "HylaFAX FaxRecvParams";
				case 34909	: return "HylaFAX FaxSubAddress";
				case 34910	: return "HylaFAX FaxRecvTime";
				case 36864	: return "ExifVersion";
				case 36867	: return "DateTimeOrigina";
				case 36868	: return "DateTimeDigitized";
				case 37121	: return "ComponentsConfiguration";
				case 37122	: return "CompressedBitsPerPixer";
				case 37377	: return "ShutterSpeedValue";
				case 37378	: return "ApertureValue";
				case 37379	: return "BrightnessValue";
				case 37380	: return "ExposureBiasValue";
				case 37381	: return "MaxApertureValue";
				case 37382	: return "SubjectDistance";
				case 37383	: return "MeteringMode";
				case 37384	: return "LightSource";
				case 37385	: return "Flash";
				case 37386	: return "FocalLength";
				case 37387	: return "FlashEnergy";
				case 37388	: return "SpatialFrequencyResponse";
				case 37389	: return "Noise";
				case 37390	: return "FocalPlaneXResolution";
				case 37391	: return "FocalPlaneYResolution";
				case 37392	: return "FocalPlaneResolutionUnit";
				case 37393	: return "ImageNumber";
				case 37394	: return "SecurityClassification";
				case 37395	: return "ImageHistory";
				case 37396	: return "SubjectLocation";
				case 37397	: return "ExposureIndex";
				case 37398	: return "TIFF/EPStandardID";
				case 37399	: return "SensingMethod";
				case 37500	: return "MakerNote";
				case 37510	: return "UserComment";
				case 37520	: return "SubsecTime";
				case 37521	: return "SubsecTimeOriginal";
				case 37522	: return "SubsecTimeDigitized";
				case 37724	: return "ImageSourceData";
				case 40960	: return "FlashpixVersion";
				case 40961	: return "ColorSpace";
				case 40962	: return "PixelXDimension";
				case 40963	: return "PixelYDimension";
				case 40964	: return "RelatedSoundFile";
				case 40965	: return "Interoperability IFD";
				case 41483	: return "FlashEnergy";
				case 41484	: return "SpatialFrequencyResponse";
				case 41486	: return "FocalPlaneXResolution";
				case 41487	: return "FocalPlaneYResolution";
				case 41488	: return "FocalPlaneResolutionUnit";
				case 41492	: return "SubjectLocation";
				case 41493	: return "ExposureIndex";
				case 41495	: return "SensingMethod";
				case 41728	: return "FileSource";
				case 41729	: return "SceneType";
				case 41730	: return "CFAPattern";
				case 41985	: return "CustomRendered";
				case 41986	: return "ExposureMode";
				case 41987	: return "WhiteBalance";
				case 41988	: return "DigitalZoomRatio";
				case 41989	: return "FocalLengthIn35mmFilm";
				case 41990	: return "SceneCaptureType";
				case 41991	: return "GainControl";
				case 41992	: return "Contrast";
				case 41993	: return "Saturation";
				case 41994	: return "Sharpness";
				case 41995	: return "DeviceSettingDescription";
				case 41996	: return "SubjectDistanceRange";
				case 42016	: return "ImageUniqueID";
				case 42112	: return "GDAL_METADATA";
				case 42113	: return "GDAL_NODATA";
				case 48129	: return "PixelFormat";
				case 48130	: return "Transformation";
				case 48131	: return "Uncompressed";
				case 48132	: return "ImageType";
				case 48256	: return "ImageWidth";
				case 48257	: return "ImageHeight";
				case 48258	: return "WidthResolution";
				case 48259	: return "HeightResolution";
				case 48320	: return "ImageOffset";
				case 48321	: return "ImageByteCount";
				case 48322	: return "AlphaOffset";
				case 48323	: return "AlphaByteCount";
				case 48324	: return "ImageDataDiscard";
				case 48325	: return "AlphaDataDiscard";
				case 50215	: return "Oce Scanjob Description";
				case 50216	: return "Oce Application Selector";
				case 50217	: return "Oce Identification Number";
				case 50218	: return "Oce ImageLogic Characteristics";
				case 50706	: return "DNGVersion";
				case 50707	: return "DNGBackwardVersion";
				case 50708	: return "UniqueCameraModel";
				case 50709	: return "LocalizedCameraModel";
				case 50710	: return "CFAPlaneColor";
				case 50711	: return "CFALayout";
				case 50712	: return "LinearizationTable";
				case 50713	: return "BlackLevelRepeatDim";
				case 50714	: return "BlackLevel";
				case 50715	: return "BlackLevelDeltaH";
				case 50716	: return "BlackLevelDeltaV";
				case 50717	: return "WhiteLevel";
				case 50718	: return "DefaultScale";
				case 50719	: return "DefaultCropOrigin";
				case 50720	: return "DefaultCropSize";
				case 50721	: return "ColorMatrix1";
				case 50722	: return "ColorMatrix2";
				case 50723	: return "CameraCalibration1";
				case 50724	: return "CameraCalibration2";
				case 50725	: return "ReductionMatrix1";
				case 50726	: return "ReductionMatrix2";
				case 50727	: return "AnalogBalance";
				case 50728	: return "AsShotNeutral";
				case 50729	: return "AsShotWhiteXY";
				case 50730	: return "BaselineExposure";
				case 50731	: return "BaselineNoise";
				case 50732	: return "BaselineSharpness";
				case 50733	: return "BayerGreenSplit";
				case 50734	: return "LinearResponseLimit";
				case 50735	: return "CameraSerialNumber";
				case 50736	: return "LensInfo";
				case 50737	: return "ChromaBlurRadius";
				case 50738	: return "AntiAliasStrength";
				case 50739	: return "ShadowScale";
				case 50740	: return "DNGPrivateData";
				case 50741	: return "MakerNoteSafety";
				case 50778	: return "CalibrationIlluminant1";
				case 50779	: return "CalibrationIlluminant2";
				case 50780	: return "BestQualityScale";
				case 50781	: return "RawDataUniqueID";
				case 50781 	: return "RawDataUniqueID";
				case 50784	: return "s Layer Metadata";
				case 50827	: return "OriginalRawFileName";
				case 50828	: return "OriginalRawFileData";
				case 50829	: return "ActiveArea";
				case 50830	: return "MaskedAreas";
				case 50831	: return "AsShotICCProfile";
				case 50832	: return "AsShotPreProfileMatrix";
				case 50833	: return "CurrentICCProfil";
				case 50833	: return "CurrentICCProfile";
				case 50834	: return "CurrentPreProfileMatri";
				case 50834	: return "CurrentPreProfileMatrix";
				case 50879	: return "ColorimetricReference";
				case 50931	: return "CameraCalibrationSignature";
				case 50932	: return "ProfileCalibrationSignature";
				case 50933	: return "ExtraCameraProfiles";
				case 50934	: return "AsShotProfileName";
				case 50935	: return "NoiseReductionApplied";
				case 50936	: return "ProfileName";
				case 50937	: return "ProfileHueSatMapDims";
				case 50938	: return "ProfileHueSatMapData1";
				case 50939	: return "ProfileHueSatMapData2";
				case 50940	: return "ProfileToneCurve";
				case 50941	: return "ProfileEmbedPolicy";
				case 50942	: return "ProfileCopyright";
				case 50964	: return "ForwardMatrix1";
				case 50965	: return "ForwardMatrix2";
				case 50966	: return "PreviewApplicationName";
				case 50967	: return "PreviewApplicationVersion";
				case 50968	: return "PreviewSettingsName";
				case 50969	: return "PreviewSettingsDigest";
				case 50970	: return "PreviewColorSpace";
				case 50971	: return "PreviewDateTime";
				case 50972	: return "RawImageDigest";
				case 50973	: return "OriginalRawFileDigest";
				case 50974	: return "SubTileBlockSize";
				case 50975	: return "RowInterleaveFactor";
				case 50981	: return "ProfileLookTableDims";
				case 50982	: return "ProfileLookTableData";
			}
			
			return "Unknown";
		} 
	}
}