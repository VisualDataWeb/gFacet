/**
 * Copyright (C) 2009 Philipp Heim and Timo Stegemann (email to: heim.philipp@googlemail.com)
 * 
 * This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License along with this program; if not, see <http://www.gnu.org/licenses/>.
 */ 

package graphElements {
	import connection.RemotingConnection;
	import connection.SPARQLConnection;
	import de.polygonal.ds.HashMap;
	import de.polygonal.ds.Iterator;
	
	import com.google.maps.MapEvent;
	import com.google.maps.Map;
	import com.google.maps.MapType;
	import com.google.maps.MapZoomEvent;
	import com.google.maps.MapMouseEvent;
	import com.google.maps.LatLng;
	import com.google.maps.LatLngBounds;
	import com.google.maps.overlays.Marker;
	import com.google.maps.overlays.MarkerOptions;
	import com.google.maps.LatLngBounds;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import mx.collections.ArrayCollection;
	import mx.core.Application;
	import org.flashdevelop.utils.FlashConnect;
	import mx.events.CollectionEvent
	import com.google.maps.services.ClientGeocoder;
	import com.google.maps.services.GeocodingEvent;
	import com.google.maps.InfoWindowOptions;
	
	/**
	* ...
	* @author Default
	*/
	public class MapItem extends ListItem {
		
		[Bindable]
		public var map:Map;
		
		private var mapIsReady:Boolean = false;
		private var bounds:LatLngBounds;
		
		private var locations:HashMap = new HashMap();
		
		public function MapItem(_key:String, _elementClass:ElementClass, _myConnection:SPARQLConnection, _facet:Facet, _incomingRel:RelationItem=null, _color:uint = 0) {
			super(_key, _elementClass, _myConnection, _facet, _incomingRel, _color);
		}
		
		public function getElement(_eId:String):Element {
			var iter:Iterator = this.insideElements.getIterator();
			while (iter.hasNext()) {
				var e:Element = iter.next();
				if (e.id == _eId) {
					return e;
				}
			}
			return null;
			
		}
		
		/*for each(var e:Element in this.ins
		if (this.insideElements.containsKey(_eid)) {
			return this.insideElements.find(_eid);
		}else {
			return null;
		}*/
		
	}
}