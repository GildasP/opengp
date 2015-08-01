package opengp;

import tweenx909.TweenX;
import tweenx909.advanced.StandardTweenX;

import opengp.Lib;

/*
Tweenx seems a great lib, with great performances, just what I needed.
No need to pack it, just some helpers to add.
http://tweenx.spheresofa.net/en.html
*/

class Tween {

	public static function to<T>( target:T, ?params:Dynamic, ?duration:Float, ?callback:Null<Void->Void>){
		if(callback != null){
			return TweenX.to(target, params, duration).onFinish(callback);
		} else {
			return TweenX.to(target, params, duration);
		}
	}

	public static function sequence(tweens:Dynamic){
		return TweenX.serial(tweens);
	}

	// using Lib.sprite to build a fake tween to time functions :)
	public static function setTimeout(func:Void->Void, duration:Float){		
		return TweenX.to(Lib.sprite).time(duration).onFinish(func);
	}
	public static function setInterval(func:Void->Void, duration:Float){
		return TweenX.serial([
			TweenX.to(Lib.sprite).time(duration)
		]).repeat().onRepeat(func);
	}

	public static function stop(tween:TweenX){ // a static version of the inline stop function...
		tween.stop();
	}
	public static function stopAll(){
		var nb:Int = 0;
		for(t in TweenX.tweens){ nb++; }
		TweenX.stopAll(TweenX.tweens);
	}

	private static var pausedTweens:Array<TweenX>;
	public static function pauseAll(){
		pausedTweens = new Array<TweenX>(); // must keep track of the tweens, or they are destroyed by stop()
		for(t in TweenX.tweens){
			pausedTweens.push(t);
		}
		stopAll();
	}
	public static function resumeAll(){
		for(t in pausedTweens){
			t.play();
		}
		pausedTweens = new Array<TweenX>();
	}

	/*public static function clearAll(){ // destroys every tween
		TweenX.clear();
	}*/
	/*public static function pauseAll(){
		for(t in TweenX.tweens){
			t.wait(99999999999999);
		}
		// TweenX.wait(9999999999999);
	}
	public static function resumeAll(){
		var nb:Int = 0;
		for(t in TweenX.tweens){ nb++; }
		trace('resuming '+nb);
		TweenX.playAll(TweenX.tweens);
	}*/

}