/**
* ...
* @author Default
* @version 0.1
*/

package com.flashdb {
	// Property.as
	
	[RemoteClass(alias="com.flashdb.Property")]
    
	import flash.net.registerClassAlias;
	
	[Bindable] public class Property {
		public var id:String;
		public var label:String;
		public var type:String;
		public var value:Object;	//String or Element
		
		public var data:Object;	//test
		
		public var objectClass:ElementClass;
		
		public var _help:String;
		
		//only on server side
		public var isHighlighted:Boolean = false;
		public var highlightColor:uint = uint("0xff0000");	//default
		
		/**
		 * Contructor
		 * 
		 * @param	_id
		 * @param	_type:	property like for example "hasAge"
		 * @param	_value: values this property leads to, for example "age 20" (instance of class age) or String "20" Datatype
		 * @param	_label: the full label, for example "hasAge:age" ??
		 * @param	_objectClass: the concrete class of the objects this property leads to, for example the "age"-elementClass!
		 * @param	help
		 */
		public function Property(_id:String = "", _type:String = "", _value:String = "", _label:String = "", _objectClass:ElementClass = null,  help:String = "") {
			this.id = _id;
			this.label = _label;
			this.type = _type;
			this.value = _value;
			this.objectClass = _objectClass;
			
			this._help = help;
			this.data = _value;
		}
		
		/*public function addValue(_v:String):void{
    	    this.values.push(_v);
    	}*/
			
		static public function register():void{
			registerClassAlias("com.flashdb.Property", Property) ;	
		}
		
	}
	
	
}