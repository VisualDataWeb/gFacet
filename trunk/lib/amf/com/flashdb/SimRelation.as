/**
* ...
* @author Philipp Heim
* @version 0.1
*/

package com.flashdb{
	// SimRelation.as
	
	[RemoteClass(alias="com.flashdb.SimRelation")]
    
	import flash.net.registerClassAlias;

	[Bindable] public class SimRelation{
		public var id:String;
		public var e1:Element;			//the element this relation starts form
		public var e2:Element;			//the element this relation is leading to
		public var typ:String;
		public var simValues:Array;
		
		public function SimRelation(_id:String="0",_e1:Element=null,_e2:Element=null,_typ:String = "",_simValues:Array=null){
			id = _id;
			e1 = _e1;
			e2 = _e2;
			typ = _typ;
			simValues = _simValues;
		}
		
		static public function register():void{
			registerClassAlias("com.flashdb.SimRelation", SimRelation) ;	
		}
	}
}