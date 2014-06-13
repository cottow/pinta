package nl.aboutcoding.servicebrowser.model
{
	import mx.collections.ArrayCollection;
	
	[RemoteClass(alias="nl.aboutcoding.servicebrowser.model.RService")]
	public class RService
	{
		[Bindable]
		public var methods:ArrayCollection;
		
		[Bindable]
		public var name:String;
		
		public function RService( n:String='new')
		{
			name = n;
			methods = new ArrayCollection();
		}
		
		public function getPackageName():String
		{
			var p:Array = name.split('.');
			p.pop();
			return p.join('.');	
		}
		
		public function getServiceName():String
		{
			var p:Array = name.split('.');
			return p.pop();	
		}
		
		public function getAMFPackageName():String
		{
			var p:Array = name.split('.');
			p.pop();
			var pn:String = p.join('/');
			if( pn == '' )
			{
				return '';
			} else {
				return pn+'/';
			}
		}

	}
}