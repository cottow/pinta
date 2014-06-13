package nl.aboutcoding.servicebrowser.controller
{
	import com.adobe.air.preferences.Preference;
	
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	
	import nl.aboutcoding.servicebrowser.business.Connector;
	import nl.aboutcoding.servicebrowser.events.ProfileModifiedEvent;
	import nl.aboutcoding.servicebrowser.model.Profile;
	import nl.aboutcoding.servicebrowser.model.ServiceInfo;

	public class ConnectController
	{
		[Bindable]
		public var profiles:ArrayCollection;
		
		private var prefs:Preference;
		private var serviceInfo:ServiceInfo = ServiceInfo.getInstance();
		private var eventHub:EventHub = EventHub.getInstance();
		private var fileName:String = "data.obj";
		
		public function ConnectController()
		{
			loadProfiles();
			eventHub.addEventListener( ProfileModifiedEvent.CHANGED, onProfileModified );
		}
		
		private function onProfileModified( event:ProfileModifiedEvent ):void
		{
			saveProfiles();
		}
		
		private function loadProfiles():void
		{
			var prefsFile:File = File.applicationStorageDirectory.resolvePath(fileName);
			var fs:FileStream = new FileStream();
			if( !prefsFile.exists )
			{
				profiles = new ArrayCollection();
			} else {
				try {
					fs.open( prefsFile, FileMode.READ );
					profiles = fs.readObject() as ArrayCollection;
					fs.close();
				} catch( e:Error ) {
					Alert.show( "Error while loading profiles: "+e.message, "Load error");
				}
			}
		}
		
		public function saveProfiles():void
		{
			var prefsFile:File = File.applicationStorageDirectory.resolvePath(fileName);		
			var fs:FileStream = new FileStream();
			try {
				fs.open( prefsFile, FileMode.WRITE );
				fs.writeObject(profiles);
				fs.close();
			} catch( e:Error ) {
				Alert.show("Failed to save profiles: "+e.message, "Save error");
			}
		}
		
		public function deleteProfile( index:int):void
		{
			profiles.removeItemAt( index );	
		}
		
		public function addProfile():void
		{
			var profile:Profile = new Profile();
			profiles.addItem( profile );
		}
		
		public function connect( p:Profile ):void
		{
			serviceInfo.activeProfile = p;
			var connector:Connector = Connector.getInstance();
			connector.connect( p );
		}

	}
}