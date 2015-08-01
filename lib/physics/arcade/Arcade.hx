package opengp.physics.arcade;

import openfl.geom.Rectangle;
import openfl.geom.Point;

// import opengp.Engine;
import opengp.Sprite;
import opengp.Shape;
import opengp.physics.arcade.Body;

/*
Interface deeply inspired by Phaser's physics.Arcade :
https://phaser.io/docs/2.3.0/Phaser.Physics.Arcade.html#enable

This engine is lighter, just what I needed, but same structure.
*/

class Arcade {

	private static var bodies:Array<Body>;
	// private static var root:Engine;

	public function new(engine:Engine) {
		// root = engine;
		bodies = new Array<Body>();
	}


	// public static function enableBody(sprite:Sprite, physics:Bool=false){
	public static function enableBody(sprite:Sprite){
		var body:Body = new Body(sprite, gravity);
		// body.physicsEnabled = physics; // if the body uses gravity, velocity, etc
		updateBody(sprite, body);
		sprite.activeUpdate(); // sprite needs to be updated if it has a body
	}
	public static function disableBody(sprite:Sprite){
		sprite.bodyEnabled = false; // disabled but not detroyed
		bodies.remove(sprite.body);
	}
	public static function reenableBody(sprite:Sprite){
		if(sprite.body != null && !sprite.bodyEnabled){
			updateBody(sprite, sprite.body);
		}
	}
	public static function updateBody(sprite:Sprite, body:Body){
		if(sprite.body != null){
			// there's already a body for the sprite, let's overwrite it
			bodies.remove(sprite.body);
		}
		sprite.body = body;
		sprite.bodyEnabled = true;

		bodies.push(sprite.body);
	}

	/*
	TODO :
	- pause/resume physics engine
	- disabling all will crash : deleting bodies, the list will shrink !
	*/

	public static function enable(sprites:Array<Sprite>){ // enable multiple sprites
		for (i in 0 ... sprites.length) {
			enableBody(sprites[i]);			
		}
	}
	public static function disable(sprites:Array<Sprite>){ // enable multiple sprites
		for (i in 0 ... sprites.length) {
			disableBody(sprites[i]);			
		}
	}

	// gravity
	public static var gravity(default, never):Point = new Point(0,0);
	public static function setGravity(gx:Float, gy:Float) {
		gravity.x = gx; gravity.y = gy;
		processBodies(function(b:Body):Void { // updates all previous set gravities
			if(!b.immovable && b.allowGravity && b.allowGlobalGravity){
				b.gravity.x = gx;
				b.gravity.y = gy;
			}
		});
	}

	// debugging
	private static var debugging:Bool = false;
	public static function debugAll(act:Bool=true){
		debugging = act;
		if(act){
			processBodies(function(b:Body){ b.debugOn(); });
		} else {
			processBodies(function(b:Body){ b.debugOff(); });
		}
	}
	public static function toggleDebug(){
		debugAll(!debugging);
	}
	public static function drawDebugMode(act:Bool=true){ // used for debugging bodies :)
		if(act){
			Shape.storeStyle();
			Shape.fill(0x00FF00, 0.3);
			Shape.stroke(0x00FF00, 1);
			Shape.rectMode("corner");
			Shape.strokeWeight(1);
		} else {
			Shape.restoreStyle();
		}
	}

	private static function processBodies(func:Body->Void) { // func(file) is applied to every file found
		for (i in 0 ... bodies.length) {
			func(bodies[i]);
		}
	}

	// collisions
	public static function intersects(sprite1:Sprite, sprite2:Sprite):Bool {
		if(!sprite1.bodyEnabled || !sprite2.bodyEnabled){
			return false;
		} else {
			/*var result:Bool = sprite1.body.hitbox.intersects(sprite2.body.hitbox);
			if(result){
				var overlap:Rectangle = sprite1.body.hitbox.intersection(sprite2.body.hitbox);
			}*/
			return sprite1.body.hitbox.intersects(sprite2.body.hitbox);
		}
	}
	public static function collide(obj1_:Dynamic, obj2_:Dynamic, collideCallback:Null<Sprite->Sprite->Void>=null, processCallback:Null<Sprite->Sprite->Bool>=null):Bool { 
		// automatic separation of checked objects
		return _testCollision(true, obj1_, obj2_, collideCallback, processCallback);
	}
	public static function overlap(obj1_:Dynamic, obj2_:Dynamic, collideCallback:Null<Sprite->Sprite->Void>=null, processCallback:Null<Sprite->Sprite->Bool>=null):Bool { 
		// collision detection without separation
		return _testCollision(false, obj1_, obj2_, collideCallback, processCallback);
	}
	private static function _testCollision(separate:Bool, obj1_:Dynamic, obj2_:Dynamic, collideCallback:Null<Sprite->Sprite->Void>=null, processCallback:Null<Sprite->Sprite->Bool>=null):Bool { 
		// like Phaser's collide() and overlap()...
		// https://phaser.io/docs/2.3.0/Phaser.Physics.Arcade.html#collide
		var list1:Array<Sprite>;
		var list2:Array<Sprite>;
		if(Lib.typeof(obj1_) != "Array"){
			list1 = [obj1_];
		} else {
			list1 = obj1_;
		}
		if(Lib.typeof(obj2_) != "Array"){
			list2 = [obj2_];
		} else {
			list2 = obj2_;
		}

		var result:Bool = false;

		for (i in 0 ... list1.length) {
			var sprite1:Sprite = list1[i];
			for (j in 0 ... list2.length) {
				var sprite2:Sprite = list2[j];

				if(sprite1 != sprite2 && intersects(sprite1, sprite2)){ // collision
					
					if(processCallback == null){
						result = true;
					} else {
						result = processCallback(sprite1, sprite2); // collision + processCallback() result (bool)
					}
					if(result){ // there's collision !

						// separation
						if(separate) _separate(sprite1, sprite2);

						if(collideCallback != null) collideCallback(sprite1, sprite2);
						result = true;
					}
				} 
			}
		}
		return result;
	}
	private static function _separate(sprite1:Sprite, sprite2:Sprite){

		var overlap:Rectangle = sprite1.body.hitbox.intersection(sprite2.body.hitbox);
		// overlap.width += 0.5;
		// overlap.height += 0.5;


		if(!sprite1.body.immovable && !sprite2.body.immovable){ // ejection is shared

			if(overlap.width<overlap.height){
				// horizontal ejection

				/*
				formula from
				https://github.com/photonstorm/phaser/blob/v2.3.0/src/physics/arcade/World.js
				line from 948 : separateX() and more precisly 1019
				*/
				
				var v1:Float = sprite1.body.velocity.x;
				var v2:Float = sprite2.body.velocity.x;

				var lap = overlap.width/2;

				if(sprite1.body.hitbox.x<sprite2.body.hitbox.x){ // move to left
					sprite1.x -= lap;
					sprite2.x += lap;
				} else { // move to right
					sprite1.x += lap;
					sprite2.x -= lap;
				}

				var nv1:Float = Math.sqrt((v2 * v2 * sprite2.body.mass) / sprite1.body.mass) * ((v2 > 0) ? 1 : -1);
				var nv2:Float = Math.sqrt((v1 * v1 * sprite1.body.mass) / sprite2.body.mass) * ((v1 > 0) ? 1 : -1);
				var avg:Float = (nv1 + nv2) * 0.5;
				nv1 -= avg;
				nv2 -= avg;
				sprite1.body.velocity.x = avg + nv1 * sprite1.body.bounce.x;
				sprite2.body.velocity.x = avg + nv2 * sprite2.body.bounce.x;

			} else {
				// vertical ejection

				var v1:Float = sprite1.body.velocity.y;
				var v2:Float = sprite2.body.velocity.y;

				var lap = overlap.height/2;

				if(sprite1.body.hitbox.y<sprite2.body.hitbox.y){ // move to left
					sprite1.y -= lap;
					sprite2.y += lap;
				} else { // move to right
					sprite1.y += lap;
					sprite2.y -= lap;
				}

				var v1:Float = sprite1.body.velocity.y;
				var v2:Float = sprite2.body.velocity.y;
				var nv1:Float = Math.sqrt((v2 * v2 * sprite2.body.mass) / sprite1.body.mass) * ((v2 > 0) ? 1 : -1);
				var nv2:Float = Math.sqrt((v1 * v1 * sprite1.body.mass) / sprite2.body.mass) * ((v1 > 0) ? 1 : -1);
				var avg:Float = (nv1 + nv2) * 0.5;
				nv1 -= avg;
				nv2 -= avg;
				sprite1.body.velocity.y = avg + nv1 * sprite1.body.bounce.y;
				sprite2.body.velocity.y = avg + nv2 * sprite2.body.bounce.y;
			}

		} else if(sprite2.body.immovable){ // ejection only for sprite1

			if(overlap.width<overlap.height){ // horizontal ejection
				if(sprite1.body.hitbox.x<sprite2.body.hitbox.x){
					sprite1.x -= overlap.width;
				} else {
					sprite1.x += overlap.width;
				}
				var v1:Float = sprite1.body.velocity.x;
				var v2:Float = sprite2.body.velocity.x;
				sprite1.body.velocity.x = v2 - v1 * sprite1.body.bounce.x;

			} else { // vertical ejection
				if(sprite1.body.hitbox.y<sprite2.body.hitbox.y){
					sprite1.y -= overlap.height;
				} else {
					sprite1.y += overlap.height;
				}
				var v1:Float = sprite1.body.velocity.y;
				var v2:Float = sprite2.body.velocity.y;
				sprite1.body.velocity.y = v2 - v1 * sprite1.body.bounce.y;
			}

		} else { // ejection only for sprite2

			if(overlap.width<overlap.height){ // horizontal ejection
				if(sprite1.body.hitbox.x<sprite1.body.hitbox.x){
					sprite1.x -= overlap.width;
				} else {
					sprite1.x += overlap.width;
				}
				var v1:Float = sprite1.body.velocity.x;
				var v2:Float = sprite1.body.velocity.x;
				sprite1.body.velocity.x = v2 - v1 * sprite1.body.bounce.x;

			} else { // vertical ejection
				if(sprite1.body.hitbox.y<sprite1.body.hitbox.y){
					sprite1.y -= overlap.height;
				} else {
					sprite1.y += overlap.height;
				}
				var v1:Float = sprite1.body.velocity.y;
				var v2:Float = sprite1.body.velocity.y;
				sprite1.body.velocity.y = v2 - v1 * sprite1.body.bounce.y;
			}
		}
	}
	public static function distanceBetween(){}
	public static function distanceToXY(){}

}