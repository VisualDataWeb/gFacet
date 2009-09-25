package com.hillelcoren.fasterSearching.utils
{
	import com.hillelcoren.fasterSearching.Person;
	
	import mx.collections.ArrayCollection;
	
	public class DataGenerator
	{
		private static const firstNames:Array = [ "Joe","Bob","Daniel","Sue","Jan","John","Peter","Paul","Scott","Susan" ];
		private static const lastNames:Array = [ "Jones","Smith","Williams","Anderson","Richards","Peterson","Neilson" ];
		private static const emails:Array = [ "yahoo","hotmail","google","msn","mac" ];
		private static const departemts:Array = [ "Sales","Marketing","Engineering","Support","Accounting" ];
		
		public static function generate( numItems:int ):ArrayCollection
		{
			var data:ArrayCollection = new ArrayCollection();
			var phoneNumber:int = 2015550000;
			
			for (var x:int=0; x<numItems; x++)
			{
				var person:Person = new Person();
				person.firstName 	= getRandomValue( firstNames ); 
				person.lastName 	= getRandomValue( lastNames );
				person.email	 	= person.firstName + "@" + getRandomValue( emails ) + ".com";
				person.phone 		= String( phoneNumber++ ); 				
				person.department 	= getRandomValue( departemts );
				data.addItem( person );
			}
			
			return data;
		}
		
		private static function getRandomValue( values:Array ):String
		{
			return values[ Math.floor( Math.random() * values.length ) ];	
		}
	}
}