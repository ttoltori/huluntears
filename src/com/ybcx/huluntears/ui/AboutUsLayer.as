package com.ybcx.huluntears.ui{
	
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.text.TextField;
	
	import starling.display.Image;
	import starling.textures.Texture;
	
	public class AboutUsLayer extends STPopupView{
		
		private var _author:TextField;
		private var _qq:TextField;
		private var _email:TextField;
		private var _techSupport:TextField;
		private var _codeBase:TextField;
		
		public function AboutUsLayer(width:Number, heigh:Number){
			super(width, heigh);
		}
		
		override protected function createPopupContent():void{
			var startX:Number = 50;
			var startY:Number = 40;
			var rowHeight:Number = 30;
			
			var origTFContainer:Sprite = new Sprite();
			
			_author = new TextField();
			_author.text = "主创：张波";
			_author.autoSize = "left";
			_author.x = 0;
			_author.y = startY;
			origTFContainer.addChild(_author);
			
			_qq = new TextField();
			_qq.text = "QQ：xxxxx";
			_qq.autoSize = "left";
			_qq.x = 0;
			_qq.y = startY+rowHeight;
			origTFContainer.addChild(_qq);
			
			_email = new TextField();
			_email.text = "EMail：xxx@xxx.com";
			_email.autoSize = "left";
			_email.x = 0;
			_email.y = startY+2*rowHeight;
			origTFContainer.addChild(_email);
			
			
			//多空开一些
			_techSupport = new TextField();
			_techSupport.text = "技术支持：北京远博畅享科技有限公司";
			_techSupport.autoSize = "left";			
			_techSupport.x = 0;
			_techSupport.y = startY+4*rowHeight;
			origTFContainer.addChild(_techSupport);
						
			_codeBase = new TextField();
			_codeBase.text = "游戏引擎：Starling@gamua.com";
			_codeBase.autoSize = "left";
			_codeBase.x = 0;
			_codeBase.y = startY+5*rowHeight;
			origTFContainer.addChild(_codeBase);
			
			var textBD:BitmapData = new BitmapData(this.width,this.height,true,0x00000000);
			textBD.draw(origTFContainer);
			var textBlock:Image = new Image(Texture.fromBitmapData(textBD));
			textBlock.x = startX;
			this.addChild(textBlock);
		}
		
	} //end of class
}