package com.hillelcoren.fasterSearching.interfaces
{
	/**
	 * The problem with the way flex searches is that it searches every item
	 * everytime you call 'refresh' on a collection. If an item implements this
	 * interface we speed up searching by checking if the current search string
	 * starts with the last failed search string. In that case we know it won't match
	 * so we can return false right away.
	 */
	public interface ISearchable
	{
		function matchesField( field:String, searchStr:String ):Boolean
		function getSearchFields():Array
		function setLastFailedSearchStr( value:String ):void
		function getLastFailedSearchStr():String			
	}
}