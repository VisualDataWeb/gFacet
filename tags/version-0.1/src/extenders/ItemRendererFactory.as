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
	import mx.core.IFactory;
	
	public class ItemRendererFactory implements IFactory
	{
		private var type:String = "";
		public function ItemRendererFactory(_type:String) {
			this.type = _type;
		}
		
		public function newInstance():* {
			if (this.type == "status") {
				return new ImageRenderer();
			}else {
				return new MyValueRenderer(this.type);
			}
			
		}
		
	}
	
}