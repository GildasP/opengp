package opengp;

import opengp.Lib;
// import opengp.File;

import openfl.media.Sound;
import openfl.Assets;

/*
Todo :
- a static log of created sounds, id Audio.mode == "archive"
associated with a Map assets string -> audio object
that way, no need to keep track of Audio objects, we can play
Audio from the asset string without re-creating the object
- depuis un dossier, direct :)
et hop ça liste tous les sons du dossier et roule ma poule
???
*/

class Audio {

	// static

	private static var audios:Array<Audio> = new Array();

	public static function from(assets:Dynamic):Audio {

		var type = Lib.typeof(assets);
		
		if(type == 'String'){
			return new Audio([assets]);
		} else if(type == 'Array'){
			return new Audio(assets);
		} else {
			throw "Audio param error. Should be either String or Array<String>.";
			return new Audio(['']);
		}
	}
	/*public static function fromFolder(folder:String):Audio {

	}*/

	// Audio object

	private var sounds:Array<Sound> = new Array();
	private var index:Int = 0;

	public function new(assets:Array<String>) {

		for (i in 0 ... assets.length) {
			sounds.push(Assets.getSound(assets[i]));
		}
		
	}
	public function play(id:Null<Int> = null){
		// play sound selected by index value 
		if(id != null) index = id;
		sounds[index].play();
	}
	public function shuffle(){
		var id = Math.floor(Math.random()*sounds.length);
		play(id);
	}
}