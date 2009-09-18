/**
 * Copyright (C) 2009 Philipp Heim and Timo Stegemann (email to: heim.philipp@googlemail.com)
 * 
 * This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License along with this program; if not, see <http://www.gnu.org/licenses/>.
 */ 

package graphElements {
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