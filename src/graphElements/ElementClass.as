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
	// ElementClass.as
	
	[RemoteClass(alias="com.flashdb.ElementClass")]
    
	import flash.net.registerClassAlias;
	
	[Bindable] public class ElementClass{
		public var id:String;
		public var label:String;
		
		// The number of all instances that are of objectClass and do have a incoming relation over property type
		public var numberOfObjectInstances:int = -1;
		
		public function ElementClass(_id:String="0", _label:String=""){
			id = _id;
			label = _label;
		}
		
		static public function register():void{
			registerClassAlias("com.flashdb.ElementClass", ElementClass) ;	
		}
		
	}
	
	
}