package nl.aboutcoding.servicebrowser.controller
{
	import flash.events.EventDispatcher;
	
	public class EventHub extends EventDispatcher
	{
		private static var _allowInstance:Boolean = false;
		private static var _instance:EventHub;
		
		public function EventHub()
		{
			if( !EventHub._allowInstance )
			{
				throw new Error();
			}
			
			EventHub._allowInstance = false;
		}
		
		public static function getInstance():EventHub
		{
			if( !EventHub._instance )
			{
				EventHub._allowInstance = true;
				EventHub._instance = new EventHub();
			}
			
			return EventHub._instance;
		}
	}
}