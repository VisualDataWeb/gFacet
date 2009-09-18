/**
 * Copyright (C) 2009 Philipp Heim and Timo Stegemann (email to: heim.philipp@googlemail.com)
 * 
 * This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License along with this program; if not, see <http://www.gnu.org/licenses/>.
 */ 

package extenders 
{
	import graphElements.Element;
	import graphElements.Property;
	import flash.text.TextField;
	import mx.containers.HBox;
	import mx.controls.Label;
	import mx.controls.List;
	import mx.controls.TextArea;
	import mx.core.UITextField;
	//import org.osflash.thunderbolt.Logger;
	
	public class MyValueRenderer extends HBox {
		
		private var type:String = "";
		private var myData:Object;
		private var myList:List = new List();
		private var myText:UITextField = new UITextField();
		private var myLabel:Label = new Label();
		
		public function MyValueRenderer(_type:String) {
			super();
			this.type = _type;
			this.percentWidth = 100;
			
			this.horizontalScrollPolicy = "off";
			this.myText.wordWrap = true;
		}
		
		override public function get data():Object {
			return myData;
            //return this.myHeader.text;
        }

        override public function set data(value:Object):void {
			super.data = value;
            myData = value;
			//Logger.debug("lllll");
			//Logger.debug("indexChild", this.getChildIndex(myLabel));
			this.removeAllChildren();
			var e:Element = value as Element;
			var p:Property = e.getProperty(type);
			var v:Object = p.value;
			if (v is Array) {	//if more than one value exist!
				myList.dataProvider = v as Array;
				this.addChild(myList);
				
			}else {
				myText.text = v as String;	//möglicherweise nicht!
				this.addChild(myText);
				
			}
			
        }
		
	}
	
}