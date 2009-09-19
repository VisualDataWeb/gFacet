/**
 * Copyright (C) 2009 Philipp Heim and Timo Stegemann (email to: heim.philipp@googlemail.com)
 * 
 * This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License along with this program; if not, see <http://www.gnu.org/licenses/>.
 */ 

import com.adobe.flex.extras.controls.springgraph.Graph;
import connection.MirroringConnection_Knoodl;
import connection.MirroringConnection_SWORE;
import connection.RemotingConnection;
import connection.DirectConnection;
import connection.MirroringConnection;
import flash.events.MouseEvent;
import graphElements.*;
import mainMenu.MainMenuController;
import graphElements.GraphController;
import connection.SPARQLConnection;
import mx.collections.ArrayCollection;
import mx.managers.PopUpManager;
import popup.ExpertSettings;

//FLAG
private static var connectionType:String = "mirroring"; // "mirroring_knoodl"; // "mirroring"; // "mirroring_swore"; // "mirroring";	//indirect (over PHP) direct or mirroring connection to an SPARQL endpoint

[Bindable]
public var graph:Graph = new Graph();

[Bindable]
public var elementClasses:ArrayCollection = new ArrayCollection();	//one can be chosen as the mainClass by the user
[Bindable]
private var currentElementClass:ElementClass = null; 

private var myConnection:SPARQLConnection = null;

private var sparqlEndpoint:String = "";
private var phpSessionID:String = "";
private var basicGraph:String = "";

private function setup(): void {
	trace("setup");
	//Logger.hide = false;// true;
	sparqlEndpoint = Application.application.parameters.sparqlEndpoint;
	phpSessionID = Application.application.parameters.PHPSESSID;
	basicGraph = Application.application.parameters.basicGraph;
	//Logger.debug("sparqlEndpoint: ", sparqlEndpoint);
	//Logger.debug("sessionId: ", phpSessionID);
	//Logger.debug("basicGraph: ", basicGraph);
	
	//ontowikiPluginTest
	/*sparqlEndpoint = "http://softwiki1.ontowiki.net/service/sparql";
	basicGraph = "http://ns.softwiki.de/req/";
	phpSessionID = "a9b28d843fb95f22a4bc93ad046deef2";
	*/
	if(connectionType == "indirect") {
		myConnection = new RemotingConnection("http://softwiki.interactivesystems.info/ECIR/flashservices/gateway.php", "FacetedGraphService");
	}else {
		if ((sparqlEndpoint != null) && (sparqlEndpoint.length > 0)) {
			/*if ((phpSessionID != null) && (phpSessionID.length > 0)) {*/
				if ((basicGraph != null) && (basicGraph.length > 0)) {
					
					if(connectionType == "direct") {
						myConnection = new DirectConnection(sparqlEndpoint, basicGraph, phpSessionID);
					}else if (connectionType == "mirroring") {
						//myConnection = new MirroringConnection_SWORE(sparqlEndpoint, basicGraph, phpSessionID);
						myConnection = new MirroringConnection(sparqlEndpoint, basicGraph, phpSessionID);
					}else {
						//Logger.error("no correct connectionType set!");
					}
					
					//myConnection = new OntowikiConnection(sparqlEndpoint, basicGraph, phpSessionID);
				}else {
					//Logger.error("no basicGraph");
				}
			/*}else {
				Logger.error("no phpSessionId");
			}*/
		}else {
			//Logger.error("no sparqlEndpoint defined!");
		}
		
		if (myConnection == null) {
			if(connectionType == "direct") {
				myConnection = new DirectConnection("http://dbpedia.org/sparql", "http://dbpedia.org");
			}else if(connectionType == "mirroring") {
				myConnection = new MirroringConnection("http://dbpedia.org/sparql", "http://dbpedia.org");
			}else if (connectionType == "mirroring_swore") {
				//Security.allowDomain("http://mms.ontowiki.net/mms_sandbox/");
				myConnection = new MirroringConnection_SWORE("http://mms.ontowiki.net/intranet/service/sparql", "http://mms.ontowiki.net/softwiki/MMS_Intranet/"); //"http://mms.ontowiki.net/mms_sandbox/service/sparql", "http://mms.ontowiki.net/softwiki/MMS_Intranet/"); // http://mms.ontowiki.net/service/sparql", "http://mms.ontowiki.net/");// , "http://testdb.softwiki.de");
			}else if (connectionType == "mirroring_knoodl") {
				myConnection = new MirroringConnection_Knoodl("http://www.knoodl.com/ui/groups/Tutorial/vocab/Wine/sparql");
			}else{
				//Logger.error("no correct connectionType set!");
			}
		}
	}
	
	
	init();
	//Security.allowDomain("http://134.91.35.75");
	//smallExternalData.send();
	//myConnection.sendCommand("getElementClasses", getElementClasses_Result);
	//FlashConnect.trace("start");
	//restart();
	//roamer.repulsionFactor = 0.5;
	//roamer.showHistory = true;
	
	//var initialItem:ListItem = new ListItem("test1", null, myConnection, rootFacet, null, getHighlightColor());
	//graph.add(initialItem);
	//setCurrentItem(initialItem);
	
	//ExternalInterface.addCallback("myFlexFunction",cleanUp);
}

public function setStopLayerVisibility(_isVisible:Boolean):void {
	stopLayer.visible = _isVisible;
}

private function changeHelp1(): void {
	help.text = "INFO: Drag the background to scroll";
	var t:Timer = new Timer(30000, 1);
	t.addEventListener(TimerEvent.TIMER_COMPLETE, onTimerComplete);
	t.start(); 	
}

public function onTimerComplete(evt:TimerEvent):void{
	help.visible = false;
}

private function settingsClickHandler(event:MouseEvent):void {
	var pop:ExpertSettings = PopUpManager.createPopUp(this, ExpertSettings) as ExpertSettings;
}
