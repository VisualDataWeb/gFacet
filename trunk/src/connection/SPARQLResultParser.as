/**
 * Copyright (C) 2009 Philipp Heim, Hanief Bastian and Timo Stegemann (email to: heim.philipp@googlemail.com)
 * 
 * This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License along with this program; if not, see <http://www.gnu.org/licenses/>.
 */ 

package connection 
{
	//import org.osflash.thunderbolt.Logger;

	public class SPARQLResultParser 
	{
		private var arrVariables:Array = new Array();
		private var arrNamespaces:Array = new Array();
		private var arrResult:Array = new Array();
		private var arrLinks:Array = new Array();
		private var booleanResult:String;
		
		public function SPARQLResultParser() 
		{
			//
		}
		
		public function parse(_xmlInput:XML):void
		{
			this.setNamespaceDeclaration = _xmlInput;
			
			for (var rootChildIdx:int = 0; rootChildIdx < _xmlInput.children().length(); rootChildIdx++ )
			{
				var strElement:String = _xmlInput.children()[rootChildIdx].name().localName.toString();
				switch(strElement.toLowerCase())
				{
					case "head" : 
						var varIdx:int = 0;
						var linkIdx:int = 0;
						for (var headChildIdx:int = 0; headChildIdx < _xmlInput.children()[rootChildIdx].children().length(); headChildIdx++ )
						{
							
							if (_xmlInput.children()[rootChildIdx].children()[headChildIdx].name().localName.toString().toLowerCase() == "variable")
							{
								//looking for all attributes in <variable>
								for (var attrIdx:int = 0; attrIdx <  _xmlInput.children()[rootChildIdx].children()[headChildIdx].attributes().length(); attrIdx++ )
								{
									var strAttribute:String = _xmlInput.children()[rootChildIdx].children()[headChildIdx].attributes()[attrIdx].name().toString();
								
									if (strAttribute.toLowerCase() == 'name')
									{	
										arrVariables[varIdx] = "?"+_xmlInput.children()[rootChildIdx].children()[headChildIdx].attribute(strAttribute).toString();
									}
								}	
								varIdx++;
							}
							else if (_xmlInput.children()[rootChildIdx].children()[headChildIdx].name().localName.toString().toLowerCase() == "link")
							{
								//looking for all attributes in <link>
								for (var attrLinkIdx:int = 0; attrLinkIdx <  _xmlInput.children()[rootChildIdx].children()[headChildIdx].attributes().length(); attrLinkIdx++ )
								{
									var strAttributeLink:String = _xmlInput.children()[rootChildIdx].children()[headChildIdx].attributes()[attrLinkIdx].name().toString();
								
									if (strAttributeLink.toLowerCase() == 'href')
									{	
										arrLinks[linkIdx] = _xmlInput.children()[rootChildIdx].children()[headChildIdx].attribute(strAttributeLink).toString();
									}
								}
								linkIdx++;
							}
							
							
							
						}						
						break;
					case "results" :
						//looping for every single result
						for (var resultIdx:int = 0; resultIdx < _xmlInput.children()[rootChildIdx].children().length(); resultIdx++ ) 
						{	
							var aObject:Object = new Object();
							for (var bindingIdx:int = 0; bindingIdx < _xmlInput.children()[rootChildIdx].children()[resultIdx].children().length(); bindingIdx++ )
							{
								var textType:String = _xmlInput.children()[rootChildIdx].children()[resultIdx].children()[bindingIdx].children().name().localName.toString();
								var strBindingAttr:String = _xmlInput.children()[rootChildIdx].children()[resultIdx].children()[bindingIdx].attributes().name().toString();
								if (strBindingAttr.toLowerCase() == "name")
								{
									var strBindingVar:String = _xmlInput.children()[rootChildIdx].children()[resultIdx].children()[bindingIdx].attribute(strBindingAttr).toString();
									strBindingVar = "?" + strBindingVar;
									
									//Logger.debug("strBindingVar : ", strBindingVar, _xmlInput.children()[rootChildIdx].children()[resultIdx].children()[bindingIdx].children().toString());
									switch (textType.toLowerCase())
									{
										case "uri":
											
											aObject[strBindingVar] = new Resource(_xmlInput.children()[rootChildIdx].children()[resultIdx].children()[bindingIdx].children().toString());																			
											break;
										case "literal" :
											
											aObject[strBindingVar] = new Literal(_xmlInput.children()[rootChildIdx].children()[resultIdx].children()[bindingIdx].children().toString());																			
											
											for (var attrIdx2:int = 0; attrIdx2 <  _xmlInput.children()[rootChildIdx].children()[resultIdx].children()[bindingIdx].children().attributes().length(); attrIdx2++ )
											{
												
												var strAttrOfLiteral:String = _xmlInput.children()[rootChildIdx].children()[resultIdx].children()[bindingIdx].children().attributes()[attrIdx2].name().toString();
												if (strAttrOfLiteral.toLowerCase() == "datatype")
												{
													aObject[strBindingVar].setDatatype = _xmlInput.children()[rootChildIdx].children()[resultIdx].children()[bindingIdx].children().attributes()[attrIdx2].toString();
												}
												
												if (strAttrOfLiteral.toLowerCase() == "http://www.w3.org/xml/1998/namespace::lang")
												{
													aObject[strBindingVar].setLanguage = _xmlInput.children()[rootChildIdx].children()[resultIdx].children()[bindingIdx].children().attributes()[attrIdx2].toString();
												}
											}
											break;
										case "bnode" :
											
											aObject[strBindingVar] = new BlankNode(_xmlInput.children()[rootChildIdx].children()[resultIdx].children()[bindingIdx].children().toString());
											
											break;
									}
								
								}
								
							}
							arrResult[resultIdx] = aObject;
						}
						break;
					case "boolean" :
						this.booleanResult = _xmlInput.children()[rootChildIdx].toString();
						break;
					
				}
				
			}
			
			
			
			//return null;
		}
		
		private function set setVariables(_xmlInput:XML):void
		{
			//myXML.htmlNS::head.htmlNS::variable.attributes()
			
		}
		
		public function get getVariables():Array
		{
			return arrVariables;
		}
		
		private function set setNamespaceDeclaration(_xmlInput:XML):void
		{
			for (var i:uint = 0; i < _xmlInput.namespaceDeclarations().length; i++) 
			{
				var ns:Namespace = _xmlInput.namespaceDeclarations()[i]; 
				var prefix:String = ns.prefix;
				
				
				
				if (prefix == "") 
				{
					
					arrNamespaces.unshift(ns);
					
				}
				else
				{
					arrNamespaces.push(ns);
				}
			}
		}
		
		public function get getNamespaceDeclaration():Array
		{
			return arrNamespaces;
		}
		
		public function get getResults():Array
		{
			return arrResult;
		}
		
		public function get getLinks():Array
		{
			return arrLinks;
		}
		
		public function get getBooleanResult():String		
		{
			return booleanResult;
		}
	}
	
}