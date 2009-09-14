/**
* ...
* @author Philipp Heim
* @version 0.3
*/

package com.flashdb{
	// Relation.as
	
	[RemoteClass(alias="com.flashdb.Relation")]
    
	import flash.net.registerClassAlias;

	[Bindable] public class Relation{
		public var id:String;
		public var subj:Object;		//List or Element
		public var predicate:String;
		public var obj:Object;		//List or Element
		public var label:String;
		
		public function Relation(_id:String="0",_subj:Object="", _predicate:String="", _obj:Object=null, _label:String=""){
			id = _id;
			subj = _subj;
			predicate = _predicate;
			obj = _obj;
			label = _label;
		}
		
		static public function register():void{
			registerClassAlias("com.flashdb.Relation", Relation) ;	
		}
	}
}