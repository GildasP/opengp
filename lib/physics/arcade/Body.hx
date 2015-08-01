package opengp.physics.arcade;

import openfl.geom.Rectangle;
import openfl.geom.Point;

import opengp.Lib;
import opengp.Shape;

/*
ça maaaarche !
mais c'est pas rationnel :/
- ya un rect, donc revenir à une extension de rect, avec un Point en bonus
x pb quand le sprite flippe
x pb quand le sprite est scalé ?
x il faut updater le dessin (ses coords) aussi en mode debug !
o l'update du dessin c'est quand-même pas top ! peu économe
*/

class Body { // http://docs.openfl.org/openfl/geom/Rectangle.html

	public var sprite:Sprite;

	// backup original non-scaled dims and relative coords (of the center/origin)
	private var relX:Float = 0;
	private var relY:Float = 0;
	private var relW:Float = 0;
	private var relH:Float = 0;

	// exchange with stage coords vars
	private var coords:Point = new Point(0,0); // local hitbox top-left corner coordinates
	private var hitbox:Rectangle; // absolute coordinates and real scaled dims


	public function new(sprite_:Sprite, curGravity:Point) {
		sprite = sprite_;
		autosize(); // automatic boundingBox by default
		initPhysics(curGravity);
	}

	// setting hitbox size and relative pos
	public function setBody(w_:Float, h_:Float, offsetX_:Float, offsetY_:Float):Body {

		relX = offsetX_; relY = offsetY_; relW = w_; relH = h_; // backup non-scaled params

		hitbox.width = Math.abs(relW*sprite.scaleX);
		hitbox.height = Math.abs(relH*sprite.scaleY);		

		if(sprite.scaleX<0){ // relative coords, set to global and scaled via update() !
			coords.x = relX+relW/2;
		} else {
			coords.x = relX-relW/2;
		}
		coords.y = relY-relH/2;

		redraw();
		return this;
	}
	public function setSize(w_:Float, h_:Float):Body {
		setBody(w_, h_, relX, relY);
		return this;
	}
	public function setOffset(offsetX_:Float, offsetY_:Float):Body {
		setBody(relW, relH, offsetX_, offsetY_);
		return this;
	}
	public function autosize():Body { // hitbox from the parent sprite's bounding box
		hitbox = sprite.getBounds(Lib.scene);
		// trace('box size : '+hitbox.width+' / '+hitbox.height);
		setBody(hitbox.width, hitbox.height, 0, 0);
		return this;
	}

	// on parent sprite rescale event
	public function parentRescaled(){
		setBody(relW, relH, relX, relY); // update avec les mêmes params locaux
	}

	// body update !
	public function update(){ // triggered by parent Sprite.update()

		// physics
		// if(physicsEnabled) updatePhysics();
		/*if(!immovable)*/ updatePhysics();

		// update hitbox to absolute coords
		var absoluteCoords:Point = sprite.localToGlobal(coords);
		hitbox.x = absoluteCoords.x;
		hitbox.y = absoluteCoords.y;

		// world bounds
		if(collideWorldBounds) checkWorldBounds();

		if(debugging) img.moveTo(hitbox.x, hitbox.y); // update debug hitbox shape
	}

	public function delete(){ // auto-destruct, triggered on removeChild() of the parent sprite
		debugOff();
		Arcade.disableBody(sprite);
	}



	// physics
	// public var physicsEnabled:Bool = false; // switched by Arcade.enableBody(sprite, physics:Bool)

	public var velocity:Point = new Point(0, 0);
	public var inertia:Point = new Point(1, 1); // I added this, to be able to slow down objects over time...
	public var acceleration:Point = new Point(0, 0);
	public var maxVelocity:Point = new Point(0, 0);
	public var bounce:Point = new Point(0,0);
	// public var friction:Point = new Point(1,0);
	public var mass:Float = 1;
	public var gravity:Point = new Point(0, 0);
	public var allowGravity:Bool = true;
	public var allowGlobalGravity:Bool = true;
	public var collideWorldBounds:Bool = false;
	public var immovable:Bool = false;
	// public var touching:Dynamic = {left:false, right:false, up:false, down:false};

	private function initPhysics(curGravity:Point){ // called on creation
		if(curGravity.x != 0 || curGravity.y != 0){
			gravity.x = curGravity.x;
			gravity.y = curGravity.y;
		}
	}

	private function updatePhysics(){

		if(allowGravity){
			velocity.x += gravity.x/10;
			velocity.y += gravity.y/10;
		}

		velocity.x += acceleration.x;
		velocity.y += acceleration.y;
		if(maxVelocity.x != 0) velocity.x = Math.abs(velocity.x)/velocity.x * Math.min(Math.abs(velocity.x), maxVelocity.x);
		if(maxVelocity.y != 0) velocity.y = Math.abs(velocity.y)/velocity.y * Math.min(Math.abs(velocity.y), maxVelocity.y);

		sprite.x += velocity.x/100; // affects the parent Sprite object
		sprite.y += velocity.y/100;

		velocity.x *= inertia.x;
		velocity.y *= inertia.y;
	}

	private function checkWorldBounds(){
		if(hitbox.left<0){ sprite.x -= hitbox.left; velocity.x = - sprite.body.velocity.x * sprite.body.bounce.x; }
		if(hitbox.right>Lib.width){ sprite.x -= hitbox.right-Lib.width; velocity.x = - sprite.body.velocity.x * sprite.body.bounce.x; } 
		if(hitbox.top<0){ sprite.y -= hitbox.top; velocity.y = - sprite.body.velocity.y * sprite.body.bounce.y; }
		if(hitbox.bottom>Lib.height){ sprite.y -= hitbox.bottom-Lib.height; velocity.y = - sprite.body.velocity.y * sprite.body.bounce.y; } 
	}

	public function setBounce(x_:Float, y_:Float){
		bounce.x = x_; 
		bounce.y = y_;
	}



	// debug Shape
	private var img:Null<Sprite> = null;
	private var debugging:Bool = false;
	public function debugOn(){
		debugOff(); // clear previous draw if exists
		debugging = true;
		draw();
		Lib.scene.addChild(img);
	}
	public function debugOff(){
		if(img != null){
			Lib.scene.removeChild(img);
			img = null;
		}
		debugging = false;
	}
	public function draw(){
		if(debugging){
			Arcade.drawDebugMode();
			img = Shape.rect(0,0,hitbox.width,hitbox.height);
			img.moveTo(hitbox.x, hitbox.y);
			Arcade.drawDebugMode(false);
		}			
	}
	public function redraw(){
		if(debugging){
			Lib.scene.removeChild(img);
			draw();
			Lib.scene.addChild(img);
		}		
	}


	// bonus !
	public function jumpThrough(platform:Sprite):Bool { // to use in a processCallback() of a Arcade.collide()
		// trace(velocity.y+" / "+hitbox.bottom+' / '+platform.body.hitbox.y+' / '+platform.body.hitbox.height+' / '+platform.body.hitbox.bottom);
		// return (velocity.y >= 0 && hitbox.bottom < platform.body.hitbox.bottom); // bootom doesn't work on my platform ?!
		return (velocity.y >= 0 && hitbox.bottom < platform.body.hitbox.y+platform.body.hitbox.height);
	}

}