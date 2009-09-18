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
	import mx.containers.HBox;
	import mx.controls.Image;
	
	public class MyDataGridStatusRenderer extends HBox{
		
		private var myImg:Image;
		[Embed(source="../../assets/img/symbolOkGrau2.gif")]
		private static var okGrau:Class;
		
		public function MyDataGridStatusRenderer() {
			myImg = new Image();
			myImg.source = okGrau;	//todo Check icon!
			this.addChild(myImg);
		}
		
		
		/*override public function get data():Object {
			
            return "";
        }

        override public function set data(value:Object):void {
			
        }*/
	}
	
}