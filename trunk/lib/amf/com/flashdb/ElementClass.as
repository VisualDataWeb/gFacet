/**
* ...
* @author Philipp Heim
* @version 0.1
*/

package com.flashdb{
	// ElementClass.as
	
	[RemoteClass(alias="com.flashdb.ElementClass")]
    
	import flash.net.registerClassAlias;
	
	[Bindable] public class ElementClass{
		public var id:String;
		public var label:String;
		
		// The number of all instances that are of objectClass and do have a incoming relation over property type
		public var numberOfObjectInstances:int = -1;
		
		public function ElementClass(_id:String="0", _label:String=""){
			id = _id;
			label = _label;
		}
		
		static public function register():void{
			registerClassAlias("com.flashdb.ElementClass", ElementClass) ;	
		}
		
	}
	
	
}