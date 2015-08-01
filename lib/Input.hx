package opengp;

import openfl.events.Event;
import openfl.events.KeyboardEvent;
// import openfl.events.JoystickEvent;

// import flash.ui.GameInput;
// import flash.ui.GameInputDevice;
// import flash.events.GameInputEvent;

import opengp.Lib;
// import opengp.Key;

/*
l'objectif : tout passer par define()

ex : define ("jump", [Key.SPACE, Key.UP, Pad.btn1, Pad.UP, VPAD.UP]) !!!

et ensuite ckeck("jump"), onPress("jump"), onRelease("jump") quel que soit l'input !
*/

class Input {

	// multi-inputs system

	public static function define(name:String, keyCodes:Array<Int>){ // define the input name, possibly for multiple keys
		keysDefined_.set(name, keyCodes);
		keyPressCallbacks_.set(name, function(){});
		keyReleaseCallbacks_.set(name, function(){});
	}

	public static function onKeyPress(name:String, func:Void->Void){ // to define input name events callbacks
		if(keyPressCallbacks_==null) throw "You must use Input.activeKeyboard() BEFORE using keyboard events !";
		keyPressCallbacks_.set(name, func);
	}
	public static function onKeyRelease(name:String, func:Void->Void){ // to define input name events callbacks
		if(keyReleaseCallbacks_==null) throw "You must use Input.activeKeyboard() BEFORE using keyboard events !";
		keyReleaseCallbacks_.set(name, func);
	}
	public static function onKeysPress(names:Array<String>, func:Void->Void){ // multiple input names for the same callback !
		if(keyPressCallbacks_==null) throw "You must use Input.activeKeyboard() BEFORE using keyboard events !";
		for (i in 0 ... names.length) {
			keyPressCallbacks_.set(names[i], func);	
		}		
	}
	public static function onKeysRelease(names:Array<String>, func:Void->Void){ // multiple input names for the same callback !
		if(keyReleaseCallbacks_==null) throw "You must use Input.activeKeyboard() BEFORE using keyboard events !";
		for (i in 0 ... names.length) {
			keyReleaseCallbacks_.set(names[i], func);	
		}	
	}


	// joysticks

	// private static var pbtns_:Array<Bool>;
	// private static var btns_:Array<Bool>;

	// private static var _gameInput:GameInput;

	/*public static function activeJoysticks(){ // to activate joysticks listening
		trace("joysticks activated...");
		Lib.stage.addEventListener (JoystickEvent.AXIS_MOVE, _handleJoyAxisMove);
		Lib.stage.addEventListener (JoystickEvent.BUTTON_DOWN, _handleJoyButtonDown);
		Lib.stage.addEventListener (JoystickEvent.BUTTON_UP, _handleJoyButtonUp);
		Lib.stage.addEventListener (JoystickEvent.HAT_MOVE, _handleJoyHatMove);
		Lib.stage.addEventListener (JoystickEvent.DEVICE_ADDED, _handleJoyAdded);
		Lib.stage.addEventListener (JoystickEvent.DEVICE_REMOVED, _handleJoyRemoved);

		// _gameInput = new GameInput();
		// _gameInput.addEventListener(GameInputEvent.DEVICE_ADDED, onDeviceAdded);
		// _gameInput.addEventListener(GameInputEvent.DEVICE_REMOVED, onDeviceRemoved);
	}*/
	/*private static function onDeviceAdded(Event:GameInputEvent):Void
{
	trace("joy added !");
// addGamepad(Event.device);
}
private static function onDeviceRemoved(Event:GameInputEvent):Void
{
	trace("joy removed !");
// removeGamepad(Event.device);
}*/
	/*public static function desactiveJoysticks(){
		Lib.stage.removeEventListener (JoystickEvent.AXIS_MOVE, _handleJoyAxisMove);
		Lib.stage.removeEventListener (JoystickEvent.BUTTON_DOWN, _handleJoyButtonDown);
		Lib.stage.removeEventListener (JoystickEvent.BUTTON_UP, _handleJoyButtonUp);
		Lib.stage.removeEventListener (JoystickEvent.HAT_MOVE, _handleJoyHatMove);
		Lib.stage.removeEventListener (JoystickEvent.DEVICE_ADDED, _handleJoyAdded);
		Lib.stage.removeEventListener (JoystickEvent.DEVICE_REMOVED, _handleJoyRemoved);
	}*/

	/*private static function _handleJoyAxisMove (e:JoystickEvent):Void {
		trace("axis move"+e.device+' / '+e.x+' / '+e.y); 
		// e.axis is an Array version, that handles 2 sticks I guess...
	}
	private static function _handleJoyButtonDown (e:JoystickEvent):Void {
		trace("btn down"+e.device+' / '+e.id);		
	}
	private static function _handleJoyButtonUp (e:JoystickEvent):Void {
		trace("btn up"+e.device+' / '+e.id);		
	}
	private static function _handleJoyHatMove (e:JoystickEvent):Void {
		// ???
		trace("hat move"+e.device+' / '+e.id+' / '+e.x+' / '+e.y+' / '+e.axis);		
	}
	private static function _handleJoyAdded (e:JoystickEvent):Void {
		trace("added "+e.device);		
	}
	private static function _handleJoyRemoved (e:JoystickEvent):Void {
		trace("added "+e.device);		
	}*/


	// keyboard

	public static function enablePauseKey(key:Int=80){
		Input.define("pause", [key]); // Key.P
		Input.onKeyPress("pause", function(){ 
			Lib.toggleGame();
		});
	}

	private static var keyboardOn_:Bool = false;
	private static var pkeys_:Array<Bool>;
	private static var keys_:Array<Bool>;
	private static var keysDefined_:Map<String,Array<Int>>;
	private static var keyPressCallbacks_:Map<String,Void->Void>;
	private static var keyReleaseCallbacks_:Map<String,Void->Void>;

	public static function activeKeyboard(){ // to activate keyboard listening
		if(!keyboardOn_){
			keyboardOn_ = true;
			pkeys_ = [];
			keys_ = [];
			keysDefined_ = new Map<String,Array<Int>>();
			keyPressCallbacks_ = new Map<String,Void->Void>();
			keyReleaseCallbacks_ = new Map<String,Void->Void>();
			Lib.root.addEventListener(Event.ENTER_FRAME, onUpdate_); // so the update occurs after Engine.update(), end before children Sprite !
			Lib.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown_);
			Lib.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp_);
		}
	}
	public static function desactiveKeyboard(){ // kill keyboard listeners and empty keyboard input settings
		if(keyboardOn_){
			keyboardOn_ = false;
			pkeys_ = [];
			keys_ = [];
			keysDefined_ = new Map<String,Array<Int>>();
			keyPressCallbacks_ = new Map<String,Void->Void>();
			keyReleaseCallbacks_ = new Map<String,Void->Void>();
			Lib.root.removeEventListener(Event.ENTER_FRAME, onUpdate_);
			Lib.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown_);
			Lib.stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyUp_);
		}
	}
	public static function keyPressed(name:String){ // current input name press state
		var codes:Null<Array<Int>> = keysDefined_.get(name);
		if(codes==null){
			return false;
		} else {
			for (i in 0 ... codes.length) {
				if(keys_[codes[i]]) return true;
			}
			return false;
		}
	}

	// private keyboard events internal callbacks
	private static function onKeyDown_(e:KeyboardEvent):Void { // key event
		keys_[e.keyCode] = true;
	}
	private static function onKeyUp_(e:KeyboardEvent):Void { // key event
		keys_[e.keyCode] = false;
	}
	private static function onUpdate_(e:Event){
		// the keys states are checked on update, to apply events synchronised with Engine frames (not between frames)

		for (key in keysDefined_.keys()){
			var keyCodes:Null<Array<Int>> = keysDefined_.get(key);
			if(keyCodes != null){
				for (j in 0 ... keyCodes.length){ var i:Int = keyCodes[j];

					if(keys_[i] != pkeys_[i]){ // state change !

						if(pkeys_[i]){ // release
							var name:String = findDefined(i);
							if(name!="") onKeyReleased_(name);
						} else { // press
							var name:String = findDefined(i);
							if(name!="") onKeyPress_(name);
						}

						pkeys_[i] = keys_[i];
					}
				}	
			}						
		}
	}

	// public functions that attach callbacks to events
	private static function onKeyPress_(name:String){ // registers a function for this control
		var func:Null<Void->Void> = keyPressCallbacks_.get(name);
		if(func != null) func();
	}
	private static function onKeyReleased_(name:String){ // registers a function for this control
		var func:Null<Void->Void> = keyReleaseCallbacks_.get(name);
		if(func != null) func();
	}
	private static function findDefined(keyCode:Int):String { // returns the name defined for the key, or "" if not defined
		for (key in keysDefined_.keys()){
			var keyCodes:Null<Array<Int>> = keysDefined_.get(key);
			if(keyCodes == null){
				return "";
			} else {
				for (j in 0 ... keyCodes.length){
					if(keyCodes[j] == keyCode) return key;
				}	
			}						
		}
		return "";
	}

}


class Key {
	public inline static var ANY = -1;
	public inline static var LEFT = 37;
	public inline static var UP = 38;
	public inline static var RIGHT = 39;
	public inline static var DOWN = 40;
	public inline static var ENTER = 13;
	public inline static var COMMAND = 15;
	public inline static var CONTROL = 17;
	public inline static var SPACE = 32;
	public inline static var SHIFT = 16;
	public inline static var BACKSPACE = 8;
	public inline static var CAPS_LOCK = 20;
	public inline static var DELETE = 46;
	public inline static var END = 35;
	public inline static var ESCAPE = 27;
	public inline static var HOME = 36;
	public inline static var INSERT = 45;
	public inline static var TAB = 9;
	public inline static var PAGE_DOWN = 34;
	public inline static var PAGE_UP = 33;
	public inline static var LEFT_SQUARE_BRACKET = 219;
	public inline static var RIGHT_SQUARE_BRACKET = 221;
	public inline static var TILDE = 192;
	public inline static var A = 65;
	public inline static var B = 66;
	public inline static var C = 67;
	public inline static var D = 68;
	public inline static var E = 69;
	public inline static var F = 70;
	public inline static var G = 71;
	public inline static var H = 72;
	public inline static var I = 73;
	public inline static var J = 74;
	public inline static var K = 75;
	public inline static var L = 76;
	public inline static var M = 77;
	public inline static var N = 78;
	public inline static var O = 79;
	public inline static var P = 80;
	public inline static var Q = 81;
	public inline static var R = 82;
	public inline static var S = 83;
	public inline static var T = 84;
	public inline static var U = 85;
	public inline static var V = 86;
	public inline static var W = 87;
	public inline static var X = 88;
	public inline static var Y = 89;
	public inline static var Z = 90;
	public inline static var F1 = 112;
	public inline static var F2 = 113;
	public inline static var F3 = 114;
	public inline static var F4 = 115;
	public inline static var F5 = 116;
	public inline static var F6 = 117;
	public inline static var F7 = 118;
	public inline static var F8 = 119;
	public inline static var F9 = 120;
	public inline static var F10 = 121;
	public inline static var F11 = 122;
	public inline static var F12 = 123;
	public inline static var F13 = 124;
	public inline static var F14 = 125;
	public inline static var F15 = 126;
	public inline static var DIGIT_0 = 48;
	public inline static var DIGIT_1 = 49;
	public inline static var DIGIT_2 = 50;
	public inline static var DIGIT_3 = 51;
	public inline static var DIGIT_4 = 52;
	public inline static var DIGIT_5 = 53;
	public inline static var DIGIT_6 = 54;
	public inline static var DIGIT_7 = 55;
	public inline static var DIGIT_8 = 56;
	public inline static var DIGIT_9 = 57;
	public inline static var NUMPAD_0 = 96;
	public inline static var NUMPAD_1 = 97;
	public inline static var NUMPAD_2 = 98;
	public inline static var NUMPAD_3 = 99;
	public inline static var NUMPAD_4 = 100;
	public inline static var NUMPAD_5 = 101;
	public inline static var NUMPAD_6 = 102;
	public inline static var NUMPAD_7 = 103;
	public inline static var NUMPAD_8 = 104;
	public inline static var NUMPAD_9 = 105;
	public inline static var NUMPAD_ADD = 107;
	public inline static var NUMPAD_DECIMAL = 110;
	public inline static var NUMPAD_DIVIDE = 111;
	public inline static var NUMPAD_ENTER = 108;
	public inline static var NUMPAD_MULTIPLY = 106;
	public inline static var NUMPAD_SUBTRACT = 109;
	/**
	* Returns the name of the key.
	* @param char The key to name.
	* @return The name.
	*/
	/*public static function nameOfKey(char:Int):String {
		if (char == -1) return "";
		if (char >= A && char <= Z) return String.fromCharCode(char);
		if (char >= F1 && char <= F15) return "F" + Std.string(char - 111);
		if (char >= 96 && char <= 105) return "NUMPAD " + Std.string(char - 96);
		switch (char){
			case LEFT: return "LEFT";
			case UP: return "UP";
			case RIGHT: return "RIGHT";
			case DOWN: return "DOWN";
			case LEFT_SQUARE_BRACKET: return "{";
			case RIGHT_SQUARE_BRACKET: return "}";
			case TILDE: return "~";
			case ENTER: return "ENTER";
			case CONTROL: return "CONTROL";
			case SPACE: return "SPACE";
			case SHIFT: return "SHIFT";
			case BACKSPACE: return "BACKSPACE";
			case CAPS_LOCK: return "CAPS LOCK";
			case DELETE: return "DELETE";
			case END: return "END";
			case ESCAPE: return "ESCAPE";
			case HOME: return "HOME";
			case INSERT: return "INSERT";
			case TAB: return "TAB";
			case PAGE_DOWN: return "PAGE DOWN";
			case PAGE_UP: return "PAGE UP";
			case NUMPAD_ADD: return "NUMPAD ADD";
			case NUMPAD_DECIMAL: return "NUMPAD DECIMAL";
			case NUMPAD_DIVIDE: return "NUMPAD DIVIDE";
			case NUMPAD_ENTER: return "NUMPAD ENTER";
			case NUMPAD_MULTIPLY: return "NUMPAD MULTIPLY";
			case NUMPAD_SUBTRACT: return "NUMPAD SUBTRACT";
		}
		return String.fromCharCode(char);
	}*/
}