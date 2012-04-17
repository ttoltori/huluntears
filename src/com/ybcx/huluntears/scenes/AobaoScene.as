package com.ybcx.huluntears.scenes{
	
	
	import com.hydrotik.queueloader.QueueLoader;
	import com.hydrotik.queueloader.QueueLoaderEvent;
	import com.ybcx.huluntears.events.GameEvent;
	import com.ybcx.huluntears.scenes.base.BaseScene;
	import com.ybcx.huluntears.ui.STProgressBar;
	
	import flash.display.BitmapData;
	
	import starling.animation.Tween;
	import starling.core.Starling;
	import starling.display.Button;
	import starling.display.Image;
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.textures.Texture;
	
	
	public class AobaoScene extends BaseScene{
		
		//---------- 图片路径 ----------------------
		private var _aobaoFocusPath:String = "assets/sceaobao/aobao_focus.png";
		private var _aobaoHeadPath:String = "assets/sceaobao/aobao_head.png";
		//道具栏背景
		private var _toolBackgroundPath:String = "assets/sceaobao/Toolbar.png";
		//卷轴
		private var _toolReelUpPath:String = "assets/sceaobao/Toolbar_Reel_1.png";
		private var _toolReelDownPath:String = "assets/sceaobao/Toolbar_Reel_2.png";
		//左右箭头
		private var _toolLeftArrowPath:String = "assets/sceaobao/toolbar_left.png";
		private var _toolRightArrowPath:String = "assets/sceaobao/toolbar_right.png";
		//返回大地图场景箭头
		private var _toolReturnPath:String = "assets/sceaobao/tool_return.png";
		//宝石
		private var _jewelPath:String = "assets/sceaobao/jewel.png";
		//隐藏地图
		private var _hidedMapPath:String = "assets/sceaobao/hidedmap.png";
		
		//--------- 图片对象 -------------------
		private var aobaoFocus:Image;
		private var aobaoHead:Image;
		private var toolBackground:Image;
		private var toolReelUp:Image;
		private var toolReelDown:Image;
		private var toolLeftArrow:Image;
		private var toolRightArrow:Image;
		private var toolReturn:Image;
		private var jewel:Image;
		private var hidedMap:Image;
		
		//玻璃板
		private var _touchBoard:Image;
		
		//loading...
		private var _progressbar:STProgressBar;
		//下载队列
		private var _queLoader:QueueLoader;					
		private var _loadCompleted:Boolean;
		
		private var _mask:Image;
		private var _reelTool:Button;
		
		
		
		
		/**
		 * 敖包特写场景
		 */ 
		public function AobaoScene(){
			super();
			
			//下载队列
			_queLoader = new QueueLoader();
			_queLoader.addEventListener(QueueLoaderEvent.ITEM_COMPLETE, onItemLoaded);
			_queLoader.addEventListener(QueueLoaderEvent.ITEM_ERROR,onItemError);
			_queLoader.addEventListener(QueueLoaderEvent.QUEUE_COMPLETE, onQueComplete);
								
			this.addEventListener(TouchEvent.TOUCH, onSceneTouch);
		}
		
		/**
		 * 处理返回按钮
		 */ 
		private function onSceneTouch(evt:TouchEvent):void{
			var touch:Touch = evt.getTouch(this);
			if (touch == null) return;
			
			if(touch.globalX>AppConfig.VIEWPORT_WIDTH-100 && touch.globalY<AppConfig.VIEWPORT_HEIGHT){
				if(toolReturn) toolReturn.visible = true;
			}else{
				if(toolReturn) toolReturn.visible = false;
			}
		}
		
		override protected function onStage(evt:Event):void{
			super.onStage(evt);
			
			if(_loadCompleted) return;
			
			//加个玻璃板，好响应鼠标动作
			//后添加玻璃板，铺满整个应用
			var bd:BitmapData = new BitmapData(this.stage.stageWidth,this.stage.stageHeight,true,0x01FFFFFF);						
			var tx:Texture = Texture.fromBitmapData(bd);
			_touchBoard = new Image(tx);
			this.addChild(_touchBoard);
			
			_queLoader.addItem(_aobaoFocusPath,null, {title : _aobaoFocusPath});
			_queLoader.addItem(_aobaoHeadPath,null, {title : _aobaoHeadPath});
			_queLoader.addItem(_toolBackgroundPath,null, {title : _toolBackgroundPath});
			_queLoader.addItem(_toolReelUpPath,null, {title : _toolReelUpPath});
			_queLoader.addItem(_toolReelDownPath,null, {title : _toolReelDownPath});
			_queLoader.addItem(_toolLeftArrowPath,null, {title : _toolLeftArrowPath});
			_queLoader.addItem(_toolRightArrowPath,null, {title : _toolRightArrowPath});
			_queLoader.addItem(_toolReturnPath,null, {title : _toolReturnPath});
			_queLoader.addItem(_jewelPath,null, {title : _jewelPath});
			_queLoader.addItem(_hidedMapPath,null, {title : _hidedMapPath});
			
			//发出请求
			_queLoader.execute();
			
			_progressbar = new STProgressBar(0x666666,this.stage.stageWidth,2,"载入敖包场景...");
			//放在舞台中央
			_progressbar.x = 0;
			_progressbar.y = this.stage.stageHeight >>1;
			this.addChild(_progressbar);
		}
		
		//单个图片加载完成
		private function onItemLoaded(evt:QueueLoaderEvent):void{
			if(evt.title==_aobaoFocusPath){
				aobaoFocus = new Image(Texture.fromBitmap(evt.content));
				this.addChild(aobaoFocus);
				
				aobaoFocus.y = -aobaoFocus.height;
				trace("aobao height: "+aobaoFocus.height);
				
				//执行动画
				var tween:Tween = new Tween(aobaoFocus, 3);
				tween.animate("y",0);
				tween.onComplete = startToPlay;
				Starling.juggler.add(tween);
				
			}
			if(evt.title==_aobaoHeadPath){
				aobaoHead = new Image(Texture.fromBitmap(evt.content));
				trace("loaded: "+_aobaoHeadPath);
			}
			if(evt.title==_toolBackgroundPath){
				toolBackground = new Image(Texture.fromBitmap(evt.content));
				trace("loaded: "+_toolBackgroundPath);
			}
			if(evt.title==_toolReelUpPath){
				toolReelUp = new Image(Texture.fromBitmap(evt.content));
				trace("loaded: "+_toolReelUpPath);
			}
			if(evt.title==_toolReelDownPath){
				toolReelDown = new Image(Texture.fromBitmap(evt.content));
				trace("loaded: "+_toolReelDownPath);
			}
			if(evt.title==_toolLeftArrowPath){
				toolLeftArrow = new Image(Texture.fromBitmap(evt.content));
				trace("loaded: "+_toolLeftArrowPath);
			}
			if(evt.title==_toolRightArrowPath){
				toolRightArrow = new Image(Texture.fromBitmap(evt.content));
				trace("loaded: "+_toolRightArrowPath);
			}
			if(evt.title==_toolReturnPath){
				toolReturn = new Image(Texture.fromBitmap(evt.content));
				trace("loaded: "+_toolReturnPath);
			}
			if(evt.title==_jewelPath){
				jewel = new Image(Texture.fromBitmap(evt.content));
				jewel.addEventListener(TouchEvent.TOUCH, onJewelTouched);
			}
			if(evt.title==_hidedMapPath){
				hidedMap = new Image(Texture.fromBitmap(evt.content));
				trace("loaded: "+_hidedMapPath);
			}
		}
		
		private function onJewelTouched(evt:TouchEvent):void{
			var touch:Touch = evt.getTouch(jewel);
			if (touch == null) return;
			
			if(touch.phase == TouchPhase.ENDED){
				if(_mask) return;
				
				var bd:BitmapData = new BitmapData(AppConfig.VIEWPORT_WIDTH,AppConfig.VIEWPORT_HEIGHT+100,true,0xCC000000);
				_mask = new Image(Texture.fromBitmapData(bd));
				this.addChildAt(_mask,this.getChildIndex(jewel));
			}
		}
		
		private function startToPlay():void{
			var fadeout:Tween = new Tween(aobaoFocus,2);
			fadeout.animate("alpha",0);
			fadeout.onComplete = delayToDo;
			Starling.juggler.add(fadeout);
			
			this.addChild(aobaoHead);
			aobaoHead.x = 104;
			aobaoHead.y = 81;
			aobaoHead.alpha = 0;
			
			this.addChild(jewel);
			jewel.x = 384;
			jewel.y = 97;
			jewel.alpha = 0;
			
			var fadein_head:Tween = new Tween(aobaoHead,2);
			fadein_head.animate("alpha",1);
			Starling.juggler.add(fadein_head);
			
			var fadein_jewel:Tween = new Tween(jewel,2);
			fadein_jewel.animate("alpha",1);
			Starling.juggler.add(fadein_jewel);
			
			//道具栏
			toolBackground.x = 0;
			//这个位置刚合适
			toolBackground.y = 452;
			this.addChild(toolBackground);
			
			//卷轴
			var upTexture:Texture = toolReelUp.texture;
			var downTexture:Texture = toolReelDown.texture;
			_reelTool = new Button(upTexture,"",downTexture);
			_reelTool.y = 482;
			_reelTool.x = AppConfig.VIEWPORT_WIDTH-70;
			this.addChild(_reelTool);
			
			//左右箭头
			toolLeftArrow.x = 10;
			toolLeftArrow.y = 550;
			this.addChild(toolLeftArrow);
			
			toolRightArrow.x = AppConfig.VIEWPORT_WIDTH-90;
			toolRightArrow.y = 540;
			this.addChild(toolRightArrow);
			
			//到大地图场景
			toolReturn.x = AppConfig.VIEWPORT_WIDTH-60;
			toolReturn.y = AppConfig.VIEWPORT_HEIGHT >> 1;
			this.addChild(toolReturn);
			
			//默认先隐藏，鼠标移动到附近，才显示
			toolReturn.visible = false;
			toolReturn.addEventListener(TouchEvent.TOUCH, onReturnTouched);
			
		}
		
		private function onReturnTouched(evt:TouchEvent):void{
			var touch:Touch = evt.getTouch(toolReturn);
			if (touch == null) return;
			
			if(touch.phase == TouchPhase.ENDED){
				var end:GameEvent = new GameEvent(GameEvent.SWITCH_SCENE);
				this.dispatchEvent(end);
			}
		}
		
		private function delayToDo():void{
			this.removeChild(aobaoFocus);			
		}
		
		private function onQueueProgress(evt:QueueLoaderEvent):void{
			_progressbar.progress = evt.queuepercentage;
		}
		
		
		//清理队列
		private function onQueComplete(evt:QueueLoaderEvent):void{
			while(_queLoader.getLoadedItems().length){
				_queLoader.removeItemAt(_queLoader.getLoadedItems().length-1);
			}
			
			_loadCompleted = true;
			this.removeChild(_progressbar);
		}
		
		private function onItemError(evt:QueueLoaderEvent):void{
			trace("item load error..."+evt.title);
		}
		
		override public function dispose():void{
			super.dispose();
			
			_queLoader.dispose();
		}
		

		
	} //end of class
}