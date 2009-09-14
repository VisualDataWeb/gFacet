/**
* ...
* @author Philipp Heim
* @version 0.1
*/
package com.flashdb{
	// Chain.as
	
	[RemoteClass(alias="com.flashdb.Facet")]
    
	import flash.net.registerClassAlias;
	import org.flashdevelop.utils.FlashConnect;
	
	[Bindable] public class Facet{
		public var id:String;
		public var property:Property;
		public var selectedElementIds:Array;
		public var incomingFacet:Facet = null;
		public var outgoingFacets:Array = new Array();;
		public var chainId:String;			//the ID of the ListItem this facet belongs to
		public var elementClassId:String;	//the URI of the concept
		
		public var orderedBy:Property;	//Date, Label, Description (all columns in the list) -> RDF data (available at the server side!)
		public var descending:Boolean = false;	//descending order true or false
		public var limit:Number;	//number of elements per page
		public var offset:Number;	//comes from the paging
		
		public var returnOnlyValids:Boolean = true;	//is set by the user via the all-button for each list. Determines whether also invalid elements can be returned and shown in the list or not!
		
		/**
		 * All the properties that were selected by the user as columns in the list (examples: label:String, comment:String, hasAge:Age, ...). Possible are all properties!
		 * These properties need to be included for each returned element (in properties)
		 */
		public var visibleElementProperties:Array = new Array();
		
		public var isResultSet:Boolean = false;	//only one of the facets can be the resultSet
		public var levelInTheTree:int = -1;	//0 means it is the resultSet and therefore the rootFacet!
		
		public var tempLevelInTheTree:int = -1; //this is just for the temporary rebuilding of the graph for a certain facet!
		
		/*
		* Contructor
		*/
		public function Facet(_id:String ="", _property:Property = null, _chainId:String = "", _selectedElementIds:Array=null, _incomingFacet:Facet=null, _outgoingFacets:Array=null, _orderedBy:Property=null, _limit:Number=10, _offset:Number=0){
			id = _id;
			property = _property;
			chainId = _chainId;
			if (_selectedElementIds == null) selectedElementIds = new Array();
			else 	selectedElementIds = _selectedElementIds;
			incomingFacet = _incomingFacet;
			if (_outgoingFacets == null) outgoingFacets = new Array();
			else 	outgoingFacets = _outgoingFacets;
			orderedBy = _orderedBy;
			limit = _limit;
			offset = _offset;
		}
		
		public function addVisibleProperty(_prop:Property):void {
			this.visibleElementProperties.push(_prop);
		}
		
		public function removeVisibleProperty(_prop:Property):void {
			var index:int = this.visibleElementProperties.indexOf(_prop);
			if (index > -1) {
				this.visibleElementProperties.splice(index, 1);
			}
		}
		
		public function getChildFacets():Array {
			var returnArray:Array = new Array();
			var facets:Array = this.outgoingFacets.concat();	//just to make a copy!
			if(this.incomingFacet != null) facets.push(this.incomingFacet);
			for each(var f:Facet in facets) {
				//FlashConnect.trace("levelInthree: own: " + this.levelInTheTree + " ,other: " + f.levelInTheTree);
				if ((f!= null) && (this.levelInTheTree < f.levelInTheTree)) {
					returnArray.push(f);
				}
			}
			return returnArray;
		}
		
		public function getParentFacet():Facet {
			var facets:Array = this.outgoingFacets.concat();	//just to make a copy!
			if (this.incomingFacet != null) {
				facets.push(this.incomingFacet);
			}
			for each(var f:Facet in facets) {
				if ((f!= null) && (this.levelInTheTree > f.levelInTheTree)) {
					return f;
				}
			}
			//FlashConnect.trace("facet is root: " + this.id+ ", "+outgoingFacets.length);
			return null;	//if this is root!
		}
		
		/**
		 * wheever the resultSet changes, we have to update the whole tree!
		 * @param	_parent
		 */
		public function setParentFacet(_parent:Facet = null):void {
			if (_parent == null) {	//if this is the new root
				this.levelInTheTree = 0;
			}else {
				this.levelInTheTree = _parent.levelInTheTree + 1;
				this.isResultSet = false;
			}
			var facets:Array = this.outgoingFacets.concat();	//just to make a copy!
			if(this.incomingFacet != null) facets.push(this.incomingFacet);
			
			for each(var f:Facet in facets) {
				if ((_parent == null)||(f.id != _parent.id)) {	//if not the new parent or if this is the root
					f.setParentFacet(this);
				}
			}
		}
		
		public function setAsResultSet():void {
			this.isResultSet = true;
			this.setParentFacet(null);
		}
		
		static public function register():void{
			registerClassAlias("com.flashdb.Facet", Facet) ;	
		}
	}
}