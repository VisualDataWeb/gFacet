package com.flashdb 
{
	import com.flashdb.ElementClass;
	import com.flashdb.Facet;
	import de.polygonal.ds.HashMap;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.events.FaultEvent;
	import org.flashdevelop.utils.FlashConnect;
	import mx.rpc.http.HTTPService;
	import mx.utils.Base64Encoder;
	
	/**
	 * ...
	 * @author Philipp Heim
	 */
	public class MirroringConnection_SWORE extends MirroringConnection
	{
		
		public function MirroringConnection_SWORE(_host:String, _basicGraph:String = "", _phpSessionId:String = "") {
			super(_host, _basicGraph, _phpSessionId);
			this.prefixes = 
			"PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#> " +
			"PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#> " +
			"PREFIX skos: <http://www.w3.org/2004/02/skos/core#> " +
			"PREFIX req: <http://ns.softwiki.de/req/> ";
			
		}
		
		private var tempEClassesFacet:Facet = null;
		private var tempConcept:String = null;
		override public function getElementClasses(_concept:String = null, _facet:Facet = null):void {
			tempEClassesFacet = _facet;
			tempConcept = _concept;
			var pattern:RegExp;
			pattern = / /g;
			//dummy : erase if finished
			//_concept = "german musicians";
			_concept = _concept.replace(pattern, " and ");
			
			var strQuery:String = 'SELECT DISTINCT ?category ?label ' +
			//'COUNT(DISTINCT ?category) AS ?numOfInstances ' + 
			'WHERE { ' +
					'{ ?category rdf:type owl:Class . } UNION {?category rdf:type rdfs:Class . } . ' +
			         '?category rdfs:label ?label .  ' +
					 'FILTER (regex(?label, "^' + _concept + '", "i")) ' +
			'} '; //ORDERED BY ' + LIMIT 20';
			
			if (_facet.descending)
				;//aQuery.query += 'ORDER BY DESC(?' + _facet.orderedBy.id + ') ';
			else
				;//aQuery.query += 'ORDER BY ASC(?' + _facet.orderedBy.id + ') ';
			
			//strQuery += 'LIMIT ' + _facet.limit + ' OFFSET ' + _facet.offset;
			
			trace("query: " + strQuery);
			//strQuery = "SELECT DISTINCT ?label WHERE {  ?x rdf:type ?y .  ?y rdfs:label ?label  } LIMIT 10 OFFSET 0";
			
			this.executeQuery(strQuery, getElementClasses_Result);
						
			//return null;
		}
		
		override protected function getElementClasses_Result(e:ResultEvent):void {
			
			this.removeCurrentQuery();
			FlashConnect.trace("getElementClasses_Result");
			var aSPARQLParser:SPARQLResultParser = new SPARQLResultParser();
			FlashConnect.trace("shit"+e.toString());
			if (e == null) FlashConnect.trace("shit");
			aSPARQLParser.parse(XML(e.result));
			FlashConnect.trace("shit");
			var arrResult:Array = aSPARQLParser.getResults;
			var returnArray:Array = new Array();
			var elemClass:ElementClass;
			FlashConnect.trace("arrResult.length: "+arrResult.length);
			for (var key:String in arrResult)
			{				
				elemClass = new ElementClass(arrResult[key]["?category"].getLabel, arrResult[key]["?label"].getLabel);
				//elemClass.numberOfObjectInstances = arrResult[key]["?numOfInstances"].getLabel;
				
				returnArray.push(elemClass);
			}
			var chain:Chain = new Chain(tempEClassesFacet.chainId, null, null, 100);
			chain.elements = returnArray;
			
			this.removeCurrentQuery();
			onResultGetElementClasses(returnArray);		
		}
		
		override public function getDistinctPropertyTypes(_elementClass:ElementClass = null):void 
		{
			FlashConnect.trace("called method getDistinctPropertyTypes");
		    
			var strQuery:String = "SELECT DISTINCT ?type ?class ?labelOfType ?labelOfClass "+ // COUNT(DISTINCT ?o) AS ?numOfInstances" +
				  " WHERE { " +
				  " ?instance rdf:type <" + _elementClass.id + "> ." +
				  " OPTIONAL { "+
					" ?instance ?type ?o ." + 
					" ?o rdf:type ?class ." +
					" ?class rdfs:label ?labelOfClass ." +
					" ?type rdfs:label ?labelOfType ."+
				  "} ."+
				  " FILTER (!regex(?type,'http://www.w3.org/1999/02/22-rdf-syntax-ns#type')) .";
				  /*" ?s ?type ?o ." +
				  " ?o rdf:type ?class ." +
				  " ?o dc:title ?oLabel ." +
				  " ?type rdfs:label ?labelOfType ." +
				  " ?class rdfs:label ?labelOfClass " +*/
				  //'FILTER (lang(?labelOfClass) = "en" && lang(?labelOfType) = "en")' +
				  //'FILTER (lang(?labelOfClass) = "en")' +
				  //'FILTER (lang(?oLabel) = "en")' +
				  "} ";//ORDER BY DESC(?numOfInstances) ?type ?class LIMIT 20";
			
			//=========================
			/*
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#> 
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#> 
PREFIX skos: <http://www.w3.org/2004/02/skos/core#> 
PREFIX req: <http://ns.softwiki.de/req/> 
SELECT DISTINCT ?p ?plabel ?ptype ?class ?classLabel
WHERE {
  ?instance rdf:type <http://ns.softwiki.de/req/Requirement> .
  OPTIONAL { 
  ?instance ?p ?o . 
  ?o rdf:type ?class .
  ?class rdfs:label ?classLabel .
  ?p rdf:type ?ptype .
  ?p rdfs:label ?plabel .
  } .
  FILTER (!regex(?p,"http://www.w3.org/1999/02/22-rdf-syntax-ns#type")) .
}
			*/
			//=========================
			
			this.executeQuery(strQuery, this.getDistinctPropertyType_Result);
		}
		
		
		override protected function addFacet(_newFacet:Facet, _offset:int = 0):void 
		{
			this.tempNewFacet = _newFacet;
			//first we have to get all the elements of the choosen elementClass! 
			//TODO: build the query! And let the result be returned to addFacet_Result!
			
			var parent:Facet = _newFacet.incomingFacet;
			
			var query:String = "SELECT DISTINCT ";
			if (parent != null) {	//if _newFacet is not root
				query += "?parent ?label_parent ?title_parent "; //?comment_parent ";
			}
			query += "?validChild ?label_child ?title_child ?name_child ?comment_child "; /* ?allChild*/
			query += "WHERE { ";
			
			if (_newFacet.elementClassId != "String") {	//work around!
				query += "?validChild rdf:type <" + _newFacet.elementClassId + "> . ";
			}
			
			if (parent != null) {
				query += "?parent rdf:type <" + parent.elementClassId + "> . ";
			}
			query += "OPTIONAL {  ";
				query += "?validChild dc:title ?title_child . ";
				query += "?validChild skos:prefLabel ?label_child . ";
				query += "?validChild <http://www.holygoat.co.uk/owl/redwood/0.1/tags/name> ?name_child . ";
				query += "?validChild <http://purl.org/dc/elements/1.1/description> ?comment_child . ";
				if (parent != null) {	//if _newFacet is not root
					//query += "?parent ?type ?validChild . ";	//this number of validChild is restricted to only those that are related to the parent!
					query += "?parent dc:title ?title_parent . ";//FILTER (lang(?label_parent) = 'en' ) ";
					query += "?parent skos:prefLabel ?label_parent . ";
					/*query += "OPTIONAL {  ";
					query += "?parent rdfs:comment ?comment_parent FILTER (lang(?comment_parent) = 'en' )";
					query += "}";*/
				}
			query += "}";
			
			if (parent != null) {
				query += "?parent ?type ?validChild . ";	//this number of validChild is restricted to only those that are related to the parent!
				query += "FILTER (regex(?type,'"+_newFacet.property.id+"')) .";
			}
			/*query += "?allChild skos:subject <" + _newFacet.chainId + "> . ";*/
			//query += "?validChild dc:title ?label_child ";	//. FILTER (lang(?label_child) = 'en' )
			//query += "OPTIONAL {  ";
			//query += "?validChild rdfs:comment ?comment_child ";	//FILTER (lang(?comment_child) = 'en' )
			//query += "}";
			query += "}";
			
			/*
			  
			PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#> 
			PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#> 
			PREFIX skos: <http://www.w3.org/2004/02/skos/core#> 
			PREFIX req: <http://ns.softwiki.de/req/> 
			SELECT DISTINCT ?parent ?label_parent ?title_parent ?validChild ?label_child ?title_child
			WHERE {
			  ?parent rdf:type <http://ns.softwiki.de/req/Requirement> .
			  ?validChild rdf:type <http://www.w3.org/2004/02/skos/core#Concept> .
			  OPTIONAL { 
			  ?parent ?type ?validChild
			  ?validChild skos:prefLabel ?label_child .
			  ?validChild dc:title ?title_child .
			  ?parent skos:prefLabel ?label_parent .
			  ?parent dc:title ?title_parent .
			  } .
			  FILTER (regex(?type,"http://www.w3.org/2004/02/skos/core#primarySubject")) .
			}
			
			*/
			
			this.executeQuery(query, this.addFacet_Result);	
		}
		
		override public function addFacet_Result(e:ResultEvent):void {
			trace("addFacet_Result");
			var parentFacet:Facet = this.tempNewFacet.incomingFacet;
			var parentElements:HashMap = new HashMap();
			if (parentFacet != null) {	//if the new facet is not the resultSet
				parentElements = this.elementLists.find(parentFacet.chainId);
			}
			
			var aSPARQLParser:SPARQLResultParser = new SPARQLResultParser();
			aSPARQLParser.parse(XML(e.result));
			var arrResult:Array = aSPARQLParser.getResults;
			
			if (arrResult.length < 1) {
				trace("no result in addFacet!");
				//onResultGetFacetedChains(new Array(new Chain(this.rootFacet.chainId,null,new Array(),0)));
			}else {
				var count:int = arrResult.length;
				trace("count: " + count);
				
				var listOfElements:HashMap = new HashMap();
				if (elementLists.containsKey(this.tempNewFacet.chainId)) {
					listOfElements = elementLists.find(this.tempNewFacet.chainId);
				}
				
				var newFacetRelations:HashMap = new HashMap();	//every relation between two elements can be accessed from both elementIds!
				if (relationLists.containsKey(this.tempNewFacet.chainId)) {
					newFacetRelations = relationLists.find(this.tempNewFacet.chainId);
				}
				
				for (var idxResult:String in arrResult) {
					var childId:String;
					var childLabel:String = null;
					var childComment:String;
					var parentId:String;
					if (arrResult[idxResult].hasOwnProperty("?validChild")) {
						childId = arrResult[idxResult]["?validChild"].getURI;
						
						if (arrResult[idxResult].hasOwnProperty("?label_child")) {
							childLabel = arrResult[idxResult]["?label_child"].getLabel;
						}
						if ((childLabel == null) && (arrResult[idxResult].hasOwnProperty("?title_child"))) {	//only because of SWORE data!!
							childLabel = arrResult[idxResult]["?title_child"].getLabel;
						}
						if ((childLabel == null) && (arrResult[idxResult].hasOwnProperty("?name_child"))) {	//only because of SWORE data!!
							childLabel = arrResult[idxResult]["?name_child"].getLabel;
						}
						if (childLabel == null) {
							childLabel = childId;
						}
						
						if (arrResult[idxResult].hasOwnProperty("?comment_child")) {
							childComment = arrResult[idxResult]["?comment_child"].getLabel;
						}
						var childElement:Element = new Element(childId, childLabel, childComment); //null, 0, tempNewFacet.property.objectClass);
						if (listOfElements.containsKey(childId)) {
							childElement = listOfElements.find(childId);
						}else {
							listOfElements.insert(childElement.id, childElement);
						}
						
						//FlashConnect.trace("new Element: " + childElement.title);
						
						//check relation back to the parent
						if (arrResult[idxResult].hasOwnProperty("?parent")) {
							parentId = arrResult[idxResult]["?parent"].getURI;
							//FlashConnect.trace("parent exists!! " + parentId);
							
							var parentElement:Element = this.getElement(parentFacet.chainId, parentId);
							if (parentElement == null) {	//if not yet exists!
								//FlashConnect.trace("create parent element!!!!");
								var parentLabel:String = null;
								var parentComment:String;
								if (arrResult[idxResult].hasOwnProperty("?label_parent")) {
									parentLabel = arrResult[idxResult]["?label_parent"].getLabel;
								}
								if ((parentLabel == null) && (arrResult[idxResult].hasOwnProperty("?title_parent"))) {	//only because of SWORE data!!
									parentLabel = arrResult[idxResult]["?title_parent"].getLabel;
								}
								
								if (arrResult[idxResult].hasOwnProperty("?comment_parent")) {
									parentComment = arrResult[idxResult]["?comment_parent"].getLabel;
								}
								parentElement = new Element(parentId, parentLabel, parentComment); //null, 0, tempNewFacet.property.objectClass);
								parentElement.isValid = false;	//IMPORTANT!!
								parentElement.isAvailable = false;
								parentElement.isActive = false;	//IMPORTANT!! is inActive initially anyway
								
								parentElements.insert(parentElement.id, parentElement);
								//listOfElements.insert(parentElement.id, parentElement);
							}else {	//if parent exists already
								if (parentElement.isActive) {	//and is active
									childElement.isActive = true;
								}
							}
							
							//FlashConnect.trace("parent: " + parentElement.title);
							
							//childElement.isValid = parentElement.isValid;	
							if (parentElement.isValid || parentElement.isAvailable) {
								childElement.isAvailable = true;	//IMPORTANT!!
							}
						
							//connects a new facet to the graph and stores all the connections to existing elements in relationLists
							if (!newFacetRelations.containsKey(parentId)) {	//if no relation for this parent instance exists yet!
								var hMap1:HashMap = new HashMap();
								newFacetRelations.insert(parentId, hMap1);
							}
							if (!newFacetRelations.containsKey(childId)) {	//if no relation for this child instance exists yet!
								var hMap2:HashMap = new HashMap();
								newFacetRelations.insert(childId, hMap2);
							}
							if (!(newFacetRelations.find(parentId) as HashMap).containsKey(childId)) {	//if not already connected
								(newFacetRelations.find(parentId) as HashMap).insert(childId, childElement);
								(newFacetRelations.find(childId) as HashMap).insert(parentId, parentElement);
								//FlashConnect.trace("new relation: " + childId + ", " + parentId);
							}
							
						}else {	//no parent (child is resultSet)
							//FlashConnect.trace("testttt");
							childElement.isActive = true;
							childElement.isAvailable = true;
						}
						//FlashConnect.trace("new Element: " + newElement.id+", label: "+newElement.title+", comment: "+newElement.description);
					}else {
						trace("not FOUND!");
					}
				}
				
				this.elementLists.insert(this.tempNewFacet.chainId, listOfElements);
				this.relationLists.insert(this.tempNewFacet.chainId, newFacetRelations);
			}
			
			if (arrResult.length == 1000) {	//if the limit has been reached!
				FlashConnect.trace("limit has been reached, currentOffset: " + this.offset);
				this.offset += 1000;
				this.addFacet(this.tempNewFacet, offset);
			}else {
				this.offset = 0;	//reset!
				FlashConnect.trace("limit has not been reached");
				if (parentFacet == null) {	//if the new facet is the rootFacet (and therefore the first node in the graph)
					this.setIsAvailable(listOfElements, true);
				}else {
					//this.propagate(parentFacet);	//not the best idea, because it is not only propagated to the newFacet but to all childFacets of this parentFacet!
				}
				
				trace("addFacet_result durch");
				this.removeCurrentQuery();
				this.generateReturnChains(this.tempNewFacet);
				
				//get all not connected instances too!
				//comment for the evaluation 
				//if(parentFacet != null)	this.getNotConnectedElements(this.tempNewFacet);	//only if not the root
			}
		}
		
		override protected function executeQuery(_query:String, _returnF:Function, _object:Object = null):void {
			
			var _aQuery:SPARQLQuery = new SPARQLQuery(this.host);
			//_aQuery = this.addAuthHeader(_aQuery) as SPARQLQuery;
			_aQuery.method = this.method;
			_aQuery.resultFormat = this.resultFormat;
			_aQuery.defaultGraphURI = this.basicGraph;
			if (_object != null) {
				_aQuery.obj = _object;
			}
			//_aQuery.query = this.prefixes + selectQuery + where;
			_aQuery.query = this.prefixes + _query;
			//_aQuery.phpSessionId = this.phpSessionId;
			_aQuery.addEventListener(ResultEvent.RESULT, _returnF);
			_aQuery.addEventListener(FaultEvent.FAULT, this.faultReturn);
			_aQuery.execute();
		}
		
		private function addAuthHeader(service:HTTPService):HTTPService {
				trace("addAuthHeader");
				var encoder:Base64Encoder = new Base64Encoder();
				encoder.encode("PhilippHeim:start123");
				
				service.headers = { Authorization:"Basic " + encoder.toString() }; 
				//service.send();
				return service;
				//return service;
		}

		
	}
	
}