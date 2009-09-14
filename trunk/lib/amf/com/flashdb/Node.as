package com.flashdb 
{
	
	/**
	* ...
	* @author Hanief Bastian 
	* 10.09.08 01:55
	* Node class
	* An abstract class of RDF nodes
	* An RDF node can be literal, blanknode, or URI/Resource
	* 
	*/
	
	public class Node 
	{
		public var label:String;
		public function Node(_label:String) 
		{
			//
			this.label = _label;
		}
		
		public function get getLabel():String
		{
			return this.label;
		}
		
		public function get getNamespace():String
		{
			
			return this.label.substr(0,QNameDelimiterIdx(this.label));
		}
		
		public function get getLocalname():String
		{
			return this.label.substr(QNameDelimiterIdx(this.label));
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
		
	}
	
}