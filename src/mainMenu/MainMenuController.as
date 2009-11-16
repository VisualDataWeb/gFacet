/**
 * Copyright (C) 2009 Philipp Heim and Timo Stegemann (email to: heim.philipp@googlemail.com)
 * 
 * This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License along with this program; if not, see <http://www.gnu.org/licenses/>.
 */ 

import connection.config.IConfig;
import connection.IConnection;
import connection.SPARQLConnection;
import connection.SPARQLResultEvent;
import flash.display.DisplayObject;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.events.TimerEvent;
import flash.xml.XMLDocument;
import graphElements.ElementClass;
import graphElements.Facet;
import graphElements.ListItem;
import graphElements.Property;
import mainMenu.events.InitialElementClassEvent;
import mainMenu.MainMenuModel;
import mx.collections.ArrayCollection;
import mx.controls.dataGridClasses.DataGridColumn;
import mx.core.Application;
import flash.utils.Timer;
import mx.events.ItemClickEvent;
import mx.collections.Sort;
import mx.collections.SortField;
import mx.managers.CursorManager;
import mx.managers.PopUpManager;
import mx.rpc.events.FaultEvent;
import mx.rpc.events.ResultEvent;
import mx.rpc.xml.SimpleXMLDecoder;
import mx.utils.ArrayUtil;
import mx.utils.ObjectUtil;
import popup.ConfigSelectionEvent;
import popup.ExpertSettings;

private var _model:MainMenuModel;

public function init():void {
	
}

// This event will never been fired
[Bindable(event="MainMenuModelChange")]
public function get model():MainMenuModel {
	if (_model == null) {
		_model = new MainMenuModel();
	}
	return _model;
}

[Bindable(event="MainMenuConnectionChange")]
public function get myConnection():IConnection {
	return model.connection;
}

public function set myConnection(value:IConnection):void {
	model.connection = value;
	dispatchEvent(new Event("MainMenuConnectionChange"));
}

public function getElementClasses(userInput:String):void {
	model.currentElementClass = null;
	model.elementClasses = new ArrayCollection();
	
	var query:String = getQuery(userInput);
	
	mainMenuForm.enabled = false;
	
	myConnection.executeSparqlQuery(query, new ArrayCollection([userInput]), getElementClasses_Result, getElementClasses_Fault);
	
}

private var resultNS:Namespace = new Namespace("http://www.w3.org/2005/sparql-results#");

private function getElementClasses_Fault(e:FaultEvent):void {
	mainMenuForm.enabled = true;
}

private function getElementClasses_Result(e:ResultEvent):void {
	
	mainMenuForm.enabled = true;
	
	var result:XML = new XML(e.result);
	
	model.elementClasses = new ArrayCollection();
	
	var results:Array = new Array();
	
	if (result..resultNS::results == "") {
		model.elementClasses.addItem("no results");
	}else {
		
		model.elementClasses = new ArrayCollection();
		
		for each (var res:XML in result..resultNS::results.resultNS::result) {
			var elem:ElementClass = new ElementClass();
			elem.id = res.resultNS::binding.(@name == "category").resultNS::uri;
			elem.label = res.resultNS::binding.(@name == "label").resultNS::literal;
			elem.numberOfObjectInstances = res.resultNS::binding.(@name == "numOfInstances").resultNS::literal;
			model.elementClasses.addItem(elem);
		}
		
		if (model.elementClasses.length == 0) {
			model.elementClasses.addItem("no results");
		}
	}
	
	var cols:Array = classesDG.columns;
	if (model.elementClasses[0] is String) {
		
	}else {
		if (model.elementClasses[0].numberOfObjectInstances >= 0) {
			
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
			model.elementClasses.sort = numericDataSort;
		}else {
			if (cols.length > 1) {
				cols.splice(1, 1);
				classesDG.columns = cols;
			}
			
			var alphaDataSort:Sort = new Sort();
			alphaDataSort.fields = [new SortField("label", false, false, false)];
			model.elementClasses.sort = alphaDataSort;
		}
	}
	
	model.elementClasses.refresh();
	
}

private function getQuery(userInput:String):String {
	var query:String = "";
	
	var pattern:RegExp;
	pattern = / /g;
	userInput = userInput.replace(pattern, " 'and' ");
	
	var prefixes:String = "" +
		"PREFIX owl: <http://www.w3.org/2002/07/owl#> " +
		"PREFIX xsd: <http://www.w3.org/2001/XMLSchema#> " +
		"PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#> " +
		"PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#> " +
		"PREFIX foaf: <http://xmlns.com/foaf/0.1/> " +
		"PREFIX dc: <http://purl.org/dc/elements/1.1/> " +
		"PREFIX dbpedia2: <http://dbpedia.org/property/> " +
		"PREFIX dbpedia: <http://dbpedia.org/> " +
		"PREFIX skos: <http://www.w3.org/2004/02/skos/core#> " + 
		"";
	
	query += prefixes;
	
	if (model.connection.config.isVirtuoso) {
		query += "SELECT DISTINCT ?category ?label " +
		"COUNT(?o) AS ?numOfInstances  " + 
		"WHERE { ?category rdf:type skos:Concept . " +  
				"?o skos:subject ?category . " +
				"?category rdfs:label ?label .  " +
				"?label bif:contains \"'" + userInput + "'\" .  " +
				"FILTER (lang(?label) = 'en') " +
		"} ORDER BY DESC(?numOfInstances) LIMIT 30 ";
	}else {
		query += "SELECT DISTINCT ?category ?label " +
		//"COUNT(?o) AS ?numOfInstances  " + 
		"WHERE { ?category rdf:type skos:Concept . " +  
				"?o skos:subject ?category . " +
				"?category rdfs:label ?label .  " +
				"FILTER regex(?label, '" + userInput + "', 'i')  . } "; 
				"FILTER (lang(?label) = 'en') " +
		"} ORDER BY DESC(?label) LIMIT 30 ";
	}
	
	return query;
}

private function setInitialElementClass(_class:ElementClass): void {
	
	model.currentElementClass = _class;
	
	dispatchEvent(new InitialElementClassEvent(_class, model.connection));
	
}

private function settingsClickHandler(event:MouseEvent):void {
	var pop:ExpertSettings = PopUpManager.createPopUp(Application.application as DisplayObject, ExpertSettings) as ExpertSettings;
	pop.addEventListener(ConfigSelectionEvent.CONFIGSELECTION, expertSettingsHandler);
}

private function expertSettingsHandler(e:ConfigSelectionEvent):void {
	model.elementClasses.removeAll();
	model.connection.config = e.selectedConfig;
	dispatchEvent(e);
}

private function mouseOverHandler(e:Event):void {
	if (mainMenuForm.enabled) {
		CursorManager.removeBusyCursor();
	}else {
		CursorManager.setBusyCursor();
	}
}

private function mouseOutHandler(e:Event):void {
	CursorManager.removeBusyCursor();
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
		
		if( pg < numberOfPages - 1 ){	//if more pages exist than navSize!
			conceptNavData.addItem({label:">", data:pg + 1});	//label and data 
			conceptNavData.addItem({label:">>", data:numberOfPages - navSize});	//last page! numberOfPages - this.elementsPerPage
		}
	}
}
