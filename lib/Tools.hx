package opengp;

import openfl.net.URLRequest;
import openfl.Lib;
import openfl.system.System;
import openfl.system.Capabilities;
import openfl.ui.Mouse;

import opengp.Engine;

/*

*/

class Tools {

	public static var root:Engine;

	public function new(engine:Engine){ // triggered by Engine.new()
		root = engine;
	}

    public static function hideMouse(){
        Mouse.hide();
    }
    public static function showMouse(){
        Mouse.show();
    }

	// lien web (marche partout, à priori)
    public static function getURL(url:String, target:String=null){
        // flash.Lib.getURL(new URLRequest(url), target);
        openfl.Lib.getURL(new URLRequest(url), target);
    }

    // quitter l'appli (android, cpp)
    public static function quit(){
        //flash.system.System.exit(1); // marche mal sur android
#if (!html5 && !flash)
        // flash.Lib.exit();
        System.exit(1);
#end
    }

    // la plateforme de l'app
    public static function getPlatform():String{
#if android
        return "Android";
#elseif ios
        return "iOS";
#elseif flash
        return "Flash";
#elseif html5
        return "Html5";
#elseif cpp
        return "C++";
#elseif neko
        return "Neko";
#else 
        return "Unknown";
#end
    }

    // gestion du fullscreen
    public static function toggleFullscreen(){
#if !mobile
        if(root.stage.displayState == flash.display.StageDisplayState.NORMAL){
            root.stage.displayState = flash.display.StageDisplayState.FULL_SCREEN_INTERACTIVE;
        } else {
            root.stage.displayState = flash.display.StageDisplayState.NORMAL;
        }
#end
    }
    public static function goFullScreen(){
#if !mobile
        root.stage.displayState = flash.display.StageDisplayState.FULL_SCREEN_INTERACTIVE;
#end
    }
    public static function quitFullScreen(){
#if !mobile
        root.stage.displayState = flash.display.StageDisplayState.NORMAL;
#end
    }

    // pixel ratio
    public static function getScreenDPI():Float {
        return Capabilities.screenDPI;
    }
    public static function getScreenDensity():Float {
        // https://gist.github.com/jgranick/1762072
        var screenDensity:Float = 1;
        var dpi = Capabilities.screenDPI;
        if (dpi < 200) {
            screenDensity = 1;
        } else if (dpi < 300) {
            screenDensity = 1.5;
        } else {
            screenDensity = 2;
        }
        return screenDensity;
    }
}