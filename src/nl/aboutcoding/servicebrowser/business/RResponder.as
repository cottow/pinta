package nl.aboutcoding.servicebrowser.business
{
	import mx.rpc.Responder;

	public class RResponder extends Responder
	{
		public function RResponder(result:Function, fault:Function)
		{
			super(result, fault);
		}
		
	}
}