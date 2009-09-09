/**
 * Copyright (C) 2009 Philipp Heim (email to: heim.philipp@googlemail.com)
 * 
 * This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License along with this program; if not, see <http://www.gnu.org/licenses/>.
 */ 

package classes.extenders.item 
{
	import com.adobe.flex.extras.controls.springgraph.GraphDataProvider;
	import com.adobe.flex.extras.controls.springgraph.GraphNode;
	import com.adobe.flex.extras.controls.springgraph.Item;
	import mx.core.Application;
	import org.flashdevelop.utils.FlashConnect;
	
	public class MyItem extends Item 
	{
		protected var node:GraphNode = null;
		
		public function MyItem(_id:String) {
			super(_id);
		}
		
		
		public function getNode():GraphNode {
			if (this.node == null) {
				trace("in getNode");
				var dP:GraphDataProvider = app().sGraph.getDataProvider() as GraphDataProvider;
				//elementNode = dP.findNodeByItem(eItem);
				trace("test "+this.id);
				this.node = dP.findNodeByItem(this);
				trace("test2");
			}
			return this.node;
		}
		
		protected function app():gFacet {
			return Application.application as gFacet;
		}
		
		public function getX():Number {
			if (this.node != null) {
				return this.node.x;
			}
			return 0;//FALSCH
		}
		
		public function getY():Number {
			if (this.node != null) {
				return this.node.y;
			}
			return 0;//FALSCH!
		}
		
		public function setPosition(_x:Number, _y:Number):void {
			
			if (this.node == null) {
				this.getNode();
			}
			if (this.node != null) {
				FlashConnect.trace("set position "+_x+" "+_y);
				this.node.x = _x;
				this.node.y = _y;
				this.node.commit();
			}else {
				FlashConnect.trace("this.node == null");
			}
		}
		
	}
	
}