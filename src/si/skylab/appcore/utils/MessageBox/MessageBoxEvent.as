package si.skylab.appcore.utils.MessageBox
{
	import flash.events.Event;
	
	public class MessageBoxEvent extends Event
	{
		public static const MESSAGEBOX_OK:String 		= 'messageBoxOK';
		public static const MESSAGEBOX_CANCEL:String 	= 'messageBoxCANCEL';
		public static const MESSAGEBOX_YES:String 		= 'messageBoxYES';
		public static const MESSAGEBOX_NO:String 		= 'messageBoxNO';
		
		public function MessageBoxEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}