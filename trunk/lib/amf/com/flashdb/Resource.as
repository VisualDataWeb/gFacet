package com.flashdb 
{
	
/**
	* ...
	* @author Hanief Bastian
	* 10.09.08 00:57
	* Resource class
	* An RDF node of URI/Resorce type
	* 
	*/
	
	public class Resource extends Node
	{
		private var uri:String;
		private var localname:String;
		
		public function Resource(_uri_or_namespace:String, _localname:String = null) 
		{
			super(_uri_or_namespace);
			if (localname == null)
			{
				this.uri = _uri_or_namespace;				
			}
			else
			{
				this.uri = _uri_or_namespace + _localname;				
				super.label = _uri_or_namespace + _localname;				
			}
		}
		
		public function get getURI():String
		{
			return this.uri;
		}
		
		/*public function get getLabel():String
		{
			return this.getURI;
		}
		
		public function get getNamespace():String
		{
			
			return this.uri.substr(0,QNameDelimiterIdx(this.uri));
		}
		
		public function get getLocalname():String
		{
			return this.uri.substr(QNameDelimiterIdx(this.uri));
		}
		
		private function QNameDelimiterIdx(_uri:String):int
		{			
			var uriIdx :int = _uri.length;
			var subStr:String;
			while (uriIdx > 0)
			{
				uriIdx--;
				subStr = _uri.substr(uriIdx, 1);
				if (subStr == ":" || subStr == "/" || subStr == "#")
				{
					break;
				}
				
			}
			uriIdx++;
			return uriIdx;
		}
		
		*/
	}
	
}