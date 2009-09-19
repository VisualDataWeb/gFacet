/**
 * Copyright (C) 2009 Philipp Heim and Timo Stegemann (email to: heim.philipp@googlemail.com)
 * 
 * This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License along with this program; if not, see <http://www.gnu.org/licenses/>.
 */ 

package connection.config 
{
	public class DBLPConfig extends Config
	{
		override public function get endpointURI():String {
			return "http://www4.wiwiss.fu-berlin.de/dblp";
		}
		
		override public function get defaultGraphURI():String {
			return "";
		}
		
		override public function get isVirtuoso():Boolean {
			return false;
		}
		
		override public function get abbreviation():String {
			return "dblp";
		}
		
		override public function get name():String {
			return "DBLP Bibliography Database (Berlin)"; 
		}
	}
	
}