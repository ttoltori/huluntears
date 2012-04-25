package com.ybcx.huluntears.scenes{
	
	
	import com.hydrotik.queueloader.QueueLoader;
	import com.hydrotik.queueloader.QueueLoaderEvent;
	import com.ybcx.huluntears.animation.FadeSequence;
	import com.ybcx.huluntears.events.GameEvent;
	import com.ybcx.huluntears.scenes.base.BaseScene;
	import com.ybcx.huluntears.ui.BottomToolBar;
	import com.ybcx.huluntears.ui.ImagePopup;
	import com.ybcx.huluntears.ui.RaidersLayer;
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
		//返回大地图场景箭头
		private var _toolReturnPath:String = "assets/sceaobao/tool_return.png";
		//宝石
		private var _jewelPath:String = "assets/sceaobao/jewel.png";
		//隐藏地图
		private var _hidedMapPath:String = "assets/sceaobao/hidedmap.png";
		//第一个攻略图路径
		private var _firstRaiderMapPath:String = "assets/sceaobao/1_tool_Raiders_1_l.png";
		
		
		
		//--------- 图片对象 -------------------
		private var aobaoFocus:Image;
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
		
		//点击宝石遮盖在地图上的黑色遮罩
		private var _mask:Image;
		//道具栏		
		private var _toolBar:BottomToolBar;
		//闪烁动画
		private var _fadeInOut:FadeSequence;
		
		//只有点击了宝石才打开移动地图开关
		private var _moveOpenFlag:Boolean;
		//宝石与敖包Y值差
		private var _jewelYDiff:Number = 0;
		//隐藏攻略图与敖包Y值差
		private var _hideMapYDiff:Number = 0;
		
		//卷轴打开的攻略地图
		private var _raiderLayer:RaidersLayer;
		
		
		
		
		/**
		 * 敖包特写场景
		 */ 
		public function AobaoScene(){
			super();
			
			//下载队列
			_queLoader = new QueueLoader();
			_queLoader.addEventListener(QueueLoaderEvent.ITEM_COMPLETE, onItemLoaded);
			_queLoader.addEventListener(QueueLoaderEvent.ITEM_ERROR,onItemError);
			_queLoader.addEventListener(QueueLoaderEvent.QUEUE_PROGRESS,onQueueProgress);
			_queLoader.addEventListener(QueueLoaderEvent.QUEUE_COMPLETE, onQueComplete);
			
			//全局鼠标移动判断
			this.addEventListener(TouchEvent.TOUCH, onSceneTouch);
		}
		
		public function set toolbar(tb:BottomToolBar):void{
			_toolBar = tb;
			_toolBar.addEventListener(GameEvent.REEL_TRIGGERD,onRaiderOpen);
		}
		
		private function onRaiderOpen(evt:GameEvent):void{
			if(_raiderLayer && this.contains(_raiderLayer)) return;
			
			var index:int = evt.context as int;
			_raiderLayer = new RaidersLayer(145,454);
			_raiderLayer.y = 50;
			_raiderLayer.x = this.stage.stageWidth-_raiderLayer.width >> 1;
			//显示第一个攻略
			_raiderLayer.availableRaider(index);
			_raiderLayer.addEventListener(GameEvent.RAIDER_TOUCHED,onRaiderTouched);
			this.addChild(_raiderLayer);
		}
		
		private function onRaiderTouched(evt:GameEvent):void{
			if(evt.context==1){//打开第一个地图
				var firstRaider:ImagePopup = new ImagePopup(482,530);
				firstRaider.imgPath = _firstRaiderMapPath;
				firstRaider.x = this.stage.stageWidth-firstRaider.width >> 1;
				firstRaider.y = 50;
				firstRaider.maskColor = 0xCC000000;
				this.addChild(firstRaider);
			}
		}
		
		/**
		 * 处理返回按钮
		 */ 
		private function onSceneTouch(evt:TouchEvent):void{
			var touch:Touch = evt.getTouch(this);
			if (touch == null) {
				//停止运动
				this.removeEventListeners(Event.ENTER_FRAME);
				return;
			}
			//在一个矩形区域内
			if(touch.globalX>AppConfig.VIEWPORT_WIDTH-100 && touch.globalY<AppConfig.VIEWPORT_HEIGHT){
				if(toolReturn) toolReturn.visible = true;
			}else{
				if(toolReturn) toolReturn.visible = false;
			}
			
			//如果贴近右边缘，就隐藏
			if(touch.globalX>AppConfig.VIEWPORT_WIDTH-10){
				if(toolReturn) toolReturn.visible = false;
			}
			//打开开关才能运动
			if(!_moveOpenFlag) return;
			
			var detectAreaHeight:Number = 100;
			var moveSpeed:Number = 0;
			//向下移动地图
			if(touch.globalY<detectAreaHeight){
				moveSpeed = 0.5;
			}
			//向上移动地图
			if(touch.globalY>AppConfig.VIEWPORT_HEIGHT-detectAreaHeight){
				moveSpeed = -0.5;
			}			
			
			this.addEventListener(Event.ENTER_FRAME,function():void{
				//运动边界检测，不能朝上走超过自己的高度
				if(aobaoFocus.y>0){
					moveSpeed = 0;
					//复位
					aobaoFocus.y = 0;
				}
				if(aobaoFocus.y<-aobaoFocus.height+AppConfig.VIEWPORT_HEIGHT){
					moveSpeed = 0;
					//复位
					aobaoFocus.y = -aobaoFocus.height+AppConfig.VIEWPORT_HEIGHT;
				}
				//地图运动
				aobaoFocus.y += moveSpeed;
				//宝石也运动
				jewel.y = aobaoFocus.y+_jewelYDiff;
				//攻略也运动
				hidedMap.y = aobaoFocus.y+_hideMapYDiff;
			});
			
			//中间区域停止移动
			if(touch.globalY>detectAreaHeight && 
				touch.globalY<AppConfig.VIEWPORT_HEIGHT-detectAreaHeight){
				moveSpeed = 0;
				//停止运动
				this.removeEventListeners(Event.ENTER_FRAME);
			}
			
		}
		
		override protected function onStage(evt:Event):void{
			super.onStage(evt);
			
			if(_loadCompleted) return;
			
			//加个玻璃板，好响应鼠标动作
			//后添加玻璃板，铺满整个应用
			var bd:BitmapData = new BitmapData(this.stage.stageWidth,this.stage.stageHeight,false,0x000000);						
			var tx:Texture = Texture.fromBitmapData(bd);
			_touchBoard = new Image(tx);
			this.addChild(_touchBoard);
			
			_queLoader.addItem(_aobaoFocusPath,null, {title : _aobaoFocusPath});

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
								
			}

			if(evt.title==_toolReturnPath){
				toolReturn = new Image(Texture.fromBitmap(evt.content));				
			}
			if(evt.title==_jewelPath){
				jewel = new Image(Texture.fromBitmap(evt.content));
				//宝石点击触发地图移动和隐藏攻略
				jewel.addEventListener(TouchEvent.TOUCH, onJewelTouched);
				this.addChild(jewel);
				jewel.x = 388;
				jewel.y = 98;	
				_jewelYDiff = 98;
			}
			if(evt.title==_hidedMapPath){
				hidedMap = new Image(Texture.fromBitmap(evt.content));
				//加点击事件
				hidedMap.addEventListener(TouchEvent.TOUCH, onHideMapTouched);
			}
		}
		
		private function onJewelTouched(evt:TouchEvent):void{
			var touch:Touch = evt.getTouch(jewel);
			if (touch == null) return;
			
			if(touch.phase == TouchPhase.ENDED){
				if(_mask) return;
				//允许地图上下移动
				_moveOpenFlag = true;
				//给宝石下面的东西加遮盖，使之变暗
				var bd:BitmapData = new BitmapData(AppConfig.VIEWPORT_WIDTH,AppConfig.VIEWPORT_HEIGHT+100,true,0xCC000000);
				_mask = new Image(Texture.fromBitmapData(bd));
				//宝石的下面
				this.addChildAt(_mask,this.getChildIndex(jewel));
				//反复闪烁隐藏攻略图		
				fadeinHideMap();
			}
		}
		

		
		private function fadeinHideMap():void{
			hidedMap.x = 570;
			hidedMap.y = 638;
			_hideMapYDiff = 638;
			this.addChild(hidedMap);			
			
			//不停的闪烁攻略
			_fadeInOut = new FadeSequence(hidedMap,0.2);
			_fadeInOut.start();
		}
		
		private function onHideMapTouched(evt:TouchEvent):void{
			var touch:Touch = evt.getTouch(hidedMap);
			if (touch == null) return;
			
			if(touch.phase == TouchPhase.ENDED){				
				
				var move:Tween = new Tween(hidedMap,0.8);
				move.animate("x", 700);
				move.animate("y", 450);
				move.animate("alpha",0.2);
				move.animate("scaleX",0.2);
				move.animate("scaleY",0.2);
				move.onComplete = function():void{
					shakeReel();
				};
				Starling.juggler.add(move);
				//停止闪烁
				_fadeInOut.dispose();
				//移除黑色遮罩
				this.removeChild(_mask);
			}
		}
		//晃动卷轴
		private function shakeReel():void{
			_toolBar.shakeReel();
			hidedMap.visible = false;
		}
		
		
		private function onReturnTouched(evt:TouchEvent):void{
			var touch:Touch = evt.getTouch(toolReturn);
			if (touch == null) return;
			
			if(touch.phase == TouchPhase.ENDED){
				var end:GameEvent = new GameEvent(GameEvent.SWITCH_SCENE);
				this.dispatchEvent(end);
			}
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
			
			//显示道具栏
			_toolBar.showToolbar();
			//点亮宝石
			startToPlay();
		}
		
		private function startToPlay():void{				
			//闪烁宝石			
			_fadeInOut = new FadeSequence(jewel,0.2,2);
			_fadeInOut.start();
			
			//到大地图场景
			toolReturn.x = AppConfig.VIEWPORT_WIDTH-60;
			toolReturn.y = AppConfig.VIEWPORT_HEIGHT >> 1;
			this.addChild(toolReturn);
			
			//默认先隐藏，鼠标移动到附近，才显示
			toolReturn.visible = false;
			toolReturn.addEventListener(TouchEvent.TOUCH, onReturnTouched);
			
		}

		
		private function onItemError(evt:QueueLoaderEvent):void{
			trace("item load error..."+evt.title);
		}
		
		override public function dispose():void{
			super.dispose();
			
			_queLoader.dispose();
			_toolBar = null;
		}
		

		
	} //end of class
}