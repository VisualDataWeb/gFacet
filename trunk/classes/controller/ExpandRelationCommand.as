/**
* ...
* @author Default
* @version 0.1
*/

package classes.controller {
	import classes.view.ElementItem;
	import classes.view.RelationItem;
	import com.flashdb.SimRelation;
	import flash.events.Event;
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	import mx.core.Application;
	import com.adobe.flex.extras.controls.springgraph.Item;
	import org.flashdevelop.utils.FlashConnect;

	public class ExpandRelationCommand extends Command{
		
		public var eItem:ElementItem;
		public var simRel:SimRelation;
		/*public var relations:Array;
		public var toClusters:Array;
		public var fromNode:Node;
		public var graph:Graph;
		*/
		public function ExpandRelationCommand(_eItem:ElementItem, _simRel:SimRelation) {
			this.eItem = _eItem;
			this.simRel = _simRel;
			/*this.relations = _relations;
			this.toClusters = _toClusters;
			this.fromNode = _fromN;
			this.fromNode.numberOfCommands++;
			this.graph = _graph;*/
			this.text = "ExpandRelationCommand, simRel.id: "+simRel.id;
		}
		
		private function app(): DynamicChains {
			return Application.application as DynamicChains;
		}
		
		/**
		 * executes the command and notifies all listeners after the command has been executed
		 */
		public override function execute():void {
			
			var rItem:RelationItem = app().getRelationItem(this.simRel);
			this.eItem.relationItems.addItem(rItem);
			
			//var save:Item = app().roamer.currentItem;
			if(!rItem.explored){	//if not yet explored
				if(rItem.hasBeenShown){	//but has been shown allready
					//we make this relation visible permanently
					FlashConnect.trace("rItem.id: "+rItem.id);
					
					//app().roamer.currentItem = rItem;
					
					//app().roamer.showItem(rItem);
					rItem.explored = true;
				}else{	//if not shown allready
					rItem.hasBeenShown = true;
				}
			}
			//app().roamer.currentItem = save;
			var timer:Timer = new Timer(6000,1);	//delay, repeatCount
			timer.addEventListener(TimerEvent.TIMER, this.timerEventListener);
			timer.start();
			
		}
		
		private function timerEventListener(e:Event):void{
			
			this.hasBeenExecuted();
		}
		
		public override function undo():void{
			
		}
	}
	
}
