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
	import connection.LookUpSPARQL;
	import flash.events.Event;
	
	import flash.events.EventDispatcher;
	
	import mx.collections.ArrayCollection;
	
	public class Config extends EventDispatcher implements IConfig
	{
		
		private var _endpointURI:String;
		
		private var _defaultGraphURI:String;
		
		private var _isVirtuoso:Boolean;
		
		private var _name:String;
		
		private var _description:String;
		
		private var _autocompleteURIs:ArrayCollection;
		
		private var _ignoredProperties:ArrayCollection;
		
		private var _lookUp:ILookUp;
		
		private var _useProxy:Boolean = true;
		
		public function Config(name:String = "", description:String = "",
					endpointURI:String = "", defaultGraphURI:String = "", isVirtuoso:Boolean = false,
					ignoredProperties:ArrayCollection = null, useProxy:Boolean = true,
					autocompleteURIs:ArrayCollection = null,
					lookUp:ILookUp = null) {
			
			this.name = name;
			this.description = description;
			this.endpointURI = endpointURI;
			this.defaultGraphURI = defaultGraphURI;
			this.isVirtuoso = isVirtuoso;
			this.ignoredProperties = ignoredProperties;
			this.useProxy = useProxy;
			
			this.lookUp = lookUp;
		}
		
		[Bindable(event="endpointURIChange")]
		public function get endpointURI():String {
			return _endpointURI;
		}
		
		public function set endpointURI(value:String):void {
			_endpointURI = value;
			dispatchEvent(new Event("endpointURIChange"));
		}
		
		[Bindable(event="defaultGraphURIChange")]
		public function get defaultGraphURI():String {
			return _defaultGraphURI;
		}
		
		public function set defaultGraphURI(value:String):void {
			_defaultGraphURI = value;
			dispatchEvent(new Event("defaultGraphURIChange"));
		}
		
		[Bindable(event="isVirtuosoChange")]
		public function get isVirtuoso():Boolean {
			return _isVirtuoso;
		}
		
		public function set isVirtuoso(value:Boolean):void {
			_isVirtuoso = value;
			dispatchEvent(new Event("isVirtuosoChange"));
		}
		
		[Bindable(event="nameChange")]
		public function get name():String {
			return _name;
		}
		
		public function set name(value:String):void {
			_name = value;
			dispatchEvent(new Event("nameChange"));
		}
		
		[Bindable(event="descriptionChange")]
		public function get description():String {
			return _description;
		}
		
		public function set description(value:String):void {
			_description = value;
			dispatchEvent(new Event("descriptionChange"));
		}
		
		[Bindable(event="ignoredPropertiesChange")]
		public function get ignoredProperties():ArrayCollection {
			return _ignoredProperties;
		}
		
		public function set ignoredProperties(value:ArrayCollection):void {
			_ignoredProperties = value;
			dispatchEvent(new Event("ignoredPropertiesChange"));
		}
		
		[Bindable(event="autocompleteURIsChange")]
		public function get autocompleteURIs():ArrayCollection {
			return _autocompleteURIs;
		}
		
		public function set autocompleteURIs(value:ArrayCollection):void {
			_autocompleteURIs = value;
			dispatchEvent(new Event("autocompleteURIsChange"));
		}
		
		[Bindable(event="lookUpChange")]
		public function get lookUp():ILookUp{
			if (_lookUp == null){
				_lookUp = new LookUpSPARQL();
			}
			return _lookUp;
		}
		
		public function set lookUp(value:ILookUp):void {
			_lookUp = value;
			dispatchEvent(new Event("lookUpChange"));
		}
		
		[Bindable(event="useProxyChange")]
		public function get useProxy():Boolean {
			return _useProxy;
		}
		
		public function set useProxy(value:Boolean):void {
			_useProxy = value;
			dispatchEvent(new Event("useProxyChange"));
		}
		
		override public function toString():String {
			return "Name: " + name + "\n" +
					"Abbrevation: " + description  + "\n" +
					"EndpointURI: " + endpointURI  + "\n" +
					"DefaultGraphURI: " + defaultGraphURI  + "\n" +
					"IsVirtuoso: " + isVirtuoso + "\n" +
					"UseProxy: " + useProxy + "\n" +
					"AutocompleteURIs: " + ((autocompleteURIs == null) ? "null" : autocompleteURIs.toArray() + " #" + autocompleteURIs.length) + "\n" +
					"IgnoredProperties: " + ((ignoredProperties == null) ? "null" : ignoredProperties.toArray() + " #" + ignoredProperties.length);
		}
	}
	
}