package graphElements 
{
	import de.polygonal.ds.HashMap;
	import flash.events.EventDispatcher;
	import mx.collections.ArrayCollection;
	/**
	 * ...
	 * @author Timo Stegemann
	 */
	public class GraphModel extends EventDispatcher
	{
		
		/*
		 * GraphModel soll einzelne FacetedGraphs und alle anderen Daten für den GraphController speichern
		 */
		public function GraphModel(singleton:SingletonEnforcer) {
			
		}
		
		public static function getInstance():GraphModel{
			if (GraphModel.instance == null){
				GraphModel.instance = new GraphModel(new SingletonEnforcer());
			}
			return GraphModel.instance;
		}
		
		private static var instance:GraphModel;
		
		private var _facetedGraphs:ArrayCollection = new ArrayCollection();
		
		public function getFacetedGraph(facet:Facet):FacetedGraph {
			for (var i:int = 0; i < _facetedGraphs.length; i++) {
				for (var j:int = 0; j < (_facetedGraphs.getItemAt(i) as FacetedGraph).facets.length; j++) {
					var facet2:Facet = (_facetedGraphs.getItemAt(i) as FacetedGraph).facets.getItemAt(j) as Facet;
					if (facet == facet2) {
						return _facetedGraphs.getItemAt(i) as FacetedGraph;
					}
				}
			}
			return null;
		}
		
		public var listItems:HashMap = new HashMap();
		public var resultSetFacet:Facet = null;

		public var _noPaging:Boolean = true; //flag
		
	}

}
class SingletonEnforcer{}