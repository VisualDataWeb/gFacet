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
	import mx.collections.ArrayCollection;
	
	public class LODConfig extends DBpediaConfig
	{
		override public function get endpointURI():String {
			return "http://lod.openlinksw.com/sparql";
		}
		
		override public function get defaultGraphURI():String {
			return "";
		}
		
		override public function get isVirtuoso():Boolean {
			return true;
		}
		
		override public function get description():String {
			return "lod";
		}
		
		override public function get name():String {
			return "Linking Open Data (LOD)"; 
		}
		
		override public function get ignoredProperties():ArrayCollection {
			var ignoredProperties:ArrayCollection = super.ignoredProperties;
			ignoredProperties.addItem("http://dbpedia.org/property/wikilink");
			return ignoredProperties;
		}
		
	}
	
}