package nl.aboutcoding.servicebrowser.model
{
	[RemoteClass(alias="nl.aboutcoding.servicebrowser.model.RArgument")]
	public class RArgument
	{
		[Bindable]
		public var name:String;
		[Bindable]
		public var type:String;
		[Bindable]
		public var value:String;
		[Bindable]
		public var useJSON:Boolean;
		
		public function RArgument( name:String='new', type:String='String', value:String='', useJSON:Boolean=false)
		{
			this.name = name;
			this.type = type;
			this.value = value;
			this.useJSON = useJSON;
		}

	}
}