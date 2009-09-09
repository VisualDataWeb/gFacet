/**
* ...
* @author Default
* @version 0.1
*/

package classes.controller {
	import flash.events.Event;
	import flash.events.EventDispatcher;

	public class Command extends EventDispatcher{
		
		public static const EXECUTED:String = "command executed";
		public static const UNDONE:String = "command undone";
		
		public var text:String = "";
		/**
		 * abstract method
		 */
		public function execute():void{
			//TODO: overwrite
		}
		
		/**
		 * abstract method
		 */
		public function undo():void{
			//TODO: overwrite
		}
		
		
		protected function hasBeenExecuted():void{
			this.dispatchEvent(new Event(Command.EXECUTED));
		}

		protected function hasBeenUndone():void{
			this.dispatchEvent(new Event(Command.UNDONE));
		}
		
		public function getText():String{
			return this.text;
		}
	}
	
}
