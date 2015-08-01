package opengp;

import motion.Actuate;
import motion.actuators.GenericActuator;

import opengp.Sprite;

class Tween {

	/*
	Le pb actuel, c'est de retourner un objet simple, qui permette de référencer simplement le truc pour plus tard...
	genre pour faire un clearTimeout ou stopper un tween...
	une Map static genre name->Dynamic, qui stocke n'importe quel objet ?
	et ensuite Tween.clearTimeout(name) ?
	par contre il va falloir faire gaffe à bien vider la map au fur et à mesure... 

	-> TweenX a l'air plus adaptée ! J'aurai ptèt même pas besoin de faire ma lib...
	http://tweenx.spheresofa.net/en.html
	https://github.com/shohei909/tweenx
	*/

	private static var processes_:Map<String,Dynamic> = new Map<String,Dynamic>();

	public static function to<T>(sprite:T, duration:Float, properties:Dynamic, callback:Null<Void->Void>=null, callbackParams:Null<Array<Dynamic>>=null):GenericActuator<T> {
		var actuator:GenericActuator<T>;
		if(callback == null){
			actuator = Actuate.tween(sprite, duration, properties, true);
		} else {
			actuator = Actuate.tween(sprite, duration, properties, true).onComplete(callback, callbackParams);
		}
		return actuator;
	}
	public static function setTimeout(func:Void->Void, duration:Float){
		return Actuate.timer(duration).onComplete(func);
	}
}