package nl.aboutcoding.servicebrowser.events
{
	import flash.events.Event;

	public class StatusChangeEvent extends Event
	{
		public static const CONNECTING:String 	= "connecting";
		public static const CONNECTED:String	= "connected";
		public static const DISCONNECTED:String	= "disconnected";
		public static const QUIT:String			= "quit";
		public static const RESET:String		= "reset";
		
		public function StatusChangeEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
	}
}