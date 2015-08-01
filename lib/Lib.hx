package opengp;

import opengp.Engine;
import opengp.Scene;
import opengp.Sprite;
import openfl.display.Stage;

/*
Light class, whith helpers reusable everywhere...
There's more heavy stuff in the Tools class.
*/

class Lib {

	public static var root:Engine;
	public static var stage:Stage;
	public static var sprite:Sprite = new Sprite(); // empty Sprite to draw in
	public static var scene(get, set):Scene;
	private static function get_scene():Scene { return root.scene; }
	private static function set_scene(s:Scene):Scene { return root.scene = s; }

	public function new(engine:Engine){ // triggered by Engine.new()
		root = engine;
		stage = root.stage;
	}

	public static var width(get, never):Float;
	private static function get_width():Float {
		return stage.stageWidth;
	}
	public static var height(get, never):Float;
	public static function get_height():Float {
		return stage.stageHeight;
	}

	public static function pauseGame(){
		root.pause();
	}
	public static function resumeGame(){
		root.resume();
	}
	public static function toggleGame(){
		root.playpause();
	}

	public static function getTimer():Int {
		return openfl.Lib.getTimer();
	}
	public static function intSeq(start:Int, end:Int):Array<Int> { // a sequence of Int, mainly for Spritesheets stuff
		var space:Int = end - start;
		var seq:Array<Int> = new Array<Int>();
		for (i in 0 ... space) {
			seq.push(start + i);
		}
		seq.push(end);
		return seq;
	}
	public static function logSeq(start:Int, end:Int){ // usefull in development !
#if debug
		trace(intSeq(start,end));
#end		
	}

    // Maths
    public static function randFloat(min:Float, max:Float):Float {
		return min + Math.random()*(max - min);
	}
	public static function randInt(min:Float, max:Float):Int {
		return Std.int(min + Math.random()*(max - min));
	}
	public static function randColor():Int {
		return Std.int(Math.random()*0xFFFFFF);
	}

	// sys
	public static function typeof(obj:Dynamic):String {
		return Type.getClassName(Type.getClass(obj));
	}
	public static function hasClass(obj:Dynamic, classe:String):Bool {		
		return Std.is(obj, Type.resolveClass(classe));
	}

	public static function noTrace(){ // triggered if !debug by Engine.new()
		haxe.Log.trace = function(v:Dynamic, ?inf:haxe.PosInfos){}; // switch off any trace() instruction
	}

	public static inline function dist(x1:Float, y1:Float, x2:Float, y2:Float):Float {
		return Math.sqrt((x2-x1)*(x2-x1) + (y2-y1)*(y2-y1));
	}

}