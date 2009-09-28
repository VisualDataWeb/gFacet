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
	import extenders.MyItem;
	import com.adobe.flex.extras.controls.springgraph.Graph;
	import com.adobe.flex.extras.controls.springgraph.GraphNode;
	import com.adobe.flex.extras.controls.springgraph.Item;
	import connection.MirroringConnection;
	import connection.RemotingConnection;
	import connection.SPARQLConnection;
	import de.polygonal.ds.HashMap;
	import de.polygonal.ds.Iterator;
	import flash.events.Event;
	import mx.collections.ArrayCollection;
	import mx.collections.Sort;
	import mx.collections.SortField;
	import mx.events.ItemClickEvent;
	import org.flashdevelop.utils.FlashConnect;
	//import org.osflash.thunderbolt.Logger;
	import mx.managers.CursorManager;

	public class ListItem extends MyItem{
		
		[Bindable] public var chain:Chain;
		[Bindable] public var cLabel:String = "Undefined";
		[Bindable] public var facet:Facet;
		
		public var key:String;
		protected var myConnection:SPARQLConnection;
		
		[Bindable] public var elementClass:ElementClass = null;
		protected var incomingRel:RelationItem;
		[Bindable] public var hasChanged:Boolean = false;	//whether the total number of elements has changed due to an update
		public var highlightColor:uint = uint("0xff0000");	//default
		
		protected var unfilteredChain:Chain = null;
		protected var filteredChain:Chain = null;
		protected var showAllElements:Boolean = true;
		
		[Bindable] public var properties:ArrayCollection = new ArrayCollection();
		[Bindable] public var dataTypeProperties:ArrayCollection = new ArrayCollection();
		[Bindable] public var selectedDataTypeProperties:ArrayCollection = new ArrayCollection();
		
		//public var validities:HashMap = new HashMap();	//which instances are valid for which selected instances from other facets? 
		//protected var totalNumberOfSelectedElements:int = 0;
		
		protected var insideElements:HashMap = new HashMap();	//all elements
		[Bindable] public var visibleElements:ArrayCollection = new ArrayCollection();	//visible elements
		[Bindable] public var numberOfValids:int = -1;
		[Bindable] public var numberOfAll:int = 0;
		
		protected var restrictingElements:HashMap = new HashMap();
		[Bindable] public var restrictingColors:ArrayCollection = new ArrayCollection();
		protected var possibleRestrictingColors:HashMap = new HashMap();	//restrictingElements that caused no restrictions until now but possibly can
		
		protected var sortA:Sort = new Sort();	//Create a Sort object to sort the ArrrayCollection.
		
		protected var relIdHelper:int = 0;
		
		//[Bindable] public var possibleElementClasses:ArrayCollection = new ArrayCollection(); 
		
		[Bindable] public var nav:ArrayCollection = new ArrayCollection();	//all the elements in the paging navigation
		//public var orgData:ArrayCollection = new ArrayCollection();	//all the data that can be displayed in the datagrid
		[Bindable] public var elementsPerPage:uint = 10;
		
		//public var pagingIndex:uint = 0;	//ist doch in facet.offset gespeichert
		protected var index:uint = 0;	//wofür?? aber möglicherweise wichtig
		public var navSize:uint = 4;	//max number of page-buttons below the list (1,2,3,4)
		
		public var currentRelStub:RelationItem = null;
		
		
		public function ListItem(_key:String, _elementClass:ElementClass, _myConnection:SPARQLConnection, _facet:Facet, _incomingRel:RelationItem=null, _color:uint = 0){	//, _previous:Element=null, _next:Element=null) {
			super(_key);	//id is the inital key ! (
			trace("new ListItem");
			//Logger.hide = true;
			this.key = _key;
			this.facet = _facet;
			this.facet.chainId = this.key;	//todo: ändern in listId
			this.incomingRel = _incomingRel;
			trace("new ListItem: "+_key+", facet.id: "+_facet.id+", chainId: "+_facet.chainId);
			//trace("color: " + _color);
			if (_color != 0) this.highlightColor = _color;
			//trace("hcolor: " + this.highlightColor);
			//this.incomingRel.nextItem = this;	//braucht man nicht..
			this.myConnection = _myConnection;
			
			if (_elementClass != null) {
				trace("elementeClass: " + _elementClass.id);
				this.setElementClass(_elementClass);
			}
			
		}
		
		public function setElementClass(_elementClass:ElementClass):void {
			this.elementClass = _elementClass;// (this.insideElements.getItemAt(0) as Element).elementClass;
			this.facet.elementClassId = this.elementClass.id;
			//this.key = this.elementClass.id;	//??
			//this.facet.chainId = this.key;	//??
			this.numberOfAll = this.elementClass.numberOfObjectInstances;
			this.numberOfValids = this.numberOfAll;
			//sort
			var sortByStatus:SortField = new SortField("status");
            sortByStatus.compareFunction = myCompareFunc;
			sortA.fields = [sortByStatus];
			
			
			
			
			
			//dummy data
			var sClass:ElementClass = new ElementClass("String", "string");
			this.dataTypeProperties.addItem(new Property("label", "Label", "", "title", sClass));
			this.dataTypeProperties.addItem(new Property("description", "Comment", "", "description", sClass));
			
			
			
			
			//trace("test00");
			//very bad!! please change!
			if (this.myConnection is MirroringConnection) {
				this.myConnection.sendCommand("addFacet", getFacetedChain_Result, [this.facet]);
			}else {
				this.app().getFacetedChains(this.facet);	//initially setting the resultSetFacet if it is not set yet!
			}
			//trace("test5");
			this.myConnection.sendCommand("getDistinctPropertyTypes", getDistinctPropertyTypes_Result, [this.elementClass]);	//ask for object properties as well as data type properties like string!
			//CursorManager.setBusyCursor();
			//trace("test6");
			this.cLabel = this.elementClass.label;// + "s";// this.chain.property.type +":" + this.chain.property.value;
			if (this.cLabel.length > 18) {
				this.cLabel = this.cLabel.substr(0, 18)+"...";
				//this.cLabel = this.cLabel.substr(this.cLabel.length - 14, this.cLabel.length - 1);
			}
		}
		
		/*public function searchForElementClass(_input:String):void {
			this.myConnection.sendCommand("getElementClasses", getElementClasses_Result, [_input]);
		}
		
		public function getElementClasses_Result(_list:Array):void{	//must be a list of elementClasses
			FlashConnect.trace("RETURNED list of elementClasses");
			
			this.possibleElementClasses = new ArrayCollection(_list);
		}*/
		
		[Bindable(event = "compareFuncChanged")] public function myCompareFunc(itemA:Element, itemB:Element):int {
			if ((itemA.isSelected) && (!itemB.isSelected)) {
				return -1;	//A before B
			}else if ((itemB.isSelected) && (!itemA.isSelected)) {
				return 1;	//b before A
			}else if ((itemA.isValid) && (!itemB.isValid)) {
				return -1;
			}else if ((itemB.isValid) && (!itemA.isValid)) {
				return 1;
			}else {	//both must be equal
				return 0;
			}
			
			/*
			var valueA:String = itemA.status;
			var valueB:String = itemB.status;
			if ((valueA == "selected") && (valueB != "selected")) {
				return -1;	//A before B
			}else if ((valueB == "selected") && (valueA != "selected")) {
				return 1;	//b before A
			}else if ((valueA == "valid") && (valueB != "valid")) {
				return -1;
			}else if ((valueB == "valid") && (valueA != "valid")) {
				return 1;
			}else {	//both must be equal
				return 0;
			}*/
		}
		
		public function selectedElementsChanged(_e:Element):void {
			FlashConnect.trace("selectedElementsChanged: " + _e.id);
			var index:int = this.facet.selectedElementIds.indexOf(_e.id);
			
			if (index != -1) {	//deselected
				//FlashConnect.trace("remove element");
				this.facet.selectedElementIds.splice(this.facet.selectedElementIds.indexOf(_e.id), 1);
				_e.isHighlighted = false;	//nur für den update der farbe
				_e.isSelected = false;
				_e.status = "invalid";
			}else {				//selected
				this.facet.selectedElementIds.push(_e.id);
				_e.isHighlighted = true;	//nur für den update der farbe
				_e.isSelected = true;
				_e.highlightColor = this.highlightColor;
				_e.status = "selected";
			}
			this.app().triggeredColor = this.highlightColor;	//this is now the source of all updates!
			this.app().setTriggeringElement(_e);	//macht die triggeredColor überflüssig
			//FlashConnect.trace("testX");
			//FlashConnect.trace("new ListItem, facet.out: " + this.facet.outgoingFacets.length+" in: "+this.facet.incomingFacet);
			
			//very bad!! please change!
			if (this.myConnection is MirroringConnection) {
				if (_e.isSelected == true) {
					this.myConnection.sendCommand("addSelection", app().getFacetedChains_Result, [_e.id, this.facet]);
				}else {
					this.myConnection.sendCommand("removeSelection", app().getFacetedChains_Result, [_e.id, this.facet]);
				}
				
			}else {
				this.app().getFacetedChains(); //complete update
			}
		}
		
		
		
		public function addRelationItem():void {
			//Logger.debug("addRelationItem! " + this.id);
			FlashConnect.trace("addRelationItem! " + this.id);
			if (this.properties.length != 0) {	//only if properties are left to build new facets
				var newRel:RelationItem = new RelationItem(this.key + "_rel" + this.relIdHelper, this);	//problem mit id!!! -> eigentlich gelöst durch relIdHelper
				this.currentRelStub = newRel;
				this.relIdHelper++;
				trace("properties.length", properties.length);
				app().graph.add(newRel);
				trace("graph.link(" + this.id + ", " + newRel.id);
				
				var object:Object = new Object();
				object.startId = this.id;
				//FlashConnect.trace("link1: " +this.id + " - " +newRel.id );
				app().graph.link(this, newRel, object);
				
				//app().setCurrentItem(this.currentRelStub);
				//app().setCurrentItem(this);
				trace("test33");
				newRel.setPosition(this.getX(), this.getY());	//initial position
				trace("test44");
				//FlashConnect.trace("relStubs: "+app().graph.numLinks(this.currentRelStub));
			}else {
				trace("currentRelStub = null");
				this.currentRelStub = null;
			}
		}
		
		public function addListItem(_newRel:RelationItem):ListItem{
			FlashConnect.trace("addListItem: ,_newRel: "+_newRel.id);
			var prop:Property = _newRel.property;
			
			//remove property // the property will be added again when the facet gets closed by the user! -> removeFacet
			this.properties.removeItemAt(this.properties.getItemIndex(prop));
			
			var newFacet:Facet = new Facet("facet_" + prop.id + "_" + prop.objectClass.id, prop);
			newFacet.levelInTheTree = this.facet.levelInTheTree + 1;
			FlashConnect.trace("prop.id " + prop.id);
			FlashConnect.trace("object class.id: " + prop.objectClass.id);
			this.facet.outgoingFacets.push(newFacet);
			FlashConnect.trace("outgoingF: " + this.facet.outgoingFacets.length);
			newFacet.incomingFacet = this.facet;
			
			var newList:ListItem = app().getListItem(prop.objectClass, newFacet, _newRel);
			_newRel.setNextItem(newList);
						
			var object:Object = new Object();
			object.startId = _newRel.id;
			
			//FlashConnect.trace("link2: " +_newRel.id + " - " +newList.id );
			app().graph.link(_newRel, newList, object);
			
			//app().setCurrentItem(newList);
			
			var dX:Number = _newRel.getX() - this.getX();
			var dY:Number = _newRel.getY() - this.getY();
			newList.setPosition(_newRel.getX() + dX/2, _newRel.getY() + dY/2);
			
			//trace("test00");
			//TODO: anstoßen, neue relation zum auswählen der listItems!
			this.addRelationItem();
			//trace("test55");
			
			//FlashConnect.trace("rel2 links: "+app().graph.numLinks(_newRel));
			return newList;
		}
		
		public function getDistinctPropertyTypes_Result(_list:Array):void {	//must be a list of properties
			//CursorManager.removeBusyCursor();
			//FlashConnect.trace("RETURNED: DistinctProperties " + _list.length);
			var dataTypeArray:Array = new Array();
			var objectTypeArray:Array = new Array();
			for each(var p:Property in _list) {
				//TODO elementClass übergeben und testen ob literal!!
				
				//Logger.debug("distinctProp", p.type);
				//Logger.debug("objectClass", p.objectClass.label);
				if ((p.value == "String") || (p.value == "string")) {	//if it is a data-type property! -> better with p.objectClass!
					//dataTypeArray.push(p);
					this.dataTypeProperties.addItem(p);
				}else {	//if it is a object-type property!
					this.properties.addItem(p);
					//objectTypeArray.push(p);
				}
			}
			/*
			//dummy data
			var sClass:ElementClass = new ElementClass("String", "string");
			dataTypeArray.push(new Property("label", "Label", "", "title", sClass));
			dataTypeArray.push(new Property("description", "Comment", "", "description", sClass));
			
			this.dataTypeProperties = new ArrayCollection(dataTypeArray);
			this.properties = new ArrayCollection(objectTypeArray);
			
			//init
			var labelProp:Property = null;
			for each(var pTemp:Property in this.dataTypeProperties) {
				if (pTemp.type == "Label") {
					labelProp = pTemp;
					break;
				}
			}
			if (labelProp != null) {
				this.selectDataTypeProperty(labelProp);
			}*/
			/*
			//very bad!! please change!
			if (this.myConnection is MirroringConnection) {
				this.myConnection.sendCommand("addFacet", getFacetedChain_Result, [this.facet]);
			}else {
				this.app().getFacetedaddFacetChains(this.facet);	//initially setting the resultSetFacet if it is not set yet!
			}
			*/
			
			//just for testing
			//
			//(this.myConnection as MirroringConnection).addFacet(this.facet);
			
			//if relation item does not exist yet
			if (this.relIdHelper == 0) {
				this.addRelationItem();	//initial
			}
		}
		
		public function getFacetedChain_Result(_chain:Chain):void {
			
			trace("setChain");
			this.setChain(_chain);
			trace("setChain finished");
			
		}

		/*public function getDistinctPropertyTypes_Fault(fault:String):void {
			CursorManager.removeBusyCursor();
			FlashConnect.trace("There was a problem with getDistinctProperties: " + fault);
			
			FlashConnect.trace("-------------");
		}*/
		
		/*public function setInsideElements(_array:Array):void {
			//this.insideElements.removeAll();
			for each(var e:Element in _array) {
				//this.insideElements.addItem(e);
			}
		}*/
		
		/**
		 * 
		 * @param	_chain
		 * @param	_triggeredColor
		 * @param	_triggeredElement
		 */
		public function setChain(_chain:Chain, _triggeredColor:uint = 0, _triggeredElement:Element = null):void {
			trace("setChain for " + this.id +", chain.totalNumber: "+ _chain.totalNumber);
			this.hasChanged = false;	//reset
			
			var validsHaveChanged:Boolean = false;	//whether the number of valids has changed
			var validsHaveDecreased:Boolean = false;//whether the number of valids has decreased or not. If changed but not decreased, the number must be increased!
			var validsAreMax:Boolean = false;		//whether the new number of valids is the maximal number of valids
			var oldNumberOfValids:int = this.numberOfValids;	//to be able to tell whether it increased or decreased
			
			//temp
			if (true) {//this.facet.returnOnlyValids) {	//if the button "all" is not selected and hence only valids are shown
				trace("chainTotalNumber: "+_chain.totalNumber + ", numberOfValids: "+this.numberOfValids);
				this.numberOfValids = _chain.totalNumber; 
				if (this.elementClass.numberOfObjectInstances == this.numberOfValids) {
					validsAreMax = true;
				}
				if (this.numberOfValids != oldNumberOfValids) {
					this.facet.offset = 0;	//because the elements are new!
					validsHaveChanged = true;
					this.hasChanged = true;
					if (this.numberOfValids < oldNumberOfValids) {
						trace("validsHaveDecreased: " + this.numberOfValids + " , " + oldNumberOfValids);
						validsHaveDecreased = true;
					}
				}
				this.numberOfAll = this.numberOfValids;	//just because it is everything that can be viewed*/
			}else {
				if (this.numberOfAll != _chain.totalNumber) {
					this.hasChanged = true;	
				}
				this.numberOfAll = _chain.totalNumber;	//??
			}
			
			//Logger.debug("setChain: ", _chain.totalNumber, _chain.elements.length);
			
			FlashConnect.trace("hasChanged: " + this.hasChanged);
			if (this.hasChanged || (this.nav.length == 0)) {	//the possibility that the number has not changed but the concrete elements have is quite small for one click!
				//Logger.debug("createNavBar: ", this.elementClass.numberOfObjectInstances, this.elementsPerPage, _chain.totalNumber);	//visibleElements.length
				//workaround!!!!!
				var tempOffset:int = facet.offset;
				if (tempOffset > 0) {
					tempOffset = facet.offset / elementsPerPage;
				}
				this.createNavBar(Math.ceil(this.numberOfValids / this.elementsPerPage), tempOffset); //visibleElements.length 	//Match.ceil = 1 or higher
			}
			
			//test
			//this.numberOfValids = this.elementClass.numberOfObjectInstances;
			//test
			
			this.chain = _chain;
			this.visibleElements.removeAll();
			
			for each(var e:Element in this.chain.elements) {
				//set the selected ones
				if (this.facet.selectedElementIds.indexOf(e.id) != -1) {
					e.status = "selected";
					e.isSelected = true;
				}
				e.init();
				this.visibleElements.addItem(e);
			}
			
			
			//this.visibleElements.sort = "title";
			
			
			//this.visibleElements.refresh();
			
			//this.visibleElements = new ArrayCollection(this.chain.elements);
			
			/*this.insideElements.clear();
			
			for each(var e:Element in this.chain.elements) {//obsolet!!
				//set the selected ones
				if (this.facet.selectedElementIds.indexOf(e.id) != -1) {
					e.status = "selected";
					e.isSelected = true;
				}
				e.init();	//temp nur solange label und comment nicht in properties sind!
				this.insideElements.insert(e.id, e);
				/*
				var insideE:Element = this.insideElements.find(e.id);
				if (insideE == null) {
					e.init();
					this.insideElements.insert(e.id, e);
					insideE = this.insideElements.find(e.id);
				}
				insideE.isValid = true;
				insideE.status = "valid";	//isValid
				if (insideE.isSelected) insideE.status = "selected"; //isSelected*/
			//}
			
			//this.updateVisibleElements();*/
			
			/*
			//if (this.numberOfValids != _chain.totalNumber) {	//_chain.elements.length	//if something changed
				this.hasChanged = true;
				this.numberOfValids = _chain.totalNumber;	//_chain.elements.length
				if (this.numberOfValids > this.maxNumberOfValids)	this.maxNumberOfValids = this.numberOfValids;	//weg
				this.chain = _chain;
				var iter:Iterator = this.insideElements.getIterator();
				while (iter.hasNext()) {	//reset	//schwachsinn!!!
					var e1:Element = iter.next();
					e1.isValid = false;
					e1.status = "invalid";	//invalid
				}
				//workaround
				//_chain.totalNumber = _chain.elements.length;	//Change to: delete!
				for each(var e:Element in _chain.elements) {
					var insideE:Element = this.insideElements.find(e.id);
					if (insideE == null) {
						e.init();
						this.insideElements.insert(e.id, e);
						insideE = this.insideElements.find(e.id);
					}
					insideE.isValid = true;
					insideE.status = "valid";	//isValid
					if (insideE.isSelected) insideE.status = "selected"; //isSelected
				}
				this.updateVisibleElements();
			//}
			*/
			
			if (_triggeredElement != null) {
				if(_triggeredElement.isSelected){	//has been selected
					if(validsHaveDecreased){
						if (this.restrictingElements.containsKey(_triggeredColor)) {
							var numSelections:int = this.restrictingElements.find(_triggeredColor);
							//Logger.debug("1. number of restrictingColors", numSelections);
							numSelections = numSelections + 1;
							
							//Logger.debug("2. number of restrictingColors", numSelections);
							this.restrictingElements.remove(_triggeredColor);	//bad but I do not know how to update the number of selections inside the hashmap!
							this.restrictingElements.insert(_triggeredColor, numSelections);
							//Logger.debug("number of restictingColrs", this.restrictingElements.find(_triggeredColor));
						}else {	//valids have increased or nothing changed
							this.restrictingElements.insert(_triggeredColor, 1);
							this.restrictingColors.addItem(_triggeredColor);
							//FlashConnect.trace("add _triggeredColor to restriting color! " + _triggeredColor);
						}
					
					}else {	//valids have increased or nothing changed
						if (_triggeredElement != null) {
							//FlashConnect.trace("for list: " + this.id + ", add possible restricting color: " + _triggeredColor);
							if (this.possibleRestrictingColors.containsKey(_triggeredColor)) {
								var num4:int = this.possibleRestrictingColors.find(_triggeredColor);
								num4++;
								this.possibleRestrictingColors.remove(_triggeredColor);	//bad but I do not know how to update the number of selections inside the hashmap!
								this.possibleRestrictingColors.insert(_triggeredColor, num4);
								//Logger.debug("number of possibleRestrictingColors", num4);
							}else {
								this.possibleRestrictingColors.insert(_triggeredColor, 1);
							}
						}
					}
				}else {	//has been deselected
					if (this.restrictingElements.containsKey(_triggeredColor)) { 		//this list is restricted by this color?
						var number:int = this.restrictingElements.find(_triggeredColor);
						//Logger.debug("remove color", _triggeredColor);
						//Logger.debug("number: ", number);
						if (number == 1) {
							this.restrictingElements.remove(_triggeredColor);
							this.restrictingColors.removeItemAt(this.restrictingColors.getItemIndex(_triggeredColor));
							
						}else {
							number--;
							this.restrictingElements.remove(_triggeredColor);	//bad but I do not know how to update the number of selections inside the hashmap!
							this.restrictingElements.insert(_triggeredColor, number);
						}
					}else if (this.possibleRestrictingColors.containsKey(_triggeredColor)) {	//check for the possibleRestrictingColors also
							
						var num:int = this.possibleRestrictingColors.find(_triggeredColor);
						//FlashConnect.trace("reduce possibleColors, color: "+_triggeredColor+", number: "+num);
						if (num == 1) {
							this.possibleRestrictingColors.remove(_triggeredColor);
						}else {
							num--;
							this.possibleRestrictingColors.remove(_triggeredColor);	//bad but I do not know how to update the number of selections inside the hashmap!
							this.possibleRestrictingColors.insert(_triggeredColor, num);
						}
						//FlashConnect.trace("error in ListItem");
					}else {
						//nothing
					}
					
					if ((this.restrictingColors.length == 0) && (!validsAreMax)) {	//if the elements are still restricted!
						var keySet:Array = this.possibleRestrictingColors.getKeySet();
						for each(var color:uint in keySet){
							this.restrictingElements.insert(color, 1);
							this.restrictingColors.addItem(color);
							//FlashConnect.trace("add possible color to restriting color! " + color);
							var num3:int = this.possibleRestrictingColors.find(color);
							if (num3 == 1) {
								this.possibleRestrictingColors.remove(color);
							}else {
								num3--;
								this.possibleRestrictingColors.remove(color);	//bad but I do not know how to update the number of selections inside the hashmap!
								this.possibleRestrictingColors.insert(color, num3);
							}
						}
					}
				}
			}
			this.hasChanged = true;	//zum update des views!!!
			this.hasChanged = false;	
			this.hasChanged = validsHaveChanged;//true;
			
			
			
			
			if (this.selectedDataTypeProperties.length == 0) {
				FlashConnect.trace("init--------------------");
				//init
				var labelProp:Property = null;
				for each(var pTemp:Property in this.dataTypeProperties) {
					if (pTemp.type == "Label") {
						labelProp = pTemp;
						break;
					}
				}
				if (labelProp != null) {
					this.selectDataTypeProperty(labelProp);
				}
			}
			
			//Logger.debug("chain received!");
			trace("chain received!");
			
			//TODO: an die richtige Stelle setzen! eher löschen!
			//refreshDataProvider(index);
			
		}
		
		
		protected function updateVisibleElements():void {
			//FlashConnect.trace("update VisibleElements");
			//FlashConnect.trace("showAllElements: false, insideElements.size: " + this.insideElements.size);
			var oldVisibleElements:ArrayCollection = this.visibleElements;
			this.visibleElements.removeAll();	//reset
			
			var iter:Iterator = this.insideElements.getIterator();
			while (iter.hasNext()) {
				var e:Element = iter.next();
				if ((!e.isValid) && this.showAllElements) {	//only if showAll is acitve
					this.visibleElements.addItem(e);
				}else if (e.isValid) {
					//FlashConnect.trace("element is valid! : "+e.id);
					this.visibleElements.addItem(e);
				}else {
					//nothing
				}
			}
			//FlashConnect.trace("VisibleElements.length: "+this.visibleElements.length);
			//this.visibleElements.sort = sortA;
			this.visibleElements.refresh();
		}
		
		public function checkHighlight(_triggeredColor:uint = 0):void {
			//trace("checkHighlight: " + this.id + ", _triggeredColor: "+_triggeredColor);
			if (this.incomingRel != null) {	//if this is not the root	//umbauen zu parent!!
				this.incomingRel.hasChanged = false;
				//FlashConnect.trace("chckHighlight! "+hasChanged);
				var object1:Object = new Object();
				var object2:Object = new Object();
				if (this.hasChanged && (this.incomingRel.previousItem as ListItem).hasChanged) {
					
					//workaround: verhindert, dass Farben gezeichnet werden, die gerade entfernt wurden! Bei Entfernung wird dennoch hasChanged aktiv und daher können Fehler auftreten!
					if (this.restrictingColors.contains(_triggeredColor)) {
						//trace("both have changed!!!");
						this.incomingRel.highlightColor = _triggeredColor;
						this.incomingRel.hasChanged = true;
						object1.settings = { alpha: 1, color: _triggeredColor, thickness: 2 };
						object2.settings = { alpha: 1, color: _triggeredColor, thickness: 2 };
					}
				}
				
				//trace("drin");
				var graph:Graph;
				if(app().graph.linked(this.incomingRel.previousItem, this.incomingRel)) {	//only if already linked!!
					object1.startId = this.incomingRel.previousItem.id;
					//FlashConnect.trace("checkHighlight, object.startId: "+object.startId);
					//FlashConnect.trace("link3: " +this.incomingRel.previousItem.id + " - " +this.incomingRel.id );
					app().graph.link(this.incomingRel.previousItem, this.incomingRel, object1);
				}
				
				if (app().graph.linked(this.incomingRel, this)) {	//only if already linked!!
					object2.startId = this.incomingRel.id;
					//FlashConnect.trace("checkHighlight, object.startId2: "+object2.startId);
					
					//FlashConnect.trace("link4: " +this.incomingRel.id + " - " +this.id );
					app().graph.link(this.incomingRel, this, object2);
				}
				
				//FlashConnect.trace("link this ,newRel");
				
			}
			
		}
		
		public function close():void {
			
			
			
			FlashConnect.trace("close listItem: " + this.id);
			//close all child facets
			var childs:Array = this.facet.getChildFacets();
			FlashConnect.trace("childs: " + childs.length + ", level: " + this.facet.levelInTheTree+" , outgoingF: "+this.facet.outgoingFacets.length);
			for each(var child:Facet in childs) {
				var lChild:ListItem = app().listItems.find(child.chainId);//app().getListItem(fOut.chainId);
				if (lChild != null) {
					//FlashConnect.trace("close child: " + lChild.id);
					lChild.close();
					
				}
				else FlashConnect.trace("Error: lOut is null!!");
			}
			
			//TODO sub removen
			if (this.currentRelStub != null) {
				app().removeItem(this.currentRelStub);
				this.currentRelStub = null;
			}
			
			//very bad!! please change!
			if (this.myConnection is MirroringConnection) {
				FlashConnect.trace("removeFacet: " + this.id);
				this.myConnection.sendCommand("removeFacet", null, [this]);
			}else {
				this.app().getFacetedChains(); //complete update
			}
			
			
			var parent:Facet = this.facet.getParentFacet();
			//remove this and its incoming relation!
			if (parent != null) {
				
				var lParent:ListItem = app().listItems.find(parent.chainId);
				//FlashConnect.trace("parent != null "+lParent.id);
				var rel:RelationItem = null;
				if (parent.id == this.facet.incomingFacet.id) {
					rel = this.incomingRel;
				}else {
					
					if (lParent != null) {
						rel = lParent.incomingRel;
					}else {
						FlashConnect.trace("ACHTUNG, rel == null!!");
					}
				}
				//FlashConnect.trace("unlink " + this.id+", "+rel.id );
				//app().graph.unlink(this, rel);
				//FlashConnect.trace("unlink " + rel.id+", "+lParent.id );
				//app().graph.unlink(rel, lParent);
				//app().graph.remove(this.incomingRel);
				//FlashConnect.trace("remove item: " + rel.id);
				app().removeItem(rel);
				
				
				
				//FlashConnect.trace("remove relationItem: " + rel.id + ", rlabel: "+rel.rLabel);
			}else {
				FlashConnect.trace("parent == null"+this.id);
			}
			
			//FlashConnect.trace("remove item: " + this.id);
			app().removeListItem(this);
			
			//FlashConnect.trace("remove listItem: " + this.key);
			
			//app().setCurrentItem(app().listItems.find(this.facet.incomingFacet.chainId));
		}
		
		public function closeButtonClicked():void {
			//deselect all selections
			/*if (this.myConnection is MirroringConnection) {
				FlashConnect.trace("removeFacet "+this.id);
				this.myConnection.sendCommand("removeFacet", null, [this]);
			}*/
			var parent:Facet = this.facet.getParentFacet();
			if (parent != null) {
				var lIn:ListItem = app().listItems.find(parent.chainId);
				lIn.removeFacet(this.facet);
			}
			/*if (this.facet.incomingFacet != null) {
				var lIn:ListItem = app().listItems.find(this.facet.incomingFacet.chainId);
				//remove this facet from the incoming facet
				lIn.removeOutgoingFacet(this.facet);
				//var inOut:Array = this.facet.incomingFacet.outgoingFacets;
				//inOut.splice(inOut.indexOf(this.facet), 1);
			}*/
			
			this.close();
		}
		
		public function removeFacet(_facet:Facet):void {
			//FlashConnect.trace("remove from item: "+this.id+" facet : "+_facet.id);
			if ((this.facet.incomingFacet == null) || (_facet.id != this.facet.incomingFacet.id)) {	//if _facet is not the incoming
				var index:int = this.facet.outgoingFacets.indexOf(_facet);
				if (index >= 0) {
					this.facet.outgoingFacets.splice(index, 1);
				}
				this.properties.addItem(_facet.property);	//to have it available again in the drop down list!
				
				
				/*var dataSortField:SortField = new SortField();
                dataSortField.name = "objectClass.numberOfObjectInstances";
                dataSortField.numeric = true;
				
                var numericDataSort:Sort = new Sort();
                numericDataSort.fields = [dataSortField];
				
                this.properties.sort = numericDataSort;
                
				this.properties.refresh();
				*/
				
				if (this.properties.length == 1) {	//if this is the first one in the array
					this.addRelationItem();	//adds the stub to create new facets!
				}
			}else {
				this.facet.incomingFacet = null;	//???
			}
			
			
			
		}
		
		/*public function removeOutgoingFacet(_facet:Facet):void {
			var index:int = this.facet.outgoingFacets.indexOf(_facet);
			if (index >= 0) {
				this.facet.outgoingFacets.splice(index, 1);
				
				//Gibt möglicherweise einen Konflikt mit der getFacetedChain ?!
				this.properties.addItem(_facet.property);	//to have it available again in the drop down list!
				
				if (this.properties.length == 1) {	//if this is the first one in the array
					this.addRelationItem();	//adds the stub to create new facets!
				}
			}
			
			
		}*/
		
		
		public function setShowAll(_clicked:Boolean):void {
			if (_clicked) {
				this.showAllElements = true;
				this.facet.returnOnlyValids = false;
				//FlashConnect.trace("show all elements");
				//this.chain = this.unfilteredChain;	//TODO: this.setChain aufrufen!!
				//this.setInsideElements(this.unfilteredChain.elements);
				//this.updateVisibleElements();
			}else {
				this.showAllElements = false;
				this.facet.returnOnlyValids = true;
				//FlashConnect.trace("show filtered elements");
				//this.chain = this.filteredChain;
				//this.setInsideElements(this.filteredChain.elements);
				//this.updateVisibleElements();
			}
			//very bad!! please change!
			if (this.myConnection is MirroringConnection) {
				//FlashConnect.trace("setShowAll " + _clicked + ", onlyValid:" + this.facet.returnOnlyValids);
				this.myConnection.sendCommand("getFacetedChain", this.getFacetedChain_Result, [this.facet]);
			}else {
				this.updateVisibleElements();
				//this.app().getFacetedChains(); //complete update
			}
		}
		
		public function setAsResultSet():void {
			//first we have to select all selections!
			if (this.myConnection is MirroringConnection) {
				FlashConnect.trace("deselectAll ");
				this.myConnection.sendCommand("deselectAll", null);
			}
			
			this.facet.setAsResultSet(); 
			
			this.app().setResultSetFacet(this.facet);	//whole update of all the facets and the resultSet!
		}
		
		
		
		
		/* PINNING	------------ */
		
		public function pin():void {
			if (this.node == null) {
				this.getNode();
				trace("durch");
			}
			if (this.node != null) {
				FlashConnect.trace("fixed = true!");
				this.node.fixed = true;
				this.node.commit();
			}else {
				FlashConnect.trace("this.node == null");
			}
		}
		
		public function unpin():void {
			if (this.node != null) {
				this.node.fixed = false;
				this.node.commit();
			}
		}
		
		
		/* PAGING FUNCTIONALITY */
		
		/**
		 * creates the paging navigation with respect to the current offset and the number of pages
		 * @param	pages 	Math.ceil(data.visibleElements.length/data.elementsPerPage)
		 * @param	set 	offset (current page!)
		 */
		public function createNavBar(numberOfPages:uint = 1, set:uint = 0):void {
			FlashConnect.trace("createNavBar");
			FlashConnect.trace("number of pages"+ numberOfPages);
			FlashConnect.trace("offset"+ set);
			FlashConnect.trace("navSize"+ navSize);
			this.nav.removeAll();
			if( numberOfPages >= 1 ){
				if( set != 0 ){
					this.nav.addItem({label:"<<",data:0});	//first page!
					if( (set - navSize ) >= 0 ){	//navSize = number of pageButtons //if currentPage > navSize
						this.nav.addItem({label:"<",data:set - navSize});
					}else{
						this.nav.addItem({label:"<",data:0});
					}
				}
				var pg:uint = 0;
				for( var x:uint = 0; x < navSize; x++){	//create the pageButtons (1,2,3...)
					pg = x + set;
					if (pg < numberOfPages) {
						this.nav.addItem({label: pg + 1,data: pg});	//for example: label=1 and data=0
					}else {
						break;
					}
				}
				
				if( pg < numberOfPages - 1 ){	//if more pages exist than navSize!
					this.nav.addItem({label:">", data:pg + 1});	//label and data 
					this.nav.addItem({label:">>", data:numberOfPages - navSize});	//last page! numberOfPages - this.elementsPerPage
				}
				//Logger.debug("this.nav.length", this.nav.length);
				
			}
		}
		
		/*private function navigatePage(event:ItemClickEvent):void
		{
			refreshDataProvider(event.item.data);
			var lb:String = event.item.label.toString();
			if( lb.indexOf("<") > -1 || lb.indexOf(">") > -1 )
			{
				createNavBar(Math.ceil(this.visibleElements.length/elementsPerPage),event.item.data);
				if( event.item.data == 0 )
				{
					pageNav.selectedIndex = 0;
				}
				else
				{
					pageNav.selectedIndex = 2;
				}
			}
			
		}
		
		/**
		 * is called whenever the user clicks a column of the datagrid in order to sort the list in another way
		 * @param	_prop
		 * @param	_sortDescending
		 */
		public function setSortCriteria(_prop:Property, _sortDescending:Boolean = false):void {
			trace("setSortCriteria: " + _prop.label + ", desc: " + _sortDescending);
			FlashConnect.trace("setSortCriteria: " + _prop.label + ", type: " + _sortDescending);
			//Logger.debug("setSortCriteria ", _sortDescending);
			this.facet.orderedBy = _prop;	//property
			this.facet.descending = _sortDescending;
			this.resetPageSet();
			
			//very bad!! please change!
			if (this.myConnection is MirroringConnection) {
				this.myConnection.sendCommand("sorting", this.getFacetedChain_Result, [this.facet]);
			}else {
				this.app().getFacetedChains(); //complete update
			}
		}
		
		/**
		 * is called when the user wants to see another page (for example the results from 11-20)
		 * @param	_p
		 */
		public function setPagingIndex(_p:Number):void {
			//this.pagingIndex = _p;	//vielleicht überflüssig da in facet gespeichert!
			//TODO: search for right datagrid
			//if datagrid is not available getFacetedChains
			this.facet.offset = _p * this.elementsPerPage;// + 1;
			this.facet.limit = this.elementsPerPage;
			//Logger.debug("offset: ", this.facet.offset);
			
			//very bad!! please change!
			if (this.myConnection is MirroringConnection) {
				this.myConnection.sendCommand("paging", this.getFacetedChain_Result, [this.facet]);
			}else {
				this.app().getFacetedChains(); //complete update
			}
			
			/*if (this.pageSet.hasOwnProperty(_p)) {
				this.chain
			}else {
				this.app().getFacetedChains(this.facet);
			}*/
		}
		
		private var pageSet:Object = new Object();
		
		private function resetPageSet():void {
			this.pageSet = new Object();
		}
		
		
		/**
		 * Add column to the dataGrid to show more properties
		 * @param	prop
		 */
		public function selectDataTypeProperty(prop:Property):void {
			if (this.dataTypeProperties.contains(prop)) {
				//FlashConnect.trace("add dataGridColumn");
				var dataField:String = prop.type;
				//FlashConnect.trace("dataField: " + dataField);
				this.selectedDataTypeProperties.addItem(prop);
				this.selectedDataTypeProperties.dispatchEvent(new Event(Event.CHANGE));
				this.dataTypeProperties.removeItemAt(this.dataTypeProperties.getItemIndex(prop));
			}else {
				//Logger.error("property is not contained in dataTypeProperties!", prop.label);
			}
		}
		
		/**
		 * reduce the number of visible properties
		 * @param	prop
		 */
		public function deselectDataTypeProperty(prop:Property):void {
			if (prop != null) {
				this.dataTypeProperties.addItem(prop);
				this.selectedDataTypeProperties.removeItemAt(this.selectedDataTypeProperties.getItemIndex(prop));
				this.selectedDataTypeProperties.dispatchEvent(new Event(Event.CHANGE));
			}else {
				//Logger.error("prop is null");
			}
		}
	}
}
