/**
* ...
* @author Philipp Heim
* @version 0.1
*/

package com.flashdb{
	// Attribute.as
	
	[RemoteClass(alias="com.flashdb.Attribute")]
    
	import flash.net.registerClassAlias;
	
	[Bindable] public class Attribute{
		public var id:String;
		public var label:String;
		public var values:Array;
		public var attributeType:String;
		
		/*
		* Contructor
		*/
		public function Attribute(_id:String = "",_label:String = "", _attType:String = "", _values:Array = null){
			this.id = _id;
			this.label = _label;
			this.attributeType = _attType;
			this.values = _values;
		}
		
		public function addValue(_v:String):void{
    	    this.values.push(_v);
    	}
		
		public function toString():String {
			return "";
		}
		
		/*public function computeSimilarity(att2:Attribute):int{
			var similarity:int = 0;
			if(att2.type != type) return similarity;
			
			for(var i:int = 0; i<values.length; i++){
				if(att2.values[i] == values[i]) similarity++;
			}
			return similarity;
		}*/
			
		static public function register():void{
			registerClassAlias("com.flashdb.Attribute", Attribute) ;	
		}
		
	}
	
	
}