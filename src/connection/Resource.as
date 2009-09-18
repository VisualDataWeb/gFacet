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
	
/**
	* Resource class
	* An RDF node of URI/Resorce type
	* 
	*/
	
	public class Resource extends Node
	{
		private var uri:String;
		private var localname:String;
		
		public function Resource(_uri_or_namespace:String, _localname:String = null) 
		{
			super(_uri_or_namespace);
			if (localname == null)
			{
				this.uri = _uri_or_namespace;				
			}
			else
			{
				this.uri = _uri_or_namespace + _localname;				
				super.label = _uri_or_namespace + _localname;				
			}
		}
		
		public function get getURI():String
		{
			return this.uri;
		}
		
		/*public function get getLabel():String
		{
			return this.getURI;
		}
		
		public function get getNamespace():String
		{
			
			return this.uri.substr(0,QNameDelimiterIdx(this.uri));
		}
		
		public function get getLocalname():String
		{
			return this.uri.substr(QNameDelimiterIdx(this.uri));
		}
		
		private function QNameDelimiterIdx(_uri:String):int
		{			
			var uriIdx :int = _uri.length;
			var subStr:String;
			while (uriIdx > 0)
			{
				uriIdx--;
				subStr = _uri.substr(uriIdx, 1);
				if (subStr == ":" || subStr == "/" || subStr == "#")
				{
					break;
				}
				
			}
			uriIdx++;
			return uriIdx;
		}
		
		*/
	}
	
}