/**
 * Copyright (C) 2009 Philipp Heim and Timo Stegemann (email to: heim.philipp@googlemail.com)
 * 
 * This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License along with this program; if not, see <http://www.gnu.org/licenses/>.
 */
package mainMenu 
{
	import connection.IConnection;
	import connection.MirroringConnection;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import graphElements.ElementClass;
	import mx.collections.ArrayCollection;
	/**
	 * ...
	 * @author Timo Stegemann
	 */
	public class MainMenuModel extends EventDispatcher
	{
		
		public function MainMenuModel() 
		{
			
		}
		
		[Bindable]
		public var currentElementClass:ElementClass = null;
		
		[Bindable]
		public var elementClasses:ArrayCollection = new ArrayCollection();	//one can be chosen as the mainClass by the user
		
		private var _connection:IConnection;
		
		[Bindable(event="ConnectionChange")]
		public function get connection():IConnection {
			return _connection;
		}
		
		public function set connection(value:IConnection):void {
			_connection = value;
			dispatchEvent(new Event("ConnectionChange"));
		}
		
	}

}