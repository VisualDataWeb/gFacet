/**
 * Copyright (C) 2009 Philipp Heim (email to: heim.philipp@googlemail.com)
 * 
 * This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License along with this program; if not, see <http://www.gnu.org/licenses/>.
 */ 

import classes.controller.Command;
import classes.view.ListItem;
import classes.view.MapItem;
import com.adobe.flex.extras.controls.forcelayout.Node;
import com.adobe.flex.extras.controls.springgraph.Roamer;
import com.adobe.flex.extras.controls.springgraph.SpringGraph;
import com.flashdb.DirectConnection;
import com.flashdb.ElementClass;
import com.flashdb.Facet;
import com.flashdb.MirroringConnection;
import com.flashdb.MirroringConnection_Knoodl;
import com.flashdb.MirroringConnection_SWORE;
import com.flashdb.RemotingConnection;
import com.flashdb.SPARQLConnection;
import mx.collections.Sort;
import mx.collections.SortField;
import mx.controls.dataGridClasses.DataGridColumn;
import mx.controls.List;
//import com.flashdb.SPARQLConnection;
import de.polygonal.ds.HashMap;
import de.polygonal.ds.Iterator;
import flash.events.MouseEvent;
import mx.collections.ArrayCollection;
import mx.controls.DataGrid;
import mx.core.IFactory;
import mx.core.UIComponent;
import com.adobe.flex.extras.controls.springgraph.Item;
import com.adobe.flex.extras.controls.springgraph.Graph;
import com.flashdb.Element;
import com.flashdb.Chain;
import com.flashdb.Property;
import com.flashdb.Element;
import com.flashdb.Relation;
import classes.view.RelationItem;
import com.adobe.flex.extras.controls.springgraph.GraphDataProvider;
import com.adobe.flex.extras.controls.springgraph.GraphNode;
import mx.events.ItemClickEvent;
import mx.events.PropertyChangeEvent;;
import org.flashdevelop.utils.FlashConnect;
import flash.external.ExternalInterface;
import org.osflash.thunderbolt.Logger;
import mx.managers.CursorManager;

//FLAG
private static var connectionType:String = "mirroring_swore"; // "mirroring_knoodl"; // "mirroring"; // "mirroring_swore"; // "mirroring";	//indirect (over PHP) direct or mirroring connection to an SPARQL endpoint

[Bindable]
public var graph: Graph = new Graph();

//public var relationItems:HashMap = new HashMap();
public var listItems:HashMap = new HashMap();

private var resultSetFacet:Facet = null;
//public var elements: Object = new Object();

[Bindable]
public var elementClasses:ArrayCollection = new ArrayCollection();	//one can be chosen as the mainClass by the user
[Bindable]
private var currentElementClass:ElementClass = null; 

private var myConnection:SPARQLConnection = null;

//private var rootFacet:Facet = new Facet("rootFacet", null, null);
public var triggeredColor:uint = 0;	//default

private var _triggeredElement:Element = null;

private var sparqlEndpoint:String = "";
private var phpSessionID:String = "";
private var basicGraph:String = "";

private function setup(): void {
	Logger.hide = false;// true;
	sparqlEndpoint = Application.application.parameters.sparqlEndpoint;
	phpSessionID = Application.application.parameters.PHPSESSID;
	basicGraph = Application.application.parameters.basicGraph;
	Logger.debug("sparqlEndpoint: ", sparqlEndpoint);
	Logger.debug("sessionId: ", phpSessionID);
	Logger.debug("basicGraph: ", basicGraph);
	
	//ontowikiPluginTest
	/*sparqlEndpoint = "http://softwiki1.ontowiki.net/service/sparql";
	basicGraph = "http://ns.softwiki.de/req/";
	phpSessionID = "a9b28d843fb95f22a4bc93ad046deef2";
	*/
	if(connectionType == "indirect") {
		myConnection = new RemotingConnection("http://softwiki.interactivesystems.info/ECIR/flashservices/gateway.php", "FacetedGraphService");
	}else {
		if ((sparqlEndpoint != null) && (sparqlEndpoint.length > 0)) {
			/*if ((phpSessionID != null) && (phpSessionID.length > 0)) {*/
				if ((basicGraph != null) && (basicGraph.length > 0)) {
					
					if(connectionType == "direct") {
						myConnection = new DirectConnection(sparqlEndpoint, basicGraph, phpSessionID);
					}else if (connectionType == "mirroring") {
						//myConnection = new MirroringConnection_SWORE(sparqlEndpoint, basicGraph, phpSessionID);
						myConnection = new MirroringConnection(sparqlEndpoint, basicGraph, phpSessionID);
					}else {
						Logger.error("no correct connectionType set!");
					}
					
					//myConnection = new OntowikiConnection(sparqlEndpoint, basicGraph, phpSessionID);
				}else {
					Logger.error("no basicGraph");
				}
			/*}else {
				Logger.error("no phpSessionId");
			}*/
		}else {
			Logger.error("no sparqlEndpoint defined!");
		}
		
		if (myConnection == null) {
			if(connectionType == "direct") {
				myConnection = new DirectConnection("http://dbpedia.org/sparql", "http://dbpedia.org");
			}else if(connectionType == "mirroring") {
				myConnection = new MirroringConnection("http://dbpedia.org/sparql", "http://dbpedia.org");
			}else if (connectionType == "mirroring_swore") {
				//Security.allowDomain("http://mms.ontowiki.net/mms_sandbox/");
				myConnection = new MirroringConnection_SWORE("http://mms.ontowiki.net/intranet/service/sparql", "http://mms.ontowiki.net/softwiki/MMS_Intranet/"); //"http://mms.ontowiki.net/mms_sandbox/service/sparql", "http://mms.ontowiki.net/softwiki/MMS_Intranet/"); // http://mms.ontowiki.net/service/sparql", "http://mms.ontowiki.net/");// , "http://testdb.softwiki.de");
			}else if (connectionType == "mirroring_knoodl") {
				myConnection = new MirroringConnection_Knoodl("http://www.knoodl.com/ui/groups/Tutorial/vocab/Wine/sparql");
			}else{
				Logger.error("no correct connectionType set!");
			}
		}
	}
	
	
	init();
	//Security.allowDomain("http://134.91.35.75");
	//smallExternalData.send();
	//myConnection.sendCommand("getElementClasses", getElementClasses_Result);
	FlashConnect.trace("start");
	//restart();
	//roamer.repulsionFactor = 0.5;
	//roamer.showHistory = true;
	
	//var initialItem:ListItem = new ListItem("test1", null, myConnection, rootFacet, null, getHighlightColor());
	//graph.add(initialItem);
	//setCurrentItem(initialItem);
	
	//ExternalInterface.addCallback("myFlexFunction",cleanUp);
}

public function cleanUp():void {
	FlashConnect.trace("clean up !!");
	myConnection.close();
}

public function getElementClasses(userInput:String):void {
	currentElementClass = null;
	elementClasses = new ArrayCollection();
	//Logger.debug("test");
	Logger.debug("send getElementClasses for", userInput);
	
	
	var f:Facet = new Facet("conceptSearchFacet", null, "conceptChain", null, null, null, new Property("numOfInstances", "numOfInstances"), conceptsPerPage, 0);
	
	myConnection.sendCommand('getElementClasses', getElementClasses_Result, [userInput, f]); //facet->property->value/type = userInput
	//myConnection.sendCommand('getConcepts', getConcepts_Result, [f, userInput]);
	
	//CursorManager.setBusyCursor();
}

private function setInitialElementClass(_class:ElementClass): void {
	FlashConnect.trace("change currentElementClass");
	currentElementClass = _class;
	
	//startconceptlabel.visible = false;
	//classdropdown.visible = false;
	var listItem:ListItem = getListItem(currentElementClass,  new Facet("firstFacet_"+_class.id, null), null);
	
	//currentResultSet = listItem;	//schlecht!!
	//setCurrentItem(listItem);
	//proxy.getElements(getElements_Result, getElements_Fault, currentElementClass);
	changeHelp1();
	
	listItem.setAsResultSet();	//initially the first listItem is also the resultSet!
	//restart();
}

public function getListItem(_elementClass:ElementClass, _facet:Facet, _rel:RelationItem=null):ListItem{
	var key:String = _elementClass.id + _facet.id;
	if (!listItems.containsKey(key)) {
		var newListItem:ListItem;
		if (_elementClass.label == "Point") {	//_rel.property.type == "geo:long" || "geo:lat"
			newListItem = new MapItem(key, _elementClass, myConnection, _facet, _rel, getHighlightColor());
		}else {
			newListItem = new ListItem(key, _elementClass, myConnection, _facet, _rel, getHighlightColor());
		}
		listItems.insert(key, newListItem);
		//FlashConnect.trace("listItem inserted, key : " + key);
		graph.add(newListItem);
		//setCurrentItem(null);
		//setCurrentItem(newListItem);
	}
	return listItems.find(key);
}

public function removeListItem(_listItem:ListItem):void {
	var p:Facet = _listItem.facet.getParentFacet();
	listItems.remove(_listItem.key);
	removeItem(_listItem);
	
	//FlashConnect.trace("p: " + p);
	if (p != null) {
		var key:String = p.chainId;
		//FlashConnect.trace("key : " + key);
		var item:Item = listItems.find(key);
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


// Make the selected item be the current item.
/*public function setCurrentItem(item: Item): void {
	if (item is ListItem) {
		//FlashConnect.trace("new current listItem!--------------------");
		
		//currentChain = item as ListItem;
		//detailViewStack.selectedChild = chainDetail;
	}else if (item is RelationItem) {
		//FlashConnect.trace("new current relationItem!--------------------");
		
	}else{
		FlashConnect.trace("current item is not listItem or chainitem");
		//return;
	}
	if (item != null) {
		FlashConnect.trace("currentItem set: "+item.id);
	}else {
		FlashConnect.trace("current Item is null");
	}
	//roamer.currentItem = item;
	
}*/

/*public function getFilterProperties():ArrayCollection {
	return selectedFilterProperties;
}*/

public function getCurrentElementClass():ElementClass {
	return currentElementClass;
}

public function getElementClasses_Result(_list:Array):void {
	//CursorManager.removeBusyCursor();
	//FlashConnect.trace("RETURNED: ElementClasses ");
	if (_list.length == 0) {
		_list[0] = "no results";
	}
	elementClasses = new ArrayCollection(_list);
	
	var cols:Array = classesDG.columns;
	if (elementClasses[0] is String) {
		
	}else {
		if (elementClasses[0].numberOfObjectInstances >= 0) {
			
			if (cols.length == 1) {
				var col:DataGridColumn = new DataGridColumn();
				col.dataField = "numberOfObjectInstances";
				col.headerText = "#objects"; 
				col.width = 70;
				
				cols.push(col);
				classesDG.columns = cols;
			}
			
			//Sort the elementClasses according to the number of instances they have
			var numericDataSort:Sort = new Sort();
			numericDataSort.fields = [new SortField("numberOfObjectInstances", false, true, true)];
			elementClasses.sort = numericDataSort;
		}else {
			if (cols.length > 1) {
				cols.splice(1, 1);
				classesDG.columns = cols;
			}
			
			var alphaDataSort:Sort = new Sort();
			alphaDataSort.fields = [new SortField("label", false, false, false)];
			elementClasses.sort = alphaDataSort;
		}
	}
	
	elementClasses.refresh();
	//TODO
	//createNavBar(5, 0);	// (numberOfPages, offset)
}

/*public function getConcepts_Result(_conceptChain:Chain):void {
	
}*/

public function getElementClasses_Fault(fault:String):void {
	//CursorManager.removeBusyCursor();
	FlashConnect.trace("There was a problem with getElementClasses: " + fault);
	FlashConnect.trace("-------------");
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

public function getFacetedChains(_tempFacet:Facet = null):void {
	FlashConnect.trace("getFacetedChains");
	//if (_rootFacet == null) _rootFacet = rootFacet;
	if ((resultSetFacet == null) && (_tempFacet == null)) {	//the worst case!
		Logger.error("resultSetFacet is NULL");
		FlashConnect.trace("resultSetFacet is NULL");
	}else {	
		if (resultSetFacet == null) {		//the initial case
			resultSetFacet = _tempFacet;	//is not null!
		}
		//stopLayer.visible = true;
		//CursorManager.setBusyCursor();
		FlashConnect.trace("getFacetedChains, resultSetFacet: "+resultSetFacet.id);
		myConnection.sendCommand("getFacetedChains", getFacetedChains_Result, [resultSetFacet]);
	}
}

public function getFacetedChains_Result(_chains:Array):void {
	//stopLayer.visible = false;
	//CursorManager.removeBusyCursor();
	trace("RETURNED: getFacetedChains " + _chains.length);
	//FlashConnect.trace("number of elements in first chain: " + _chains[0].elements.length);
	for each(var c:Chain in _chains) {
		if (listItems.containsKey(c.id)) {
			var lItem:ListItem = listItems.find(c.id);
			lItem.setChain(c, triggeredColor, triggeredElement);
		}else {
			trace("ERROR: no key: " + c.id);
		}	
	}
	
	var iter:Iterator = listItems.getIterator();
	while (iter.hasNext()) {
		var lItem2:ListItem = iter.next();
		lItem2.checkHighlight(triggeredColor);	//warum nicht innerhalb der setChain methode?? -> weil erst alle veränderungen vorgenommen werden.
	}
	trace("test2");
	//roamer.updateGraph();
	trace("test3");
	//trace("test2");
}

public function getFacetedChains_Fault(fault:String):void {
	//stopLayer.visible = false;
	//CursorManager.removeBusyCursor();
	FlashConnect.trace("There was a problem with getFacetedChains: " + fault);
	FlashConnect.trace("-------------");
	
}


private function changeHelp1(): void {
	help.text = "INFO: Drag the background to scroll";
	var t:Timer = new Timer(30000, 1);
	t.addEventListener(TimerEvent.TIMER_COMPLETE, onTimerComplete);
	t.start(); 	
}

public function onTimerComplete(evt:TimerEvent):void{
	help.visible = false;
}

public function setTriggeringElement(_e:Element):void {
	_triggeredElement = _e;
}

public function set triggeredElement(value:Element):void {
	_triggeredElement = value;
}

public function get triggeredElement():Element {
	return _triggeredElement;
}


//----------------------------------------------
//Elastic Main Menu

import mx.effects.easing.Elastic;
import flash.utils.Timer;

private var menuTimer:Timer;
private var fastMenuTimer:Timer;
private var menuVisible:Boolean;
[Bindable]
private var showMenuButton:Boolean;

[Embed(source="assets/img/menu.png")]
[Bindable]
public var btnMenuIcon:Class;

private function init():void{
	initMenuMoveOn.play();
	menuTimer = new Timer(2000, 0);
	menuTimer.addEventListener(TimerEvent.TIMER, onMenuTimeOut);
	fastMenuTimer = new Timer(500, 0);
	fastMenuTimer.addEventListener(TimerEvent.TIMER, onFastMenuTimeOut);
}

private function onMenuTimeOut(event:TimerEvent):void{
	trace('menuTimeOut'+event);
	menuTimer.stop();
	hideMenu();
}
private function onFastMenuTimeOut(event:TimerEvent):void{
	//trace(event);
	fastMenuTimer.stop();
	hideMenu();
}
private function setMenuVisible(status:Boolean):void{
	menuVisible=status;
	if(status){
		showMenuButton=false;
	}else{
		showMenuButton=true;
	}
}
private function showMenu():void{
	if(!menuVisible){
		initMenuMoveOn.play();
		menuTimer.start();
	}
	trace('[moveOnisPlaying]'+initMenuMoveOn.isPlaying);
}
private function hideMenu(event:MouseEvent=null):void{
	if(menuVisible && (currentElementClass != null)){	//if menu is visible and an initial elementClass has been chosen already
		if(event!=null){
			trace(event.currentTarget);
			trace('[initMenuMoveOff]'+initMenuMoveOff.isPlaying);
			trace('[moveOnisPlaying]'+initMenuMoveOn.isPlaying);
			if(!initMenuMoveOff.isPlaying || initMenuMoveOn.isPlaying){
				initMenuMoveOff.play();	
				//epvMenu.removeEventListener(MouseEvent.ROLL_OVER,
			}
		}else{
			//timer timed out
			initMenuMoveOff.play();	
		}
	}
	//trace('[moveOffisPlaying]'+initMenuMoveOff.isPlaying);
}
private function mouseAction(event:MouseEvent=null):void{
	//trace(event.target);
	//trace(event);
	if(event.target == 'animatedMenu0'){
		switch(event.type){
			case 'rollOut':
				trace('rollOutEpv0');
				break;
			case 'rollOver':
				menuTimer.start();
				trace('rollOverEpv0');
				break;
			case 'mouseMove':
				//trace('mouseMove');
				break;
		}
	}else{
		switch(event.type){
			case 'rollOut':
				if(!menuTimer.running){
					fastMenuTimer.start();	
				}						
				trace('rollOutElse');
				break;
			case 'rollOver':
				showMenu();
				trace('rollOverElse');
				break;
			case 'mouseMove':
				menuTimer.stop();
				//trace('mouseMove');
				break;
		}
	}
	
}
private function timerAction(action:String,target:String=null):void{
	//trace(event);
	switch(action){
		case 'rollOut':
			menuTimer.start();
			break;
		case 'rollOver':
			trace('rollOver');
			break;
		case 'mouseMove':
			//trace('mouseMove');
			break;
	}
}
private function showStatus():void{
	trace('[moveOnisPlaying]'+initMenuMoveOn.isPlaying);
	trace('[moveOffisPlaying]'+initMenuMoveOff.isPlaying);
}

/* ---------- conceptNav-------------------*/
[Bindable] public var conceptNavData:ArrayCollection = new ArrayCollection();
[Bindable] public var conceptsPerPage:uint = 10;
private var index:uint = 0;	//wofür?? aber möglicherweise wichtig
public var navSize:uint = 4;	//max number of page-buttons below the list (1,2,3,4)

private function navigateConcepts(event:ItemClickEvent):void {
	/*data.setPagingIndex(event.item.data);
	//data.refreshDataProvider(event.item.data);
	var lb:String = event.item.label.toString();
	if( lb.indexOf("<") > -1 || lb.indexOf(">") > -1 ){	//if either <<, <, > or >> has been clicked
		data.createNavBar(Math.ceil(data.chain.totalNumber/data.elementsPerPage),event.item.data);
		if( event.item.data == 0 ){
			pageNav.selectedIndex = 0;
		}else{
			pageNav.selectedIndex = 2;
		}
	}*/
}

/**
 * creates the paging navigation with respect to the current offset and the number of pages
 * @param	pages 	Math.ceil(data.visibleElements.length/data.elementsPerPage)
 * @param	set 	offset (current page!)
 */
public function createNavBar(numberOfPages:uint = 1, set:uint = 0):void {
	//Logger.debug("createNavBar");
	//Logger.debug("number of pages", numberOfPages);
	//Logger.debug("offset", set);
	//Logger.debug("navSize", navSize);
	conceptNavData.removeAll();
	if( numberOfPages > 1 ){
		if( set != 0 ){
			conceptNavData.addItem({label:"<<",data:0});	//first page!
			if( (set - navSize ) >= 0 ){	//navSize = number of pageButtons //if currentPage > navSize
				conceptNavData.addItem({label:"<",data:set - navSize});
			}else{
				conceptNavData.addItem({label:"<",data:0});
			}
		}
		var pg:uint = 0;
		for( var x:uint = 0; x < navSize; x++){	//create the pageButtons (1,2,3...)
			pg = x + set;
			conceptNavData.addItem({label: pg + 1,data: pg});	//for example: label=1 and data=0
		}
		Logger.debug("conceptNavData.length", conceptNavData.length);
		
		if( pg < numberOfPages - 1 ){	//if more pages exist than navSize!
			conceptNavData.addItem({label:">", data:pg + 1});	//label and data 
			conceptNavData.addItem({label:">>", data:numberOfPages - navSize});	//last page! numberOfPages - this.elementsPerPage
		}
	}
}

public function setResultSetFacet(_facet:Facet):void {
	resultSetFacet = _facet;
	
	//very bad, please change!
	if (myConnection is MirroringConnection) {
		myConnection.sendCommand("setResultSet", getFacetedChains_Result, [resultSetFacet]);
	}else {
		getFacetedChains();	//whole update of all the facets and the resultSet!
	}
}

public function getResultSetFacet():Facet {
	return resultSetFacet;
}

public function setStopLayerVisibility(_isVisible:Boolean):void {
	stopLayer.visible = _isVisible;
}
