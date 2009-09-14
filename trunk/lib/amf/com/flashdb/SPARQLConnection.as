package com.flashdb {
	import flash.events.EventDispatcher;
	
	/**
	* ...
	* @author Default
	*/
	public class SPARQLConnection extends EventDispatcher {
		private var host:String;
		
		
		public function SPARQLConnection(_host:String) {
			this.host = _host;
		}
		
		public function close():void{
			
		}
		
		public function sendCommand(_command:String, _onResult:Function, _args:Array = null):void {
			
		}
		
	}
	
}