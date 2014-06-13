package nl.aboutcoding.servicebrowser.events
{
	import flash.events.Event;

	public class ProfileModifiedEvent extends Event
	{
		public static const CHANGED:String = "changed";
		
		public function ProfileModifiedEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
	}
}