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
	* Node class
	* An abstract class of RDF nodes
	* An RDF node can be literal, blanknode, or URI/Resource
	* 
	*/
	
	public class Node 
	{
		public var label:String;
		public function Node(_label:String) 
		{
			//
			this.label = _label;
		}
		
		public function get getLabel():String
		{
			return this.label;
		}
		
		public function get getNamespace():String
		{
			
			return this.label.substr(0,QNameDelimiterIdx(this.label));
		}
		
		public function get getLocalname():String
		{
			return this.label.substr(QNameDelimiterIdx(this.label));
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
		
	}
	
}