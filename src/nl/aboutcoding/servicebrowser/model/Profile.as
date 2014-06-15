package nl.aboutcoding.servicebrowser.model
{
	import mx.collections.ArrayCollection;
	
	[RemoteClass(alias="nl.aboutcoding.servicebrowser.model.Profile")]
	public class Profile
	{
		[Bindable]
		public var name:String = "new";
		[Bindable]
		public var url:String = "http://localhost/";
		[Bindable]
		public var useCredentials:Boolean = false;
		[Bindable]
		public var user:String = "admin";
		[Bindable]
		public var password:String;
		[Bindable]
		public var serviceDest:String = 'amfphp';
		[Bindable]
		public var services:ArrayCollection;
		
		public function Profile()
		{
			services = new ArrayCollection();
		}
		
		public function getServiceByName( name:String ):RService
		{

			for each( var s:RService in services )
			{
				if( s.name == name )
				{
					return s;
				}
			}
			return null;
		}
	}
}