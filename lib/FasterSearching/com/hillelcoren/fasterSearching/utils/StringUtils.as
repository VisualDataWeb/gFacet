package com.hillelcoren.fasterSearching.utils
{	
	import mx.utils.StringUtil;
	
	public class StringUtils
	{
		/**
		 * Check if the string begins with the pattern
		 */
		public static function beginsWith( string:String, pattern:String):Boolean
		{
			if (!string)
			{
				return false;
			}
			
			string  = string.toLowerCase();
			pattern = pattern.toLowerCase();
			
			return pattern == string.substr( 0, pattern.length );
		}
		
		public static function contains( string:String, searchStr:String ):Boolean
		{
			var regExp:RegExp = new RegExp( searchStr, "i" );
			
			return regExp.test( string );			
		}
				
		public static function anyWordBeginsWith( string:String, pattern:String ):Boolean
		{
			if (!string)
			{
				return false;
			}
			
			if (beginsWith( string, pattern ))
			{
				return true;
			}
			
			// check to see if one of the words in the string is a match
			var words:Array = string.split( " " );
			
			for each (var word:String in words)
			{
				if (beginsWith( word, pattern ))
				{
					return true;
				}
			}
			
			return false;
		}				
	}
}