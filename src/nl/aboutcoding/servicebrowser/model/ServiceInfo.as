package nl.aboutcoding.servicebrowser.model
{
	import nl.aboutcoding.servicebrowser.controller.EventHub;
	import nl.aboutcoding.servicebrowser.events.ProfileModifiedEvent;
	import nl.aboutcoding.servicebrowser.events.StatusChangeEvent;
	
	public class ServiceInfo
	{
		private static var _allowInstance:Boolean = false;
		private static var _instance:ServiceInfo;
		
		private var eventHub:EventHub = EventHub.getInstance();
		
		[Bindable]
		public var activeProfile:Profile;
		
		public function ServiceInfo()
		{
			if( !_allowInstance )
			{
				throw new Error();
			}
			
			_allowInstance = false;
			eventHub.addEventListener( StatusChangeEvent.DISCONNECTED, onDisconnect );
		}
		
		public static function getInstance():ServiceInfo
		{
			if( !_instance )
			{
				_allowInstance = true;
				_instance = new ServiceInfo();
			}
			
			return _instance;
		}
		
		private function onDisconnect( event:StatusChangeEvent ):void
		{
			activeProfile = null;
		}
		
		public function dataChanged():void
		{
			eventHub.dispatchEvent( new ProfileModifiedEvent( ProfileModifiedEvent.CHANGED ) );
		}

	}
}