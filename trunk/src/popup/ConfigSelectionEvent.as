package popup 
{
	import connection.config.IConfig;
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Timo Stegemann
	 */
	public class ConfigSelectionEvent extends Event 
	{
		
		public static const CONFIGSELECTION:String = "ConfigSelectionEvent";
		
		private var _config:IConfig = null;
		
		public function ConfigSelectionEvent(selectedConfig:IConfig, bubbles:Boolean=false, cancelable:Boolean=false) 
		{ 
			super(CONFIGSELECTION, bubbles, cancelable);
			
			_config = selectedConfig;
		}
		
		public function get selectedConfig():IConfig {
			return _config;
		}
		
		public override function clone():Event 
		{ 
			return new ConfigSelectionEvent(selectedConfig, bubbles, cancelable);
		} 
		
		public override function toString():String 
		{ 
			return formatToString("ConfigSelectionEvent", "selectedConfig", "type", "bubbles", "cancelable", "eventPhase"); 
		}
		
	}
	
}