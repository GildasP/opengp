package opengp;

import openfl.display.BitmapData;
import openfl.display.Bitmap;
import openfl.Assets;

import opengp.Sprite;

class Image extends Sprite {

	private var img:Bitmap;
	
	public function new(asset:String) { super();
		img = new Bitmap(Assets.getBitmapData(asset));
		applyImageMode();
		addChild(img);	
	}

	public static function getBitmap(asset:String):Bitmap { // to get the Bitmap outside a Sprite
		var img:Bitmap = new Bitmap(Assets.getBitmapData(asset));
		return img;
	}
	public static function getImage(asset:String):Image { // to get the Bitmap outside a Sprite
		var img = new Image(asset);
		img.applyImageMode();
		return img;
	}
	public static function get(asset:String):Image { // getImage() alias
		return getImage(asset);
	}

	private static var imageMode_ = "center";
	public static function imageMode(mode:String){
		if(mode == "center" || mode == "CENTER"){
			imageMode_ = "center";
		} else {
			imageMode_ = "corner";
		}
	}
	private function applyImageMode(){
		if(imageMode_ == "center"){
			centerOrigin();
		} else {
			cornerOrigin();
		}
	}

	public function centerOrigin(){
		moveTo(-img.width/2*scaleX, -img.height/2*scaleY);
	}
	public function cornerOrigin(){
		moveTo(0, 0);
	}

	public override function scaleTo(scaleX_:Float, scaleY_:Null<Float>=null):Image {
		if(scaleY_ == null) scaleY_ = scaleX_;
		super.scaleTo(scaleX_,scaleY_);
		applyImageMode();
		return this;
	}
}