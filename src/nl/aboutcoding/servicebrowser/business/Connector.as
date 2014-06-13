package nl.aboutcoding.servicebrowser.business
{
	import com.adobe.serialization.json.JSON;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.rpc.AbstractOperation;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.remoting.mxml.RemoteObject;
	
	import nl.aboutcoding.servicebrowser.controller.EventHub;
	import nl.aboutcoding.servicebrowser.events.ProfileModifiedEvent;
	import nl.aboutcoding.servicebrowser.events.StatusChangeEvent;
	import nl.aboutcoding.servicebrowser.model.Profile;
	import nl.aboutcoding.servicebrowser.model.RArgument;
	import nl.aboutcoding.servicebrowser.model.RMethod;
	import nl.aboutcoding.servicebrowser.model.RService;
	import nl.aboutcoding.servicebrowser.model.ServiceInfo;
	
	public class Connector
	{
		private static var _allowInstance:Boolean = false;
		private static var _instance:Connector;
		
		public static var FMT_AMFPHP:String = "amfphp";
		
		private var eventHub:EventHub 		= EventHub.getInstance();
		private var serviceInfo:ServiceInfo 	= ServiceInfo.getInstance();

		private var proxy:RemoteObject;
		
		public function Connector()
		{
			if( !Connector._allowInstance )
			{
				throw new Error();
			}
			
			Connector._allowInstance = false;
		}
		
		public static function getInstance():Connector
		{
			if( !Connector._instance )
			{
				Connector._allowInstance = true;
				Connector._instance = new Connector();
			}
			
			return Connector._instance;
		}
		
		public function connect( profile:Profile ):void
		{
			eventHub.dispatchEvent( new StatusChangeEvent( StatusChangeEvent.CONNECTING ) );
			
			proxy = new RemoteObject();
			proxy.endpoint = profile.url;
			proxy.destination = profile.serviceDest;			
			proxy.showBusyCursor = true;
			eventHub.dispatchEvent( new StatusChangeEvent( StatusChangeEvent.CONNECTED ) );
		}
		
		public function call( service:RService, method:RMethod, resp:RResponder ):void
		{	
			proxy.source = service.name;
			var op:AbstractOperation = proxy.getOperation( method.name );
			if( !op.hasEventListener( ResultEvent.RESULT ) )
				op.addEventListener( ResultEvent.RESULT, resp.result );
			if( !op.hasEventListener( FaultEvent.FAULT ) )
				op.addEventListener( FaultEvent.FAULT, resp.fault );

			// set arguments
			var args:Array = new Array();
			for each( var arg:RArgument in method.arguments ) 
			{
				if( ( arg.value.charAt(0) == '{' ) && ( arg.value.charAt( arg.value.length-1)  == '}' ) )
				{
					try {
						args.push( JSON.decode( arg.value ) );
					} catch( e:Error ) {
						Alert.show("Invalid JSON string: '"+arg.value+"'", "Error");
					}
				} else {
					args.push(arg.value);	
				}
			}
			op.arguments = args;
			
			// call
			op.send();
		}
		
		public function discover( serviceName:String, format:String ):void
		{
			serviceInfo.activeProfile.services.removeAll();
			eventHub.dispatchEvent( new StatusChangeEvent( StatusChangeEvent.RESET ) );
			proxy.source = serviceName;
			if( format == Connector.FMT_AMFPHP )
			{
				var op:AbstractOperation = proxy.getOperation('getServices');
				if( !op.hasEventListener( ResultEvent.RESULT ) )
					op.addEventListener( ResultEvent.RESULT, onAMFPHPServicesReceived );
				if( !op.hasEventListener( FaultEvent.FAULT ) )
					op.addEventListener( FaultEvent.FAULT, onServicesFault );
				op.send();
			}
		}
		
		private function onAMFPHPServicesReceived( event:ResultEvent ):void
		{
			var s:RService;
			for each( var obj:Object in event.result )
			{
				var pack:String = '';
				if( obj.hasOwnProperty('children') )
				{
					pack = obj.label;
					for each( var serv:Object in obj.children )
					{
						// these are all services to be added withing pack
						s = new RService( obj.label+"."+serv.label );
						serviceInfo.activeProfile.services.addItem( s );
						discoverAMFPHPMethods( s );
					}
				} else {
					// single service
					s = new RService( obj.label as String );
					serviceInfo.activeProfile.services.addItem( s );
					discoverAMFPHPMethods( s );
				}
			}
		}
		
		private function discoverAMFPHPMethods( service:RService ):void
		{
			var rem:RemoteObject = new RemoteObject('amfphp');
			rem.endpoint = serviceInfo.activeProfile.url;
			rem.source = 	'amfphp.DiscoveryService';
			var op:AbstractOperation = rem.getOperation('describeService');
			var listener:Function = function(event:ResultEvent):void{
				parseAMFMethods( service.name, event );
			};
			
			if( op.hasEventListener( ResultEvent.RESULT ) )
			{
				op.removeEventListener( ResultEvent.RESULT, listener );
			}
			op.addEventListener( ResultEvent.RESULT, listener );
			if( !op.hasEventListener( FaultEvent.FAULT ) )
				op.addEventListener( FaultEvent.FAULT, onServicesFault );
			
			var param:Object = new Object();
			param.label = service.getServiceName();
			param.data = service.getAMFPackageName();
			op.send( param );
		}
		
		private function parseAMFMethods( sname:String, event:ResultEvent ):void
		{
			var serv:RService = serviceInfo.activeProfile.getServiceByName( sname );

			var ret:Array = new Array();
			var m:RMethod;
			var a:RArgument;
			for each ( var obj:Object in event.result )
			{
				for (var sub:Object in obj )
				{
					m = new RMethod( String(sub) );
					for each( var arg:Object in obj[sub].arguments )
					{
						m.arguments.addItem(new RArgument( String(arg), '', '')); 
					}
					ret.push( m );
				}
			}
			serv.methods = new ArrayCollection( ret );
			eventHub.dispatchEvent( new ProfileModifiedEvent( ProfileModifiedEvent.CHANGED ) );
		}
		
		private function onServicesFault( event:FaultEvent ):void
		{
			Alert.show("Unable to do services discovery, invalid service URL or server response", "Error");
		}
	}
}