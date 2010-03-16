/**
 * Copyright (C) 2009 Philipp Heim and Timo Stegemann (email to: heim.philipp@googlemail.com)
 * 
 * This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License along with this program; if not, see <http://www.gnu.org/licenses/>.
 */ 

package connection {
	import com.google.maps.wrappers.EventDispatcherWrapper;
	import de.polygonal.ds.HashMap;
	//import com.mikenimer.components.debug.ColdFusion.CFTimerDebugObject;
	//import com.mikenimer.components.debug.ResultEventDebugObject;
	import flash.events.Event;
	import graphElements.Chain;
	import graphElements.Element;
	import graphElements.Facet;
	import graphElements.Property;
	//import org.osflash.thunderbolt.Logger;
	import mx.rpc.http.HTTPService;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.events.FaultEvent;
	import graphElements.ElementClass;
	import org.flashdevelop.utils.FlashConnect;
	import mx.managers.CursorManager;
	import mx.core.Application;
	
	/**
	* ...
	* @author Default
	* Direct connection to SPARQL endpoint
	*/
	
	/*
	 * Notes : - Works for rootFacet & chaining
	 *         - Error : The query might be not right => the outgoingfacet might be not related to the parent facet => FIXED
	 *         29.09.08 : 
	 * 				- Fixed bug for return value of getFacetedChainsResponse function
	 *         10.11.08 :
	 *              - modified the query of getDistinctPropertyTypes by adding ?labelOfClass and ?labelOfType, so getLocalName() will not be used to describe the ?type or ?class
	 */
	 
	public class DirectConnection extends SPARQLConnection {
		
		public var method:String;
		public var phpSessionId:String;
		
		private var singleFacets:Array;
		private var resultKeys:Object;
		private var chainsArray:Object;
		private var rootFacet:Facet;
		private var resultSet:Facet;
		
		private var numCurrentQueries:int = 0;	//the number of currently sent queries that didn't come back yet (that are currently processed by the server)
		
		//bound variable is too long sometime, so make a shorter alias variable to be executed just for the selectQuery.
		//BEWARE the the value in arrTrueNameVar and arrAliasVar has "?" char int beginning => ?rootFacet
		
		private	var aliasFacetObj:Object;
		private	var realFacetObj:Object;
		
		//TODO: make a onresult function locally and differentiate for each command
		protected var onResultGetDistinctPropertyTypes:Function;
		protected var onResultGetFacetedChains:Function;
		protected var onResultGetElementClasses:Function;
		public function DirectConnection(_host:String, _basicGraph:String = "", _phpSessionId:String = "") {
			super(_host);
			//Logger.hide = false;// true;
			this.host = _host;
			this.phpSessionId = _phpSessionId;
			//configuration for dbPedia
			this.basicGraph = _basicGraph;// "http://dbpedia.org";
			this.method = "GET"
			//this.method = "POST";
			this.resultFormat = "xml";
			
			this.prefixes = "";
			"PREFIX owl: <http://www.w3.org/2002/07/owl#> " +
			"PREFIX xsd: <http://www.w3.org/2001/XMLSchema#> " +
			"PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#> " +
			"PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#> " +
			"PREFIX foaf: <http://xmlns.com/foaf/0.1/> " +
			"PREFIX dc: <http://purl.org/dc/elements/1.1/> " +
			"PREFIX dbpedia2: <http://dbpedia.org/property/> " +
			"PREFIX dbpedia: <http://dbpedia.org/> " +
			"PREFIX skos: <http://www.w3.org/2004/02/skos/core#> ";
		}
		
		override public function reset():void {
			super.reset();
			
			aliasFacetObj = null;
			chainsArray = null;
			fastEC = false;
			fastPT = false;
			method = "GET";
			numCurrentQueries = 0;
			phpSessionId = null;
			realFacetObj = null;
			resultKeys = null;
			resultSet = null;
			rootFacet = null;
			singleFacets = new Array();
			tempConcept = null;
			tempEClassesFacet = null;
			tempElementClass = null;
		}
		
		override public function sendCommand(_command:String, _onResult:Function, _args:Array = null):void {
			super.sendCommand(_command, _onResult, _args);
			
			this.addCurrentQuery();
			
			//Logger.hide = false;
			//Logger.debug("sendCommand" + _command);
			//onResult = _onResult;
			switch(_command) {
				case "getDistinctPropertyTypes":
					
					onResultGetDistinctPropertyTypes = _onResult;
					this.getDistinctPropertyTypes(_args[0]);
					break;
				case "getElementClasses":
					onResultGetElementClasses = _onResult;
					
					this.getElementClasses(_args[0], _args[1]);
					break;
				default:
					if (_args != null) {
						onResultGetFacetedChains = _onResult;
						this.getFacetedChains(_args[0]);	/*, _args[1]*/
					}
					break;
					//
			}
		}
		
		private var tempEClassesFacet:Facet = null;
		private var tempConcept:String = null;
		private var fastEC:Boolean = false;
		public function getElementClasses(_concept:String = null, _facet:Facet = null):void {
			FlashConnect.trace("getElementClasses");
			tempEClassesFacet = _facet;
			tempConcept = _concept;
			var pattern:RegExp;
			pattern = / /g;
			//dummy : erase if finished
			//_concept = "german musicians";
			_concept = _concept.replace(pattern, " and ");
		
			//FlashConnect.trace("called method getElementClasses");
			var aQuery:SPARQLQuery = new SPARQLQuery(this.host);
			aQuery.method = this.method;
			aQuery.resultFormat = this.resultFormat;
			aQuery.defaultGraphURI = this.basicGraph;
			/*aQuery.query = this.prefixes +
			'SELECT DISTINCT ?category ?label ' +
			'COUNT(?subject) AS ?numOfInstances  ' + 
			'WHERE {  ?subject skos:subject ?category .  ' + 
			         '?category rdfs:label ?label .  ' +
					 '?label bif:contains "' + _concept + '" .  ' +
					 'FILTER (lang(?label) = "en") ' +
			'} '; //ORDERED BY ' + LIMIT 20';
			
			if (_facet.descending)
				aQuery.query += 'ORDER BY DESC(?' + _facet.orderedBy.id + ') ';
			else
				aQuery.query += 'ORDER BY ASC(?' + _facet.orderedBy.id + ') ';
			
			aQuery.query += 'LIMIT ' + _facet.limit + ' OFFSET ' + _facet.offset;
			*/
			
			
			
			if (fastEC) {
				//fast
				aQuery.query = this.prefixes + 'SELECT DISTINCT ?category ?label ' + 
				'WHERE { ?category rdf:type skos:Concept . ' + 
						 '?category rdfs:label ?label .  ' +
						 '?label bif:contains "' + _concept + '" .  ' +
						 'FILTER (lang(?label) = "en") ' +
				'} ';
			}else {
				aQuery.query = this.prefixes + 'SELECT DISTINCT ?category ?label ' +
				'COUNT(?o) AS ?numOfInstances  ' + 
				'WHERE { ?category rdf:type skos:Concept . ' +  
						 '?o skos:subject ?category . ' +
						 '?category rdfs:label ?label .  ' +
						 '?label bif:contains "' + _concept + '" .  ' +
						 'FILTER (lang(?label) = "en") ' +
				'} ORDER BY DESC(?numOfInstances) LIMIT 30 ';	
			}
			
			
			/*if (_facet.descending)
				aQuery.query += 'ORDER BY DESC(?label)';// + _facet.orderedBy.id + ') ';
			else
				aQuery.query += 'ORDER BY ASC(?label)';// ' + _facet.orderedBy.id + ') ';
			
			aQuery.query += 'LIMIT ' + _facet.limit + ' OFFSET ' + _facet.offset;
			*/
			aQuery.phpSessionId = this.phpSessionId;
			aQuery.addEventListener(ResultEvent.RESULT, getElementClasses_Result);
			aQuery.addEventListener(FaultEvent.FAULT, getElementClasses_Fault);
			aQuery.execute();
						
			//return null;
		}
		
		protected function getElementClasses_Fault(e:FaultEvent):void 
		{
			if (fastEC) {	//if already tried with the fast method!
				FlashConnect.trace("fault");
				fastEC = false;
				this.removeCurrentQuery();
				var returnArray:Array = new Array();
				returnArray[0] = "please specify your search";
				onResultGetElementClasses(returnArray);
			}else {
				FlashConnect.trace("fault but we try the faster version (getElementClasses_Fault)");
				fastEC = true;
				this.getElementClasses(tempConcept, tempEClassesFacet);
			}
			//Logger.error("getElementClasses : ", e.fault.faultString);
			
		}
		//returns Array of elements
		protected function getElementClasses_Result(e:ResultEvent):void
		{
			fastEC = false;
			FlashConnect.trace("result ");
			
			//FlashConnect.trace("called method sparqlResponseListener");
			var aSPARQLParser:SPARQLResultParser = new SPARQLResultParser();
			
			aSPARQLParser.parse(XML(e.result));
			
			var arrResult:Array = aSPARQLParser.getResults;
			var returnArray:Array = new Array();
			var elemClass:ElementClass;
			for (var key:String in arrResult)
			{				
				elemClass = new ElementClass(arrResult[key]["?category"].getLabel, arrResult[key]["?label"].getLabel);
				if (arrResult[key]["?numOfInstances"] != null) {
					elemClass.numberOfObjectInstances = arrResult[key]["?numOfInstances"].getLabel;
				}
				
				//FlashConnect.trace("in getElementClasses: " + elemClass.label);
				returnArray.push(elemClass);
			}
			
			var chain:Chain = new Chain(tempEClassesFacet.chainId, null, null, 100);
			chain.elements = returnArray;
			
			this.removeCurrentQuery();
			onResultGetElementClasses(returnArray);			
		}
		
		
		private var tempElementClass:ElementClass;
		private var fastPT:Boolean = false;
		//problem : ?numOfInstances only works correctly for first facet. because in the beginning display all the intances (no filtering).
		//		    All the child facet is filtered regarding the instances of the parent facet, 
		//          but ?numOfInstances gives value as the facet is not filtered.
		public function getDistinctPropertyTypes(_elementClass:ElementClass = null):void {
			
			FlashConnect.trace("called method getDistinctPropertyTypes");
		    tempElementClass = _elementClass;

			var strQuery:String = "SELECT DISTINCT ?type ?class ?labelOfType ?labelOfClass COUNT(DISTINCT ?o) AS ?numOfInstances" +
				  " WHERE { " +
				  " ?s skos:subject <" + _elementClass.id + "> ." +
				  " ?s ?type ?o ." +
				  " ?o skos:subject ?class ." +
				  " ?o rdfs:label ?oLabel ." +
				  " ?type rdfs:label ?labelOfType ." +
				  " ?class rdfs:label ?labelOfClass " +
				  //'FILTER (lang(?labelOfClass) = "en" && lang(?labelOfType) = "en")' +
				  'FILTER (lang(?labelOfClass) = "en")' +
				  'FILTER (lang(?oLabel) = "en")' +
				  "} ORDER BY DESC(?numOfInstances) ?type ?class LIMIT 40";
			
				  
			//fast
			var strQuery2:String = "SELECT DISTINCT ?type ?class ?labelOfType ?labelOfClass " +
				  " WHERE { " +
				  " ?s skos:subject <" + _elementClass.id + "> ." +
				  " ?s ?type ?o ." +
				  " ?o skos:subject ?class ." +
				  " ?o rdfs:label ?oLabel ." +
				  " ?type rdfs:label ?labelOfType ." +
				  " ?class rdfs:label ?labelOfClass " +
				  //'FILTER (lang(?labelOfClass) = "en" && lang(?labelOfType) = "en")' +
				  'FILTER (lang(?labelOfClass) = "en")' +
				  'FILTER (lang(?oLabel) = "en")' +
				  "} ";// ORDER BY DESC(?numOfInstances) ?type ?class LIMIT 20";
				  
			//=========================
			
			//=========================
			
			var aQuery:SPARQLQuery = new SPARQLQuery(this.host);
			aQuery.method = this.method;
			aQuery.resultFormat = this.resultFormat;
			aQuery.defaultGraphURI = this.basicGraph;
			aQuery.query = this.prefixes;
			if (fastPT) {
				aQuery.query += strQuery2;
			}else {
				aQuery.query += strQuery;
			}
			aQuery.phpSessionId = this.phpSessionId;
			aQuery.addEventListener(ResultEvent.RESULT, getDistinctPropertyType_Result);
			aQuery.addEventListener(FaultEvent.FAULT, getDistinctPropertyType_Fault);
			
			aQuery.execute();	
		}
		
		protected function getDistinctPropertyType_Fault(e:FaultEvent):void
		{
			if (fastPT) {
				trace("fault!!");
				fastPT = false;
				this.removeCurrentQuery();
			}else {
				//we try it ones more with the fast query method!!
				trace("fault but we try the faster version (getDistinctPropertyType_Fault)");
				fastPT = true;
				this.getDistinctPropertyTypes(tempElementClass);
			}
			//FlashConnect.trace("getDistinctPropertyType_Fault");
			//Logger.error("getDistinctPropertyType : ", e.fault.faultString);
		}
		
		//return array or properties
		protected function getDistinctPropertyType_Result(e:ResultEvent):void
		{
			fastPT = false;
			FlashConnect.trace("getDistinctPropType_result");
			
			
			 var aSPARQLParser:SPARQLResultParser = new SPARQLResultParser();
			
			aSPARQLParser.parse(XML(e.result));
			
			var arrResult:Array = aSPARQLParser.getResults;	
			var testIds:Array = new Array();
			var typesArray:Array = new Array();
			
			for each (var item:Object in arrResult)
			{
			
				var _label:String = item["?labelOfType"].getLabel + ":" + item["?labelOfClass"].getLabel; //z.B. hasAge:age	
				var _id:String = item["?type"].getLabel;
				if (testIds.indexOf(_label) == -1) {
					var _type:String = item["?type"].getLocalname;  //z.B. hasAge
					var _value:String;
					var _class:String = "String";	//default
					var _labelOfClass:String = "String"; 	//default
					if (item["?class"] != null) {
						_class = item["?class"].getLocalname;
						_labelOfClass = item["?class"].getLabel;
					}
					
					var _elemClass:ElementClass = new ElementClass(_labelOfClass, _class);
					if (item["?numOfInstances"] != null) {
						_elemClass.numberOfObjectInstances = item["?numOfInstances"].getLabel;
					}
					testIds.push(_label);
					typesArray.push(new Property(_id, _type, _value, _label, _elemClass));
				}
				
			}
			
			
			this.removeCurrentQuery();
			onResultGetDistinctPropertyTypes(typesArray);
		}
		
		//public function getFacetedChains(_rootFacet:Facet):void 	/*, _elementClass:ElementClass = null*/
		public function getFacetedChains(_rootFacet:Facet):void 	
		{
			var selectedFacets:Array;
			//FlashConnect.trace("called method getFacetedChains");
			
			this.resultKeys = new Object();
			this.chainsArray = new Object();
			this.singleFacets = new Array();
			

			selectedFacets = new Array();		
			
			aliasFacetObj = new Object();
			realFacetObj = new Object();
			
			
			
			
			this.rootFacet = _rootFacet;
			this.resultSet = _rootFacet;
			

			
			this.resultSet.id = replaceChar(this.resultSet.id);	

			this.getFacets(this.rootFacet); //fill the singleFacets array

			
			var selectQuery:String = "";
			var idx:int = 0;
			var aFacetIsSelected:Boolean = false;
			var pathToRSArray:Array = new Array();
			for each (var aFacet:Facet in this.singleFacets)
			{
				
				//Logger.debug("facet id : ", aFacet.id);
				if(aFacet.isResultSet)
				{
					aliasFacetObj[aFacet.id] = "resultSet";
					realFacetObj["resultSet"] = aFacet.id;
						
					idx--;
				}
				else
				{
					aliasFacetObj[aFacet.id] = "facet"+idx;
					realFacetObj["facet" + idx] = aFacet.id;	
				}
				
				if (aFacet.isResultSet)
					selectQuery += " ?" + aliasFacetObj[aFacet.id] + " ?label_" + aliasFacetObj[aFacet.id] + " ?comment_" + aliasFacetObj[aFacet.id] + " ?zitgistLink_" + aliasFacetObj[aFacet.id];
				else
					selectQuery += " ?" + aliasFacetObj[aFacet.id] + " ?label_" + aliasFacetObj[aFacet.id] + " ?comment_" + aliasFacetObj[aFacet.id];
				var anObject:Object = new Object();
				anObject["element"] = "?" + aFacet.id;
				resultKeys[aFacet.id] = anObject;
				chainsArray["?" + aFacet.id] = new Chain(aFacet.chainId, null, new Array(), 0);
								
				if (aFacet.selectedElementIds.length > 0 && !(aFacet.isResultSet))
				{
					aFacetIsSelected = true;
					selectedFacets.push(aFacet);

				}
				idx++;
			}
			
			
			var outFacet:Facet;	
			var combinedQuery:String;
			var backPropagateQuery1:String = "";
			var backPropagateQuery2:String = "";
			var mainQuery:String = "";
			var writtenFacets:Array;
			writtenFacets = new Array();
			var resultBackPropagation:Object;
			var countQuery:String;
			var selectOfMainQuery:String;
			
			for each (var displayFacet:Facet in this.singleFacets)
			{	
				selectQuery = "";
				mainQuery = "";
				backPropagateQuery1 = "";
				backPropagateQuery2 = "";
				writtenFacets = [];
				countQuery = "";
				selectOfMainQuery = "";
				/*
				if (displayFacet.isResultSet)
					selectQuery += " ?" + aliasFacetObj[displayFacet.id] + " ?label_" + aliasFacetObj[displayFacet.id] + " ?comment_" + aliasFacetObj[displayFacet.id] + " ?zitgistLink_" + aliasFacetObj[displayFacet.id] + " ?totalNumber ";
				else
					selectQuery += " ?" + aliasFacetObj[displayFacet.id] + " ?label_" + aliasFacetObj[displayFacet.id] + " ?comment_" + aliasFacetObj[displayFacet.id] + " ?totalNumber ";
				*/
				
				if (displayFacet.isResultSet)
					selectQuery += " ?" + aliasFacetObj[displayFacet.id] + " ?label_" + aliasFacetObj[displayFacet.id] + " ?comment_" + aliasFacetObj[displayFacet.id] + " ?zitgistLink_" + aliasFacetObj[displayFacet.id] + " ";
				else
					selectQuery += " ?" + aliasFacetObj[displayFacet.id] + " ?label_" + aliasFacetObj[displayFacet.id] + " ?comment_" + aliasFacetObj[displayFacet.id] + " ";
				
				if (aFacetIsSelected)
				{
					//PART I : filtering 
					var filterQuery:String = "";
					var filterId:String;
					
					//query for result set
					//mainQuery += "SELECT DISTINCT ?" + aliasFacetObj[this.resultSet.id] + " ?label_" + aliasFacetObj[this.resultSet.id] + " ?comment_" + aliasFacetObj[this.resultSet.id] + " ?zitgistLink_" + aliasFacetObj[this.resultSet.id] + " WHERE { ";
					mainQuery += " WHERE { ";
					mainQuery += " ?" + aliasFacetObj[this.resultSet.id] + " skos:subject <" + this.resultSet.elementClassId + ">  . ";					
					mainQuery += " ?" + aliasFacetObj[this.resultSet.id] + " rdfs:label ?label_" + aliasFacetObj[this.resultSet.id] + " . ";					
					mainQuery += 'FILTER (lang(?label_' + aliasFacetObj[this.resultSet.id] + ') = "en" )';
					mainQuery += "OPTIONAL {?" + aliasFacetObj[this.resultSet.id] + " rdfs:comment ?comment_" + aliasFacetObj[this.resultSet.id] + " ";
					mainQuery += 'FILTER (lang(?comment_' + aliasFacetObj[this.resultSet.id] + ') = "en" )';
					mainQuery += "} "; //end of OPTIONAL
					mainQuery += "OPTIONAL {?" + aliasFacetObj[this.resultSet.id] + " owl:sameAs ?zitgistLink_" + aliasFacetObj[this.resultSet.id] + ' FILTER regex(str(?zitgistLink_' + aliasFacetObj[this.resultSet.id] + '),"zitgist.com","i")}';
					
					writtenFacets.push(this.resultSet.id);
					
					//query for the selected facet(s) and its path to RS
					for each(var selectedFacet:Facet in selectedFacets)
					{
						var result:Object = generateMainQuery(selectedFacet, writtenFacets);
						mainQuery += result.query;
						writtenFacets = writtenFacets.concat(result.writtenFacets);
						
					}
					selectOfMainQuery += "SELECT DISTINCT ";
					for each (var effectedFacetId:String in writtenFacets)
					{
						selectOfMainQuery += " ?" + aliasFacetObj[effectedFacetId] + " ?label_" + aliasFacetObj[effectedFacetId] + " ?comment_" + aliasFacetObj[effectedFacetId] + " ";
						if (effectedFacetId == this.resultSet.id)
							selectOfMainQuery += " ?zitgistLink_" + aliasFacetObj[effectedFacetId] + " ";
					}
					mainQuery = selectOfMainQuery + mainQuery + "}";
					
					//PART II : Backpropagation
					
					resultBackPropagation = this.generateBackpropagationQuery(displayFacet,this.resultSet,writtenFacets);
					backPropagateQuery1 = "  " + resultBackPropagation.backQueryOut + " " + resultBackPropagation.backQueryIn + "  ";
					
					countQuery = "SELECT COUNT(DISTINCT(?" + aliasFacetObj[displayFacet.id] + ")) AS ?totalNumber_" + aliasFacetObj[displayFacet.id] + " WHERE { {" + mainQuery + "} " + backPropagateQuery1 + "} ";
					//combinedQuery = "SELECT DISTINCT" + selectQuery + " WHERE {" + countQuery + " {" + mainQuery + "} " + backPropagateQuery1 ;						
					combinedQuery = "SELECT DISTINCT" + selectQuery + " WHERE {{" + mainQuery + "} " + backPropagateQuery1 ;						
					
					//combinedQuery += "FILTER (!!bound(?" + aliasFacetObj[displayFacet.id] + "))";
					combinedQuery += "} ORDER BY ASC(?label_" + aliasFacetObj[displayFacet.id] + ") OFFSET " + displayFacet.offset + " LIMIT " + displayFacet.limit;
					//Logger.debug("backPropagateQueryOut", resultBackPropagation.backQueryOut);
					//Logger.debug("backPropagateQueryIn",resultBackPropagation.backQueryIn);
					
				}
				else //if none is selected
				{
					//Main query part : getting all intances for RS
					var rootQuery:String;
					mainQuery += " ?" + aliasFacetObj[this.resultSet.id] + " skos:subject <" + this.resultSet.elementClassId + ">  . ";
					mainQuery += " ?" + aliasFacetObj[this.resultSet.id] + " rdfs:label ?label_" + aliasFacetObj[this.resultSet.id] + " . ";					
					mainQuery += 'FILTER (lang(?label_' + aliasFacetObj[this.resultSet.id] + ') = "en" ) ';
					mainQuery += "OPTIONAL {?" + aliasFacetObj[this.resultSet.id] + " rdfs:comment ?comment_" + aliasFacetObj[this.resultSet.id] + ' FILTER (lang(?comment_' + aliasFacetObj[this.resultSet.id] + ') = "en" )} ';
					mainQuery += "OPTIONAL {?" + aliasFacetObj[this.resultSet.id] + " owl:sameAs ?zitgistLink_" + aliasFacetObj[this.resultSet.id] + ' FILTER regex(str(?zitgistLink_' + aliasFacetObj[this.resultSet.id]+ '),"zitgist.com","i")} ';
					
					//Backpropagation part
					//generate outgoing facets (the right side of ResultSet) query
					
					resultBackPropagation = this.generateBackpropagationQuery(displayFacet,this.resultSet,writtenFacets);
					
					backPropagateQuery1 += resultBackPropagation.backQueryOut;
					backPropagateQuery2 += resultBackPropagation.backQueryIn;

					combinedQuery = "SELECT DISTINCT" + selectQuery + " WHERE { " + mainQuery + " " + backPropagateQuery1 + " " + backPropagateQuery2 + " ";
					//combinedQuery += "FILTER (!!bound(?" + aliasFacetObj[displayFacet.id] + ")) ";
					//subquery to count all the records
					//combinedQuery += "{SELECT COUNT(DISTINCT(?" + aliasFacetObj[displayFacet.id] + ")) AS ?totalNumber" + " WHERE { " + mainQuery + " " + backPropagateQuery1 + " " + backPropagateQuery2 + " "  + "} }";
					countQuery = "SELECT COUNT(DISTINCT(?" + aliasFacetObj[displayFacet.id] + ")) AS ?totalNumber_" + aliasFacetObj[displayFacet.id] + " WHERE { " + mainQuery + " " + backPropagateQuery1 + " " + backPropagateQuery2 + " "  + "} ";
					combinedQuery += "}";
					combinedQuery += " ORDER BY ASC(?label_" + aliasFacetObj[displayFacet.id] + ") OFFSET " + displayFacet.offset + " LIMIT " + displayFacet.limit;
				
					//Logger.debug("backPropagateQueryOut", resultBackPropagation.backQueryOut);
					//Logger.debug("backPropagateQueryIn",resultBackPropagation.backQueryIn);
				}			
				//Logger.debug("combined query : ", combinedQuery);
				//Logger.debug("combined query : ", countQuery);
				var _aQuery:SPARQLQuery = new SPARQLQuery(this.host);
				_aQuery.method = this.method;
				_aQuery.resultFormat = this.resultFormat;
				_aQuery.defaultGraphURI = this.basicGraph;
				
				_aQuery.query = this.prefixes + countQuery;
				_aQuery.phpSessionId = this.phpSessionId;
				_aQuery.addEventListener(ResultEvent.RESULT, getTotalNumber);
				//_aQuery.addEventListener(FaultEvent.FAULT, getFacetedChains_Fault);
				_aQuery.execute();
				
				var _aQuery2:SPARQLQuery = new SPARQLQuery(this.host);
				_aQuery2.method = this.method;
				_aQuery2.resultFormat = this.resultFormat;
				_aQuery2.defaultGraphURI = this.basicGraph;
				
				_aQuery2.query = this.prefixes + combinedQuery;
				_aQuery2.phpSessionId = this.phpSessionId;
				_aQuery2.addEventListener(ResultEvent.RESULT, getFacetedChains_Result);
				_aQuery2.addEventListener(FaultEvent.FAULT, getFacetedChains_Fault);
				_aQuery2.execute();
				
			}
			
		}
		
		//generate main query
		// return currObject:Object 
		//        properties   currObject.query:String 			: generated query
		//					   currObject.writtenFacets:Array	: facet(s) written in the query
		private function generateMainQuery(_facet:Facet, _writtenFacets:Array):Object
		{
			var currObject:Object = new Object();
			var filterQuery:String = "";
			var filterId:String = "";
			
			currObject.query = "";
			currObject.writtenFacets = new Array();
			
			
			//not found in writtenFacets
			if(_writtenFacets.indexOf(_facet.id) == -1)
			{
				var parent:Facet = new Facet();				
				var nextObject:Object = new Object();
				
				parent = _facet.getParentFacet();
				
				//not resultSet
				if (parent != null)
				{
					
					
					if (parent == _facet.incomingFacet)
					{
						//if parent is an incoming facet of current facet
						//the SPARQL query : ?parentF ?property ?currentF 
						currObject.query += " ?" + aliasFacetObj[parent.id] + " <" + _facet.property.id + ">  ?" + aliasFacetObj[_facet.id] +" . ";
						currObject.query += " ?" + aliasFacetObj[_facet.id] + " skos:subject <" + _facet.elementClassId + ">  . ";					
						currObject.query += " ?" + aliasFacetObj[_facet.id] + " rdfs:label ?label_" + aliasFacetObj[_facet.id] + " . ";					
						currObject.query += 'FILTER (lang(?label_' + aliasFacetObj[_facet.id] + ') = "en" )';
						currObject.query += "OPTIONAL {?" + aliasFacetObj[_facet.id] + " rdfs:comment ?comment_" + aliasFacetObj[_facet.id] + " ";
						currObject.query += 'FILTER (lang(?comment_' + aliasFacetObj[_facet.id] + ') = "en" )';
						currObject.query += "} "; //end of OPTIONAL
						
						if ((_facet.selectedElementIds.length) > 1 ) 
						{
							for each (filterId in _facet.selectedElementIds) 
							{
								filterQuery += " { ?"+ aliasFacetObj[parent.id] +" <" + _facet.property.id + "> <" + filterId + "> } UNION ";
							}
					
							filterQuery = filterQuery.substr(0, filterQuery.length - 6);
							filterQuery += " . ";
						} 
						else 
						{
							//only 1
							for each (filterId in _facet.selectedElementIds) 
							{
								filterQuery += "  ?"+ aliasFacetObj[parent.id] +" <" + _facet.property.id + "> <" + filterId + "> ";
								filterQuery += " . ";
							}
						}
							
						
					}
					else 
					{
						//if parent is an outgoing facet of current facet
						//the SPARQL query : ?currentF ?property ?parentF
						currObject.query += " ?" + aliasFacetObj[_facet.id] + " <" + parent.property.id + ">  ?" + aliasFacetObj[parent.id] +" . ";
						currObject.query += " ?" + aliasFacetObj[_facet.id] + " skos:subject <" + _facet.elementClassId + ">  . ";					
						currObject.query += " ?" + aliasFacetObj[_facet.id] + " rdfs:label ?label_" + aliasFacetObj[_facet.id] + " . ";					
						currObject.query += 'FILTER (lang(?label_' + aliasFacetObj[_facet.id] + ') = "en" )';
						currObject.query += "OPTIONAL {?" + aliasFacetObj[_facet.id] + " rdfs:comment ?comment_" + aliasFacetObj[_facet.id] + " ";
						currObject.query += 'FILTER (lang(?comment_' + aliasFacetObj[_facet.id] + ') = "en" )';
						currObject.query += "} "; //end of OPTIONAL
						
						if ((_facet.selectedElementIds.length) > 1 ) 
						{
							for each (filterId in _facet.selectedElementIds) 
							{
								filterQuery += " { <" + filterId + "> <" + parent.property.id + "> ?" + aliasFacetObj[parent.id] + " } UNION ";
							}
					
							filterQuery = filterQuery.substr(0, filterQuery.length - 6);
							filterQuery += " . ";
						} 
						else 
						{
							//only 1
							for each (filterId in _facet.selectedElementIds) 
							{
								filterQuery += "  <" + filterId + "> <" + parent.property.id + "> ?" + aliasFacetObj[parent.id] + " ";											
								filterQuery += " . ";
							}
						}
						
					}
					
					nextObject = generateMainQuery(parent, _writtenFacets);
					
					currObject.query += filterQuery + nextObject.query;
					currObject.writtenFacets = currObject.writtenFacets.concat(_facet.id, nextObject.writtenFacets);
					
				}
				
				
				
				
				
			}
			
			return currObject;
		}
		
		//generate backpropagation query
		// return currObject:Object 
		//        properties   currObject.backQueryOut:String 	: generated query with flow outgoing from parent : aChild <- parent
		//					   currObject.backQueryIn:String	: generated query with flow incoming to parent :   parent  <- aChild 
		private function generateBackpropagationQuery(displayFacet:Facet,_parent:Facet,effectedFacetIds:Array):Object
		{
			var currObject:Object = new Object();
			var nextObject:Object = new Object();
			var children:Array = _parent.getChildFacets();
			currObject.backQueryOut = "";
			currObject.backQueryIn = "";
			for each (var aChild:Facet in children) 
			{
				//parent is the incoming facet of aChild means the current facet (aChild) is located 
				//in the list of outgoing facets of RS. See the flow below
				//       aChild <- .. <- RS 
				if (_parent == aChild.incomingFacet)
				{
					if (effectedFacetIds.indexOf(aChild.id) == -1) //not found
					{
						currObject.backQueryOut += "OPTIONAL {";
						currObject.backQueryOut += " ?" + aliasFacetObj[_parent.id] + " <" + aChild.property.id + ">  ?" + aliasFacetObj[aChild.id] +" . ";
						currObject.backQueryOut += " ?" + aliasFacetObj[aChild.id] + " skos:subject <" + aChild.elementClassId + ">  . ";
						currObject.backQueryOut += " ?" + aliasFacetObj[aChild.id] + " rdfs:label ?label_" + aliasFacetObj[aChild.id] + " . ";
						currObject.backQueryOut += 'FILTER (lang(?label_' + aliasFacetObj[aChild.id] + ') = "en" )';
						currObject.backQueryOut += "OPTIONAL {?" + aliasFacetObj[aChild.id] + " rdfs:comment ?comment_" + aliasFacetObj[aChild.id] + ' FILTER (lang(?comment_' + aliasFacetObj[aChild.id] + ') = "en" )} ';
						if (aChild.id == displayFacet.id)
							currObject.backQueryOut += "FILTER (!!bound(?" + aliasFacetObj[displayFacet.id] + ")) ";
					}
					nextObject = this.generateBackpropagationQuery(displayFacet,aChild,effectedFacetIds);
					//urrObject.backQueryOut += nextObject.backQueryOut;
					//currObject.backQueryIn += nextObject.backQueryIn;
					if (nextObject.backQueryOut != "")
						currObject.backQueryOut += nextObject.backQueryOut;
					else
						currObject.backQueryOut += nextObject.backQueryIn;
					if (effectedFacetIds.indexOf(aChild.id) == -1) //not found
					{
						currObject.backQueryOut += "}";
					}
				}
				//parent is not the incoming facet of aChild means the current facet (aChild) is located 
				//in the list of incoming facets of RS... See the flow below
				//         RS <- .... <- aChild
				else
				{
					if (effectedFacetIds.indexOf(aChild.id) == -1) //not found
					{	currObject.backQueryIn += "OPTIONAL {";
						currObject.backQueryIn += " ?" + aliasFacetObj[aChild.id] + " <" + _parent.property.id + ">  ?" + aliasFacetObj[_parent.id] +" . ";
						currObject.backQueryIn += " ?" + aliasFacetObj[aChild.id] + " skos:subject <" + aChild.elementClassId + ">  . ";
						currObject.backQueryIn += " ?" + aliasFacetObj[aChild.id] + " rdfs:label ?label_" + aliasFacetObj[aChild.id] + " . ";
						currObject.backQueryIn += 'FILTER (lang(?label_' + aliasFacetObj[aChild.id] + ') = "en" )';			
						currObject.backQueryIn += "OPTIONAL {?" + aliasFacetObj[aChild.id] + " rdfs:comment ?comment_" + aliasFacetObj[aChild.id] + ' FILTER (lang(?comment_' + aliasFacetObj[aChild.id] + ') = "en" )} ';
						if (aChild.id == displayFacet.id)
							currObject.backQueryIn += "FILTER (!!bound(?" + aliasFacetObj[displayFacet.id] + ")) ";
					}
					nextObject = this.generateBackpropagationQuery(displayFacet,aChild,effectedFacetIds);
					//currObject.backQueryOut += nextObject.backQueryOut;
					//currObject.backQueryIn += nextObject.backQueryIn;
					if (nextObject.backQueryIn != "")
						currObject.backQueryIn += nextObject.backQueryIn;
					else
						currObject.backQueryIn += nextObject.backQueryOut;
					if (effectedFacetIds.indexOf(aChild.id) == -1) //not found
					{
						currObject.backQueryIn += "}";
					}
				}
			}
			
			return currObject;
		}
		
		
		private function getFacetedChains_Fault(e:FaultEvent):void
		{
			this.removeCurrentQuery();
			//Logger.error("getFacetedChains : ", e.fault.faultString);
		}

		private function getTotalNumber(e:ResultEvent):void
		{
			trace("getTotalNumber!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
			this.removeCurrentQuery();
			var newChainsArray:Array = new Array();
			var aSPARQLParser:SPARQLResultParser = new SPARQLResultParser();
			
			aSPARQLParser.parse(XML(e.result));
			
			var arrResult:Array = aSPARQLParser.getResults;
			
			for (var idxResult:String in arrResult)
			{	
				for (var facetId:String in resultKeys)
				{
					var _facetId:String = resultKeys[facetId]["element"];
					if (arrResult[idxResult].hasOwnProperty("?totalNumber_"+aliasFacetObj[facetId]))
					{
						chainsArray[_facetId].totalNumber = arrResult[idxResult]["?totalNumber_" +aliasFacetObj[facetId]].getLabel;
						//chainsArray[_facetId].totalNumber = 8;
						FlashConnect.trace("totalNumber : " + chainsArray[_facetId].totalNumber);
					}
					
				}
			}
			for each(var aFacet:Facet in singleFacets) 
			{					
				newChainsArray.push(chainsArray["?" + aFacet.id]);							
			}
			onResultGetFacetedChains(newChainsArray);
		}
		//returns Array of chains
		private function getFacetedChains_Result(e:ResultEvent):void
		{
			this.removeCurrentQuery();
			
			var aSPARQLParser:SPARQLResultParser = new SPARQLResultParser();
			
			aSPARQLParser.parse(XML(e.result));
			
			var arrResult:Array = aSPARQLParser.getResults;
			
			
			if (arrResult.length < 1)
			{			
				onResultGetFacetedChains(new Array(new Chain(this.rootFacet.chainId,null,new Array(),0)));				
			}
			else
			{
				var count:int = arrResult.length;
				var elementArray:Array = new Array();
				var elemArray:Array = new Array();
				var element:Element;
				var newChainsArray:Array = new Array();
				
				var properties:Object;
				var labelProp:Property;
				var commentProp:Property;
				for (var idxResult:String in arrResult)
				{	
					for (var facetId:String in resultKeys)
					{	
						labelProp = null;
						commentProp = null;
						
						//NOTE : resultKeys[facetId]["element"] == "?" + facetId => _facetId
						var _facetId:String = resultKeys[facetId]["element"];
						
						if (arrResult[idxResult].hasOwnProperty("?"+aliasFacetObj[facetId]))
						{
							elemArray = chainsArray[_facetId].elements;			
							properties = new Object();
							
							//elements is not empty
							if (elemArray.length > 0)
							{							
								var elementFound:Boolean = false;
								//searching the URI of the current element (_facetIdAlias) in the elementArray
								//if exist then skip it... dont put it again in the elementArray
							
								for (var elementIdx:int = 0; elementIdx < elemArray.length ; elementIdx++ )
								{									
									if (elemArray[elementIdx].id == arrResult[idxResult]["?"+aliasFacetObj[facetId]].getURI)
									{
										elementFound = true;										
										break;
									}
								}		
								//if the current element not exists in the elementArray
								//then put it in the list
								if (elementFound == false)
								{																		
									if (arrResult[idxResult]["?comment_"+aliasFacetObj[facetId]])
									{																	
										labelProp = new Property(arrResult[idxResult]["?"+aliasFacetObj[facetId]].getURI + "_label", "rdfs:label", arrResult[idxResult]["?label_"+aliasFacetObj[facetId]].getLabel, arrResult[idxResult]["?label_"+aliasFacetObj[facetId]].getLabel);
										commentProp = new Property(arrResult[idxResult]["?"+aliasFacetObj[facetId]].getURI + "_comment", "rdfs:comment", arrResult[idxResult]["?comment_"+aliasFacetObj[facetId]].getLabel, arrResult[idxResult]["?comment_"+aliasFacetObj[facetId]].getLabel);
									
										element = new Element(arrResult[idxResult]["?"+aliasFacetObj[facetId]].getURI, arrResult[idxResult]["?label_"+aliasFacetObj[facetId]].getLabel, arrResult[idxResult]["?comment_"+aliasFacetObj[facetId]].getLabel);
										element.setProperty(labelProp);
										element.setProperty(commentProp);
									}
									else
									{   
										labelProp = new Property(arrResult[idxResult]["?"+aliasFacetObj[facetId]].getURI + "_label", "rdfs:label", arrResult[idxResult]["?label_"+aliasFacetObj[facetId]].getLabel, arrResult[idxResult]["?label_"+aliasFacetObj[facetId]].getLabel);
									
										element = new Element(arrResult[idxResult]["?"+aliasFacetObj[facetId]].getURI, arrResult[idxResult]["?label_" + aliasFacetObj[facetId]].getLabel, null);
										element.setProperty(labelProp);
									}
						
									elementArray.push(arrResult[idxResult]["?"+aliasFacetObj[facetId]].getURI);
								
									chainsArray[_facetId].elements.push(element);
									//chainsArray[_facetId].totalNumber = arrResult[idxResult]["?totalNumber"].getLabel;
									//chainsArray[_facetId].totalNumber = 5;
									//chainsArray[_facetId].totalNumber = arrResult.length;															
								}
							
							}
							else //if element is empty
							{						
								if (arrResult[idxResult]["?comment_"+aliasFacetObj[facetId]])
								{   								
									labelProp = new Property(arrResult[idxResult]["?"+aliasFacetObj[facetId]].getURI + "_label", "rdfs:label", arrResult[idxResult]["?label_"+aliasFacetObj[facetId]].getLabel, arrResult[idxResult]["?label_" + aliasFacetObj[facetId]].getLabel);
									commentProp  = new Property(arrResult[idxResult]["?"+aliasFacetObj[facetId]].getURI + "_comment", "rdfs:comment", arrResult[idxResult]["?comment_"+aliasFacetObj[facetId]].getLabel, arrResult[idxResult]["?comment_"+aliasFacetObj[facetId]].getLabel);
									element = new Element(arrResult[idxResult]["?"+aliasFacetObj[facetId]].getURI, arrResult[idxResult]["?label_" + aliasFacetObj[facetId]].getLabel, arrResult[idxResult]["?comment_" + aliasFacetObj[facetId]].getLabel);
								
									element.setProperty(labelProp);
									element.setProperty(commentProp);								
								}
								else
								{   
									labelProp = new Property(arrResult[idxResult]["?"+aliasFacetObj[facetId]].getURI + "_label", "rdfs:label", arrResult[idxResult]["?label_"+aliasFacetObj[facetId]].getLabel, arrResult[idxResult]["?label_"+aliasFacetObj[facetId]].getLabel);
									element = new Element(arrResult[idxResult]["?"+aliasFacetObj[facetId]].getURI, arrResult[idxResult]["?label_" + aliasFacetObj[facetId]].getLabel, null);
									element.setProperty(labelProp);
								}
								elementArray.push(arrResult[idxResult]["?"+aliasFacetObj[facetId]].getURI);
								chainsArray[_facetId].elements.push(element);
								//chainsArray[_facetId].totalNumber = arrResult[idxResult]["?totalNumber"].getLabel;
								//chainsArray[_facetId].totalNumber = 5;
								//chainsArray[_facetId].totalNumber = arrResult.length
							}
						}
					}
					
				}

				var startIndex:int;
				var endIndex:int;
				for each(var aFacet:Facet in singleFacets) 
				{					
					newChainsArray.push(chainsArray["?" + aFacet.id]);							
				}
				onResultGetFacetedChains(newChainsArray);
				
			}
		}
		
		private function getFacets(_facet:Facet):void
		{
			var childrenArray:Array = new Array();
			childrenArray = _facet.getChildFacets();
			for each (var childFacet:Facet in childrenArray)
			{
				this.getFacets(childFacet);
			}
			
			_facet.id = replaceChar(_facet.id);
			this.singleFacets.push(_facet);
		}
		
		
		
		private function replaceChar(str:String):String
		{
			var pattern:RegExp;
			
			pattern = /:/g;
			str = str.replace(pattern, "_");
			pattern = /\//g;
			str = str.replace(pattern, "_");
			pattern = /\./g;
			str = str.replace(pattern, "_");
			pattern = /#/g;
			str = str.replace(pattern, "_");
			return str;
		}
		
		
		protected function addCurrentQuery():void {
			if (this.numCurrentQueries == 0) {
				CursorManager.setBusyCursor();
				this.app().setStopLayerVisibility(true);
			}
			this.numCurrentQueries++;
			trace("number of queries: " + this.numCurrentQueries);
		}
		
		protected function removeCurrentQuery():void {
			trace("num: " + this.numCurrentQueries);
			this.numCurrentQueries--;
			trace("num2: " + this.numCurrentQueries);
			if (this.numCurrentQueries <= 0) {
				this.numCurrentQueries = 0;
				CursorManager.removeBusyCursor();
				this.app().setStopLayerVisibility(false);
			}
			trace("number of queries: " + this.numCurrentQueries);
		}
		
		protected function app():Main {
			return Application.application as Main;
		}
		
	}
	
}