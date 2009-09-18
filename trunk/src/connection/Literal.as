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

	public class Literal extends Node
	{
		//private var uri:String;
		//private var label:String;
		private var datatype:String;
		private var lang:String;
		
		public function Literal(_text:String,_lang:String = null):void
		{
			//this.label = _text;
			super(_text);
		}
		
		/*public function get getText():String
		{
			return this.label;
		}
		public function get getLabel():String
		{
			return this.getText;
		}*/
		public function get getLanguage():String
		{
			return this.lang;
		}
		
		public function get getDatatype():String
		{
			return this.datatype;
		}
		
		public function set setDatatype(_datatype:String):void
		{
			this.datatype = _datatype;
		}
		
		public function set setLanguage(_lang:String):void
		{
			this.lang = _lang;
		}
		
		//While using ORDER BY the URI sometimes is defined not as Resource class but Literal class
		// so this function is built
		public function get getURI():String
		{
			return super.getLabel;
		}
		
	}
	
}