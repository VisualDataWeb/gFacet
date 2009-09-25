/**
 * Copyright (C) 2009 Philipp Heim and Timo Stegemann (email to: heim.philipp@googlemail.com)
 * 
 * This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License along with this program; if not, see <http://www.gnu.org/licenses/>.
 */ 

package graphElements{
	// Element.as
	
	[RemoteClass(alias="com.flashdb.Element")]
    
	import com.hillelcoren.fasterSearching.AbstractObject;
	import flash.net.registerClassAlias;
	import com.hillelcoren.fasterSearching.utils.StringUtils;
	//import org.osflash.thunderbolt.Logger;
	
	[Bindable] public class Element extends AbstractObject{
		public var id:String;
		
		public var title:String;	//obsolete 
		public var description:String;	//obsolete 
		
		public var properties:Array;// Object;
		//public var elementClass:ElementClass;	//obsolete 
		
		/**
		 * The number of focusElements that are connected to this element (even indirectly)
		 * This number is related to the status. So, if the number is 0, the status is invalid. If the number is >0, the status is valid.
		 */
		public var numConFocusElements:int;
		
		//only on the client side (wird nur von DynamicChains noch genutzt!!
		//private var chainItemIds:Array = new Array();	//refers to the chainItems this element is hidden in
		//private var chainProperties:Array = new Array();
		
		//only on client side
		public var isHighlighted:Boolean = false;
		public var highlightColor:uint = uint("0xf8f8f8");	//default
		
		//public var propertiesToString:String = "";
		
		public var listIndex:int;
		
		public var restrictingColor:uint;
		public var status:String = "invalid";	//0 = selected, 1 = valid, 2 = invalid	//deprecated!!
		public var isValid:Boolean = false;
		public var isSelected:Boolean = false;
		public var isNew:Boolean = true;
		public var isAvailable:Boolean = false;	//available for further filtering
		public var isActive:Boolean = false;	//whether this element can be used at all under the current resultSet!
		
		
		/*
		 * NEW constructor
		 */
		/*public function Element(_id:String, _elementClass:ElementClass, _properties:Object = new Object, _numConFocusElements:int = 0) {
			id = _id;
			elementClass = _elementClass;
			properties = _properties;
			numConFocusElements = _numConFocusElements;
			this.initCols();
		}
		
		private function initCols():void {
			if (this.properties != null) {
				if (this.properties.length > 0) {
					this.col1 = this.properties[0].value;
					if (this.properties.length > 1) {
						this.col2 = this.properties[1].value;
						if (this.properties.length > 2) {
							this.col3 = this.properties[2].value;
						}
					}
					
				}
			}
		}*/
		
		public function Element(_id:String="0", _title:String="", _description:String="", _properties:Array = null, _numConFocusElements:int = 0, _elementClass:ElementClass = null){
			id = _id;
			title = _title;
			description = _description;
			
			
			
			if (_properties == null) {
				properties = new Array();// Object();
			}else {
				properties = _properties;
			}
			
			/* work around until title and description are deleted*/
			/*if (properties == null) {
				properties = new Array();
				properties.push(new Property(id + "_label", "rdfs:label", _title, _title));
				//properties.push(new Property(id + "_label", "rdfs:label", title, title));
				if (_description.length != 0) {
					properties.push(new Property(id + "_comment", "rdfs:comment", _description, _description));
					//properties.push(new Property(id + "_comment", "rdfs:comment", description, description));
				}
			}*/
			
			//numConFocusElements = _numConFocusElements;
			//elementClass = _elementClass;
		}
		
		/*public function propsToString():void {
			if (properties != null) {
				trace("propeties length: " + properties.length);
				this.propertiesToString = properties[0].label;
				for (var i:int = 1; i < properties.length; i++) {
					trace(properties[i].label);
					this.propertiesToString = this.propertiesToString + " ," + properties[i].label;
				}
			}else {
				trace("propeties = null: " +id );
			}
		}*/
		
		
		static public function register():void{
			registerClassAlias("com.flashdb.Element", Element) ;	
		}
		
		public function init():void {
			//Logger.debug("title: ", title);
			//Logger.debug("description", description);
			
			this.properties = new Array();
			if ((this.title != null) && (this.title.length > 0)) {
				this.setProperty(new Property(id + "_label", "Label", title, title));
			}
			if ((this.description != null) && (this.description.length > 0)) {
				this.setProperty(new Property(id + "_comment", "Comment", description, description));
			}
		}
		
		/*public function resetChainItemIds():void {
			chainItemIds = new Array();
			chainProperties = new Array();
		}
		
		public function addChainItemId(_propId:String, _id:String):void {
			this.chainItemIds.push(_id);
			this.chainProperties.push(_propId);
		}
		
		public function removeChainItemId(_propId:String, _id:String):void {
			var index:int = this.chainItemIds.indexOf(_id);
			if (index > -1) {
				this.chainItemIds.splice(index, 1);
				this.chainProperties.splice(index, 1);
			}
		}
		
		public function isInChainItems():Boolean {
			if(this.chainItemIds.length == 0) return false;
			else return true;
		}
		
		public function hasChainWithProperty(_propId:String):Boolean {
			if(this.chainProperties.indexOf(_propId) != -1) {
				return true;
			}else {
				return false;
			}
		}
		
		public function getChainItemIds():Array {
			return chainItemIds;
		}*/
		
		public function setProperty(_prop:Property):void {
			//Logger.debug("new prop:", _prop.type, _prop.value);
			/*if (!this.properties is Array) {
				this.properties = new Array();
			}
			if (this.properties is Array) {
				if (this.properties.length == 0) {
					this.properties = new Array();
				}
			}*/
			//Logger.debug("test1, "+this.properties.length);
			this.properties.push(_prop);
			//Logger.debug("test2");
			//this.properties[_prop.type] = _prop;
			
			
			
			/*var e:ElementClass = _prop.objectClass;
			if (e != null) Logger.debug("e.label", e.label);
			
			
			if (!this.properties is Object) {	//temp
				this.properties = new Object();
			}
			this.properties[_prop.type] = _prop;*/
			/*if (this.properties != null) {
				var index:int = this.properties.indexOf(_prop);
				if (index >= 0) {
					this.properties.splice(index, 1);	//delete the old prop
				}
				trace("set nex prop : " + _prop.id);
				this.properties.push(_prop);	//add the new prop
			}*/
			
		}
		
		public function getProperty(_type:String):Property {
			
			for each(var p:Property in this.properties) {
				if (p.type == _type) {
					return p;
				}
			}
			return null;
			
			
			//return this.properties[_type];
			
			/*if (this.properties is Object) {
				if (this.properties.hasOwnProperty(_type)) {
					return this.properties[_type];
				}else {
					return null;
				}
			}else {	//temp
				Logger.debug("error, this.properties is not an object");
				return null;
			}*/
			
			
			/*var p:Property = null;
			for each(var pTemp:Property in this.properties) {
				if (pTemp.type == _type) {
					p = pTemp;
					break;
				}
				trace("type: "+pTemp.type);
			}
			return p;*/
		}
		
		public static const FIELD_TITLE:String = "title";	//wird nicht gebraucht!?
		
		override public function getSearchFields():Array{	//wird nicht gebraucht!?
			return [ FIELD_TITLE ];
		}
		
		override public function matchesField( field:String, searchStr:String ):Boolean
		{
			return StringUtils.contains( this.title, searchStr );
			/*if (field == FIELD_EMAIL)
			{
				return StringUtils.contains( email, searchStr );
			}
			else
			{
				return StringUtils.anyWordBeginsWith( this[field], searchStr );
			}*/
		}
			
	}
	
	
}