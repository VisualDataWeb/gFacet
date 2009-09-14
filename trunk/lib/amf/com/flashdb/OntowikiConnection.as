package com.flashdb 
{
	import com.flashdb.Facet;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.events.FaultEvent;
	
	/**
	 * ...
	 * @author Philipp Heim
	 */
	public class OntowikiConnection extends DirectConnection
	{
		
		public function OntowikiConnection(_host:String, _basicGraph:String = "", _phpSessionId:String = "") {
			super(_host, _phpSessionId, _basicGraph);
		}
		
		override public function getElementClasses(_concept:String = null, _facet:Facet = null):void {
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
			//aQuery.query = this.prefixes + 'SELECT * WHERE {?s ?p ?o}';	
			
			//searching for classes by providing keyword of class (concept)
			aQuery.query = 'SELECT DISTINCT ?class  ?classLabel ' +
			//'COUNT(?instance) AS ?numOfInstances  ' + 
			'WHERE { ' +
					'{ ?class rdf:type owl:Class . } UNION {?class rdf:type rdfs:Class . } . ' +
					//'?instance  rdf:type ?class .  ' + 
					 '?class rdfs:label ?classLabel .  ' +			         
					 '?classLabel bif:contains "' + _concept + '" .  ' +
					 'FILTER (lang(?classLabel) = "en") ' +
			'} ';
			
			/*
			//searching for classes by providing keyword of instance
			aQuery.query = 'SELECT DISTINCT ?class  ?classLabel ' +
			'COUNT(?instance) AS ?numOfInstances  ' + 
			'WHERE {  ?instance  rdf:type ?class .  ' + 
					 '?class rdfs:label ?classLabel .  ' +
			         '?instance rdfs:label ?instanceLabel .  ' +
					 '?instanceLabel bif:contains "' + _concept + '" .  ' +
					 'FILTER (lang(?classLabel) = "en") ' +
			'} ';
			*/
			
			//this.prefixes +
			//'SELECT DISTINCT ?category ?label WHERE {?subject skos:subject ?category . ?category rdfs:label ?label . FILTER (lang(?label) = "en")}  LIMIT 2000';
			//'SELECT DISTINCT ?category ?label WHERE {  ?subject skos:subject ?category .  ?category rdfs:label ?label .  ?label bif:contains "' + _concept +'" } LIMIT 20';
			/*'SELECT DISTINCT ?category ?label ' +
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
			
			aQuery.query += 'LIMIT ' + _facet.limit + ' OFFSET ' + _facet.offset;*/
			aQuery.query += 'LIMIT 10';
			aQuery.phpSessionId = this.phpSessionId;
			aQuery.addEventListener(ResultEvent.RESULT, getElementClasses_Result);
			aQuery.addEventListener(FaultEvent.FAULT, getElementClasses_Fault);
			aQuery.execute();
						
			//return null;
		}
	}
	
}