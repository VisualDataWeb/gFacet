package mainMenu.events 
{
	import connection.IConnection;
	import flash.events.Event;
	import graphElements.ElementClass;
	
	/**
	 * ...
	 * @author Timo Stegemann
	 */
	public class InitialElementClassEvent extends Event 
	{
		
		public static const INITIALELEMENTCLASS:String = "InitialElementClass";
		
		private var iec:ElementClass;
		
		private var con:IConnection;
		
		public function InitialElementClassEvent(initialElementClass:ElementClass, connection:IConnection = null, bubbles:Boolean=false, cancelable:Boolean=false) 
		{
			iec = initialElementClass;
			
			con = connection;
			
			super(INITIALELEMENTCLASS, bubbles, cancelable);
			
		}
		
		public function get initialElementClass():ElementClass {
			return iec;
		}
		
		public function get connection():IConnection {
			return con;
		}
		
		public override function clone():Event 
		{ 
			return new InitialElementClassEvent(initialElementClass, connection, bubbles, cancelable);
		} 
		
		public override function toString():String 
		{ 
			return formatToString("InitialElementClassEvent", "type", "bubbles", "cancelable", "eventPhase"); 
		}
		
	}
	
}