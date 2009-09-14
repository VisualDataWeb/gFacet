package com.flashdb 
{
	
	/**
	* ...
	* @author Hanief Bastian
	* 10.09.08 01:00
	* Resource class
	* An RDF node of Literal type
	* 
	*/
	
	public class Literal extends Node
	{
		//private var uri:String;
		//private var label:String;
		private var datatype:String;
		private var lang:String;
		
		public function Literal(_text:String,_lang:String = null):void
		{
			//this.label = _text;
			super(_text);
		}
		
		/*public function get getText():String
		{
			return this.label;
		}
		public function get getLabel():String
		{
			return this.getText;
		}*/
		public function get getLanguage():String
		{
			return this.lang;
		}
		
		public function get getDatatype():String
		{
			return this.datatype;
		}
		
		public function set setDatatype(_datatype:String):void
		{
			this.datatype = _datatype;
		}
		
		public function set setLanguage(_lang:String):void
		{
			this.lang = _lang;
		}
		
		//While using ORDER BY the URI sometimes is defined not as Resource class but Literal class
		// so this function is built
		public function get getURI():String
		{
			return super.getLabel;
		}
		
	}
	
}