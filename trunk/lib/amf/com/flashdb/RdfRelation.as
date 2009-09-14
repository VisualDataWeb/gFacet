/**
* ...
* @author Philipp Heim
* @version 0.1
*/

package com.flashdb{
	// RdfRelation.as
	
	[RemoteClass(alias="com.flashdb.RdfRelation")]
    
	import flash.net.registerClassAlias;

	[Bindable] public class RdfRelation{
		public var id:String;
		public var e1:Element;			//the element this relation starts form
		public var e2:Element;			//the element this relation is leading to
		public var typ:String;		
		
		//the following vars do not exist on the server side relation class!
		public var edgeId:String;	//braucht man nicht mehr ?!
		
		public function RdfRelation(_id:String="0",_e1:Element=null,_e2:Element=null,_typ:String = ""){
			id = _id;
			e1 = _e1;
			e2 = _e2;
			typ = _typ;
			
			edgeId = "";
		}
		
		static public function register():void{
			registerClassAlias("com.flashdb.RdfRelation", RdfRelation) ;	
		}
	}
}