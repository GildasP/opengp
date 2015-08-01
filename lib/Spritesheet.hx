package opengp;

import spritesheet.Spritesheet;
import spritesheet.importers.BitmapImporter;
import spritesheet.data.BehaviorData;
import spritesheet.AnimatedSprite;
import openfl.Assets;
import openfl.display.BitmapData;

import opengp.Sprite;

/*
Wrapper for the excellent Spritesheet lib by Joshua Granick.
Just what I needed, seemingly identical to HaxePunk and Phaser's API.
The original lib is a bit shatty, though.
https://github.com/jgranick/spritesheet
docs : http://fugocode.blogspot.fr/2013/04/animated-sprite-using-bitmap.html
*/

class Spritesheet extends Sprite {

	private var sheet:spritesheet.Spritesheet;
	private var animation:AnimatedSprite;
	public var currentAnimation:String = "";
	public var tileWidth:Int;
	public var tileHeight:Int;

	/*
	TODO :
	new() : it should be possible to remove col/rows params, and get them from the bitmap dimensions...
	add() : count from 1 instead of 0, to match Flash timeline !
	*/
	public function new(asset:String, columns:Int, rows:Int) { super();

		lastTime = Lib.getTimer();

		// calculation of the tiles width/height
		var bmp:BitmapData = Assets.getBitmapData(asset);
		var _tileWidth:Float = bmp.width/columns;
		var _tileHeight:Float = bmp.height/rows;
		if(_tileWidth != Math.round(_tileWidth) || _tileHeight != Math.round(_tileHeight)){
			throw "Illegal spritesheet size for "+asset+" - wrong cols/rows number";
		}
		tileWidth = Std.int(_tileWidth);
		tileHeight = Std.int(_tileHeight);

		// tilesheet end animation creation
		sheet = BitmapImporter.create(bmp, columns, rows, tileWidth, tileHeight);
		animation = new AnimatedSprite(sheet); // there's a second Bool param for smoothing... 

		applyImageMode(); // set origin
		stop(0); // show first frame by default
		addChild(animation);		
	}

	public function add(name:String, frames:Array<Int>=null, frameRate:Int=30, loop:Bool=true){
		// HaxePunk-like interface
		sheet.addBehavior(new BehaviorData(name, frames, loop, frameRate));
	}

	public function play(name:String=""){
		if(currentAnimation != name){
			if(!updateActivated_) activeUpdate(); // begin update() loop
			if(name == ""){ 
				name = currentAnimation; // resume
			} else {
				currentAnimation = name;
			}
			animation.showBehavior(name);
		}		
	}
	public function stop(frame:Int=-1){
		var currentAnimation_:String = currentAnimation;
		if(frame>=0){ // a trick to show the desired frame...
			add("killzspecialX", [frame], 1, false);
			play("killzspecialX");
		}
		currentAnimation = currentAnimation_; // to be able to resume
		update(); // to view it
		killUpdate();
	}

	public function playSequence(names:Array<String>){ // chain multiple animations (if they don't loop)
		animation.showBehaviors(names);
	}

	private var lastTime:Int;
	public override function update(){ super.update();
		var delta = Lib.getTimer() - lastTime;
		animation.update(delta);
		lastTime = Lib.getTimer();
	}


	// nearly same stuff as opengp.Image, for origin's position

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
		moveTo(-tileWidth/2*scaleX, -tileHeight/2*scaleY);
	}
	public function cornerOrigin(){
		moveTo(0, 0);
	}

	public override function scaleTo(scaleX_:Float, scaleY_:Null<Float>=null):Sprite {
		if(scaleY_ == null) scaleY_ = scaleX_;
		super.scaleTo(scaleX_,scaleY_);
		applyImageMode();
		return this;
	}
}