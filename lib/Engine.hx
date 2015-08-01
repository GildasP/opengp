package opengp;

import openfl.display.Sprite;
import openfl.events.Event;

import opengp.Lib;
import opengp.Sprite;
import opengp.Camera;

class Engine extends openfl.display.Sprite {

	public function new() { super();
		var lib = new Lib(this);
		var tools = new Tools(this);
		// camera = new Camera(this);

		this.addEventListener(Event.ENTER_FRAME, onUpdate);
		stage.addEventListener(Event.RESIZE, onResize);

		// auto-ban trace when building releases versions (all targets)
#if debug
		trace('/debug build/');
#else
		Lib.noTrace();
#end
	}
	private function onUpdate(e:Event):Void { update(); }
	private function onResize(e:Event):Void { resize(); }

	// override me !
	public function update(){}
	public function resize(){} 

	private static var isPaused_:Bool = false;
	public function pause(){
		if(!isPaused_){
			isPaused_ = true; // stops update() function
			this.removeEventListener(Event.ENTER_FRAME, onUpdate);
			opengp.Tween.pauseAll(); // stops current tweens
			iterateChildren(function(s){ s.pauseUpdate(); }); // pauses all Engine children
		}			
	}
	public function resume(){
		if(isPaused_){
			isPaused_ = false;
			this.addEventListener(Event.ENTER_FRAME, onUpdate);
			opengp.Tween.resumeAll();
			iterateChildren(function(s){ s.resumeUpdate(); });
		}
	}	
	public function playpause(){
		if(isPaused_){
			resume();
		} else {
			pause();
		}
	}

	/*private var children:Array<opengp.Sprite> = new Array<opengp.Sprite>();
	public override function addChild(child:opengp.Sprite){ super.addChild(child);
		children.push(child);
	}*/

	private function iterateChildren(func:Dynamic->Void){
		// numChildren and getChildAt() are found in openfl.display.DisplayObjectContainer class
		for (i in 0 ... numChildren) {
			func(getChildAt(i)); // seems to work ! but the children are DisplayObjects, not Sprites...
		}
	}

	public override function addChild(child:Dynamic):Dynamic { super.addChild(child);
		// trace(Lib.typeof(child) + ' > ' + Lib.hasClass(child, 'opengp.Sprite'));
		if(Lib.hasClass(child, 'opengp.Sprite') || Lib.hasClass(child, 'opengp.Scene')) child.added();
		// trace('Engine has '+numChildren+' children');
		return child;
	}
	public override function removeChild(child:Dynamic):Dynamic { super.removeChild(child);
		if(Lib.hasClass(child, 'opengp.Sprite') || Lib.hasClass(child, 'opengp.Scene')){ 
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
		// trace('Engine has '+numChildren+' children');
		return child;
	}

	// scenes et camera
	public var scene(default, set):Null<Scene> = null;
	private function set_scene(s:Scene):Scene {
		if(scene != null) removeChild(scene);
		scene = s;
		camera = s.camera;
		addChild(s);
		return scene;
	}

	public var camera:Null<Camera> = null;
}