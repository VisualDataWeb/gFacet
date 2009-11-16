/**
 * Copyright (C) 2009 Philipp Heim and Timo Stegemann (email to: heim.philipp@googlemail.com)
 * 
 * This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License along with this program; if not, see <http://www.gnu.org/licenses/>.
 */ 

import com.adobe.flex.extras.controls.springgraph.Item;
import connection.MirroringConnection;
import de.polygonal.ds.HashMap;
import de.polygonal.ds.Iterator;
import graphElements.GraphModel;
import graphElements.NoPagingListItem;

[Bindable(event="GraphModelChange")]
public function get model():GraphModel {
	return GraphModel.getInstance();
}

public function get listItems():HashMap {
	
	trace("** --- So sollte nicht mehr auf ListItems zugegriffen werden ---");
	
	return model.listItems;
}

public function getFacetedChains(_tempFacet:Facet = null):void {
	//if (_rootFacet == null) _rootFacet = rootFacet;
	if ((model.resultSetFacet == null) && (_tempFacet == null)) {	//the worst case!
		//Logger.error("resultSetFacet is NULL");
	}else {	
		if (model.resultSetFacet == null) {		//the initial case
			model.resultSetFacet = _tempFacet;	//is not null!
		}
		//stopLayer.visible = true;
		//CursorManager.setBusyCursor();
		myConnection.sendCommand("getFacetedChains", getFacetedChains_Result, [model.resultSetFacet]);
	}
}

public function getFacetedChains_Result(_chains:Array):void {
	//stopLayer.visible = false;
	//CursorManager.removeBusyCursor();
	trace("RETURNED: getFacetedChains " + _chains.length);
	//FlashConnect.trace("number of elements in first chain: " + _chains[0].elements.length);
	for each(var c:Chain in _chains) {
		if (model.listItems.containsKey(c.id)) {
			var lItem:ListItem = model.listItems.find(c.id);
			lItem.setChain(c, triggeredColor, triggeredElement);
		}else {
			trace("ERROR: no key: " + c.id);
		}	
	}
	
	var iter:Iterator = model.listItems.getIterator();
	while (iter.hasNext()) {
		var lItem2:ListItem = iter.next();
		lItem2.checkHighlight(triggeredColor);	//warum nicht innerhalb der setChain methode?? -> weil erst alle veränderungen vorgenommen werden.
	}
	trace("test2");
	//roamer.updateGraph();
	trace("test3");
	//trace("test2");
}

public function getListItem(_elementClass:ElementClass, _facet:Facet, _rel:RelationItem=null):ListItem{
	var key:String = _elementClass.id + _facet.id;
	if (!model.listItems.containsKey(key)) {
		var newListItem:ListItem;
		if (model._noPaging) {
			newListItem = new NoPagingListItem(key, _elementClass, myConnection, _facet, _rel, getHighlightColor());
		}else {
			if (_elementClass.label == "Point") {	//_rel.property.type == "geo:long" || "geo:lat"
				newListItem = new MapItem(key, _elementClass, myConnection, _facet, _rel, getHighlightColor());
			}else {
				newListItem = new ListItem(key, _elementClass, myConnection, _facet, _rel, getHighlightColor());
			}
		}
		
		model.listItems.insert(key, newListItem);
		//FlashConnect.trace("listItem inserted, key : " + key);
		graph.add(newListItem);
		//setCurrentItem(null);
		//setCurrentItem(newListItem);
	}
	return model.listItems.find(key);
}

public function setResultSetFacet(_facet:Facet):void {
	model.resultSetFacet = _facet;
	
	//very bad, please change!
	if (myConnection is MirroringConnection) {
		myConnection.sendCommand("setResultSet", getFacetedChains_Result, [model.resultSetFacet]);
	}else {
		getFacetedChains();	//whole update of all the facets and the resultSet!
	}
}

public function getResultSetFacet():Facet {
	return model.resultSetFacet;
}


public var triggeredColor:uint = 0;	//default
private var _triggeredElement:Element = null;

public function setTriggeringElement(_e:Element):void {
	_triggeredElement = _e;
}

public function set triggeredElement(value:Element):void {
	_triggeredElement = value;
}

public function get triggeredElement():Element {
	return _triggeredElement;
}


public function removeListItem(_listItem:ListItem):void {
	var p:Facet = _listItem.facet.getParentFacet();
	model.listItems.remove(_listItem.key);
	removeItem(_listItem);
	
	//FlashConnect.trace("p: " + p);
	if (p != null) {
		var key:String = p.chainId;
		//FlashConnect.trace("key : " + key);
		var item:Item = model.listItems.find(key);
		//FlashConnect.trace("item " + item.id);
		//setCurrentItem(item);
	}else {
		//setCurrentItem(null);
	}
}

public function removeItem(_item:Item):void {
	graph.remove(_item);
	//FlashConnect.trace("remove from history: " + _item.id);
	//roamer.removeFromHistory(_item);
	
	//remove all facets
	//setCurrentItem(null);
}

private var colors:Array = new Array(uint("0x33FFCD"), uint("0x33CDFF"), uint("0x66FF33"), uint("0xff33cc"), uint("0xFFCD33"), uint("0xCDFF33"), uint("0x3366FF"), uint("0x33FF66")); //new Array(uint("0xff6600"), uint("0xff33cc"), uint("0xff9999"), uint("0x9966ff"), uint("0xcc66ff"), uint("0xff66cc"), uint("0xcc66cc"));
private var colorIndex:int = 0;

private function getHighlightColor():uint {
	colorIndex++;
	if ((colors.length-1) < colorIndex) {
		colorIndex = 0;
	}
	return colors[colorIndex];
}