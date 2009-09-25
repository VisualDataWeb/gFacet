package com.hillelcoren.fasterSearching
{
	import com.hillelcoren.fasterSearching.utils.StringUtils;
	
	public class Person extends AbstractObject
	{
		public static const FIELD_FIRST_NAME:String = "firstName";
		public static const FIELD_LAST_NAME:String 	= "lastName";
		public static const FIELD_PHONE:String 		= "phone";
		public static const FIELD_EMAIL:String 		= "email";
		public static const FIELD_DEPARTMENT:String = "department";
		
		private var _firstName:String;
		private var _lastName:String;
		private var _phone:String;
		private var _email:String;
		private var _department:String;
		
		override public function getSearchFields():Array
		{
			return [ FIELD_FIRST_NAME, FIELD_LAST_NAME, FIELD_PHONE, FIELD_EMAIL, FIELD_DEPARTMENT ];
		}
		
		override public function matchesField( field:String, searchStr:String ):Boolean
		{
			if (field == FIELD_EMAIL)
			{
				return StringUtils.contains( email, searchStr );
			}
			else
			{
				return StringUtils.anyWordBeginsWith( this[field], searchStr );
			}
		}
		
		public function set firstName( value:String ):void
		{
			_firstName = value;
		}	
		
		public function get firstName():String
		{
			return _firstName;
		}
		
		public function set lastName( value:String ):void
		{
			_lastName = value;
		}	
		
		public function get lastName():String
		{
			return _lastName;
		}
		
		public function set phone( value:String ):void
		{
			_phone = value;
		}	
		
		public function get phone():String
		{
			return _phone;
		}
		
		public function set email( value:String ):void
		{
			_email = value;
		}	
		
		public function get email():String
		{
			return _email;
		}
		
		public function set department( value:String ):void
		{
			_department = value;
		}	
		
		public function get department():String
		{
			return _department;
		}			
	}
}