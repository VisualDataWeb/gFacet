/**
 * Copyright (C) 2009 Philipp Heim (email to: heim.philipp@googlemail.com)
 * 
 * This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License along with this program; if not, see <http://www.gnu.org/licenses/>.
 */ 

package classes.extenders.dataGrid 
{
	import mx.collections.ICollectionView;
	import mx.collections.ArrayCollection;
	import mx.collections.ListCollectionView;
	import mx.collections.XMLListCollection;
	import mx.collections.IList;
	import flash.events.EventDispatcher;
	/**
	 * ValueListHandler wraps a collection object which copies the format by the dataProvider used by 
	 * the Flex DataGrid. This class frontloads the number of records specified by the grid and fills it up
	 * with null values making it valid for the DataGrid to scroll to.
	 */
	public class ValueListHandler extends EventDispatcher
	{
		/**
		 * The base object used as the DataGrid's dataProvider.
		 */
		private var _collection:ICollectionView;
		/**
		 * The total number of non-null records in the _collection object.
		 */
		private var _objectTotal:Number;
		
		function ValueListHandler():void{}
		/**
		 * The function that handles the front loading of collection data 
		 * based on the length of the records provided. The collection object is filled
		 * with null values making it valid for the DataGrid to cross check when scrolling.
		 */
		private function frontload(n:Number):void{
			var ref:ListCollectionView;
			_objectTotal = _collection.length;
 	 		var destLen:Number = n-1;
 	 		var i:Number = _collection.length-1;
 	 		 while (i++ < destLen){
 	 			try{
 	 				ListCollectionView(_collection).addItem((_collection is XMLListCollection) ? new XML() : null);
 	 			}catch(e:Error){
 	 				trace("front load error :: " + e.message);
 	 			}
	 	 	} 
 	 	}
 	 	/**
		* This property returns the total number of non-null values in the collection 
		* data
		*
		*/
		public function get length():Number{
			return _objectTotal;
		}
		/**
		 * This method populates the collection object after a sort process from the DataGrid.
		 * It refills the collection object based on the first viewable row index from the grid 
		 * and empties the previous elements containing data.
		 */
 	 	public function setSortedReference(value:Object, size:Number, index:Number):void{ 	 		
 	 		var i:Number = -1;
 	 		var len:Number = size-1;
 	 		var ci:Number = 0;
 	 		var limit:Number = _objectTotal = (_collection is XMLListCollection) ? XMLList(value).length() : ListCollectionView(value).length;
 	 		
 	 		while(i++ < len){
 	 			if(i>=index && i < index+limit){
		  			try{
			 	 		_collection[i] = value[ci];
			 	 		ci++;
			 	 	}catch(e:Error){
			 			trace("append sort update error :: " + e.message);
			 	 	}	
		 	 	}else{
		 	 		//empty previous elements
		 	 		try{
			 	 		_collection[i] = (_collection is XMLListCollection) ? new XML() : null;
			 	 	}catch(e:Error){
			 	 		trace(i + "empty sort update error :: " + e.message);
			 	 	}
		 	 	} 	 		
 	 		}
 	 	}
 	 	/**
 	 	 * The method that populates the collection object after the DataGrid receives
 	 	 * a dataProvider property set. It copies the same object used by the DataGrid as dataProvider
 	 	 * and sets it as the reference data used by the DataGrid. Any changes made to the collection
 	 	 * object will reflect with how the DataGrid handles its dataProvider changes.
 	 	 * <p>This method copies the same method used by the DataGrid when setting 
 	 	 * its dataProvider. By pre-setting the type of the dataProvider to be used
 	 	 * the grid will ignore processing the collection object when set as its dataProvider</p>
 	 	 * 
 	 	 * @returns The collection object formatted to ICollectionView.
 	 	 * 
 	 	 */
		public function setReference(value:Object, size:Number):ICollectionView{
	        if (value is Array){
	            _collection = new ArrayCollection(value as Array);
	        }else if (value is ICollectionView){
	            _collection = ICollectionView(value);
	           
	        }else if (value is IList){
	            _collection = new ListCollectionView(IList(value));
	           
	        }else if (value is XMLList){
	            _collection = new XMLListCollection(value as XMLList);
	           
	        }else if (value is XML){
	            var xl:XMLList = new XMLList();
	            xl += value;
	            _collection = new XMLListCollection(xl);
	            
	        }else if(value is ArrayCollection){
	        	_collection = value as ArrayCollection;
	        }else {
	            var tmp:Array = [];
	            if (value != null){
		             tmp.push(value);
		        }
	            _collection = new ArrayCollection(tmp);
	        }
	         if(size){
				frontload(size);
			}
	        return _collection;
 	 	}
 	 	/**
 	 	 * Updates the collection object elements starting on the index provided. If the element being updated
 	 	 * is not null, it will skip the data assignment. This is to prevent overwriting data on an editable DataGrid.
 	 	 */
 	 	public function updateCollectionElements(value:Object, startindex:Number):void{
 	 		/**
 	 		 * Have to check this again. somehow it receives -1.
 	 		 */
 	 		var i:Number = (startindex < 0 ) ? 0 : startindex;
 	 		var ci:Number = -1;
 	 		var len:Number = (_collection is XMLListCollection) ? XMLList(value).length() : ListCollectionView(value).length;
 	 		while(ci++ < len){
	  			try{
	  				if(_collection[ci+i] == null || _collection[ci+i] == ""){
		  				_collection[ci+i] = value[ci];
		  				_objectTotal++;
		  			}
		 	 	}catch(e:Error){
		 	 		trace(">>> " + e.message);	
		 	 	} 	 		
 	 		}
 	 
 	 	}
 	 	/**
 	 	 * Checks if the collection element is null. If the element is found null, tt returns the 
 	 	 * index of that element.
 	 	 */
 	 	public function rangeIsValid(startindex:Number, viewcount:Number):Number{
 	 		var i:Number = startindex-1;
 	 		var len:Number = i+viewcount;
 	 		var colLen:Number = _collection.length;
 	 		while ( i++ < len){
 	 			try{
	 	 			if(_collection[i] == null || _collection[i] == ""){
	 	 				return i;
	 	 			}
	 	 		}catch(e:Error){
	 	 			trace("error");
		 	 			return (i < colLen) ? i : -1;
	 	 		}
 	 		}
		 	return -1;
 	 	}
  	}
       
}