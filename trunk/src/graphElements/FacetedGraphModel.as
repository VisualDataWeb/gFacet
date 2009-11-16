/**
 * Copyright (C) 2009 Philipp Heim and Timo Stegemann (email to: heim.philipp@googlemail.com)
 * 
 * This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License along with this program; if not, see <http://www.gnu.org/licenses/>.
 */
package graphElements 
{
	import connection.IConnection;
	import mx.collections.ArrayCollection;
	/**
	 * ...
	 * @author Timo Stegemann
	 */
	public class FacetedGraphModel
	{
		
		public function FacetedGraphModel(connection:IConnection) 
		{
			_connection = connection;
		}
		
		private var _connection:IConnection;
		
		public function get connection():IConnection {
			return _connection;
		}
		
		private var _facets:ArrayCollection = new ArrayCollection();
		
		public function get facets():ArrayCollection {
			return _facets;
		}
		
	}

}