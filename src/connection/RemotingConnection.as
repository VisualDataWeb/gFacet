/**
 * Copyright (C) 2009 Philipp Heim and Timo Stegemann (email to: heim.philipp@googlemail.com)
 * 
 * This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License along with this program; if not, see <http://www.gnu.org/licenses/>.
 */ 

package connection {
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.net.NetConnection;
	import flash.net.ObjectEncoding;
	import flash.net.Responder;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.NetStatusEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import org.flashdevelop.utils.FlashConnect;
	import graphElements.*;
	//import org.osflash.thunderbolt.Logger;
	
	public class RemotingConnection extends SPARQLConnection{
		
		private var myConnection:NetConnection
		
		private const TIMEOUT_DELAY:int = 50000;

		private var command:String;
		private var timeoutDelay:Timer;

		private var host:String;
		private var service:String;
		
		/**
		 * Contructor
		 */	
		public function RemotingConnection(_host:String, _service:String) {
			super(_host);
			//Logger.hide = true;
			//FlashConnect.trace("Hello there");
			Property.register();
			Element.register();
			Relation.register();
			Chain.register();
			ElementClass.register();
			Facet.register();
			
			this.host = _host;
			this.service = _service;
			
			//timeoutDelay = new Timer(TIMEOUT_DELAY, 1);
			//timeoutDelay.addEventListener(TimerEvent.TIMER, onTimeout);
			
			myConnection = new NetConnection();
			myConnection.objectEncoding = ObjectEncoding.AMF3;
			
			//ERROR handling
			myConnection.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityError);
			//myConnection.addEventListener(IOErrorEvent.IO_ERROR, onError);
			myConnection.addEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
			
			this.connect();
		}
		
		private function connect():void{
			//timeoutDelay.reset();
			close();
			myConnection.connect(this.host);
			//timeoutDelay.start();
			//trace("trying to connect to "+ host+ ":"+ service);
		}
		
		override public function close():void {
			super.close();
			
			if (myConnection.connected) {
				//Logger.warn("close connection");
				//FlashConnect.trace("closing");
				myConnection.close();
				timeoutDelay.stop();
			}
		}
		
		private function securityError(event:Event):void {
			//Logger.error("error with remoting connection", event.type, event.toString());
			//trace("Failure: ", event.type);
			close();
		}
		
		private function netStatusHandler(event:NetStatusEvent):void {
			//Logger.debug("netStatusHandler: ", event.info);
            switch (event.info.code) {
                case "NetConnection.Connect.Success":
                    //Logger.info("connected to server");
                    break;
            }
        }
		
		private function onTimeout(event:Event):void{
			timeoutDelay.stop();
			timeoutDelay.reset();
			//FlashConnect.trace("TIMEOUT------- RECONNECTING");
			//TODO restart the GUI
			connect();
		}
		
		override public function sendCommand(_command:String, _onResult:Function, _args:Array = null):void {
			//Logger.debug("sendCommand to server: ", _command);
			this.command = this.service + "." + _command;
			var responder:Responder = new Responder(_onResult, onFault);
			
			if (_args == null) {
				_args = new Array();
			}
			
			_args.splice(0, 0, this.command);	//adds command at index 0
			_args.splice(1, 0, responder);		//adds responder at index 1
			
			var output:String =  this.command + " " + _args.join(" ");
			//FlashConnect.trace(">> " + _args.length);
			
			myConnection.call.apply(myConnection, _args); 	//calls the method with _args as parameters
			
			//timeoutDelay.reset();
			//timeoutDelay.start();
		}
		
		public function onFault(fault:String):void {
			// ERROR log level
			//Logger.error("failure response from server for command: ", this.command);
			//FlashConnect.trace("There was a problem with "+this.command+": " + fault);
			//trace("-------------");
		}
	}
	
}