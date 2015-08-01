package opengp;

import openfl.display.Sprite;
import openfl.events.Event;

import opengp.Lib;
import opengp.Sprite;
import opengp.Camera;

class Scene extends openfl.display.Sprite {

	public var camera:Camera;

	public function new() { super();
		// var lib = new Lib(this);
		// var tools = new Tools(this);
		camera = new Camera(this);

		// this.addEventListener(Event.ENTER_FRAME, onUpdate);
		// stage.addEventListener(Event.RESIZE, onResize);
	}
	private function onUpdate(e:Event):Void { update(); }
	private function onResize(e:Event):Void { resize(); }

	// override me !
	public function update(){}
	public function resize(){}
	public function added(){ activeUpdate(); }
	public function removed(){ killUpdate(); }

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

	private function iterateChildren(func:Dynamic->Void){
		// numChildren and getChildAt() are found in openfl.display.DisplayObjectContainer class
		for (i in 0 ... numChildren) {
			func(getChildAt(i)); // seems to work ! but the children are DisplayObjects, not Sprites...
		}
	}

	public override function addChild(child:Dynamic):Dynamic { super.addChild(child);
		// trace(Lib.typeof(child) + ' > ' + Lib.hasClass(child, 'opengp.Sprite'));
		if(Lib.hasClass(child, 'opengp.Sprite')) child.added();
		// trace('Scene has '+numChildren+' children');
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
		// trace('Scene has '+numChildren+' children');
		return child;
	}
}