/**
* ...
* @author Philipp Heim
* @version 0.1
*/

package com.flashdb {

	[RemoteClass(alias="com.flashdb.Similarity")]
    
	import flash.net.registerClassAlias;
	
	[Bindable] public class Similarity {
		
		public var id:String;
		public var similarity:int; 		//number of similar values
		public var simValues:Array;  	//concrete values that are similar
		public var attributeType:String;
		
		public function Similarity(_id:String="", _similarity:int=0, _simValues:Array=null, _attType:String="") {
			id = _id;
			similarity = _similarity;
			simValues = _simValues;
			attributeType = _attType;
		}
		
		static public function register():void{
			registerClassAlias("com.flashdb.Similarity", Similarity) ;	
		}
	}
	
}
