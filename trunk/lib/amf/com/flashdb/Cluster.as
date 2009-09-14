/**
* ...
* @author Philipp Heim
* @version 0.1
*/

package com.flashdb{
	// Cluster.as
	
	[RemoteClass(alias="com.flashdb.Cluster")]
    
	import flash.net.registerClassAlias;
	
	[Bindable] public class Cluster{
		public var id:String
		public var label:String;
		public var elements:Array;
		
		//the following vars do not exist on the server side cluster class!
		public var nodeId:String;
		public var relations:Array;
		public var version:int;		//??????//every change of the similarity threshold is propagated through the graph. This propagation leads to an update of every cluster and an increase of the version.
		
		/*
		* Contructor
		*/
		public function Cluster(_id:String="",_label:String=""){
			this.id = _id;
			this.label = _label;
			this.elements = new Array();
			
			this.relations = new Array();
			this.nodeId = "";
			this.version = 0;
		}
		
	    public function addElement(_e:Element):void{
    	    this.elements.push(_e);
    	}
		
		public function addRelation(_r:Relation):void{
			this.relations.push(_r);
		}
		
		static public function register():void
		{
			registerClassAlias("com.flashdb.Cluster", Cluster) ;	
		}
   }
}