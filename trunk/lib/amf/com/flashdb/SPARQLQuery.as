package com.flashdb 
{
	import mx.rpc.http.HTTPService;
	
	/**
	* ...
	* @author Hanief Bastian
	* An SPARQL query class
	*/
	public class SPARQLQuery extends HTTPService
	{
		public var query:String;
		public var defaultGraphURI:String;
		public var phpSessionId:String;
		public var obj:Object = null;
		
		public function SPARQLQuery(_host:String) 
		{
			super(_host);
			super.url = _host;
		}
		
		public function execute():void
		{
			var params:Object = new Object();
			if (this.phpSessionId != "") {
				params.SESSIONID = this.phpSessionId;
			}
			params.query = this.query;
			params.output = super.resultFormat;
			if (this.defaultGraphURI != "") {
				params["default-graph-uri"] = this.defaultGraphURI;
				params["m"] = this.defaultGraphURI;
			}
			
			//super.addEventListener(ResultEvent.RESULT, responseListener);
			super.cancel();
			super.send(params);
		}
	}
	
}