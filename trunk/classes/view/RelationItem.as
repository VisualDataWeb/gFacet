/**
 * Copyright (C) 2009 Philipp Heim (email to: heim.philipp@googlemail.com)
 * 
 * This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License along with this program; if not, see <http://www.gnu.org/licenses/>.
 */ 

package classes.view {
	import classes.extenders.item.MyItem;
	import com.adobe.flex.extras.controls.springgraph.Item;
	import com.flashdb.Element;
	import com.flashdb.Property;
	import mx.core.Application;
	import org.flashdevelop.utils.FlashConnect;

	public class RelationItem extends MyItem{
		
		[Bindable] public var property:Property = null;
		[Bindable] public var previousItem:ListItem = null;
		public var nextItem:ListItem = null;
		[Bindable] public var hasChanged:Boolean = false;	//whether the total number of elements has changed due to an update
		public var highlightColor:uint = uint("0xff0000");	//default
		
		[Bindable] public var rLabel:String;
		
		
		public function RelationItem(_id:String, _previous:ListItem) {
			super(_id);
			trace("new RelationItem: " + _id);
			FlashConnect.trace("new RelationItem: " + _id);
			this.previousItem = _previous;
		}
		
		public function setProperty(_prop:Property):void {
			this.property = _prop;
			this.rLabel = this.property.label.slice(0, this.property.label.indexOf(":"));// +":" + this.property.objectClass.label;// this.property.type +":" + this.property.value;
			if (this.rLabel.length > 14) {
				this.rLabel = this.rLabel.substr(this.rLabel.length - 14, this.rLabel.length - 1);
			}
			
			//this.previousItem.addListItem(this);
		}
		
		public function setNextItem(_item:ListItem):void {
			this.nextItem = _item;
		}
		
		/*public function setPreviousItem(_item:ListItem):void {
			FlashConnect.trace("unlink previosus: " + this.previousItem.id);
			app().graph.unlink(this, this.previousItem);
			this.previousItem = _item;
			FlashConnect.trace("link _item :" + _item.id);
			var object:Object = new Object();
			object.startId = _item.id;
			app().graph.link(_item, this, object);
		}
		
		public function setNextItem(_item:ListItem):void {
			app().graph.unlink(this, this.nextItem);
			this.nextItem = _item;
			app().graph.link(this, this.nextItem);
		}*/
	}
	
}
