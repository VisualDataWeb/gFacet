/**
 * Copyright (C) 2009 Philipp Heim and Timo Stegemann (email to: heim.philipp@googlemail.com)
 * 
 * This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License along with this program; if not, see <http://www.gnu.org/licenses/>.
 */
package connection 
{
	import connection.config.IConfig;
	import flash.events.IEventDispatcher;
	import mx.collections.ArrayCollection;
	
	/**
	 * ...
	 * @author Timo Stegemann
	 */
	public interface IConnection extends IEventDispatcher
	{
		function sendCommand(command:String, onResult:Function, args:Array = null):void;
		function clone():IConnection;
		function executeSparqlQuery(sources:ArrayCollection, sparqlQueryString:String, resultHandler:Function, format:String = "XML", useDefaultGraphURI:Boolean = true, errorHandler:Function = null, parsingInformations:Object = null):SPARQLService;
		function get config():IConfig;
		function set config(value:IConfig):void;
	}
	
}