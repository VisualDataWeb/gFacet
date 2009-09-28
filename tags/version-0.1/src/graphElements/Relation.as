/**
 * Copyright (C) 2009 Philipp Heim and Timo Stegemann (email to: heim.philipp@googlemail.com)
 * 
 * This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License along with this program; if not, see <http://www.gnu.org/licenses/>.
 */ 

package graphElements{
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