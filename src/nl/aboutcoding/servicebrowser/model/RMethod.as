package nl.aboutcoding.servicebrowser.model
{
	import mx.collections.ArrayCollection;
	
	[RemoteClass(alias="nl.aboutcoding.servicebrowser.model.RMethod")]
	public class RMethod
	{
		
		[Bindable]
		public var name:String;
		[Bindable]
		public var arguments:ArrayCollection;
		
		public function RMethod( name:String='new', args:ArrayCollection=null)
		{
			this.name = name;
			this.arguments = args;
			if( this.arguments == null )
			{
				this.arguments = new ArrayCollection();
			}
		}
		
		public function toString():String
		{
			return name;	
		}

	}
}