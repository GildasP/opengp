package opengp;

import openfl.text.TextField;
import openfl.text.TextFormat;
import openfl.text.AntiAliasType;
import openfl.text.TextFormatAlign;
import openfl.Assets;

/*
special chars issue... 'acceptés' shows 'accept s'
even with a font that has the char in it :/
haxe.Utf8.validate(this.text) gives true
trace(haxe.Utf8.decode(this.text) doesn't help :/
?!!!
*/

class Text extends TextField {

	private static var defaultStyle:TextFormat;
	public static var initiated:Bool = false; // temporary, for defaultStyle ignition...

	// public var isPaused_:Bool; // just for the global game pause logic

	private var myStyle:TextFormat;
	private var upcase_:Bool = false;
	private var lowcase_:Bool = false;

	public function new(txt:String, size:Int=-1, color:Int=-1){ super();

		// default style TextFormat var initialisation
		if(!initiated){
			defaultStyle = new TextFormat("", 12, 0x000000);
			// default system font, 12px, black
			initiated = true;
		}

		this.text = txt;

		// TextFormat options
		if(initiated){
			myStyle = new TextFormat(defaultStyle.font, defaultStyle.size, defaultStyle.color);
			this.setTextFormat(myStyle);
		}
		// myStyle = defaultStyle;
		// if(size>0) myStyle.size = size;
		// if(color>=0) myStyle.color = color;

		this.defaultTextFormat = myStyle;

		// TextField default options
		this.multiline = true;
		this.wordWrap = true;
	}
	public function pauseUpdate(){} // to match Engine children iteration on game play/pause
	public function resumeUpdate(){}

	public function moveTo(x_:Float, y_:Float):Text{
		x = x_; y = y_;
		return this;
	}
	public function moveBy(x_:Float, y_:Float):Text{
		x += x_; y += y_;
		return this;
	}

	public function set(txt:String):Text {
		this.text = txt;
		applyCase(); // forced up or lower case mode
		return this;
	}
	public function add(txt:String):Text {
		this.text += txt;
		applyCase(); // forced up or lower case mode
		return this;
	}
	public function addNL(txt:String):Text {
		this.text += '\n'+txt;
		applyCase(); // forced up or lower case mode
		return this;
	}
	public function clear():Text {
		this.text = "";
		return this;
	}
	public function remove(txt:String):Text { // removes txt string from text
		var cut:Int = this.text.indexOf(txt);
		while(cut>=0){
			this.text = this.text.substr(0, cut) + this.text.substr(cut+txt.length, this.text.length-(cut+txt.length));
			cut = this.text.indexOf(txt);
		}
		return this;
	}

	public function setDim(w:Float, h:Float):Text {
		this.width = w; this.height=h;
		return this;
	}
	public function setSize(size:Int):Text {
		myStyle.size = size;
		this.setTextFormat(myStyle);
		return this;
	}
	public function setFont(font:String):Text {
		myStyle.font = font;
		this.setTextFormat(myStyle);
		return this;
	}
	public function setColor(color:Int):Text {
		myStyle.color = color;
		this.setTextFormat(myStyle);
		return this;
	}
	public function antialias(doantialias:Bool=true):Text{
		if(doantialias){
			this.antiAliasType = AntiAliasType.NORMAL;
		} else {
			this.antiAliasType = AntiAliasType.ADVANCED;
			this.sharpness = -400;
		}
		return this;
	}
	public function upCase(val:Bool=true):Text { // all text is and will be uppercased
		upcase_ = val;
		if(val){ 
			this.text = this.text.toUpperCase();
			lowcase_ = false;
		}
		return this;
	}
	public function lowCase(val:Bool=true):Text { // all text is and will be lowercased
		lowcase_ = val;
		if(val){ 
			this.text = this.text.toLowerCase();
			upcase_ = false;
		}
		return this;
	}
	public function lineSpacing(space:Int=0):Text {
		myStyle.leading = space;
		this.setTextFormat(myStyle);
		return this;
	}
	public function left():Text {
		myStyle.align = TextFormatAlign.LEFT;
		this.setTextFormat(myStyle);
		return this;
	}
	public function right():Text {
		myStyle.align = TextFormatAlign.RIGHT;
		this.setTextFormat(myStyle);
		return this;
	}
	public function center():Text {
		myStyle.align = TextFormatAlign.CENTER;
		this.setTextFormat(myStyle);
		return this;
	}
	public function justify():Text {
		myStyle.align = TextFormatAlign.JUSTIFY;
		this.setTextFormat(myStyle);
		return this;
	}


	public static function setStyle(font:String="", size:Float=12, color:Int=0x000000){
		// (?font:String, ?size:Float, ?color:Int, ?bold:Bool, ?italic:Bool, ?underline:Bool, ?url:String, ?target:String, ?align:TextFormatAlign, ?leftMargin:Float, ?rightMargin:Float, ?indent:Float, ?leading:Float) 
		defaultStyle = new TextFormat(Assets.getFont(font).fontName, size, color);
		initiated = true;
	}

	private function applyCase(){
		if(upcase_) this.text = this.text.toUpperCase();
		if(lowcase_) this.text = this.text.toLowerCase();		
	}
}