package com.hillelcoren.fasterSearching
{
	import com.hillelcoren.fasterSearching.interfaces.ISearchable;
	import com.hillelcoren.fasterSearching.utils.StringUtils;
	
	import flash.utils.getQualifiedClassName;
	
	public class AbstractObject implements ISearchable
	{
		protected var _lastFailedSearchStr:String;

		public function matchesField( field:String, searchStr:String ):Boolean
		{
			return StringUtils.anyWordBeginsWith( this[field], searchStr );
		}
		
		public function getSearchFields():Array
		{
			throw new Error("This method needs to be overriden: " + getQualifiedClassName( this ));
		}
		
		public function setLastFailedSearchStr( value:String ):void
		{
			_lastFailedSearchStr = value;
		}
		
		public function getLastFailedSearchStr():String
		{
			return _lastFailedSearchStr;		
		}
	}
}