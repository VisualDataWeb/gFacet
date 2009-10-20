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
	import connection.ILookUp;
	
	import mx.collections.ArrayCollection;
	
	/**
	 * ...
	 * @author Timo Stegemann
	 */
	public interface IConfig 
	{
		[Bindable(event="endpointURIChange")]
		function get endpointURI():String;
		
		function set endpointURI(value:String):void;
		
		[Bindable(event="defaultGraphURIChange")]
		function get defaultGraphURI():String;
		
		function set defaultGraphURI(value:String):void;
		
		[Bindable(event="isVirtuosoChange")]
		function get isVirtuoso():Boolean;
		
		function set isVirtuoso(value:Boolean):void;
		
		[Bindable(event="nameChange")]
		function get name():String;
		
		function set name(value:String):void;
		
		[Bindable(event="descriptionChange")]
		function get description():String;
		
		function set description(value:String):void;
		
		[Bindable(event="autocompleteURIsChange")]
		function get autocompleteURIs():ArrayCollection;
		
		function set autocompleteURIs(value:ArrayCollection):void;
		
		[Bindable(event="ignoredPropertiesChange")]
		function get ignoredProperties():ArrayCollection;
		
		function set ignoredProperties(value:ArrayCollection):void;
		
		[Bindable(event="lookUpChange")]
		function get lookUp():ILookUp;
		
		function set lookUp(value:ILookUp):void;
		
		[Bindable(event="useProxyChange")]
		function get useProxy():Boolean;
		
		function set useProxy(value:Boolean):void;
		
		function equals(value:IConfig):Boolean
		
		function clone():IConfig;
	}
	
}