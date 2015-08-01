package opengp;

import openfl.events.Event;
import openfl.events.KeyboardEvent;
import openfl.events.JoystickEvent;

import opengp.Lib;

class Gamepad {

	// number of gamepads and buttons handled
	private static inline var nbGamepads:Int = 8;
	public static inline var nbBtns:Int = 10;


	private static var activated_:Bool = false;

	public static function start(){ // to activate joysticks listening
		if(!activated_){
			activated_ = true;
			trace("joysticks activated...");

			gamepads = new Array();
			for (i in 0 ... nbGamepads) {
				gamepads.push(new SinglePad(i));
			}

			Lib.stage.addEventListener (JoystickEvent.AXIS_MOVE, _handleJoyAxisMove);
			Lib.stage.addEventListener (JoystickEvent.BUTTON_DOWN, _handleJoyButtonDown);
			Lib.stage.addEventListener (JoystickEvent.BUTTON_UP, _handleJoyButtonUp);
			Lib.stage.addEventListener (JoystickEvent.HAT_MOVE, _handleJoyHatMove);
			Lib.stage.addEventListener (JoystickEvent.DEVICE_ADDED, _handleJoyAdded);
			Lib.stage.addEventListener (JoystickEvent.DEVICE_REMOVED, _handleJoyRemoved);
		}
			
	}
	public static function stop(){
		if(activated_){
			activated_ = false;
			gamepads = new Array();
			Lib.stage.removeEventListener (JoystickEvent.AXIS_MOVE, _handleJoyAxisMove);
			Lib.stage.removeEventListener (JoystickEvent.BUTTON_DOWN, _handleJoyButtonDown);
			Lib.stage.removeEventListener (JoystickEvent.BUTTON_UP, _handleJoyButtonUp);
			Lib.stage.removeEventListener (JoystickEvent.HAT_MOVE, _handleJoyHatMove);
			Lib.stage.removeEventListener (JoystickEvent.DEVICE_ADDED, _handleJoyAdded);
			Lib.stage.removeEventListener (JoystickEvent.DEVICE_REMOVED, _handleJoyRemoved);
		}			
	}
	private static function _handleJoyAxisMove (e:JoystickEvent):Void {
		// trace("axis move"+e.device+' / '+e.x+' / '+e.y); 
		// e.axis is an Array version, that handles 2 sticks I guess...
		if(e.device < nbGamepads){
			var pad = gamepads[e.device];
			pad.btns[Gamepad.UP] = (e.y<0);
			pad.btns[Gamepad.DOWN] = (e.y>0);
			pad.btns[Gamepad.LEFT] = (e.x<0);
			pad.btns[Gamepad.RIGHT] = (e.x>0);
		}
	}
	private static function _handleJoyButtonDown (e:JoystickEvent):Void {
		// trace("btn down"+e.device+' / '+e.id);
		if(e.device < nbGamepads){
			gamepads[e.device].btns[e.id] = true;
		}	
	}
	private static function _handleJoyButtonUp (e:JoystickEvent):Void {
		// trace("btn up"+e.device+' / '+e.id);	
		if(e.device < nbGamepads){
			gamepads[e.device].btns[e.id] = false;
		}		
	}
	private static function _handleJoyHatMove (e:JoystickEvent):Void {
		// ???
		trace("hat move"+e.device+' / '+e.id+' / '+e.x+' / '+e.y+' / '+e.axis);		
	}
	private static function _handleJoyAdded (e:JoystickEvent):Void {
		trace("gamepad added "+e.device);
		if(e.device < nbGamepads){
			gamepads[e.device].connected = true;
		}		
	}
	private static function _handleJoyRemoved (e:JoystickEvent):Void {
		trace("gamepad added "+e.device);		
		if(e.device < nbGamepads){
			gamepads[e.device].connected = false;
		}		
	}

	public static var gamepads:Array<SinglePad>;

	public static var UP:Int; // populated from SinglePad
	public static var DOWN:Int;
	public static var LEFT:Int;
	public static var RIGHT:Int;
}
class SinglePad {

	public var connected:Bool = false;
	public var index:Int;
	public var btns:Array<Bool> = new Array(); // true = down
	// private var nbBtns:Int = 10;

	public function new(id_:Int) {
		index = id_;

		for (i in 0 ... Gamepad.nbBtns+4) { // initial buttons states + 4 directions
			btns[i] = false;
		}

		// populate directions ids at the end
		Gamepad.UP = Gamepad.nbBtns+0;
		Gamepad.DOWN = Gamepad.nbBtns+1;
		Gamepad.LEFT = Gamepad.nbBtns+2;
		Gamepad.RIGHT = Gamepad.nbBtns+3;
	}
	public function isDown(btnId:Int):Bool {
		if(btnId < Gamepad.nbBtns+4){
			return btns[btnId];
		} else {
			return false;
		}		
	}
	public function isUp(btnId:Int):Bool {
		if(btnId < Gamepad.nbBtns+4){
			return !btns[btnId];
		} else {
			return true;
		}		
	}
}