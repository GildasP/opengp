package opengp;

import openfl.geom.Rectangle;

import opengp.Lib;
import opengp.Scene;

class Camera extends Rectangle {

	public static var scene:Scene;

	public function new(scene_:Scene){ // triggered by Engine.new()
		super(0, 0, Lib.width, Lib.height);
		scene = scene_;
		
		// hop ceci devient le viewport !
		scene.scrollRect = this; //new Rectangle(0, 0, Lib.width, Lib.height);
	}

	public function setPosition(){}
	public function moveBy(x_:Float, y_:Float=0){
		x += x_; y += y_;

// #if flash
		scene.scrollRect = this;
// #end

		for (i in 0 ... fixedSprites.length) {
			if(fixedSprites[i] != null) fixedSprites[i].moveBy(x_, y_);
		}
	}
	public function moveTo(x_:Float, y_:Float=0){
		moveBy(x_-x, y_-y);
	}

	public static var fixedSprites:Array<Sprite> = new Array();
	public function addFixedSprite(sprite:Sprite){
		if(fixedSprites.indexOf(sprite)<0) fixedSprites.push(sprite);
	}
	public function removeFixedSprite(sprite:Sprite){
		if(fixedSprites.indexOf(sprite)>=0) fixedSprites.remove(sprite);
	}
}