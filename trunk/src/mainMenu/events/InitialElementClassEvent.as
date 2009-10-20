package mainMenu.events 
{
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
		
		public function InitialElementClassEvent(initialElementClass:ElementClass, bubbles:Boolean=false, cancelable:Boolean=false) 
		{
			iec = initialElementClass;
			
			super(INITIALELEMENTCLASS, bubbles, cancelable);
			
		}
		
		public function get initialElementClass():ElementClass {
			return iec;
		}
		
		public override function clone():Event 
		{ 
			return new InitialElementClassEvent(initialElementClass, bubbles, cancelable);
		} 
		
		public override function toString():String 
		{ 
			return formatToString("InitialElementClassEvent", "type", "bubbles", "cancelable", "eventPhase"); 
		}
		
	}
	
}