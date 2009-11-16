/**
 * Copyright (C) 2009 Philipp Heim, Hanief Bastian and Timo Stegemann (email to: heim.philipp@googlemail.com)
 * 
 * This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License along with this program; if not, see <http://www.gnu.org/licenses/>.
 */ 

package connection {
	import connection.config.IConfig;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.utils.Dictionary;
	import mx.collections.ArrayCollection;
	import mx.rpc.events.FaultEvent;
	import connection.model.ConnectionModel;
	import global.StatusModel;
	import flash.system.Security;
	
	public class SPARQLConnection extends EventDispatcher implements IConnection {
		public var host:String;
		public var basicGraph:String;
		public var resultFormat:String = "XML";
		public var prefixes:String = "";
		
		public function SPARQLConnection(_host:String = "", _basicGraph:String = "") {
			this.host = _host;
			this.basicGraph = _basicGraph;
		}
		
		public function close():void{
			
		}
		
		public function reset():void {
			
		}
		
		public function sendCommand(_command:String, _onResult:Function, _args:Array = null):void {
			
		}
		
		public function clone():IConnection {
			var con:IConnection = new SPARQLConnection();
			con.config = config.clone();
			return con;
		}
		
		
		private var _config:IConfig = null;
		
		[Bindable(event="ConfigChange")]
		public function get config():IConfig {
			if (_config == null) {
				_config = ConnectionModel.getInstance().sparqlConfig.clone();
			}
			return _config;
		}
		
		public function set config(value:IConfig):void {
			ConnectionModel.getInstance().sparqlConfig = value;
			_config = value;
			dispatchEvent(new Event("ConfigChange"));
		}
		
		public var phpSessionID:String = "";
		
		/**
		 * Ab hier von Klasse aus RelFinder kopiert!
		 */
		
		private var contentType:String = "application/sparql-results+json";
		
		public function executeSparqlQuery(sparqlQueryString:String, sources:ArrayCollection, resultHandler:Function,
				errorHandler:Function = null, parsingInformations:Object = null, format:String = "XML",
				useDefaultGraphURI:Boolean = true):SPARQLService {
			
			
			//Alert.show(sparqlQueryString);
			
			if (resultHandler == null) {
				resultHandler = findRelations_Result;
			}
			
			var url:String = config.endpointURI + "/sparql?query=";
			
			var sparqlService:SPARQLService = new SPARQLService(config.endpointURI);
			sparqlService.sources = sources;
			sparqlService.parsingInformations = parsingInformations;
			
			if (config.useProxy) {
				sparqlService.url = ConnectionModel.getInstance().proxy + "?" + config.endpointURI + "/sparql?";
			}else {
				sparqlService.url = config.endpointURI + "/sparql?";
			}
			sparqlService.useProxy = false;
			sparqlService.method = "GET";
			sparqlService.contentType = contentType;
			sparqlService.resultFormat = "text";
			sparqlService.addEventListener(SPARQLResultEvent.SPARQL_RESULT, resultHandler);
			
			if (errorHandler != null) {
				sparqlService.addEventListener(FaultEvent.FAULT, errorHandler);
			}else {
				sparqlService.addEventListener(FaultEvent.FAULT, findRelations_Fault);
			}
			
			var params:Dictionary = new Dictionary();
			if (useDefaultGraphURI && config.defaultGraphURI != null && config.defaultGraphURI != "") {
				params["default-graph-uri"] = config.defaultGraphURI;
				params["m"] = config.defaultGraphURI;
			}
			
			if (phpSessionID != null && phpSessionID != "") {
				params["SESSIONID"] = phpSessionID;
			}
			
			params["format"] = format;
			params["query"] = sparqlQueryString;
			
			sparqlService.send(params);
			return sparqlService;
		}
		
		private function findRelations_Result(e:SPARQLResultEvent):void {
			StatusModel.getInstance().addFound();
			var resultNS:Namespace = new Namespace("http://www.w3.org/2005/sparql-results#");
			var result:XML = new XML(e.result);
			var out:String;
			
			if (result..resultNS::results == "") {
				out = "No Relation found" + "\n\n";

			}else{
				out = result.toString() + "\n\n";
			}
			trace("No ResultParser defined:\n" + out);
		}
		
		private function findRelations_Fault(e:FaultEvent):void {
			StatusModel.getInstance().addFound();
			StatusModel.getInstance().addError();
			trace("SPARQLConnection Fault");
			trace(e);
		}
		
	}
	
}