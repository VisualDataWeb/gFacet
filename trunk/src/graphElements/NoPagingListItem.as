/**
 * Copyright (C) 2009 Philipp Heim and Timo Stegemann (email to: heim.philipp@googlemail.com)
 * 
 * This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License along with this program; if not, see <http://www.gnu.org/licenses/>.
 */ 

package graphElements {
	import connection.SPARQLConnection;
	import graphElements.ElementClass;
	
	public class NoPagingListItem extends ListItem {
		
		public function NoPagingListItem(_key:String, _elementClass:ElementClass, _myConnection:SPARQLConnection, _facet:Facet, _incomingRel:RelationItem=null, _color:uint = 0){	//, _previous:Element=null, _next:Element=null) {
			super(_key, _elementClass, _myConnection, _facet, _incomingRel, _color);
			this.facet.offset = 0;
			this.facet.limit = 3000;	//just for testing! --> so actually no limit at all!
		}
		
		override public function setElementClass(_elementClass:ElementClass):void {
			super.setElementClass(_elementClass);
			
			this.cLabel = this.elementClass.label;// + "s";// this.chain.property.type +":" + this.chain.property.value;
			if (this.cLabel.length > 30) {
				this.cLabel = this.cLabel.substr(0, 30)+"...";
				//this.cLabel = this.cLabel.substr(this.cLabel.length - 14, this.cLabel.length - 1);
			}
		}
		
	}
	
}