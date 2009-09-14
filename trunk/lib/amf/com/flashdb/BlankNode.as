package com.flashdb 
{
	
/**
	* ...
	* @author Hanief Bastian
	* 10.09.08 00:59
	* Resource class
	* An RDF node of Blank Node type
	* 
	*/
	
	public class BlankNode extends Resource
	{
		//private var uri_or_namespace:String;
		public function BlankNode(_uri_or_namespace:String, localname:String = null) 
		{
			super(_uri_or_namespace);
			/*
			 * if (localname == null)
			{
				this.uri_or_namespace = _uri_or_namespace;
			}
			else
			{
				this.uri_or_namespace = _uri_or_namespace + localname;
			}
			*/
		}
		
		public function get getID():String
		{
			return getURI;
		}
		
	}
	
}