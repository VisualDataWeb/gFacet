package com.hillelcoren.fasterSearching.utils
{
	import com.hillelcoren.fasterSearching.interfaces.ISearchable;
	
	public class SearchUtils
	{
		private static var _enableFasterSearch:Boolean;
		
		/**
		 * This will check if an item matches a search string. It breaks
		 * up the searh string by commas as "or" matches and spaces as "and"
		 * matches
		 */
		public static function isMatch( item:ISearchable, searchStr:String ):Boolean
		{
			if (_enableFasterSearch && !quickCheck( item, searchStr ))
			{
				return false;
			}
			
			var orSearchStrs:Array = searchStr.split( "," );
			
			for each (var orSearchPart:String in orSearchStrs)
			{
				var andSearchStrs:Array = orSearchPart.split( " " );
				var isMatch:Boolean;
				
				for each (var andSearchStr:String in andSearchStrs)
				{
					isMatch = false;
					
					for each (var field:String in item.getSearchFields())
					{
						if (item.matchesField( field, andSearchStr ))
						{
							isMatch = true;
						}	
					}
					
					if (!isMatch)
					{
						break;
					}
				}	
				
				if (isMatch)
				{
					item.setLastFailedSearchStr( "" );
					return true;
				}
			}
			
			item.setLastFailedSearchStr( searchStr );
			return false;			
		}
		
		private static function quickCheck( item:ISearchable, searchStr:String ):Boolean
		{
			if (!item)
			{
				return false;
			}
			
			var lastFailedSearchStr:String = item.getLastFailedSearchStr();
			
			if (lastFailedSearchStr && lastFailedSearchStr.length > 0)
			{
				var oldNumTerms:int = item.getLastFailedSearchStr().split( "," ).length;
				var newNumTerms:int = searchStr.split( "," ).length;
				
				if (oldNumTerms != newNumTerms)
				{
					return true;
				}
				
				if (StringUtils.beginsWith( searchStr, lastFailedSearchStr) )
				{
					return false;
				}
			}
			
			return true;
		}
		
		public static function set enableFasterSearch( value:Boolean ):void
		{
			_enableFasterSearch = value;
		}
	}
}