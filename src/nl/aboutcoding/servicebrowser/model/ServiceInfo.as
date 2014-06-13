package nl.aboutcoding.servicebrowser.model
{
	import mx.binding.utils.ChangeWatcher;
	
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
			if( !ServiceInfo._allowInstance )
			{
				throw new Error();
			}
			
			ServiceInfo._allowInstance = false;
			eventHub.addEventListener( StatusChangeEvent.DISCONNECTED, onDisconnect );
		}
		
		public static function getInstance():ServiceInfo
		{
			if( !ServiceInfo._instance )
			{
				ServiceInfo._allowInstance = true;
				ServiceInfo._instance = new ServiceInfo();
			}
			
			return ServiceInfo._instance;
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