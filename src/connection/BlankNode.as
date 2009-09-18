/**
 * Copyright (C) 2009 Philipp Heim, Hanief Bastian and Timo Stegemann (email to: heim.philipp@googlemail.com)
 * 
 * This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License along with this program; if not, see <http://www.gnu.org/licenses/>.
 */ 

package connection
{
	
	public class BlankNode extends Resource
	{
		//private var uri_or_namespace:String;
		public function BlankNode(_uri_or_namespace:String, localname:String = null) 
		{
			super(_uri_or_namespace);
			/*
			 * if (localname == null)
			{
				this.uri_or_namespace = _uri_or_namespace;
			}
			else
			{
				this.uri_or_namespace = _uri_or_namespace + localname;
			}
			*/
		}
		
		public function get getID():String
		{
			return getURI;
		}
		
	}
	
}