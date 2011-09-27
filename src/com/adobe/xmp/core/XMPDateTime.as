// Adobe Systems Incorporated, 2009
// Copyright 2009, Adobe Systems Incorporated. All rights reserved.
// Redistribution and use in source and binary forms, with or without modification, 
// are permitted provided that the following conditions are met:
//
// 1. Redistributions of source code must retain the above copyright notice, 
//    this list of conditions and the following disclaimer.
//
// 2. Redistributions in binary form must reproduce the above copyright notice, 
//    this list of conditions and the following disclaimer in the documentation and/or 
//    other materials provided with the distribution.
//
// 3. Neither the name of Adobe nor the names of its contributors may be used to endorse or 
//    promote products derived from this software without specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND 
// ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF 
// MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT 
// SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, 
// SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT 
// OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
// HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, 
// OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, 
// EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

package com.adobe.xmp.core
{
	import flash.utils.getTimer;
	
	/** 
	 * Represents a date-time value in an XMP Date property.
	 * XMP uses rendered dates and times in the ISO8601 format.
	 * This class provides conversion methods from and to the JavaScript <code>Date</code> object.    
	 */
	public class XMPDateTime
	{
		/** the single values an XMP date consists of */ 
		private var _year: int = 0;
		private var _month: int = 0;
		private var _day: int = 0;
		private var _hour: int = 0;
		private var _minute: int = 0;
		private var _second: int = 0;
		private var _milliSecond: int = 0;
		private var _timezoneOffset: int = 0;
		private var _hasDate: Boolean = false;
		private var _hasTime: Boolean = false;
		private var _hasTimeZone: Boolean = false;

		
		/** 
		 * Retrieves the year value from a date-time. 
		 * @return The year.
		 */
		public function get year(): int
		{
			return _year;
		}
		/** 
		 * Sets the year value of a date-time.
		 * @param value The new value.
		 */
		public function set year(value: int): void
		{
			this._year = value;
			this._hasDate = true;
		}

	
		/** 
		 * Retrieves the month value from a date-time. 
		 * @return  The month value in the range 1..12
		 */
		public function get month(): int
		{
			return _month;
		}
		/** 
		 * Sets the month value in a date-time. 
		 * @param value The new month value in the range 1..12
		 */
		public function set month(value: int): void
		{
			_month = value >= 1 ?
				(value <= 12 ? value : 12) :
				1;
			this._hasDate = true;
		}
		

		/** 
		 * Retrieves the day-of-month value from a date-time. 
		 * @return The day value in the range 1..31
		 */
		public function get day(): int
		{
			return _day;
		}
		/** 
		 * Sets the day-of-month value in a date-time. 
		 * @param value The new day value in the range 1..31
		 */
		public function set day(value: int): void
		{
			_day = value >= 1 ?
				(value <= 31 ? value : 31) :
				1;
			this._hasDate = true;
		}			
	

		/** 
		 * Retrieves the hour value from a date-time.   
		 * @return The hour value in the range 0..23
		 */
		public function get hour(): int
		{
			return _hour;
		}
		/** 
		 * Sets the hour value in a date-time. 
		 * @param value The new hour value in the range 0..23
		 */
		public function set hour(value: int): void
		{
			_hour = value >= 0 ?
				(value <= 23 ? value : 23) :
				0;
			_hasTime = true;	
		}			
		

		/** 
		 * Retrieves the minute value from a date-time. 
		 * @return The minute value in the range 0..59
		 */ 
		public function get minute(): int
		{
			return _minute;
		}
		/**
		 * Sets the minute value in a date-time. 
		 * @param value The new minute value in the range 0..59
		 */
		public function set minute(value: int): void
		{
			_minute = value >= 0 ?
				(value <= 59 ? value : 59) :
				0;
			_hasTime = true;	
		}
					
		
		/** 
		 * Retrieves the second value from a date-time.  
		 * @return The second value in the range 0..59
		 */
		public function get second(): int
		{
			return _second;
		}
		/**
		 * Sets the second value in a date-time. 
		 * @param value The new second value in the range 0..59
		 */
		public function set second(value: int): void
		{
			_second = value >= 0 ?
				(value <= 59 ? value : 59) :
				0;
			_hasTime = true;	
		}			
		
		
		/**
		 * Retrieves the milliseconds value for a time value.
		 * @return The millisecond value, in the range 0..999.
 		 */
		public function get milliSecond(): int
		{
			return _milliSecond;
		}
		/**
		 * Sets the milliseconds value for a time value.
		 * @param value The new millisecond value, in the range 0..999		   
		 */
		public function set milliSecond(value: int): void
		{
			_milliSecond = value >= 0 ?
				(value <= 999 ? value : 999) :
				0;
			_hasTime = true;	
		}			

			
		/** 
		 * Retrieves the time-zone offset from a date-time, in minutes.
		 * @return  The time-zone offset in minutes difference from GMT. Can be negative.
		 */
		public function get timezoneOffset(): int
		{
			return _timezoneOffset;
		}
		/** 
		 * Sets the time-zone offset in a date-time, in minutes. 
		 * @param value The new time-zone offset in minutes difference from GMT. Can be negative.
		 */
		public function set timezoneOffset(value: int): void
		{
			_timezoneOffset = value;
			_hasTime = true;
			_hasTimeZone = true;
		}


		/** 
		 * Retrieves the hours portion of the time-zone offset.
		 * @return  The time-zone offset hours portion. Can be negative.
		 */
		public function get timezoneHour(): int
		{
			return _timezoneOffset / 60;
		}
		
		
		/** 
		 * Retrieves the minutes portion of the time-zone offset.
		 * @return  The time-zone offset minutes portion, always positive. 
		 */
		public function get timezoneMinute(): int
		{
			return Math.abs(_timezoneOffset % 60);
		}
		
		
		/** 
		 * Sets the time-zone value for date-time using the regional settings
		 * of the operating system.
		 * This must only be called when all other fields are filled in to 
		 * make sure that daylight saving is respected in the calculation.
		 */
		public function setLocalTimezone(): void
		{
			this._timezoneOffset = 
				- new Date(_year, _month - 1, _day, _hour, _minute, _second, _milliSecond)
					.getTimezoneOffset();
			_hasTimeZone = true;			
		}

		
		/**
		 * Checks that the time zone has been explicitly set. 
 		 * Use this to distinguish a zero-value that has been set, 
		 * from a zero-value that results from no explicit value 
		 * having been specified.
		 * @return True if the time zone has been set explicitly.
		 */ 
		public function hasDate(): Boolean
		{
			return _hasDate;
		}
		
			
		/**
		 * Checks that the time has been explicitly set with
		 * hour, minute, second, and millisecond values. 
		 * The time value 00:00:00 can represent 12:00 am, but is 
		 * also the default state when no time has been specified.
		 * Use this to distinguish a zero-value that has been set, 
		 * from a zero-value that results from no explicit value 
		 * having been specified.
		 * @return True if the time has been explicitly set.
		 */ 
		public function hasTime(): Boolean
		{
			return _hasTime;	
		}

		/**
		 * Checks that the time zone has been explicitly set. 
 		 * Use this to distinguish a zero-value that has been set, 
		 * from a zero-value that results from no explicit value 
		 * having been specified.
		 * @return True if the time zone has been set explicitly.
		 */ 
		public function hasTimezone(): Boolean
		{
			return _hasTimeZone;
		}


		/** 
		 * Converts an ISO8601 string value to a <code>XMPDateTime</code> object.
		 * @param iso8601 The date string to convert.
		 * @return The Date object.
		 */ 
		public static function convertISO8601ToDate(iso8601: String): Date
		{
			var dt:XMPDateTime = createFromISO8601(iso8601);
			if (dt != null)
			{
				return dt.toDate();
			}
			else
			{
				return null;
			}	
		}

		/** 
		 * Converts a <code>XMPDateTime</code> object to an ISO8601 string value.
		 * @param date The Date object.
		 * @param ignoreTZ	True to ignore the time zone. Default is false
		 * @return The ISO8601 string value.
		 */ 
		public static function convertDateToISO8601(date: Date, ignoreTZ: Boolean = false): String
		{
			var dt:XMPDateTime = createFromDate(date, ignoreTZ);
			if (dt != null)
			{
				return dt.toISO8601String();
			}
			else
			{
				return null;
			}	
		}
		
		
		/**
		 * Converts this object into a JavaScript-style Date object.
		 * @param ignoreTimeZone True to ignore the time zone. Default is false
		 * @return The JavaScript Date object.
		 */
		public function toDate(ignoreTimezone: Boolean = false): Date
		{
			var utcMS:Number = Date.UTC(
				_year,
				_month - 1 >= 0 ? _month - 1 : 0,
				_day >= 1 ? _day : 1,
				_hour,
				_minute,
				_second,
				_milliSecond);
			if (!ignoreTimezone)
			{
				utcMS -= timezoneOffset * 60 * 1000;
			}	
			return new Date(utcMS); 
		}
		
		
		/**
		 * Converts this date-time to universal coordinated time (UTC). 
		 * @return A new <code>XMPDateTime</code> object.
		 */
		public function toUTCDate(): Date
		{
			return new Date(
				_year,
				_month - 1 >= 0 ? _month - 1 : 0,
				_day >= 1 ? _day : 1,
				_hour,
				_minute,
				_second,
				_milliSecond);
		}
		
		
		/**
		 * Converts this <code>XMPDateTime</code> into an ISO 8601 string.
		 * Formats the date according to ISO 8601 and http://www.w3.org/TR/NOTE-datetime:
		 * <ul>
		 * <li>YYYY
		 * <li>YYYY-MM
		 * <li>YYYY-MM-DD
		 * <li>YYYY-MM-DDThh:mmTZD
		 * <li>YYYY-MM-DDThh:mm:ssTZD
		 * <li>YYYY-MM-DDThh:mm:ss.sTZD
		 * </ul>
		 * 
		 * Data  fields:
		 * <ul>
		 * <li>YYYY	 = four-digit year
		 * <li>MM	 = two-digit month (01=January, etc.)
		 * <li>DD	 = two-digit day of month (01 through 31)
		 * <li>hh	 = two-digit hour (00 through 23)
		 * <li>mm	 = two-digits minute (00 through 59)
		 * <li>ss	 = two-digits second (00 through 59)
		 * <li>s	 = one or more digits representing a decimal fraction of a second
		 * <li>TZD	 = time zone designator (Z or +hh:mm or -hh:mm)
		 * </ul>
		 * <p>
		 * <em>Note:</em> ISO 8601 does not allow years less than 1000 or greater than 9999. 
		 * This API allows any year, even negative ones. The year is formatted as "%.4d".<br>
		 * <em>Note:</em> The quasi-bogus "time only" values from Photoshop CS are not supported.
		 * 
		 * @param dateTime An <code>XMPDateTime</code> object.
		 * @return The ISO 8601 string.
		 */	
		public function toISO8601String(): String
		{
			// date is rendered if one of the fields year, month or day is set
			if (_hasDate)
			{
				var buffer: String = formatNumber(_year, 4);
				if (month == 0)
				{
					return buffer;
				}
		
				// month
				buffer += "-" + formatNumber(month, 2);
				if (_day == 0)
				{
					return buffer;
				}
		
				// day
				buffer += "-" + formatNumber(day, 2);
				
				
				// time, rendered if any time field is not zero
				if (hasTime())
				{
					// hours and minutes
					buffer += "T" + 
						formatNumber(_hour, 2) +
						":" +
						formatNumber(_minute, 2);
					
					// seconds and milliseconds
					if (_second != 0  ||  _milliSecond != 0)
					{
						buffer += ":" +
							formatNumber(_second, 2);
						if (_milliSecond != 0)
						{
							buffer += "." +
								formatNumber(_milliSecond, 3);
						}	
					}
					
					// time zone
					if (hasTimezone())
					{
						if (_timezoneOffset == 0)
						{
							buffer += "Z";
						}
						else
						{
							var hr: int = Math.abs(timezoneHour);
							var mn: int = timezoneMinute;
							buffer += 
								(_timezoneOffset < 0 ? "-" : "+") +
								formatNumber(hr, 2) +
								":" +
								formatNumber(mn, 2);
						}
					}
				}		
			}	
			return buffer;
		}

		
		/**
		 * Converts a JavaScript <code>Date</code> object to an <code>XMPDateTime</code> object.
		 * @param date The JavaScript <code>Date</code> object.
		 * @param ignoreTZ	True to ignore the time zone. Default is false
		 * @return The new <code>XMPDateTime</code> object.
		 */ 
		public static function createFromDate(date: Date, ignoreTZ: Boolean = false): XMPDateTime
		{
			if (date != null)
			{
				var dt:XMPDateTime = new XMPDateTime();
				dt.year = date.getFullYear();
				dt.month = date.getMonth() + 1;
				dt.day = date.getDate();
				dt.hour = date.getHours();
				dt.minute = date.getMinutes();
				dt.second = date.getSeconds();
				dt.milliSecond = date.getMilliseconds();
				if (!ignoreTZ)
				{
					// IMPORTANT:
					// Date = UTC - local time in minutes
					// XMPDateTime = local time - UTC in minutes
					dt.timezoneOffset = -date.getTimezoneOffset();
					dt._hasTimeZone = true;	
				}
				
				return dt;
			}
			else
			{
				return null;
			}	
		}
		
		
		/**
		 * Converts an ISO8601 date string to an <code>XMPDateTime</code> object.
		 * @param iso8601 The date string.
		 * @return The new <code>XMPDateTime</code> object.
		 */ 
		public static function createFromISO8601(iso8601: String): XMPDateTime
		{
			var dt: XMPDateTime = new XMPDateTime();
			if (iso8601 == null)
			{
				return dt;
			}
			
			var index: int = iso8601.indexOf("T");
			if (index < 0)
			{
				index = iso8601.length;
			}
			var dateStr: String = iso8601.substring(0, index);
			var timeStr: String = iso8601.substring(index + 1, iso8601.length);
			var dateArr: Array = dateStr.split("-");
			dt.year = dateArr.shift();
			if (dateArr.length == 0)
			{
				return dt;
			}
			dt.month = dateArr.shift();
			if (dateArr.length == 0)
			{
				return dt;
			}
			dt.day = parseInt(dateArr.shift());
			
			var multiplier: Number;
			var offsetHours: Number;
			var offsetMinutes: Number = 0;
			var offsetStr: String;
			
			var offsetPos: int = Math.max(timeStr.indexOf("+"), timeStr.indexOf("-"));
			if (offsetPos >= 0)
			{
				multiplier = timeStr.indexOf("+") >= 0 ? 1 : -1;
				offsetStr = timeStr.substring(offsetPos + 1, timeStr.length);
				timeStr = timeStr.substring(0, offsetPos);
				var colon:int = offsetStr.indexOf(":");
				if (colon >= 0)
				{
					// format +/-hh:MM
					offsetHours = Number(offsetStr.substring(0, colon));
					offsetMinutes = Number(offsetStr.substring(colon + 1, offsetStr.length));
				}
				else if (offsetStr.length <= 2)
				{
					// format +/-hh
					offsetHours = Number(offsetStr);
				}
				else
				{
					// format +/-hhmm
					offsetHours = Number(offsetStr.substring(0, offsetStr.length - 2));
					offsetMinutes = Number(offsetStr.substring(
						offsetStr.length - 2, offsetStr.length));
				}
				dt._hasTimeZone = true;
			}
			else // offset does not exist or is "Z"
			{
				multiplier = 1;
				offsetHours = 0;
				offsetMinutes = 0;
				if (timeStr.indexOf("Z") >= 0)
				{
					dt._hasTimeZone = true;
					timeStr = timeStr.replace("Z", "");
				}
			}
			
			if (dt.hasTimezone())
			{
				dt.timezoneOffset = (offsetHours * 60 + offsetMinutes) * multiplier;
			}	 
			
			if (timeStr.length > 0)
			{
				var timeArr: Array = timeStr.split(":");
				dt.hour = timeArr.shift();
				dt.minute = Number(timeArr.shift());
	
				var secondsArr: Array = (timeArr.length > 0) ? 
					String(timeArr.shift()).split(".") : null;
				dt.second = (secondsArr != null && secondsArr.length > 0) ? 
					Number(secondsArr.shift()) : 0;
				if (secondsArr != null && secondsArr.length > 0)
				{
					var ms: String = secondsArr.shift();
					if (ms.length > 3)
					{
						// round parts of milliseconds propertly 
						var float:Number = 
							parseFloat(ms.substring(0, 3) + "." + ms.substring(3, ms.length));
						dt.milliSecond = Math.round(float);	
					}
					else
					{
						dt.milliSecond = parseInt(ms);
					}
				}
			}	
	        return dt;
	    }
		
		
		/**
		 * Creates a string out of an integer with a requested length, 
		 * filling the empty places with leading zeros.
		 * @param n  The integer value.
		 * @param length The requested length of the number.
		 */
		internal static function formatNumber(n: int, length: int): String
		{
			const zeros: String = "000000000000";
			var result: String = n.toString();
			var missing: int = length - result.length;
			if (missing > 0)
			{
				result = zeros.substr(0, missing) + result;
			}
			return result;
		}
		
		
		/** Converts a <code>XMPDateTime</code> object to its string representation.
		 * @return The date string, formatted according to ISO8601.
		 * @see #toISO8601String
		 */ 
		public function toString(): String
		{
			return toISO8601String();
		} 
	}	
}