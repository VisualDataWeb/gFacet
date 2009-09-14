package com.flashdb{
	import flash.net.NetConnection;
	import flash.net.ObjectEncoding;
	import flash.net.Responder;
	
	public class SoftwikiGraphProxy{
		private var myService:NetConnection
		
		/**
		 * Contructor
		 */	
		public function SoftwikiGraphProxy(){
			
			/* FOR THE SERVER CLIENT COMMUNICATION */
			//Cluster.register();
			//Similarity.register();
			//Attribute.register();
			//SimRelation.register();
			//RdfRelation.register();
			
			//currently used!
			Property.register();
			Element.register();
			Relation.register();
			Chain.register();
			ElementClass.register();
			Facet.register();
			
			
			myService = new NetConnection();
			myService.objectEncoding = ObjectEncoding.AMF3;
			myService.connect("http://softwiki.interactivesystems.info/Graph/flashservices/gateway.php");
			//myService.connect("http://localhost/flashservices/gateway.php");
		}
		
		public function getElementClasses(_onResult:Function, _onFault:Function):void{
			trace("-------------");
			trace("getElementClasses");
			var responder:Responder = new Responder(_onResult, _onFault);
			myService.call("SoftwikiGraphService.getElementClasses", responder);
		}
		
		public function getDistinctPropertyTypes(_onResult:Function, _onFault:Function, _currentClass:ElementClass = null):void{
			trace("-------------");
			trace("getDistinctPropertyTypes");
			var responder:Responder = new Responder(_onResult, _onFault);
			myService.call("SoftwikiGraphService.getDistinctPropertyTypes", responder, _currentClass);
		}
		
		public function getDistinctProperties(_onResult:Function, _onFault:Function, _currentClass:ElementClass = null, _currentType:String = null):void{
			trace("-------------");
			trace("getDistinctProperties "+_currentClass+" "+_currentType);
			var responder:Responder = new Responder(_onResult, _onFault);
			myService.call("SoftwikiGraphService.getDistinctProperties", responder, _currentClass, _currentType);
		}
		
		public function getStartElement(_onResult:Function, _onFault:Function, _currentClass:ElementClass = null, _currentFilters:Array = null ):void {
			trace("-------------");
			trace("getStartElement");
			var responder:Responder = new Responder(_onResult, _onFault);
			myService.call("SoftwikiGraphService.getStartElement", responder, _currentClass, _currentFilters);
		}
		
		public function getChains(_onResult:Function, _onFault:Function, _e:Element, _currentFilters:Array = null):void{
			trace("-------------");
			trace("getChains from server for element "+_e.id);
			var responder:Responder = new Responder(_onResult, _onFault);
			myService.call("SoftwikiGraphService.getChains", responder, _e, _currentFilters);
		}
		
		public function getRelations(_e:Element, _onResult:Function, _onFault:Function):void{
			trace("-------------");
			trace("getRelations from server for element "+_e.id);
			var responder:Responder = new Responder(_onResult, _onFault);
			myService.call("SoftwikiGraphService.getRelations", responder, _e);
		}
		
		public function getRelationsAndChains(_e:Element, _onResult:Function, _onFault:Function):void {
			trace("-------------");
			trace("getRelationsAndChains from server for element "+_e.id);
			var responder:Responder = new Responder(_onResult, _onFault);
			myService.call("SoftwikiGraphService.getRelations", responder, _e);
		}
		
		
		public function getElements(_onResult:Function, _onFault:Function, _currentClass:ElementClass = null, _selectedFilterProperties:Array = null):void{
			trace("-------------");
			trace("getElements from server");
			var responder:Responder = new Responder(_onResult, _onFault);
			myService.call("SoftwikiGraphService.getElements", responder, _currentClass, _selectedFilterProperties);
		}
		
		public function getChain(_onResult:Function, _onFault:Function, _currentClass:ElementClass = null, _selectedFilterProperties:Array = null):void{
			trace("-------------");
			trace("getChain from server");
			var responder:Responder = new Responder(_onResult, _onFault);
			myService.call("SoftwikiGraphService.getChain", responder, _currentClass, _selectedFilterProperties);
		}
		
		public function getFacetedChains(_onResult:Function, _onFault:Function, _rootFacet:Facet, _focusClass:ElementClass):void{
			trace("-------------");
			trace("getFacetedChains from server");
			trace("inGetFacetedChains, "+_rootFacet.chainId);
			var responder:Responder = new Responder(_onResult, _onFault);
			myService.call("SoftwikiGraphService.getFacetedChains", responder, _rootFacet, _focusClass);
		}
		
		public function close():void {
			//var responder:Responder = new Responder(
			//myService.call("SoftwikiGraphService.close" );
			myService.close();
		}
		
		/**
		 * remoting error callback
		 * @param   f Fault event
		 */
		public function onFault(fault:String):void{
			trace("There was a problem: " + fault);
			trace("-------------");
		}
		
		
	}
}	