/**
 * Copyright (C) 2009 Philipp Heim and Timo Stegemann (email to: heim.philipp@googlemail.com)
 * 
 * This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License along with this program; if not, see <http://www.gnu.org/licenses/>.
 */ 

package connection 
{
	import graphElements.Chain;
	import graphElements.ElementClass;
	import graphElements.Facet;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.events.FaultEvent;
	
	public class MirroringConnection_Knoodl extends MirroringConnection
	{
		
		public function MirroringConnection_Knoodl(_host:String, _basicGraph:String = "", _phpSessionId:String = "") {
			super(_host, _basicGraph, _phpSessionId);
			this.prefixes = 
			"PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#> " +
			"PREFIX owl: <http://www.w3.org/2002/07/owl#> " +
			"PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#> ";
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
			
			//var strQuery:String = 'SELECT DISTINCT ?a ?b ?c ' +
			//'WHERE { ?a ?b ?c }';
			
			var strQuery:String = 'SELECT DISTINCT ?category ?label ' +
			//'COUNT(DISTINCT ?category) AS ?numOfInstances ' + 
			'WHERE { ' +
					' ?category rdf:type owl:Class . ' +//} UNION {?category rdf:type rdfs:Class . } . ' +
					' ?category bif:contains "' + _concept + '" .  ' +
					' OPTIONAL { ' +
						' ?category rdf:ID ?label . ' +
					' } ' +
			         //'?category rdfs:label ?label .  ' +
					'FILTER (regex(?category, "^' + _concept + '", "i")) ' +
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
			trace("getElementClasses_Result");
			var aSPARQLParser:SPARQLResultParser = new SPARQLResultParser();
			trace("shit"+e.toString());
			if (e == null) trace("shit");
			aSPARQLParser.parse(XML(e.result));
			trace("shit");
			var arrResult:Array = aSPARQLParser.getResults;
			var returnArray:Array = new Array();
			var elemClass:ElementClass;
			trace("arrResult.length: "+arrResult.length);
			for (var key:String in arrResult)
			{				
				//elemClass = new ElementClass(arrResult[key]["?category"].getLabel, arrResult[key]["?label"].getLabel);
				var label:String = "none";
				if (arrResult[key].hasOwnProperty("?label")) {
					label = arrResult[key]["?label"].getLabel;
				}else {
					label = arrResult[key]["?category"].getLocalname;
				}
				elemClass = new ElementClass(arrResult[key]["?category"].getLabel, label);
				//elemClass.numberOfObjectInstances = arrResult[key]["?numOfInstances"].getLabel;
				
				returnArray.push(elemClass);
			}
			var chain:Chain = new Chain(tempEClassesFacet.chainId, null, null, 100);
			chain.elements = returnArray;
			
			this.removeCurrentQuery();
			onResultGetElementClasses(returnArray);		
		}
	}
	
}