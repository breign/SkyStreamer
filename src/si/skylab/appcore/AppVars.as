/**
 * class populates application wide variables, eg. location of the system server,...
 * @author benjamin.povirk@gmail.com, 12.4.09
 **/
package si.skylab.appcore
{
	public final class AppVars
	{
		//our fingerprint
		public static var IUID:String = "";

		public static var CurrentLanguage:Object = null;
		public static var CurrentLanguageId:String = "sl"; 
		public static var CurrentLanguageName:String = "Slovenščina"; 
		
		//Local help stuff
		public static var LocalHelp:Boolean = false;

	}
}