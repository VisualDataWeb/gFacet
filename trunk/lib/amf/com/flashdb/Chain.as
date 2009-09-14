/**
* ...
* @author Philipp Heim
* @version 0.4
*/

package com.flashdb{
	// Chain.as
	
	[RemoteClass(alias="com.flashdb.Chain")]
    
	import flash.net.registerClassAlias;
	import org.flashdevelop.utils.FlashConnect;
	
	[Bindable] public class Chain{	//a Chain is the content of a ListItem!
		public var id:String
		public var property:Property;	//obsolete
		public var properties:Array;
		public var elements:Array;
		public var totalNumber:int;	//number of elements in the whole result set (more then the first ten!)
		
		//only on client side
		public var isHighlighted:Boolean = false;
		public var highlightColor:uint = uint("0xff0000");	//default
		
		/*
		* Contructor
		*/
		public function Chain(_id:String = "", _properties:Object = null, _elements:Array=null, _totalNumber:int=0) {
			this.id = _id;
			if (_properties is Array) {
				this.properties = _properties as Array;
				this.property = _properties[0];
			}else {
				this.property = _properties as Property;
				this.properties = new Array(this.property);
			}
			
			//this.properties = new Array();
			if (_elements == null) this.elements = new Array();
			else this.elements = _elements;
			this.totalNumber = _totalNumber;
		}
		
		public function getNextElement(e:Element):Element {
			var i:int = this.elements.indexOf(e);
			return this.elements[i + 1];
		}
		
		public function getPreviousElement(e:Element):Element {
			var i:int = this.elements.indexOf(e);
			return this.elements[i - 1];
		}
		
		/**
		 * Updates the elements in this chain
		 * @param	_chain
		 */
		public function update(_chain:Chain):void {
			/*if (_chain.property.id == this.property.id) {
				//FlashConnect.trace("update a chain");
				//einfacher update, keine problem behandlung!!
				var newElements:Array = _chain.elements;
				var newL:int = newElements.length;
				var l:int = this.elements.length;
				
				if (this.elements[0].id == newElements[newL - 1].id) {	//if the newElements are previous elements
					//FlashConnect.trace("add newElements infront");
					newElements.splice(newL - 1, 1);
					this.elements = newElements.concat(this.elements);	//put the newElements infront
				}else if (this.elements[l - 1].id == newElements[0].id) {	//if the newElements are next elements
					//FlashConnect.trace("add newElements behind");
					newElements.splice(0, 1);
					this.elements = this.elements.concat(newElements);	//put the newElements behind
				}else {
					FlashConnect.trace("ERROR in update");
				}
				
			}else {
				FlashConnect.trace("ERROR in update chain");
			}*/
		}
		
		public function setColor(_color:uint):void {
			this.highlightColor = _color;
		}
		
		static public function register():void
		{
			registerClassAlias("com.flashdb.Chain", Chain) ;	
		}
   }
}