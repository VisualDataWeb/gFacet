/**
 * Copyright (C) 2009 Philipp Heim and Timo Stegemann (email to: heim.philipp@googlemail.com)
 * 
 * This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License along with this program; if not, see <http://www.gnu.org/licenses/>.
 */ 

import flash.events.MouseEvent;
import flash.events.TimerEvent;
import mx.effects.easing.Elastic;
import flash.utils.Timer;
import mx.events.ItemClickEvent;
import mx.collections.Sort;
import mx.collections.SortField;
		

private var menuTimer:Timer;
private var fastMenuTimer:Timer;
private var menuVisible:Boolean;
[Bindable]
private var showMenuButton:Boolean;

[Embed(source="../../assets/img/Menu.png")]
[Bindable]
public var btnMenuIcon:Class;
		
		
public function init():void {
	//trace("init!");
	initMenuMoveOn.play();
	menuTimer = new Timer(2000, 0);
	menuTimer.addEventListener(TimerEvent.TIMER, onMenuTimeOut);
	fastMenuTimer = new Timer(500, 0);
	fastMenuTimer.addEventListener(TimerEvent.TIMER, onFastMenuTimeOut);
}

private function onMenuTimeOut(event:TimerEvent):void{
	//trace('menuTimeOut'+event);
	menuTimer.stop();
	hideMenu();
}
private function onFastMenuTimeOut(event:TimerEvent):void{
	//trace(event);
	fastMenuTimer.stop();
	hideMenu();
}
private function setMenuVisible(status:Boolean):void{
	menuVisible=status;
	if(status){
		showMenuButton=false;
	}else{
		showMenuButton=true;
	}
}
private function showMenu():void{
	if(!menuVisible){
		initMenuMoveOn.play();
		menuTimer.start();
	}
	//trace('[moveOnisPlaying]'+initMenuMoveOn.isPlaying);
}
private function hideMenu(event:MouseEvent=null):void{
	if(menuVisible && (currentElementClass != null)){	//if menu is visible and an initial elementClass has been chosen already
		if(event!=null){
			//trace(event.currentTarget);
			//trace('[initMenuMoveOff]'+initMenuMoveOff.isPlaying);
			//trace('[moveOnisPlaying]'+initMenuMoveOn.isPlaying);
			if(!initMenuMoveOff.isPlaying || initMenuMoveOn.isPlaying){
				initMenuMoveOff.play();	
				//epvMenu.removeEventListener(MouseEvent.ROLL_OVER,
			}
		}else{
			//timer timed out
			initMenuMoveOff.play();	
		}
	}
	//trace('[moveOffisPlaying]'+initMenuMoveOff.isPlaying);
}
private function mouseAction(event:MouseEvent=null):void{
	//trace(event.target);
	//trace(event);
	if(event.target == 'animatedMenu0'){
		switch(event.type){
			case 'rollOut':
				//trace('rollOutEpv0');
				break;
			case 'rollOver':
				menuTimer.start();
				//trace('rollOverEpv0');
				break;
			case 'mouseMove':
				//trace('mouseMove');
				break;
		}
	}else{
		switch(event.type){
			case 'rollOut':
				if(!menuTimer.running){
					fastMenuTimer.start();	
				}						
				//trace('rollOutElse');
				break;
			case 'rollOver':
				showMenu();
				//trace('rollOverElse');
				break;
			case 'mouseMove':
				menuTimer.stop();
				//trace('mouseMove');
				break;
		}
	}
	
}
private function timerAction(action:String,target:String=null):void{
	//trace(event);
	switch(action){
		case 'rollOut':
			menuTimer.start();
			break;
		case 'rollOver':
			//trace('rollOver');
			break;
		case 'mouseMove':
			//trace('mouseMove');
			break;
	}
}
private function showStatus():void{
	//trace('[moveOnisPlaying]'+initMenuMoveOn.isPlaying);
	//trace('[moveOffisPlaying]'+initMenuMoveOff.isPlaying);
}

public function getElementClasses(userInput:String):void {
	currentElementClass = null;
	elementClasses = new ArrayCollection();
	//Logger.debug("test");
	//Logger.debug("send getElementClasses for", userInput);
	
	
	var f:Facet = new Facet("conceptSearchFacet", null, "conceptChain", null, null, null, new Property("numOfInstances", "numOfInstances"), conceptsPerPage, 0);
	
	myConnection.sendCommand('getElementClasses', getElementClasses_Result, [userInput, f]); //facet->property->value/type = userInput
	//myConnection.sendCommand('getConcepts', getConcepts_Result, [f, userInput]);
	
	//CursorManager.setBusyCursor();
}

public function getElementClasses_Result(_list:Array):void {
	//CursorManager.removeBusyCursor();
	//FlashConnect.trace("RETURNED: ElementClasses ");
	if (_list.length == 0) {
		_list[0] = "no results";
	}
	elementClasses = new ArrayCollection(_list);
	
	var cols:Array = classesDG.columns;
	if (elementClasses[0] is String) {
		
	}else {
		if (elementClasses[0].numberOfObjectInstances >= 0) {
			
			if (cols.length == 1) {
				var col:DataGridColumn = new DataGridColumn();
				col.dataField = "numberOfObjectInstances";
				col.headerText = "#objects"; 
				col.width = 70;
				
				cols.push(col);
				classesDG.columns = cols;
			}
			
			//Sort the elementClasses according to the number of instances they have
			var numericDataSort:Sort = new Sort();
			numericDataSort.fields = [new SortField("numberOfObjectInstances", false, true, true)];
			elementClasses.sort = numericDataSort;
		}else {
			if (cols.length > 1) {
				cols.splice(1, 1);
				classesDG.columns = cols;
			}
			
			var alphaDataSort:Sort = new Sort();
			alphaDataSort.fields = [new SortField("label", false, false, false)];
			elementClasses.sort = alphaDataSort;
		}
	}
	
	elementClasses.refresh();
	//TODO
	//createNavBar(5, 0);	// (numberOfPages, offset)
}

/*public function getConcepts_Result(_conceptChain:Chain):void {
	
}*/

public function getElementClasses_Fault(fault:String):void {
	//CursorManager.removeBusyCursor();
	//FlashConnect.trace("There was a problem with getElementClasses: " + fault);
	//FlashConnect.trace("-------------");
}

private function setInitialElementClass(_class:ElementClass): void {
	//FlashConnect.trace("change currentElementClass");
	currentElementClass = _class;
	
	//startconceptlabel.visible = false;
	//classdropdown.visible = false;
	var listItem:ListItem = getListItem(currentElementClass,  new Facet("firstFacet_"+_class.id, null), null);
	
	//currentResultSet = listItem;	//schlecht!!
	//setCurrentItem(listItem);
	//proxy.getElements(getElements_Result, getElements_Fault, currentElementClass);
	changeHelp1();
	
	listItem.setAsResultSet();	//initially the first listItem is also the resultSet!
	//restart();
}

/* ---------- conceptNav-------------------*/
[Bindable] public var conceptNavData:ArrayCollection = new ArrayCollection();
[Bindable] public var conceptsPerPage:uint = 10;
private var index:uint = 0;	//wofür?? aber möglicherweise wichtig
public var navSize:uint = 4;	//max number of page-buttons below the list (1,2,3,4)

private function navigateConcepts(event:ItemClickEvent):void {
	/*data.setPagingIndex(event.item.data);
	//data.refreshDataProvider(event.item.data);
	var lb:String = event.item.label.toString();
	if( lb.indexOf("<") > -1 || lb.indexOf(">") > -1 ){	//if either <<, <, > or >> has been clicked
		data.createNavBar(Math.ceil(data.chain.totalNumber/data.elementsPerPage),event.item.data);
		if( event.item.data == 0 ){
			pageNav.selectedIndex = 0;
		}else{
			pageNav.selectedIndex = 2;
		}
	}*/
}

/**
 * creates the paging navigation with respect to the current offset and the number of pages
 * @param	pages 	Math.ceil(data.visibleElements.length/data.elementsPerPage)
 * @param	set 	offset (current page!)
 */
public function createNavBar(numberOfPages:uint = 1, set:uint = 0):void {
	//Logger.debug("createNavBar");
	//Logger.debug("number of pages", numberOfPages);
	//Logger.debug("offset", set);
	//Logger.debug("navSize", navSize);
	conceptNavData.removeAll();
	if( numberOfPages > 1 ){
		if( set != 0 ){
			conceptNavData.addItem({label:"<<",data:0});	//first page!
			if( (set - navSize ) >= 0 ){	//navSize = number of pageButtons //if currentPage > navSize
				conceptNavData.addItem({label:"<",data:set - navSize});
			}else{
				conceptNavData.addItem({label:"<",data:0});
			}
		}
		var pg:uint = 0;
		for( var x:uint = 0; x < navSize; x++){	//create the pageButtons (1,2,3...)
			pg = x + set;
			conceptNavData.addItem({label: pg + 1,data: pg});	//for example: label=1 and data=0
		}
		//Logger.debug("conceptNavData.length", conceptNavData.length);
		
		if( pg < numberOfPages - 1 ){	//if more pages exist than navSize!
			conceptNavData.addItem({label:">", data:pg + 1});	//label and data 
			conceptNavData.addItem({label:">>", data:numberOfPages - navSize});	//last page! numberOfPages - this.elementsPerPage
		}
	}
}
