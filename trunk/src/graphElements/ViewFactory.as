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

	import mx.core.UIComponent;
	import com.adobe.flex.extras.controls.springgraph.IViewFactory;
	import com.adobe.flex.extras.controls.springgraph.Item;
	import org.flashdevelop.utils.FlashConnect;
	import graphElements.*;
	
	/** The object that knows how to create views that correspond to a given Item. 
	 * We recognize these types:
	 * - for Items of type Word, we create a WordView
	 * - for Items of type Meaning, we create a MeaningView
	 */
	public class ViewFactory implements IViewFactory
	{
		public function ViewFactory() {
			
		}
		
		public function getView(item:Item):UIComponent
		{
			FlashConnect.trace("getView from the viewFactory for item: "+item.id);
			if (item is graphElements.RelationItem) {
				return new RelationView();
			}else if (item is graphElements.ListItem) {
				if (item is graphElements.MapItem) {
					return new graphElements.MapView();
				}else {
					return new ListView();
				}
			}
			FlashConnect.trace("return null");
			return null;
		}
		
	}
	
}
