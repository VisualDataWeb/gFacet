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
	import mx.containers.HBox;
	import mx.controls.Image;
	//import org.osflash.thunderbolt.Logger;
	
	public class ImageRenderer extends HBox 
	{
		private var myImg:Image;
		private var status:String = "invalid";
		private var myData:Object;
		
		[Embed(source="../../assets/img/symbolOk2.gif")]
		private static var ok:Class;
		
		[Embed(source="../../assets/img/dot.gif")]
		private static var available:Class;
		
		[Embed(source="../../assets/img/symbolWrong2.gif")]
		private static var wrong:Class;
		
		public function ImageRenderer() {
			super();
			
			myImg = new Image();
			myImg.source = wrong;	//todo Check icon!
			this.addChild(myImg);
		}
		
		override public function get data():Object {
			
            return this.myData;
        }

        override public function set data(value:Object):void {
			myData = value;
			
			//Logger.debug("status", status);
			if ((value as Element).isValid) {
				myImg.source = ok;
			}else if ((value as Element).isSelected) {
				myImg.source = ok;
			}else if ((value as Element).isAvailable) {
				myImg.source = available;
			}else {
			/*}else if (!(value as Element).isValid) {*/
				myImg.source = wrong;
			}/*else {
				//myImg.source = "assets/img/unpin1.png";
			}*/
			
			/*this.status = (value as Element).status;
			//Logger.debug("status", status);
			if (this.status == "valid") {
				myImg.source = ok;
			}else if (this.status == "selected") {
				myImg.source = ok;
			}else if (this.status == "invalid") {
				myImg.source = wrong;
			}else {
				//myImg.source = "assets/img/unpin1.png";
			}*/
            /*var strHeader:String = (value as DataGridColumn).headerText;
            if (strHeader == null || strHeader == "") return;
			this.myHeader.text = strHeader;
			*/
        }
		
	}
	
}