/**
 * Function package used for desktop, web and mobile AS3 projects
 * Use caution when importing stuff. We do not want anything heavy here.
 * @author benjamin
 * @author dejan
 */ 
package si.skylab.appcore
{
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.net.registerClassAlias;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import flash.utils.getTimer;
	
	import mx.collections.ArrayCollection;
	import mx.collections.ArrayList;
	import mx.core.FlexGlobals;
	import mx.core.IUID;
	import mx.events.CloseEvent;
	import mx.utils.UIDUtil;
	
	import spark.formatters.DateTimeFormatter;

	/**
	 * class holds misc/helper static functions to be used trough app
	 * @author dejan, benjamin 19.7.2010
	 */
	public final class AppFunctions
	{
		
		/**
		 * function returnes randomized array
		 * @return Array
		 * @param Array myArray to be randomized
		 */ 
		public static function ArrayRandomize(myArray:Array):Array {
			for (var i:int = 0; i < myArray.length; i++)
			{
				var rand:uint = int(Math.random() * myArray.length);
				myArray.push( myArray.splice( rand, 1 )[0] );
			}
			return myArray;
		}
		
		public static function countKeys(myDictionary:Dictionary):int {
			var n:int = 0;
			for (var key:* in myDictionary) {
				n++;
			}
			return n;
		}
		
		public static function DegFromRad(radians:Number):Number {
			return radians * 180/Math.PI;
		}
		
		public static function RadFromDeg(degrees:Number):Number {
			return degrees * Math.PI / 180;
		}	
		
		/**
		 * function returnes computed angle between two geometryc points in space
		 * @return Number
		 */ 
		public static function AngleBetweenPoints(x1:Number, y1:Number, x2:Number, y2:Number):Number
		{
			var dx:Number = x2 - x1;
			var dy:Number = y2 - y1;
			return Math.atan2(dy,dx);
		}			
		
		/**
		 * function for replacing part of string in string
		 * @return String replaced needle in haytack
		 * @param String haystack
		 * @param String needle
		 * @param String replacement
		 */ 
		public static function StrReplace(haystack:String, needle:String, replacement:String):String {
			var temp:Array = haystack.split(needle);
			return temp.join(replacement);
		}
		
		/**
		 * return top level app's height
		 * @return Number
		 */ 
		public static function AppHeight():Number {
			return FlexGlobals.topLevelApplication.height;
		}
		
		/**
		 * return top level app's width
		 * @return Number
		 */ 
		public static function AppWidth():Number {
			return FlexGlobals.topLevelApplication.width;
		}
		
		/**
		 * function navigates to URL in the OS default browser
		 * @return void
		 * @param String url
		 * @param String target (_blank|_self|_top|_parent)
		 */ 
		public static function URL(url:String, target:String = null):void {
			try {
				navigateToURL(new URLRequest(url), target);
			} catch(error:Error) {
				AppFunctions.Log("[getURL] "+error);
			}
		}
		
		/**
		 * Returns trimmed string (no whitespace at the beginning or end)
		 * @return String
		 * @param String s to be trimmed
		 */		
		public static function Trim(s:String):String {
			return s.replace(/^([\s|\t|\n]+)?(.*)([\s|\t|\n]+)?$/gm, "$2");
		}	
		
		/**
		 * method reigns in a value to keep it between the supplied minimum and maximum limits.
		 * Useful for wrapping number values (particularly paginated interfaces).
		 * @return Number
		 * @param Number
		 * @param Number
		 * @param Number
		 */
		public static function NumberWrap(theValue:Number, minLimit:Number, maxLimit:Number):Number {
			var result:Number = theValue;
			if (theValue < minLimit)
			{
				result = maxLimit;
			} else if (theValue > maxLimit) {
				result = minLimit;
			}
			return result;
		}
		
		/**
		 * returnes random number in between min and max parameters
		 * @return Number
		 * @param Number
		 * @param Number
		 */ 
		public static function RandRange(minNum:Number, maxNum:Number):Number {
			return (Math.floor(Math.random() * (maxNum - minNum + 1)) + minNum);
		}	
		
		/**
		 * returns Boolean true or false, randomly.
		 * @return Boolean
		 */		
		public static function RandomBoolean():Boolean {
			return Math.random() >= 0.5;
		}
		
		/**
		 * returns string without any HTML tags
		 * @return String cleaned from html
		 * @param String html
		 * @param String tags to be keeped from cleaning
		 */		
		public static function StripHtmlTags(html:String, tags:String = ""):String {
			var tagsToBeKept:Array = [];
			if (tags.length > 0)
				tagsToBeKept = tags.split(new RegExp("\\s*,\\s*"));
			
			var tagsToKeep:Array = [];
			for (var i:int = 0; i < tagsToBeKept.length; i++)
			{
				if (tagsToBeKept[i] != null && tagsToBeKept[i] != "")
					tagsToKeep.push(tagsToBeKept[i]);
			}
			
			var toBeRemoved:Array = [];
			var tagRegExp:RegExp = new RegExp("<([^>\\s]+)(\\s[^>]+)*>", "g");
			
			var foundedStrings:Array = html.match(tagRegExp);
			for (i = 0; i < foundedStrings.length; i++)
			{
				var tagFlag:Boolean = false;
				if (tagsToKeep != null)
				{
					for (var j:int = 0; j < tagsToKeep.length; j++)
					{
						var tmpRegExp:RegExp = new RegExp("<\/?" + tagsToKeep[j] + "( [^<>]*)*>", "i");
						var tmpStr:String = foundedStrings[i] as String;
						if (tmpStr.search(tmpRegExp) != -1)
							tagFlag = true;
					}
				}
				if (!tagFlag)
					toBeRemoved.push(foundedStrings[i]);
			}
			for (i = 0; i < toBeRemoved.length; i++)
			{
				var tmpRE:RegExp = new RegExp("([\+\*\$\/])","g");
				var tmpRemRE:RegExp = new RegExp((toBeRemoved[i] as String).replace(tmpRE, "\\$1"),"g");
				html = html.replace(tmpRemRE, "");
			}
			return html;
		}	
		
		public static function StripHtmlTagsAll(string:String):String {
			var s:String = string;
			var regexp:RegExp = new RegExp("<[^<]*<", "gi");
			return s.replace(regexp, "");
		}		
		
		/**
		 * perform safe encoding of characters that could harm html
		 * @return String
		 * @param String
		 */ 
		public static function HtmlEscape(string:String=""):String {
			return String(string).split("&").join("&amp;").split("<").join("&lt;").split(">").join("&gt;");
		}
		
		public static function EmailValidate(email:String):Boolean {
			var emailExpression:RegExp = /([a-z0-9._-]+?)@([a-z0-9.-]+)\.([a-z]{2,4})/i;
			return emailExpression.test(email);
		}		
		
		/**
		 * takes an AC of strings and the filters out all duplicate entries
		 * @return ArrayCollection
		 * @param ArrayCollection to be uniqized
		 */ 
		public static function GetUniqueValues(collection:ArrayCollection):ArrayCollection {
			var length:Number = collection.length;
			var dic:Dictionary = new Dictionary();
			
			//this should be whatever type of object you have inside your AC
			var value:Object;
			for(var i:Number = 0; i < length; i++){
				value = collection.getItemAt(i);
				dic[value] = value;
			}
			
			//this bit goes through the dictionary and puts data into a new AC
			var unique:ArrayCollection = new ArrayCollection();
			for(var prop:String in dic){
				unique.addItem(dic[prop]);
			}
			return unique;
		}

		/**
		 * Get the unique values stored within an arrayCollection
		 *
		 * @param The arrayCollection to search
		 * @param The property value of the arrayCollection's objects to target
		 * @return an arrayCollection of unique items;
		 */
		public static function getUniqueValuesOnProperty(collection:ArrayCollection, propertyName:String):ArrayCollection {
			
			var length:Number = collection.length;
			var dict:Dictionary = new Dictionary();
			
			//this should be whatever type of object you have inside your AC
			var obj:Object;
			for(var i:int = 0; i < length; i++){
				obj = collection.getItemAt(i);
				
//				dict[obj[propertyName]] = obj[propertyName];
				dict[obj[propertyName]] = obj;
			}
			
			//this bit goes through the dictionary and puts data into a new AC
			var unique:ArrayCollection = new ArrayCollection();
			unique.disableAutoUpdate();
			for(var propertyString:String in dict){
				unique.addItem(dict[propertyString]);
			}
			return unique;
		}
		
		/**
		 * takes an AC of and returnes only given propery values in array
		 * @return Array
		 * @param ArrayCollection collection to be iterated
		 * @param String property to be extracted
		 */ 
		public static function GetProperyValuesInArray(collection:ArrayCollection, property:String):Array {
			var ret:Array = [];
			for each(var o:Object in collection) ret.push(o[property]);
			return ret;
		}
		
		public static function ObjectExistsInAC(item:Object, group:ArrayCollection, property:String=""):int {
			var i:int = 0;
			for each (var o:Object in group) {
				if (o[property] == item[property]) return i;
			}
			return -1;
		}
		
		/**
		 * return left-padded string
		 * @return String
		 * @param Object to be padded
		 * @param int max length of the returned string
		 * @param String to be used for padding
		 */
		public static function Lpad(original:Object, length:int=2, pad:String="0"):String {
			if (pad=="") pad=" ";
			var padded:String = original == null ? "" : original.toString();
			while (padded.length < length) padded = pad + padded;
			return padded;
		}
		
		/**
		 * return right-padded string
		 * @return String
		 * @param Object to be padded
		 * @param int max length of the returned string
		 * @param String to be used for padding
		 */
		public static function Rpad(original:Object, length:int, pad:String=" "):String {
			if (pad=="") pad=" ";
			var padded:String = original == null ? "" : original.toString();
			while (padded.length < length) padded = padded + pad;
			return padded;
		}
		
		/**
		 * return shortened string
		 * @return String
		 * @param Object to be shortened
		 * @param int max length of the returned string
		 * @param String to be used as ending
		 */
		public static function Shorten(original:Object, length:int, end:String="."):String {
			var padded:String = original == null ? "" : original.toString();
			if (padded.length>length) 
				return padded.substr(0, length-1)+end;
			else
				return padded;
		}
		
		/**
		 * returnes human readable stack AppFunctions.Log(trace of the error. Used for debugging
		 * @return String
		 * @param Error
		 */ 
		public static function getFunctionName(e:Error):String {
			var stacktrace:String = e.getStackTrace();     	// entire stack AppFunctions.Log(trace
			var startIndex:int = stacktrace.indexOf("at ");	// start of first line
			var endIndex:int = stacktrace.indexOf("()");   	// end of function name
			return stacktrace.substring(startIndex + 3, endIndex);
		}
		
		/**
		 * method returnes seconds of unixtime from given date string or now if default
		 * <code> AppFunctions.Log(Strtotime("12/31/2010"));
		 * - AppFunctions.Log(Strtotime("12/31/2010 01:01:01"));
		 * - AppFunctions.Log(Strtotime("12.31.2010 1:1:1"));
		 * - AppFunctions.Log(Strtotime());
		 * ! note month/day/year </code>
		 * @return int seconds unixtime
		 * @param String date to be converted, else current is used
		 */ 
		public static function StrToTime(date:String=""):int {
			var timestamp:String = date == "" || null ? new Date().toString() : date.toString().split(".").join("/").split("-").join("/");
			return Math.round(new Date(timestamp).time/1000);
		}
		
		/**
		 * same as StrToTime except this function returnes valid AS3 Date Object
		 */ 
		public static function StrToDate(date:String=""):Date {
			var timestamp:String = date == "" || null ? new Date().toString() : String(date).split(".").join("/").split("-").join("/");
			return new Date(timestamp);
		}
		
		/**
		 * function returnes string representation of desired format of the date
		 * valid formatters are: y M d h H k K m s E a
		 */ 
		public static function DateFormat(date:Date, format:String="yyyy-MM-dd HH:mm:ss"):String {
			var f:DateTimeFormatter = new DateTimeFormatter();
			f.dateTimePattern = format;
			return f.format(date);
		}
		
		public static function Time(seconds:Boolean=false):String {
			var date:Date = new Date();
			if (seconds)
				return AppFunctions.Lpad(date.hours,2)+":"+AppFunctions.Lpad(date.minutes,2)+":"+AppFunctions.Lpad(date.seconds,2);
			else
				return AppFunctions.Lpad(date.hours,2)+":"+AppFunctions.Lpad(date.minutes,2);
		}
		
		/**
		 * Return given / current month's start Date object
		 * AppFunctions.Log(DateMonthStart());
		 * AppFunctions.Log(DateMonthStart("12.21.2000"));
		 * AppFunctions.Log(DateMonthStart("12.21.2000 5:5:5")); 
		 * @param String date
		 * @see StrToDate
		 */ 
		public static function DateMonthStart(date:String="", hour:Number=0, minute:Number=0):Date {
			var tempDate:Date;
			var d:Date;
			if (date=="" || date==null) {
				d = new Date();
				tempDate = new Date(d.getFullYear(),d.getMonth(),d.getDate(),hour,minute,0,0);				
			} else {
				d = new Date(StrToTime(date)*1000);
				tempDate = new Date(d.getFullYear(),d.getMonth(),d.getDate(),hour,minute,0,0);
			}
			return new Date(tempDate.time-((tempDate.getDate()-1)*86400000));
		}
		
		/**
		 * returnes string as MySQL timestamp representation from given date object
		 * @return String YYYY-MM-DD HH:MM:SS
		 * @param dateVal Date  
		 */ 
		public static function ToSqlDate(dateVal:Date=null):String
		{
			if (dateVal==null) dateVal = new Date();
			return dateVal.fullYear
				+ "-" + Lpad(dateVal.month+1)  // month is zero-based
				+ "-" + Lpad(dateVal.date)
				+ " " + Lpad(dateVal.hours)
				+ ":" + Lpad(dateVal.minutes)
				+ ":" + Lpad(dateVal.seconds);
		}
		
		public static function ConclusionDateTime(curdate:Date, hour:Number=0, minute:Number=0):Date {
//			if (curdate.hours>hour)
//				return new Date(curdate.getFullYear(),curdate.getMonth(),curdate.getDate()-1,hour,minute,0,0);
//			else
				return new Date(curdate.getFullYear(),curdate.getMonth(),curdate.getDate(),hour,minute,0,0);
		}
		
		/**
		 * method returnes bytes to... 
		 * @return Number
		 * @param String unitPrefix [k,M,G,T or b for bits]
		 */
		public static function BytesTo(bytes:Number,unitPrefix:String="k"):String {
			switch (unitPrefix) {
				case "k":
					return String(Math.round(bytes/1024));
					break;
				
				case "M":
					return (bytes/Math.pow(1024,2)).toFixed(2);
					break;
				
				case "G":
					return (bytes/Math.pow(1024,3)).toFixed(2);
					break;
				
				case "T":
					return (bytes/Math.pow(1024,4)).toFixed(2);
					break;
				
				case "b":
					return String(bytes*8);
					break;
				
				default:
					return String(bytes);
					break;
			}			
		}

		/**
		 * Convert int to binary string representation
		 * @return String
		 * @param int
		 */
		public static function toBinary(numberToConvert : int) : String {
			var result : String = "";
			for ( var i : Number = 0; i < 32 ; i++) {
				// Extract least significant bit using bitwise AND
				var lsb : int = numberToConvert & 1;
				// Add this bit to the result
				result = (lsb ? "1" : "0") + result;               
				// Shift numberToConvert right by one bit, to see next bit
				numberToConvert >>= 1;
			}
			return result;
		}

		/**
		 * Convert binary string to int
		 * @return int
		 * @param String
		 */
		public static function toDecimal(binaryRepresentation : String) : int {
			var result : Number = 0;
			for (var i : int = binaryRepresentation.length; i > 0 ; i--) {
				result += parseInt( binaryRepresentation.charAt( binaryRepresentation.length - i ) ) * Math.pow( 2, i - 1 );
			}              
			return result;
		}	
		
		/**
		 * function cleans parameters received from server for DB query
		 * @use someArray.map(AppFunctions.CleanForDB);
		 */ 
		public static function CleanForDB(element:*, index:int, arr:Array):* {
			if (element === "NULL") {
				return null;
			} else if ( String(element).toUpperCase()==="TRUE" ) { 
				return true;
			} else if ( String(element).toUpperCase()==="FALSE" ) { 
				return false;
			} else {
				return element;
			}
		}

		public static function CloneObject(source:Object):Object {
			registerClassAlias( "si.skylab.appcore.AppFunctions", AppFunctions ); 
			var copier:ByteArray = new ByteArray();
			copier.writeObject(source);
			copier.position = 0;
			return(copier.readObject());
		}
		
		public static function CopyItemWithUID(item:Object):Object {
			var copyObj:Object = CloneObject(item);
			
			if (copyObj is IUID)
			{
				IUID(copyObj).uid = UIDUtil.createUID();
			}
			else if (copyObj is Object && "mx_internal_uid" in copyObj)
			{
				copyObj.mx_internal_uid = UIDUtil.createUID();
			}
			
			return copyObj;
		}		
		
		public static function SleepMS(ms:int):void {
			var init:int = getTimer();
			while(true) {
				if(getTimer() - init >= ms) {
					break;
				}
			}
		}
		
		/**
		 * filter through given ArrayCollection and extract objects matching value on given property
		 * @return ArrayList that can be directly inserted to ArrayCollection.addAll() 
		 * @param ArrayCollection from which to filter objects out
		 * @param String property which we want to match against
		 * @param Object value we want to match on given property
		 */
		public static function ExtractObjectsByPropVal(from:ArrayCollection, property:String, value:Object):ArrayList {
			var ret:ArrayList = new ArrayList();
			for each (var o:Object in from)	if (o[property] == value) ret.addItem(o);
			return ret;
		}
		
		/**
		 * Log & debug
		 */ 
		public static function Log(... text:Array):void {
			if (CONFIG::development) trace( text.toString() );
		}
		
	}
}