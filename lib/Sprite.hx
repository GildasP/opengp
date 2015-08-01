package opengp;

// import opengp.Lib;
import openfl.display.Sprite;
import openfl.events.Event;

class Sprite extends openfl.display.Sprite {

	public function new() { super(); }

	public function moveTo(x_:Float, y_:Float):Sprite{
		x = x_; y = y_;
		return this;
	}
	public function moveBy(x_:Float, y_:Float):Sprite{
		x += x_; y += y_;
		return this;
	}
	public function rotate(angle:Float):Sprite{
		rotation = angle;
		return this;
	}
	public function rotateBy(angle:Float):Sprite{
		rotation += angle;
		return this;
	}
	public function resizeTo(w:Float, h:Float):Sprite {
		width = w; height = h;
		return this;
	}
	/*public function resizeBy(w:Float, h:Float){
		width += w; height += h;
	}*/
	public function scaleTo(scaleX_:Float, scaleY_:Null<Float>=null):Sprite {
		if(scaleY_ == null) scaleY_ = scaleX_;
		scaleX = scaleX_; scaleY = scaleY_;
		if(bodyEnabled) body.parentRescaled(); // body transform
		return this;
	}

	public var flipped(default, set):Bool = false;
	private function set_flipped(flip:Bool):Bool { 
		if(flip){
			scaleX = -1*Math.abs(scaleX);
		} else {
			scaleX = Math.abs(scaleX);
		}
		if(bodyEnabled) body.parentRescaled(); // body transform
		return flipped=flip; 
	} 

	private var updateActivated_:Bool = false;
	public function activeUpdate(){ // to be able to use the update() overridable function...
		if(!updateActivated_){
			this.addEventListener(Event.ENTER_FRAME, onUpdate);
			updateActivated_ = true;
		}
	}
	public function killUpdate(){
		if(updateActivated_) this.removeEventListener(Event.ENTER_FRAME, onUpdate);
		updateActivated_ = false;
	}
	public function pauseUpdate(){ // only if update was previously activated
		if(updateActivated_) this.removeEventListener(Event.ENTER_FRAME, onUpdate);
	}
	public function resumeUpdate(){ // only if update was previously activated
		if(updateActivated_) this.addEventListener(Event.ENTER_FRAME, onUpdate);
	}
	private function onUpdate(e:Event):Void { 
		update(); 
		if(bodyEnabled) body.update();
	}

	// override me !
	public function update(){} // must use activeUpdate() to enable this
	public function resize(){} // called by Engine.resize()
	public function added(){}
	public function removed(){
		fixedToCamera=false; // gets the delete from camera list done
		killUpdate();
	}

	public override function addChild(child:Dynamic):Dynamic { super.addChild(child);
		// trace(Lib.typeof(child) + ' > ' + Lib.hasClass(child, 'opengp.Sprite'));
		if(Lib.hasClass(child, 'opengp.Sprite')) child.added();
		return child;
	}
	public override function removeChild(child:Dynamic):Dynamic { super.removeChild(child);
		if(Lib.hasClass(child, 'opengp.Sprite')){ 
			if(child.bodyEnabled){
				// remove the associated body
				child.body.delete();
			}
			if(child.fixedToCamera){
				// remove from camera.fixedSprites list
				child.fixedToCamera = false;
				Lib.root.camera.removeFixedSprite(child);
			}
			child.removed();
		}
		return child;
	}

	public function setGraphicsFromSprite(s:Sprite){ // usefull to duplicate stuff, and apply a Shape image inside a Sprite
		graphics.copyFrom(s.graphics);
	}
	/*
	addGraphics / removeGraphics
	no need, there's addChild(stuff) and removeChild(stuff) that work, if keeping record of stuff Sprite...
	graphics seems a single slot drawing canvas, although it's a multiple one in HaxePunk.
	it seems complicated to replicate it, and not so usefull.
	*/

	private function iterateChildren(func:Dynamic->Void){
		// numChildren and getChildAt() are found in openfl.display.DisplayObjectContainer class
		for (i in 0 ... numChildren) {
			func(getChildAt(i)); // seems to work ! but the children are DisplayObjects, not Sprites...
		}
	}

	// physics entry
	public var body:Null<Dynamic> = null;
	public var bodyEnabled:Bool = false;

	// camera
	public var fixedToCamera(default,set):Bool = false;
	private function set_fixedToCamera(val:Bool):Bool {
		if(!fixedToCamera && val) Lib.root.camera.addFixedSprite(this);
		if(fixedToCamera && !val) Lib.root.camera.removeFixedSprite(this);
		return fixedToCamera = val;
	}
	// var inCamera:Bool = true;
	// autoCull:Bool = false; // to not render sprite outside of viewport
	// cameraOffset:Point = new Point(); // coords from top-left ?



	// mouse

	/*
	I'll have to keep track of all mouse events used... 
	especially when I'l use anonymous functions :/
	And I'll be able to do mySprite.off();
	to remove all MOUSE events on it (but not other event types)
	*/
	private var _myMouseEvents:Map<String,Dynamic->Void>;
	private var _myMouseEventsEnabled:Bool = false;

	public function on(e:String, callback:Dynamic->Void):Sprite {

		if(!_myMouseEventsEnabled){
			_myMouseEvents = new Map<String,Dynamic->Void>();
			_myMouseEventsEnabled = true;
		}

		var event:String = _getMouseEvent(e);
		if(event != ""){
			if(hasEventListener(event)){ // only one callback for each event... 
				var old_callback:Null<Dynamic->Void> = _myMouseEvents.get(event);
				if(old_callback != null) removeEventListener(event, old_callback);
			}
			_myMouseEvents.set(event, callback);
			addEventListener(event, callback);
			
		}
		return this;
	}

	public function off(e:String=""):Sprite {
		if(!_myMouseEventsEnabled) return this; // no event
		if(e == ""){
			// remove every recorded event
			for (key in _myMouseEvents.keys()){
				var old_callback:Null<Dynamic->Void> = _myMouseEvents.get(key);
				if(old_callback != null && hasEventListener(key)){
					removeEventListener(key, old_callback);
				}
			}
			_myMouseEvents = new Map<String, Dynamic->Void>();

		} else {
			var event:String = _getMouseEvent(e);
			var old_callback:Null<Dynamic->Void> = _myMouseEvents.get(event);
			if(old_callback != null && hasEventListener(event)){
				removeEventListener(event, old_callback);
			}
			_myMouseEvents.remove(event);
		}			
		return this;
	}

	private function _getMouseEvent(e:String):String {
		e = e.toLowerCase();
		var event:String = "";
		switch (e) {
			case "click":
				event = openfl.events.MouseEvent.CLICK;
			case "rclick":
				event = openfl.events.MouseEvent.RIGHT_CLICK;
			case "dbclick":
				event = openfl.events.MouseEvent.DOUBLE_CLICK;
			case "mouseover":
				event = openfl.events.MouseEvent.MOUSE_OVER;
			case "mouseout":
				event = openfl.events.MouseEvent.MOUSE_OUT;
			case "rollover":
				event = openfl.events.MouseEvent.ROLL_OVER;
			case "rollout":
				event = openfl.events.MouseEvent.ROLL_OUT;
			case "mousedown":
				event = openfl.events.MouseEvent.MOUSE_DOWN;
			case "mouseup":
				event = openfl.events.MouseEvent.MOUSE_UP;
			case "mousemove":
				event = openfl.events.MouseEvent.MOUSE_MOVE;
		}
		return event;
	}
}