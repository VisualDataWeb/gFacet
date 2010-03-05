package connection 
{
	import connection.DirectConnection;
	import extenders.HeaderFactory;
	import graphElements.Chain;
	import graphElements.Element;
	import graphElements.ListItem;
	import graphElements.ElementClass;
	import graphElements.Facet;
	import de.polygonal.ds.HashMap;
	import de.polygonal.ds.Iterator;
	import flash.xml.XMLDocument;
	import flash.xml.XMLNode;
	import graphElements.Property;
	import mx.collections.ArrayCollection;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.events.FaultEvent;
	import mx.utils.ObjectUtil;
	import org.flashdevelop.utils.FlashConnect;
	import mx.collections.Sort;
	import mx.collections.SortField;
	import mx.rpc.http.HTTPService;
	import mx.rpc.xml.SimpleXMLEncoder;
	
	/**
	 * ...
	 * @author Timo Stegemann
	 */
	public class ConfigurableConnection extends MirroringConnection
	{		
		private var returnChains:Array = new Array();
		
		public function ConfigurableConnection(_host:String = "", _basicGraph:String = "", _phpSessionId:String = "") {
			super(_host, _basicGraph, _phpSessionId);
			trace("--- init configuarable connection");
		}
		
		override public function reset():void {
			super.reset();
			
			fastEC = false;
			fastPT = false;
			returnChains = new Array();
			tempConcept = null;
			tempEClassesFacet = null;
			tempElementClass = null;
		}
		
		override public function sendCommand(_command:String, _onResult:Function, _args:Array = null):void {
			trace("sendCommand" + _command);
			this.addCurrentQuery();
			
			switch(_command) {
				case "getDistinctPropertyTypes":

					onResultGetDistinctPropertyTypes = _onResult;
					this.getDistinctPropertyTypes(_args[0]);
					break;
				case "getFacetedChains":
					
					onResultGetFacetedChains = _onResult;
					this.getFacetedChains(_args[0]);
					break;
				case "getElementClasses":
					onResultGetElementClasses = _onResult;
					
					this.getElementClasses(_args[0], _args[1]);
					break;
					
					
				case "addFacet":
					
					this.addFacet(_args[0]);
					break;	
				case "removeFacet":
					
					this.removeFacet(_args[0]);
					break;
				case "getFacetedChain":
					
					this.getFacetedChain(_args[0]);
					this.addFacet(_args[0]);
					break;
				case "setResultSet":
					
					this.setResultSet(_args[0]);
					break;
				case "addSelection":
					
					this.addSelectionWithAnd(_args[0], _args[1]);
					break;
				case "removeSelection":
					
					this.removeSelection(_args[0], _args[1]);
					break;
				case "paging":
					
					this.page(_args[0]);
					break;
				case "sorting":
					
					this.sort(_args[0]);
					break;
					
				case "deselectAll":
					this.deselectAll();
					break;
				default:
					//
			}
		}
		
		/**
		 * 
		 * @param	_elementId	the id of the resently selected element
		 * @param	_facet		the facet where the selection happened
		 */
		override public function addSelectionWithAnd(_elementId:String, _facet:Facet):void {
			FlashConnect.trace("in addSelectionWithAnd! "+_elementId+" , "+_facet.id);
			//FlashConnect.trace(" _facet.out: " + _facet.outgoingFacets.length + " in: " + _facet.incomingFacet);
			
			this.setIsValid(this.elementLists.find(_facet.chainId), false);	//initially set all invalid!
			for each(var eId:String in _facet.selectedElementIds) {
				var selectedElement:Element = this.getElement(_facet.chainId, _elementId);
				selectedElement.isSelected = true;
				selectedElement.isValid = true;
			}
			
			this.recursiveFiltering(_facet);
			
			this.propagate(app().getResultSetFacet());	//should be the root (resultSet)!
		}
		
		/**
		 * starting from the delivered facet, we go up to the resultSet and filter it.
		 * @param	_facet
		 */
		private function recursiveFiltering(_childFacet:Facet):void {
			FlashConnect.trace("recursiveFiltering "+_childFacet.id);
			var parentFacet:Facet = _childFacet.getParentFacet();
			if (parentFacet != null) {	//_childFacet is not the resultSet! 
				FlashConnect.trace("parentFacet: "+parentFacet.id);
				var parentElements:HashMap = this.elementLists.find(parentFacet.chainId);
				this.setIsValid(parentElements, false);	//initially set all invalid!
				
				var allChildFacets:Array = parentFacet.getChildFacets();
				FlashConnect.trace("number of childFacets: " + allChildFacets.length);
				var anyFilter:Boolean = false;	//whether there is at least one filter left
				
				var pIter:Iterator = parentElements.getIterator();
				while (pIter.hasNext()) {
					//FlashConnect.trace("test");
					var pE:Element = pIter.next() as Element;
					pE.isValid = true;	//initally true until we don't find a valid connection
					
					for each(var childF:Facet in allChildFacets) {
						//FlashConnect.trace("test1");
						var validEs:Array = this.getAllValids(childF);
						if (validEs.length > 0) {	//if it is filtered already
							anyFilter = true;	//at least one filter!
							//check for at least one valid connection
							var validConExists:Boolean = this.hasValidConnection(childF, parentFacet, pE);
							if (!validConExists) {	//if not exist!
								pE.isValid = false;
								//FlashConnect.trace("valid con exists not for "+pE.id+", child: "+childF.id);
								break;
							}else {
								//FlashConnect.trace("valid con exists for "+pE.id+", child: "+childF.id);
							}
						}else {
							//FlashConnect.trace("== 0, " + childF.id);
						}
					}
					
					
				}
				
				if (!anyFilter) {	//no filter at all
					this.setIsValid(parentElements, false);
				}
				
				this.recursiveFiltering(parentFacet);
			}else {	//there is no parent!
				//workaround
				if (_childFacet.selectedElementIds.length > 0) {
					var elements:HashMap = this.elementLists.find(_childFacet.chainId);
					this.setIsValid(elements, false);
					for each(var e:Element in elements) {
						if (e.isSelected) {
							e.isValid = true;
						}
					}
				}
				
				
				FlashConnect.trace("parentFacet = null");
			}
		}
		
		private function hasValidConnection(_childF:Facet, _parentF:Facet, _pE:Element):Boolean {
			//child is filtered!
			//FlashConnect.trace("testx");
			var relations:HashMap;
			if ((_childF.incomingFacet != null)&&(_parentF.id == _childF.incomingFacet.id)) {	//if it is the incomingFacet
				relations = this.relationLists.find(_childF.chainId);	//we have to take the relations from the childFacet!
			}else {
				relations = this.relationLists.find(_parentF.chainId);	//we have to take the relations from the parentFacet!
			}
			var relatedElements:HashMap = relations.find(_pE.id);	//related elements in childFacet
			//FlashConnect.trace("testy");
			if (relatedElements != null) {
				var iter:Iterator = relatedElements.getIterator();
				while (iter.hasNext()) {
					//FlashConnect.trace("testz");
					var cE:Element = iter.next();
					if (cE.isValid) {
						return true;
					}
				}
			}
			
			return false;
		}
		
		override protected function setIsValid(_list:HashMap, _setValid:Boolean = false):void {
			FlashConnect.trace("setValidity "+_list.size+", "+_setValid);
			var iter:Iterator = _list.getIterator();
			while (iter.hasNext()) {
				(iter.next() as Element).isValid = _setValid;	//what about status = "invalid";
			}
		}
		
		
		//braucht man die Funktion noch?
		override protected function setIsAvailable(_list:HashMap, _setAvailable:Boolean = false):void {
			if (_list != null) {
				FlashConnect.trace("setAllAvailable "+_list.size+", "+_setAvailable);
				var iter:Iterator = _list.getIterator();
				while (iter.hasNext()) {
					(iter.next() as Element).isAvailable = _setAvailable;	//what about status = "invalid";
				}
			}
		}
		
		override protected function setIsActive(_list:HashMap, _setActive:Boolean = false):void {
			if (_list != null) {
				FlashConnect.trace("setAllActive "+_list.size+", "+_setActive);
				var iter:Iterator = _list.getIterator();
				while (iter.hasNext()) {
					(iter.next() as Element).isActive = _setActive;	//what about status = "invalid";
				}
			}
		}
		
		private function getAllValids(_facet:Facet):Array {
			var ar:Array = new Array();
			if(this.elementLists.containsKey(_facet.chainId)) {
				var elements:HashMap = this.elementLists.find(_facet.chainId);
				var iter:Iterator = elements.getIterator();
				while (iter.hasNext()) {
					var e:Element = iter.next() as Element;
					
					if (e.isValid) {
						//trace("e.isValid: " + e.isValid);
						ar.push(e);
					}
				}
			}else {
				trace("error, no list exists!");
			}
			return ar;
		}
		
		private function getAllSelected(_facet:Facet):Array {
			var ar:Array = new Array();
			if(this.elementLists.containsKey(_facet.chainId)) {
				var elements:HashMap = this.elementLists.find(_facet.chainId);
				var iter:Iterator = elements.getIterator();
				while (iter.hasNext()) {
					var e:Element = iter.next() as Element;
					
					if (e.isSelected) {
						//trace("e.isSelected: " + e.isSelected);
						e.isValid = true;
						ar.push(e);
					}
				}
			}else {
				trace("error, no list exists!");
			}
			return ar;
		}
		
		//----------------- END: ADD SELECTION --------------------------
		//----------------- START: REMOVE SELECTION --------------------------
		
		/**
		 * 
		 * @param	_elementId	the id of the resently deselected element
		 * @param	_facet		the facet this happened
		 */
		override public function removeSelection(_elementId:String, _facet:Facet):void {
			FlashConnect.trace("in removeSelection! "+_elementId);
			
			var deselectedElement:Element = this.getElement(_facet.chainId, _elementId);
			FlashConnect.trace("has been valid: " + deselectedElement.isValid);
			deselectedElement.isSelected = false;
			deselectedElement.isValid = false;
			
			//search for deepest child!
			var deepest:Facet = this.getDeepestChild(_facet);
		
			FlashConnect.trace("deepest: " + deepest.id);
			this.recursiveFiltering(deepest);
			
			this.propagate(app().getResultSetFacet());	//should be the root (resultSet)!
		}
		
		private function getDeepestChild(_start:Facet):Facet {
			return recursiveGetDeepestChild(_start);
		}
		
		private function recursiveGetDeepestChild(_start:Facet):Facet {
			
			var childFacets:Array = _start.getChildFacets();
			
			var deepestChild:Facet = _start;
			for each(var f:Facet in childFacets) {
				var tempChild:Facet = this.recursiveGetDeepestChild(f);
				if (deepestChild.levelInTheTree < tempChild.levelInTheTree) {
					deepestChild = tempChild;	//new deepest child
				}
			}
			return deepestChild;
			
			
		}
		
		//----------------- END: REMOVE SELECTION --------------------------
		//----------------- START: ADD FACET --------------------------
		override protected function addFacet(_newFacet:Facet, _offset:int = 0):void {
			trace("addFacet "+_newFacet.id);
			this.tempNewFacet = _newFacet;
			//first we have to get all the elements of the choosen elementClass! 
			//TODO: build the query! And let the result be returned to addFacet_Result!
			var query:String = "SELECT DISTINCT ";
			var parent:Facet = _newFacet.incomingFacet;
			
			if (parent != null) {	//if _newFacet is not root
				query += "?parent ?label_parent ?comment_parent ";
			}
			query += "?validChild ?label_child ?comment_child "; /* ?allChild*/
			query += "WHERE { ";
			if (parent != null) {	//if _newFacet is not root
				query += "?parent skos:subject <" + parent.elementClassId + "> . ";
				query += "?parent <"+_newFacet.property.id+"> ?validChild. ";	//this number of validChild is restricted to only those that are related to the parent!
				query += "?parent rdfs:label ?label_parent. FILTER (lang(?label_parent) = 'en' ) ";
				query += "OPTIONAL {  ";
				query += "?parent rdfs:comment ?comment_parent FILTER (lang(?comment_parent) = 'en' )";
				query += "}";
			}
			query += "?validChild skos:subject <" + _newFacet.elementClassId + "> . ";
			/*query += "?allChild skos:subject <" + _newFacet.elementClassId + "> . ";*/
			query += "?validChild rdfs:label ?label_child. FILTER (lang(?label_child) = 'en' ) ";
			query += "OPTIONAL {  ";
			query += "?validChild rdfs:comment ?comment_child FILTER (lang(?comment_child) = 'en' )";
			query += "}} LIMIT 1000 OFFSET "+_offset;
			
			this.executeQuery(query, this.addFacet_Result);	
		}
		
		/**
		 * saves all the new elements and all the new relations to the parentElements
		 * @param	e
		 */
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
				FlashConnect.trace("no result in addFacet!");
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
			
			/*if (arrResult.length == 1000) {	//if the limit has been reached!
				FlashConnect.trace("limit has been reached, currentOffset: " + this.offset);
				this.offset += 1000;
				this.addFacet(this.tempNewFacet, offset);
			}else {*/
				this.offset = 0;	//reset!
				trace("limit has not been reached");
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
			//}
		}
		
		/**
		 * Is executed in the background!
		 * @param	_newFacet
		 */
		private function getNotConnectedElements(_newFacet:Facet):void {
			FlashConnect.trace("get not connected elements");
			var query:String = "SELECT DISTINCT ";
			var parent:Facet = _newFacet.incomingFacet;
			
			query += "?validChild ?label_child ?comment_child "; /* ?allChild*/
			query += "WHERE { ";
			if (parent != null) {	//if _newFacet is not root
				query += "?parent skos:subject <" + parent.elementClassId + "> . ";		
			}
			query += "?validChild skos:subject <" + _newFacet.elementClassId + "> . ";
			query += "?validChild rdfs:label ?label_child. FILTER (lang(?label_child) = 'en' ) ";
			/*if (parent != null) {
				query += "OPTIONAL { ?parent <" + _newFacet.property.id + "> ?validChild }";	//only those that are not bound to the parent!! //the direction is always correct for a new Facet!!
				query += "FILTER (!bound(?validChild)) ";
			}*/
			query += "OPTIONAL {  ";
			query += "?validChild rdfs:comment ?comment_child FILTER (lang(?comment_child) = 'en' )";
			query += "} ";
			query += "} ";
			
			//this.tempTempNewFacetCId = this.tempNewFacet.chainId;
			this.executeQuery(query, this.getNotConnectedElements_Result, this.tempNewFacet.chainId);	
		}
		
		//private var tempTempNewFacetCId:String;	//funktioniert nicht für mehrere facetten gleichzeitig!!!!! ändern!
		
		override public function getNotConnectedElements_Result(e:ResultEvent):void {
			var sq:SPARQLQuery = e.target as SPARQLQuery;
			
			if (sq.obj != null) {
				var facetChainId:String = sq.obj as String;
				FlashConnect.trace("facetChainId: "+facetChainId);
				var aSPARQLParser:SPARQLResultParser = new SPARQLResultParser();
				aSPARQLParser.parse(XML(e.result));
				var arrResult:Array = aSPARQLParser.getResults;
				
				if (arrResult.length < 1) {
					FlashConnect.trace("no result in getNotConnectedElements!");
					//onResultGetFacetedChains(new Array(new Chain(this.rootFacet.chainId,null,new Array(),0)));
				}else {
					var count:int = arrResult.length;
					FlashConnect.trace("count: " + count);
					
					var listOfElements:HashMap = this.elementLists.find(facetChainId);
					
					for (var idxResult:String in arrResult) {
						var childId:String;
						var childLabel:String;
						var childComment:String;
						if (arrResult[idxResult].hasOwnProperty("?validChild")) {
							childId = arrResult[idxResult]["?validChild"].getURI;
							
							if (arrResult[idxResult].hasOwnProperty("?label_child")) {
								childLabel = arrResult[idxResult]["?label_child"].getLabel;
							}
							if (arrResult[idxResult].hasOwnProperty("?comment_child")) {
								childComment = arrResult[idxResult]["?comment_child"].getLabel;
							}
							if (!listOfElements.containsKey(childId)) {
								var childElement:Element = new Element(childId, childLabel, childComment); //null, 0, tempNewFacet.property.objectClass);
								childElement.isActive = false;	//IMPORTANT!
								listOfElements.insert(childElement.id, childElement);
							}
						}
					}
					
					this.elementLists.insert(facetChainId, listOfElements);
				}
			}else {
				FlashConnect.trace("no facetChainId!");
			}
		}
		
		//----------------- END: ADD FACET --------------------------
		//----------------- START: REMOVE FACET --------------------------
		
		private function removeFacet(_lItem:ListItem):void {
			FlashConnect.trace("in removeFacet!");
			//TODO
			//deselect selections
			var selectedIds:Array = _lItem.facet.selectedElementIds;
			//FlashConnect.trace("selectedElements: " + selectedIds.length);
			for each(var eId:String in selectedIds) {
				var elements:HashMap = this.elementLists.find(_lItem.facet.chainId);
				var e:Element = elements.find(eId);
				_lItem.selectedElementsChanged(e);	//deselect element
			}
			
			this.elementLists.remove(_lItem.facet.chainId);
			FlashConnect.trace("test");
			var pFacet:Facet = _lItem.facet.getParentFacet();
			if ((pFacet == null) || ((_lItem.facet.incomingFacet != null) && (pFacet.id == _lItem.facet.incomingFacet.id))) {
				this.relationLists.remove(_lItem.facet.chainId);
			}else {
				FlashConnect.trace("remove pFacet");
				this.relationLists.remove(pFacet.chainId);
			}
			
			trace("remove facet durch");
			this.removeCurrentQuery();
			
			//this.generateReturnChains();
		}
		
		//----------------- END: REMOVE FACET --------------------------
		//----------------- START: SET RESULTSET --------------------------
		
		private function setResultSet(_newResultSet:Facet):void {
			FlashConnect.trace("in setResultSet!"+_newResultSet.id);
			//ask for all instances of the current resultSet! // TODO: check whether already all instances are available on client side!
			
			//TODO: activate all instances of _newResultSet
			var elementsRS:HashMap = this.elementLists.find(_newResultSet.chainId);
			this.setIsActive(elementsRS, true);
			//TODO: für alle childFacetten, erst alle deaktivieren und dann die aktivieren, die eine verbindung zu aktivem parent haben!
			this.recursiveSetRS(_newResultSet);
			
			this.propagate(_newResultSet);
			FlashConnect.trace("in setResultSet durch!");
			
			//this.removeCurrentQuery();
			//this.generateReturnChains();
		}
		
		override public function recursiveSetRS(_parent:Facet):void {
			var childFacets:Array = _parent.getChildFacets();
			for each(var f:Facet in childFacets) {
				this.setIsActive(this.elementLists.find(f.chainId), false);	//set initial all active=false
				var relations:HashMap;
				//FlashConnect.trace("test00 "+f.id);
				if ((f.incomingFacet != null)&&(f.incomingFacet.id == _parent.id)) {	//if incoming is parent or null!
					relations = this.relationLists.find(f.chainId);
				}else {
					relations = this.relationLists.find(_parent.chainId);
					//FlashConnect.trace("test01"+relations);
				}
				//FlashConnect.trace("test0");
				var parentElements:HashMap = this.elementLists.find(_parent.chainId);
				var iter:Iterator = parentElements.getIterator();
				//FlashConnect.trace("test05");
				while (iter.hasNext()) {
					var pE:Element = iter.next();
					//FlashConnect.trace("test06");
					if (pE.isActive && relations.containsKey(pE.id)) {
						//FlashConnect.trace("test07"+pE.id+", "+relations.size);
						var connected:HashMap = relations.find(pE.id);
						var iter2:Iterator = connected.getIterator();
						while (iter2.hasNext()) {
							var e:Element = iter2.next();
							
							//FlashConnect.trace("test09");
							e.isActive = true;	//set all elements that are connected to active elements in the parent facet acitve too
							//FlashConnect.trace("setActive: " + e.id);
							
						}
						
					}
					
				}
				//FlashConnect.trace("test1");
				this.recursiveSetRS(f);
				//FlashConnect.trace("test2");
			}
		}
		
		private function deselectAll():void {
			var iter:Iterator = this.app().listItems.getIterator();
			while (iter.hasNext()) {
				var lItem:ListItem = iter.next();
				var selectedIds:Array = lItem.facet.selectedElementIds;
				for each(var eId:String in selectedIds) {
					var elements:HashMap = this.elementLists.find(lItem.facet.chainId);
					var e:Element = elements.find(eId);
					lItem.selectedElementsChanged(e);	//deselect element
				}
			}
			trace("deselect all durch");
			this.removeCurrentQuery();
		}
		
		
		//----------------- END: SET RESULTSET --------------------------
		//----------------- START: PAGING --------------------------
		
		private function page(_facet:Facet):void {
			
			
			var offset:int = _facet.offset;
			var limit:int = _facet.limit;
			
			var c2:Chain = this.createChain(_facet.chainId, _facet.returnOnlyValids, limit, offset, _facet.orderedBy, _facet.descending);
			
			var lItem:ListItem = this.app().listItems.find(_facet.chainId);
			lItem.setChain(c2);
			
			FlashConnect.trace("in page durch!");
			this.removeCurrentQuery();
			
			//this.generateReturnChains(_facet);
		}
		
		//----------------- END: PAGING --------------------------
		//----------------- START: SORTING --------------------------
		
		private function sort(_facet:Facet):void {
			FlashConnect.trace("in sort durch!");
			this.removeCurrentQuery();
			this.generateReturnChains(_facet);
		}
		
		//----------------- END: SORTING --------------------------
		//----------------- START: GETFACETEDCHAIN --------------------------
		
		private function getFacetedChain(_facet:Facet):void {
			FlashConnect.trace("get faceted chain durch!");
			this.removeCurrentQuery();
			this.generateReturnChains(_facet);
		}
		
		//----------------- END: GETFACETEDCHAIN --------------------------
		//----------------- START: PROPAGATION --------------------------
		
		/**
		 * starting from the delivered facet (mostly the current resultSet) we propagate the validity through the tree of facets
		 * @param	_startFacet
		 */
		private function propagate(_startFacet:Facet):void {
			FlashConnect.trace("in Propagation "+_startFacet.id);
			
			//TODO: check relations to the facet with a higher levelInTheTree as the delivered one!
			
			/*if (true) {	//if no valids are in the startFacet -> nothing is selected at all!
				FlashConnect.trace("set all available: "+_startFacet.id);
				this.setIsAvailable(this.elementLists.find(_startFacet.chainId), true);	//set all elements of the rootFacet available!
			}*/
			if (true) {
				this.recursivePropagationWithAnd(null, _startFacet);
			}else {
				this.recursivePropagation(null, _startFacet);	//initial
			}
			
			trace("propagate durch!");
			this.removeCurrentQuery();
			this.generateReturnChains();
		}
		
		private function recursivePropagationWithAnd(_parentFacet:Facet, _childFacet:Facet):void {
			FlashConnect.trace("recursivePropagationWithAnd, _childF: " + _childFacet.id);
			if (_parentFacet != null) {	//if not the initial loop
				
				var parentChainId:String = _parentFacet.chainId;
				//reset _childFacet!
				var childChainId:String = _childFacet.chainId;
				var childElements:HashMap = this.elementLists.find(childChainId);
				this.setIsAvailable(childElements, false);
				
				//hier stimmt was nicht mit der reihenfolge!!?? parent, child ??
				
				//TODO availables berechnen!
				var relations:HashMap;
				if ((_childFacet.incomingFacet != null)&&(_childFacet.incomingFacet.id == _parentFacet.id)) {	//if incoming is parent!
					relations = this.relationLists.find(childChainId);
				}else {
					relations = this.relationLists.find(parentChainId);
				}
				var parentElements:HashMap = this.elementLists.find(parentChainId);
				
				var validChilds:Array = this.getAllValids(_childFacet);
				
				var iter:Iterator = childElements.getIterator();
				while (iter.hasNext()) {	//go though all childElements
					var cE:Element = iter.next();
					if (relations.containsKey(cE.id)) {
						var tempRels:HashMap = relations.find(cE.id);	//get connected parents
						var iter2:Iterator = tempRels.getIterator();
						var match:Boolean = false;	//whether a match with two valids exist
						while (iter2.hasNext()) {	//find all related elements in the parentFacet
							var pE:Element = iter2.next();
							
							if (validChilds.length == 0) {
								if (pE.isActive && (pE.isAvailable || pE.isValid)) {
									//if (pE.isAvailable) {
										cE.isAvailable = true;
									//}
									/*if (pE.isValid) {
										cE.isValid = true;
										match = true;
										trace("cE is valid: " + cE.id);
									}*/
								}
							}else {	//child has been filtered
								if (pE.isValid && cE.isValid) {
									match = true;
								}
							}
						}
						if (!match) {
							cE.isValid = false;	//IMPORTANT!
						}
					}
				}
				
			}else {
				FlashConnect.trace("parentFacet == null");
				var valids:Array = this.getAllValids(_childFacet);
				var selected:Array = this.getAllSelected(_childFacet);
				
				
				//FlashConnect.trace("ttest");
				if ((valids.length > 0) || (selected.length > 0)) {	//TODO
					trace("ttest2");
					this.setIsAvailable(this.elementLists.find(_childFacet.chainId), false);
				}else {
					this.setIsAvailable(this.elementLists.find(_childFacet.chainId), true);
				}
			}
			//FlashConnect.trace(" facet.out: " + _childFacet.outgoingFacets.length + " in: " + _childFacet.incomingFacet);
			
			var facets:Array = _childFacet.getChildFacets();
			//var facets:Array = _childFacet.outgoingFacets.concat();	//just to make a copy!
			//if (_childFacet.incomingFacet != null) facets.push(_childFacet.incomingFacet);
			for each(var f:Facet in facets) {
				//if (f == null) {
				//	FlashConnect.trace("f is null!!");
				//}
				//if ((_parentFacet == null) || (f.id != _parentFacet.id)) {	//if it is not the parent! or null (for the resultSet)
					this.recursivePropagationWithAnd(_childFacet, f);	//the old childFacet is now the parent!
				//}
			}
		}
		
		//----------------- END: PROPAGATION --------------------------
		
		
		/**
		 * generates the chains each having 10 elements in a certain order that will be returned to the interface
		 */
		override protected function generateReturnChains(_facet:Facet = null):void {
			//this.removeCurrentQuery();
			this.returnChains = new Array();	//reset!
			trace("generateReturnChains! ");
			
			if (_facet == null) {	//send all!!
				FlashConnect.trace("send all");
				var keySet:Array = this.elementLists.getKeySet();
				for each(var key:String in keySet){
					var c1:Chain = this.createChain(key, true, 10, 0, null, false);	//TODO aus facette holen!!
					returnChains.push(c1);
				}
				
			}else {	//only one
				var offset:int = _facet.offset;
				var limit:int = _facet.limit;
				
				var c2:Chain = this.createChain(_facet.chainId, _facet.returnOnlyValids, limit, offset, _facet.orderedBy, _facet.descending);
				
				returnChains.push(c2);
			}
			
			app().getFacetedChains_Result(this.returnChains);
			trace("chains returned");
		}
		
		private function createChain(_chainId:String, _onlyValids:Boolean, _limit:int, _offset:int, _orderingProp:Property, _desc:Boolean):Chain {
			FlashConnect.trace("createChain: " + _chainId + " onlyValids: " + _onlyValids + ", offset: " + _offset );
			if(_orderingProp != null) FlashConnect.trace(", order: " + _orderingProp.label+", desc: "+_desc);
			var ar1:ArrayCollection = new ArrayCollection();
			var ar2:Array = new Array();
			var elements:HashMap = (this.elementLists.find(_chainId) as HashMap);
			if (_onlyValids) {
				if (elements != null) {
					var iter:Iterator = elements.getIterator();
					while (iter.hasNext()) {	//build array of all valids
						var e:Element = iter.next() as Element;
						if ((e.isActive) && (e.isAvailable || e.isValid || e.isSelected)) {	//former e.isValid
							//FlashConnect.trace(_chainId + ", e: "+e.id);
							//add to validElements
							ar1.addItem(e);
						}
					}
				}else {
					trace("Error: No elements found for chain "+_chainId);
				}
				
			}else {
				ar1 = new ArrayCollection(elements.toArray());	//all //TODO: Frage: auch inactive elemente??
			}
			
			if (ar1.length > 0) {	//if elements are left
				//TODO: sorting!!
				var dataSortField:SortField = new SortField();
				dataSortField.caseInsensitive = true;
				var mySort:Sort = new Sort();
				
				if (_orderingProp != null) {
					FlashConnect.trace("sorting " + _orderingProp.label);
					dataSortField.name = _orderingProp.label;
					if (dataSortField.name == "status") {
						dataSortField.compareFunction = myCompareFunc;
					}
					dataSortField.descending = _desc;
				}else {
					FlashConnect.trace("default sorting");
					//default sort
					dataSortField.name = "title";
				}
				mySort.fields = [dataSortField];
				ar1.sort = mySort;
				ar1.refresh();
				
				//FlashConnect.trace(ar1.getItemAt(0).title);
				
				ar2 = ar1.toArray(); //ar1.toArray().slice(_offset, _offset + _limit);	//no offset or limit!!!
				FlashConnect.trace("ar2[0]: " + ar2[0].title);
			}else {
				FlashConnect.trace("no elements left!");
			}
			
			return new Chain(_chainId, null, ar2, ar1.length);
		}
		
		override public function myCompareFunc(itemA:Element, itemB:Element):int {
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
		}
		
		override protected function getElement(_chainId:String, _eId:String):Element {
			if(this.elementLists.containsKey(_chainId)) {
				var elements:HashMap = this.elementLists.find(_chainId);
				if (elements.containsKey(_eId)) {
					return elements.find(_eId) as Element;
				}
			}
			return null;	//if the element does not exist for the delivered facet
		}
		
		private var tempElementClass:ElementClass;
		private var fastPT:Boolean = false;
		//problem : ?numOfInstances only works correctly for first facet. because in the beginning display all the intances (no filtering).
		//		    All the child facet is filtered regarding the instances of the parent facet, 
		//          but ?numOfInstances gives value as the facet is not filtered.
		override public function getDistinctPropertyTypes(_elementClass:ElementClass = null):void {
			
			
		    tempElementClass = _elementClass;

			var strQuery:String = "SELECT DISTINCT ?type ?class ?labelOfType ?labelOfClass COUNT(DISTINCT ?o) AS ?numOfInstances" +
				  " WHERE { " +
				  " ?s skos:subject <" + _elementClass.id + "> ." +
				  " ?s ?type ?o ." +
				  " ?o skos:subject ?class ." +
				  //" ?o rdfs:label ?oLabel ." +
				  " ?type rdfs:label ?labelOfType ." +
				  " ?class rdfs:label ?labelOfClass " +
				  //'FILTER (lang(?labelOfClass) = "en" && lang(?labelOfType) = "en")' +
				  'FILTER (lang(?labelOfClass) = "en")' +
				  //'FILTER (lang(?oLabel) = "en")' +
				  "} ORDER BY DESC(?numOfInstances) ?type ?class LIMIT 40";
			
				  
			//fast
			var strQuery2:String = "SELECT DISTINCT ?type ?class ?labelOfType ?labelOfClass " +
				  " WHERE { " +
				  " ?s skos:subject <" + _elementClass.id + "> ." +
				  " ?s ?type ?o ." +
				  " ?o skos:subject ?class ." +
				  //" ?o rdfs:label ?oLabel ." +
				  " ?type rdfs:label ?labelOfType ." +
				  " ?class rdfs:label ?labelOfClass " +
				  //'FILTER (lang(?labelOfClass) = "en" && lang(?labelOfType) = "en")' +
				  'FILTER (lang(?labelOfClass) = "en")' +
				  //'FILTER (lang(?oLabel) = "en")' +
				  "} ORDER BY DESC(?labelOfType)"; //?numOfInstances) ?type ?class LIMIT 20";
				  
			//=========================
			
			if (fastPT) {
				executeSparqlQuery(prefixes + strQuery2, null, getDistinctPropertyType_Result, getDistinctPropertyType_Fault);
			}else {
				executeSparqlQuery(prefixes + strQuery, null, getDistinctPropertyType_Result, getDistinctPropertyType_Fault);
			}
			
		}
		
		override protected function getDistinctPropertyType_Fault(e:FaultEvent):void{
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
		
		private var tempEClassesFacet:Facet = null;
		private var tempConcept:String = null;
		private var fastEC:Boolean = false;
		override public function getElementClasses(_concept:String = null, _facet:Facet = null):void {
			trace("getElementClasses");
			tempEClassesFacet = _facet;
			tempConcept = _concept;
			var pattern:RegExp;
			pattern = / /g;
			_concept = _concept.replace(pattern, " and ");
			
			var query:String = "";
			
			if (fastEC) {
				//fast
				query = this.prefixes + 'SELECT DISTINCT ?category ?label ' + 
				'WHERE { ?category rdf:type skos:Concept . ' + 
						 '?category rdfs:label ?label .  ' +
						 '?label bif:contains "' + _concept + '" .  ' +
						 'FILTER (lang(?label) = "en") ' +
				'} ';
			}else {
				query = this.prefixes + 'SELECT DISTINCT ?category ?label ' +
				'COUNT(?o) AS ?numOfInstances  ' + 
				'WHERE { ?category rdf:type skos:Concept . ' +  
						 '?o skos:subject ?category . ' +
						 '?category rdfs:label ?label .  ' +
						 '?label bif:contains "' + _concept + '" .  ' +
						 'FILTER (lang(?label) = "en") ' +
				'} ORDER BY DESC(?numOfInstances) LIMIT 30 ';	
			}
			
			executeSparqlQuery(query, null, getElementClasses_Result, getElementClasses_Fault);
			
		}
		
		override protected function executeQuery(query:String, result:Function, object:Object = null):void {
			
			var sources:ArrayCollection;
			
			if (object){
				sources = new ArrayCollection();
				sources.addItem(object);
			} else {
				sources = null;
			}
			executeSparqlQuery(prefixes + query, sources, result, faultReturn);
		}
		
		override public function faultReturn(e:FaultEvent):void{
			this.removeCurrentQuery();
			FlashConnect.trace("faultReturn!!! "+e.fault.faultString);
			//Logger.error("getFacetedChains : ", e.fault.faultString);
		}
		
	}

}