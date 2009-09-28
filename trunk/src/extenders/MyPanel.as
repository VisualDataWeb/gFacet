/********************************************
 title   : SuperPanel
 version : 1.5
 author  : Wietse Veenstra
 website : http://www.wietseveenstra.nl
 date    : 2007-03-30
********************************************/
 package extenders {
	import graphElements.ListItem;
	import flash.events.Event;
	import mx.containers.Panel;
	import mx.containers.VBox;
	import mx.controls.Button;
	import mx.controls.Label;
	import mx.core.EdgeMetrics;
	import mx.core.UIComponent;
	import mx.core.Application;
	import mx.events.DragEvent;
	import mx.events.EffectEvent;
	import mx.effects.Resize;
	import mx.managers.CursorManager;
	
	import flash.display.DisplayObject;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.events.MouseEvent;
	import mx.binding.utils.BindingUtils;
	//import org.osflash.thunderbolt.Logger;
	import org.flashdevelop.utils.FlashConnect;

	
	public class MyPanel extends Panel {
		[Bindable] public var showControls:Boolean = false;
		[Bindable] public var enableResize:Boolean = false;
		[Bindable] public var enableDrag:Boolean = false;
		[Bindable] public var listItem:ListItem = null;
		
		//Logger.hide = true;
		
		[Embed(source="../../assets/img/resizeCursor.png")]
		private static var resizeCursor:Class;
		
		
		private var	pTitleBar:UIComponent;
		private var oW:Number;
		private var oH:Number;
		private var oX:Number;
		private var oY:Number;
		//private var normalMaxButton:Button	= new Button();
		private var closeButton:Button		= new Button();
		private var resizeHandler:Button	= new Button();
		
		private var rollDownButton:Button	= new Button();
		
		private var minimizeButton:Button 	= new Button();
		
		private var pinButton:Button		= new Button();
		
		private var resultListSet:Button = new Button();
		
		private var upMotion:Resize			= new Resize();
		private var downMotion:Resize		= new Resize();
		private var oPoint:Point 			= new Point();
		private var resizeCur:Number		= 0;
		
		private var allButton:Button		= new Button();
		
		private var headerHeight:Number = 22;
		private var widthClosed:Number = 80;
		
		public var isPinned:Boolean = false;
				
		public function MyPanel() {}

		override protected function createChildren():void {
			super.createChildren();
			this.pTitleBar = super.titleBar;
			//this.setStyle("headerColors", [0xC3D1D9, 0xD2DCE2]);
			//this.setStyle("borderColor", 0xD2DCE2);
			this.doubleClickEnabled = true;
			
			if (enableResize) {
				this.resizeHandler.width     = 12;
				this.resizeHandler.height    = 12;
				this.resizeHandler.styleName = "resizeHndlr";
				this.rawChildren.addChild(resizeHandler);
				this.initPos();
			}
			
			if (showControls) {
				this.minimizeButton.width			= 10;
				this.minimizeButton.height			= 10;
				this.minimizeButton.styleName		= "minimizeBtn";
				this.minimizeButton.toolTip			= "scale node up / down";
				
				//this.normalMaxButton.width     	= 10;
				//this.normalMaxButton.height    	= 10;
				//this.normalMaxButton.styleName 	= "increaseBtn";
				
				this.closeButton.width     		= 10;
				this.closeButton.height    		= 10;
				this.closeButton.styleName 		= "closeBtn";
				this.closeButton.toolTip		= "close node";
				
				this.pinButton.width     		= 10;
				this.pinButton.height    		= 10;
				this.pinButton.styleName 		= "pinBtn";
				this.pinButton.toolTip			= "pin node";
				
				this.rollDownButton.width 		= 8;
				this.rollDownButton.height		= 8;
				this.rollDownButton.styleName	= "rollUpBtn";
				
				this.allButton.width			= 20;
				this.allButton.height			= 15;
				this.allButton.label 			= "all";
				this.allButton.styleName 		= "allBtn";
				this.allButton.toolTip			= "show all";
				this.allButton.selected 		= false;	//initally selected //eigentlich sollte das hier an das Model gekoppelt werden!!
				
				this.resultListSet.width		= 20;
				this.resultListSet.height 		= 15;
				this.resultListSet.label		= "RS";
				this.resultListSet.toolTip		= "set as Result Set";
				this.resultListSet.styleName 	= "allBtn";
				this.resultListSet.selected		= this.listItem.facet.isResultSet;	//eigentlich sollte das hier an das Model gekoppelt werden!!
				//this.resultListSet.toggle	= true;
				
				//only for the evaluation: 
				this.pTitleBar.addChild(this.allButton);
				
				//this.pTitleBar.addChild(this.minimizeButton);
				//this.pTitleBar.addChild(this.normalMaxButton);
				this.pTitleBar.addChild(this.closeButton);
				this.pTitleBar.addChild(this.pinButton);
				//this.pTitleBar.addChild(this.rollDownButton);
				//only for the evaluation 
				this.pTitleBar.addChild(this.resultListSet);
				
			}
			
			this.positionChildren();	
			this.addListeners();
			
			//initally closed
			//this.height = headerHeight + 2;
			//this.width = widthClosed;
			//this.normalMaxButton.width = 0;
			//this.closeButton.width = 0;
			//this.pinButton.width = 0;
			//this.resizeHandler.visible = false;
		}
		
		public function initPos():void {
			this.oW = this.width;
			this.oH = this.height;
			this.oX = this.x;
			this.oY = this.y;
		}
	
		public function positionChildren():void {
			if (showControls) {
				this.resultListSet.buttonMode = true;
				this.resultListSet.useHandCursor = true;
				this.resultListSet.x = this.unscaledWidth - this.resultListSet.width - 65;
				this.resultListSet.y = 4;
				
				this.allButton.buttonMode	= true;
				this.allButton.useHandCursor = true;
				this.allButton.x = this.unscaledWidth - this.allButton.width - 40;
				this.allButton.y = 4;
				
				this.pinButton.buttonMode    = true;
				this.pinButton.useHandCursor = true;
				this.pinButton.x = this.unscaledWidth - this.pinButton.width - 24;
				this.pinButton.y = 8;
				
				//this.minimizeButton.buttonMode		= true;
				//this.minimizeButton.useHandCursor	= true;
				//this.minimizeButton.x	= this.unscaledWidth - this.minimizeButton.width - 24;
				//this.minimizeButton.y 	= 8;
				
				//this.normalMaxButton.buttonMode    = true;
				//this.normalMaxButton.useHandCursor = true;
				//this.normalMaxButton.x = this.unscaledWidth - this.normalMaxButton.width - 24;
				//this.normalMaxButton.y = 8;
				this.closeButton.buttonMode	   = true;
				this.closeButton.useHandCursor = true;
				this.closeButton.x = this.unscaledWidth - this.closeButton.width - 8;
				this.closeButton.y = 8;
				
				//this.rollDownButton.buttonMode    = true;
				//this.rollDownButton.useHandCursor = true;
				//this.rollDownButton.x = 4;// this.unscaledWidth - this.normalMaxButton.width - 24;
				//this.rollDownButton.y = 8;
			}
			
			if (enableResize) {
				this.resizeHandler.y = this.unscaledHeight - resizeHandler.height - 1;
				this.resizeHandler.x = this.unscaledWidth - resizeHandler.width - 1;
			}
		}
		
		public function addListeners():void {
			this.addEventListener(MouseEvent.CLICK, panelClickHandler);
			//this.pTitleBar.addEventListener(MouseEvent.DOUBLE_CLICK, titleBarDoubleClickHandler);
			
			
			if (enableDrag) {
				this.pTitleBar.addEventListener(MouseEvent.MOUSE_DOWN, titleBarDownHandler);
			}
			
			if (showControls) {
				this.closeButton.addEventListener(MouseEvent.CLICK, closeClickHandler);
				this.minimizeButton.addEventListener(MouseEvent.CLICK, rollDownClickHandler);
				//this.normalMaxButton.addEventListener(MouseEvent.CLICK, normalMaxClickHandler);
				this.rollDownButton.addEventListener(MouseEvent.CLICK, rollDownClickHandler);
				this.pinButton.addEventListener(MouseEvent.CLICK, pinClickHandler);
				
				this.allButton.addEventListener(MouseEvent.CLICK, allClickHandler);
				this.resultListSet.addEventListener(MouseEvent.CLICK, resultListClickHandler);
				
				BindingUtils.bindSetter(updateResultListBtn, listItem.facet, "isResultSet");
				
				//BindingUtils.bindProperty(this.resultListSet, "enabled", (data as ListItem).facet, "isResultList");
				//BindingUtils.bindProperty(this.resultListSet, "selected", (data as ListItem).facet, "isResultList");
			}
			
			if (enableResize) {
				this.resizeHandler.addEventListener(MouseEvent.MOUSE_OVER, resizeOverHandler);
				this.resizeHandler.addEventListener(MouseEvent.MOUSE_OUT, resizeOutHandler);
				this.resizeHandler.addEventListener(MouseEvent.MOUSE_DOWN, resizeDownHandler);
			}
		}
		
		public function updateResultListBtn(isRS:Boolean):void {
			if (!isRS) {
				/*Logger.debug("updateRS", isRS);
				//this.resultListSet.visible = false;
				this.resultListSet.selected = true;
				
				//this.resultListSet.enabled = false;
			}else {*/
				//Logger.debug("updateRS", isRS);
				FlashConnect.trace("updateRS"+ isRS+" , "+this.listItem.id);
				//this.resultListSet.visible = true;
				this.resultListSet.selected = false;
				
				//this.resultListSet.enabled = true;
			}
		}
		
		public function panelClickHandler(event:MouseEvent):void {
			this.pTitleBar.removeEventListener(MouseEvent.MOUSE_MOVE, titleBarMoveHandler);
			this.parent.setChildIndex(this, this.parent.numChildren - 1);
			this.panelFocusCheckHandler();
		}
		
		public function titleBarDownHandler(event:MouseEvent):void {
			this.pTitleBar.addEventListener(MouseEvent.MOUSE_MOVE, titleBarMoveHandler);
		}
			
		public function titleBarMoveHandler(event:MouseEvent):void {
			if (this.width < screen.width) {
				Application.application.parent.addEventListener(MouseEvent.MOUSE_UP, titleBarDragDropHandler);
				this.pTitleBar.addEventListener(DragEvent.DRAG_DROP,titleBarDragDropHandler);
				this.parent.setChildIndex(this, this.parent.numChildren - 1);
				this.panelFocusCheckHandler();
				this.alpha = 0.5;
				this.startDrag(false, new Rectangle(0, 0, screen.width - this.width, screen.height - this.height));
				
			}
			/**
			 * added by Philipp Heim
			 */
			event.stopImmediatePropagation();
		}
		
		public function titleBarDragDropHandler(event:MouseEvent):void {
			this.pTitleBar.removeEventListener(MouseEvent.MOUSE_MOVE, titleBarMoveHandler);
			this.alpha = 1.0;
			this.stopDrag();
		}
		
		public function panelFocusCheckHandler():void {
			//performance probleme!
			/*for (var i:int = 0; i < this.parent.numChildren; i++) {
				var child:UIComponent = UIComponent(this.parent.getChildAt(i));
				if (this.parent.getChildIndex(child) < this.parent.numChildren - 1) {
					child.setStyle("headerColors", [0xe8e8e8, 0xc8c8c8]);
					child.setStyle("borderColor", 0xc8c8c8);
				} else if (this.parent.getChildIndex(child) == this.parent.numChildren - 1) {
					child.setStyle("headerColors", [0xc8c8c8, 0xa8a8a8]);
					child.setStyle("borderColor", 0xa8a8a8);
				}
			}*/
		}
		
		public function rollDownClickHandler(event:MouseEvent):void {
			this.pTitleBar.removeEventListener(MouseEvent.MOUSE_MOVE, titleBarMoveHandler);
			Application.application.parent.removeEventListener(MouseEvent.MOUSE_UP, resizeUpHandler);
			
			this.upMotion.target = this;
			this.upMotion.duration = 300;
			this.upMotion.heightFrom = oH;
			this.upMotion.widthFrom = oW;
			this.upMotion.heightTo = headerHeight +2;
			this.upMotion.widthTo = widthClosed;
			this.upMotion.end();
			
			this.downMotion.target = this;
			this.downMotion.duration = 300;
			this.downMotion.heightFrom = headerHeight + 2;
			this.downMotion.widthFrom = widthClosed; //+2
			this.downMotion.heightTo = oH;
			this.downMotion.widthTo = oW;
			this.downMotion.end();
			
			
			if (this.width < screen.width) {
				if (this.rollDownButton.styleName == "rollUpBtn") {
					
					this.upMotion.play();
					
					this.pTitleBar.removeChild(this.allButton);
					this.pTitleBar.removeChild(this.closeButton);
					this.pTitleBar.removeChild(this.pinButton);
					this.pTitleBar.removeChild(this.resultListSet);
					this.resizeHandler.visible = false;
					this.rollDownButton.styleName = "rollDownBtn";
				} else {
					
					this.downMotion.play();
					
					this.downMotion.addEventListener(EffectEvent.EFFECT_END, endEffectEventHandler);
					
					this.rollDownButton.styleName = "rollUpBtn";
				}
			}
		}
		
						
		public function endEffectEventHandler(event:EffectEvent):void {
			this.pTitleBar.addChild(this.allButton);
			this.pTitleBar.addChild(this.closeButton);
			this.pTitleBar.addChild(this.pinButton);
			this.pTitleBar.addChild(this.resultListSet);
			this.resizeHandler.visible = true;
		}

		/*public function normalMaxClickHandler(event:MouseEvent):void {
			if (this.normalMaxButton.styleName == "increaseBtn") {
				if (this.height > (headerHeight + 2)) {
					this.initPos();
					this.x = 0;
					this.y = 0;
					this.width = screen.width;
					this.height = screen.height;
					this.normalMaxButton.styleName = "decreaseBtn";
					this.positionChildren();
				}
			} else {
				this.x = this.oX;
				this.y = this.oY;
				this.width = this.oW;
				this.height = this.oH;
				this.normalMaxButton.styleName = "increaseBtn";
				this.positionChildren();
			}
		}*/
		
		private function app(): Main {
			return Application.application as Main;
		}
			
		public function closeClickHandler(event:MouseEvent):void {
			this.removeEventListener(MouseEvent.CLICK, panelClickHandler);
			//this.parent.removeChild(this);
			listItem.closeButtonClicked();
			//app().removeListItem(this.data as ListItem);
		}
		
		public function resizeOverHandler(event:MouseEvent):void {
			this.resizeCur = CursorManager.setCursor(resizeCursor);
		}
		
		public function resizeOutHandler(event:MouseEvent):void {
			CursorManager.removeCursor(CursorManager.currentCursorID);
		}
		
		public function resizeDownHandler(event:MouseEvent):void {
			Application.application.parent.addEventListener(MouseEvent.MOUSE_MOVE, resizeMoveHandler);
			Application.application.parent.addEventListener(MouseEvent.MOUSE_UP, resizeUpHandler);
			this.resizeHandler.addEventListener(MouseEvent.MOUSE_OVER, resizeOverHandler);
			this.panelClickHandler(event);
			this.resizeCur = CursorManager.setCursor(resizeCursor);
			this.oPoint.x = mouseX;
			this.oPoint.y = mouseY;
			this.oPoint = this.localToGlobal(oPoint);
			
			/**
			 * added by Philipp Heim
			 */
			event.stopImmediatePropagation();
		}
		
		public function resizeMoveHandler(event:MouseEvent):void {
			this.stopDragging();

			var xPlus:Number = Application.application.parent.mouseX - this.oPoint.x;			
			var yPlus:Number = Application.application.parent.mouseY - this.oPoint.y;
			
			if (this.oW + xPlus > 140) {
				this.width = this.oW + xPlus;
			}
			
			if (this.oH + yPlus > 80) {
				this.height = this.oH + yPlus;
			}
			this.positionChildren();
		}
		
		public function resizeUpHandler(event:MouseEvent):void {
			Application.application.parent.removeEventListener(MouseEvent.MOUSE_MOVE, resizeMoveHandler);
			Application.application.parent.removeEventListener(MouseEvent.MOUSE_UP, resizeUpHandler);
			CursorManager.removeCursor(CursorManager.currentCursorID);
			this.resizeHandler.addEventListener(MouseEvent.MOUSE_OVER, resizeOverHandler);
			this.initPos();
		}
		
		public function pinClickHandler(event:MouseEvent):void {
			if (this.pinButton.styleName == "pinBtn") {
				if(this.listItem != null) this.listItem.pin();
				this.pinButton.styleName = "unpinBtn";
				this.isPinned = true;
			}else {
				if(this.listItem != null) this.listItem.unpin();
				this.pinButton.styleName = "pinBtn";
				this.isPinned = false;
			}
		}
		
		public function allClickHandler(event:MouseEvent):void {
			if (!this.allButton.selected) {
				listItem.setShowAll(true);
				this.allButton.selected = true;
				
			}else {
				listItem.setShowAll(false);
				this.allButton.selected = false;
			}
		}
		
		public function resultListClickHandler(event:MouseEvent):void {
			//FlashConnect.trace("before: resultListClickHandler: "+this.resultListSet.selected+", "+this.listItem.id);
			if (!this.resultListSet.selected) {
				this.resultListSet.selected = true;
				listItem.setAsResultSet();
			}
			//FlashConnect.trace("after: resultListClickHandler: "+this.resultListSet.selected+", "+this.listItem.id);
		}
		
		
	}
	
}