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
	import graphElements.Element;
	import connection.SPARQLConnection;
	import graphElements.Chain;
	import graphElements.ElementClass;
	
	public class NoPagingListItem extends ListItem {
		
		public function NoPagingListItem(_key:String, _elementClass:ElementClass, _myConnection:SPARQLConnection, _facet:Facet, _incomingRel:RelationItem=null, _color:uint = 0){	//, _previous:Element=null, _next:Element=null) {
			super(_key, _elementClass, _myConnection, _facet, _incomingRel, _color);
			this.facet.offset = 0;
			this.facet.limit = 3000;	//just for testing! --> so actually no limit at all!
		}
		
		override public function setElementClass(_elementClass:ElementClass):void {
			super.setElementClass(_elementClass);
			this.elementsPerPage = 3000;
			this.cLabel = this.elementClass.label;// + "s";// this.chain.property.type +":" + this.chain.property.value;
			if (this.cLabel.length > 30) {
				this.cLabel = this.cLabel.substr(0, 30)+"...";
				//this.cLabel = this.cLabel.substr(this.cLabel.length - 14, this.cLabel.length - 1);
			}
		}
		
		override public function setChain(_chain:Chain, _triggeredColor:uint = 0, _triggeredElement:Element = null):void {
			
			//super.setChain(_chain, _triggeredColor, _triggeredElement);
			
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
			
			//FlashConnect.trace("hasChanged: " + this.hasChanged);
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
				//FlashConnect.trace("init--------------------");
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
		
	}
	
}