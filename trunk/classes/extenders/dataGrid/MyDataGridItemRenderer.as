/**
 * Copyright (C) 2009 Philipp Heim (email to: heim.philipp@googlemail.com)
 * 
 * This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License along with this program; if not, see <http://www.gnu.org/licenses/>.
 */ 

package classes.extenders.dataGrid 
{
	import flash.events.MouseEvent;
	import mx.containers.HBox;
	import mx.controls.Button;
	import mx.controls.dataGridClasses.DataGridColumn;
	import mx.controls.Label;
	import org.flashdevelop.utils.FlashConnect;
	
	public class MyDataGridItemRenderer extends HBox{
		
		private var myHeader:Label;
        private var closeButton:Button;
		private var f:Function;
		private var myData:Object;

        public function MyDataGridItemRenderer(_f:Function) {
            super();
			//this.styleName = "myDataHeader";
			this.horizontalScrollPolicy = "false";
			f = _f;
			myHeader = new Label();
			myHeader.styleName = "myButtonStyle2";
			myHeader.styleName = "myHeaderText";
            closeButton = new Button();
			closeButton.styleName = "closeColumnBtn";
			//var x:MouseEvent;
			closeButton.addEventListener(MouseEvent.CLICK, closeClickHandler); 
            this.addChildAt(myHeader, 0);
            this.addChildAt(closeButton, 1);
			//closeButton.addEventListener(MouseEvent.CLICK, );
            //lnkURL.addEventListener(MouseEvent.CLICK, navigateToCompany);
		}
		
		private function closeClickHandler(event:MouseEvent):void {
			FlashConnect.trace("click remove Column button");
			f(this.myHeader.text);
			//event.stopPropagation();
		}

        override public function get data():Object {
			return myData;
            //return this.myHeader.text;
        }

        override public function set data(value:Object):void{
            myData = value;
			var strHeader:String = (value as DataGridColumn).headerText;
            if (strHeader == null || strHeader == "") return;
			this.myHeader.text = strHeader;
			
        }
		
	}
	
}