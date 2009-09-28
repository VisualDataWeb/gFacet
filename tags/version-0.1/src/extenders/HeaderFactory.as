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
	import mx.controls.Button;
	import mx.core.IFactory;
	
	public class HeaderFactory implements IFactory
	{
		private var f:Function;	//temp!
		public function HeaderFactory(_f:Function) {
			f = _f;
			//IFactory.
		}
		
		public function newInstance():* {
			if (this.f != null) {
				return new MyDataGridItemRenderer(f);// new MyDataGridColumnHeaderRenderer();// 
			}else {
				return new MyDataGridStatusRenderer();
			}
		}
		
	}
	
}