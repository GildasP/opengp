package opengp;

import openfl.display.Graphics;
import openfl.display.BitmapData;
import openfl.geom.Matrix;

import opengp.Lib;
import opengp.Sprite;

/*
The Processing drawing API for OpenFL
Easy simple and complex vector shapes drawing, with style buffer.

May output openfl.Graphics or opengp.Sprite...
depends on what you need !
*/


typedef Vertex = { x:Float, y:Float }; // just for the Shape class needs

class Shape {

	// system
	private static var Lib_sprite:Sprite;
	private static function applyStyle(){ // apply stroke and fill settings before drawing
		if(!complexMode_) Lib_sprite = new Sprite(); //Lib_sprite.graphics.clear(); // clear graphics if new shape :)
		if(strokeThickness>0) Lib_sprite.graphics.lineStyle(strokeThickness, strokeColor, strokeAlpha);
		if(fillAlpha>0) Lib_sprite.graphics.beginFill(fillColor, fillAlpha);
	}
	private static function endStyle(){
		if(fillAlpha>0) Lib_sprite.graphics.endFill();
	}
	private static function buildShape(forceSprite:Bool=false):Sprite { // produces a sprite of a graphics from the Lib_sprite drawing...
		// if(givingSprite_ || forceSprite){

			/*var sprite:Sprite = new Sprite();
			sprite.graphics.copyFrom(Lib_sprite.graphics);
			return sprite;*/
			
			return Lib_sprite;
		/*} else {
			return Lib_sprite.graphics;
		}*/
	}

	// private static var givingSprite_:Bool = true; // produces Sprites by default
	private static var complexMode_:Bool = false;

	/*public static function giveSprites(){
		givingSprite_ = true;
	}
	public static function giveGraphics(){
		givingSprite_ = false;
	}*/
	
	/*public static function complexMode(){
		Lib_sprite.graphics.clear(); // on remet à zéro
		complexMode_ = true;
	}
	public static function getComplex(w_:Int=0, h_:Int=0, rot:Float=0):GImage {
		complexMode_ = false;
		//var img = createGImage(Std.int(Lib_sprite.width), Std.int(Lib_sprite.height));
		//trace("natural dims : "+Lib_sprite.width+" / "+Lib_sprite.height);
		if(w_==0) w_ = Std.int(Lib_sprite.width);
		if(h_==0) h_ = Std.int(Lib_sprite.height);
		var img = createGImage(w_, h_, rot);
		Lib_sprite.graphics.clear(); // on remet à zéro
		return img;
	}*/

	// bonus
	/*
	storeStyle
	restoreStyle
	*/
	
	/**/

	// 2D primitives
	/*arc()
	ellipse()
	line()
	point()
	quad()
	rect()
	triangle()*/

	public static function background(color_:Int, alpha_:Float=1):Void {
		storeStyle(); // stroe previous settings

		noStroke();
		fill(color_, alpha_);
		// giveSprites(); // always build a Sprite
		rectMode("corner");
		var bkg:Sprite = rect(0, 0, Lib.width, Lib.height);
		
		restoreStyle(); // restore previous settings

		// doesn't return anything, and auto-add itself to root Sprite
		Lib.root.addChild(bkg);
	}
	public static function ellipse(x_:Float=0, y_:Float=0, width:Float=0, height:Float=0):Sprite {
		if (width == 0) throw "Illegal ellipse, sizes cannot be 0.";
		if (height == 0) height = width;

		var x = x_; var y= y_;
		if(ellipseMode_=="center"){
			x -= (width+strokeThickness)/2;
			y -= (height+strokeThickness)/2;
		}
		applyStyle();
		Lib_sprite.graphics.drawEllipse(x, y, width, height);
		endStyle();

		return buildShape();		
	}
	public static function rect(x_:Float=0, y_:Float=0, width:Float=0, height:Float=0, radius_:Float=0):Sprite {
		if (width == 0 || height == 0) throw "Illegal rect, sizes cannot be 0.";

		var x = x_; var y= y_;
		if(rectMode_=="center"){
			x -= (width+strokeThickness)/2;
			y -= (height+strokeThickness)/2;
		}
		applyStyle();
		if(radius_==0){
			Lib_sprite.graphics.drawRect(x, y, width, height);
		} else {
			Lib_sprite.graphics.drawRoundRect(x, y, width, height, 2*radius_, 2*radius_);
		}		
		endStyle();
		
		return buildShape();
	}
	public static function line(x1:Float, y1:Float, x2:Float, y2:Float):Sprite {

		var x_:Float = Math.min(x1, x2);
		var y_:Float = Math.min(y1, y2);
		var w_:Float = Math.abs(x2-x1);
		var h_:Float = Math.abs(y2-y1);

		if(complexMode_){ x_ = 0; y_ = 0; } // pas de décalage

		applyStyle();
		Lib_sprite.graphics.moveTo(x1-x_, y1-y_);
		Lib_sprite.graphics.lineTo(x2-x_, y2-y_);
		endStyle();

		return buildShape();
	}
	public static function quad(x1:Float, y1:Float, x2:Float, y2:Float, x3:Float, y3:Float, x4:Float, y4:Float):Sprite {
		beginShape();
		vertex(x1, y1);
		vertex(x2, y2);
		vertex(x3, y3);
		vertex(x4, y4);
		return endShape();
	}
	public static function triangle(x1:Float, y1:Float, x2:Float, y2:Float, x3:Float, y3:Float):Sprite {
		beginShape();
		vertex(x1, y1);
		vertex(x2, y2);
		vertex(x3, y3);
		return endShape();
	}
	public static function point(x_:Float=0, y_:Float=0):Sprite {
		// un rectangle si épaisseur 1px, sinon un cercle
		if(strokeThickness>1){
			var rond:Dynamic = ellipse(x_, y_, Std.int(strokeThickness/4));
			// rond.centerOrigin();
			return rond;
		} else {
			return rect(x_, y_, 1, 1);
		}
	}

	// Vertex
	/*beginShape()
	bezierVertex()
	curveVertex()
	endShape()
	texture()
	textureMode()
	vertex()*/
	private static var vectArray:Array<Vertex> = new Array();
	public static function beginShape(){
		vectArray = new Array();
	}
	public static function vertex(x_:Float, y_:Float){
		var v:Vertex = { x:x_, y:y_ };
		vectArray.push(v);
	}
	public static var sommets:Array<Float>;
	public static function endShape(close:Bool=true):Sprite {
		// ok, là il va falloir dessiner :)
		if(vectArray.length<=1) throw "Illegal shape, needs at least 2 vertex.";

		// coord et dims du bitmap qui contiendrait tout...
		var minX:Float = vectArray[0].x;
		var maxX:Float = vectArray[0].x;
		var minY:Float = vectArray[0].y;
		var maxY:Float = vectArray[0].y;
		for (i in 1...vectArray.length){
			minX = Math.min(minX, vectArray[i].x);
			maxX = Math.max(maxX, vectArray[i].x);
			minY = Math.min(minY, vectArray[i].y);
			maxY = Math.max(maxY, vectArray[i].y);
		}
		var x_:Float;
		var y_:Float;
		if(rectMode_=="center"){
			x_ = (minX+maxX)/2;
			y_ = (minY+maxY)/2;
		} else {
			x_ = minX;
			y_ = minY;
		}			
		
		var w_:Float = maxX - minX;
		var h_:Float = maxY - minY;

		applyStyle();

		sommets = new Array(); // pour pouvoir récupérer la liste ensuite
		if(rectMode_=="center"){
			sommets.push(vectArray[0].x-minX+strokeThickness); sommets.push(vectArray[0].y-minY+strokeThickness);
			Lib_sprite.graphics.moveTo(vectArray[0].x-minX+strokeThickness, vectArray[0].y-minY+strokeThickness); // move to 1st
			for (i in 1...vectArray.length){
				sommets.push(vectArray[i].x-minX+strokeThickness); sommets.push(vectArray[i].y-minY+strokeThickness);
				Lib_sprite.graphics.lineTo(vectArray[i].x-minX+strokeThickness, vectArray[i].y-minY+strokeThickness);
			}
			if(close) Lib_sprite.graphics.lineTo(vectArray[0].x-minX+strokeThickness, vectArray[0].y-minY+strokeThickness); // line to 1st
		} else {
			sommets.push(vectArray[0].x-x_+strokeThickness); sommets.push(vectArray[0].y-y_+strokeThickness);
			Lib_sprite.graphics.moveTo(vectArray[0].x-x_+strokeThickness, vectArray[0].y-y_+strokeThickness); // move to 1st
			for (i in 1...vectArray.length){
				sommets.push(vectArray[i].x-x_+strokeThickness); sommets.push(vectArray[i].y-y_+strokeThickness);
				Lib_sprite.graphics.lineTo(vectArray[i].x-x_+strokeThickness, vectArray[i].y-y_+strokeThickness);
			}
			if(close) Lib_sprite.graphics.lineTo(vectArray[0].x-x_+strokeThickness, vectArray[0].y-y_+strokeThickness); // line to 1st
		}
		
		endStyle();		
		
		/*var image:GImage = createGImage(Std.int(w_+2*strokeThickness), Std.int(h_+2*strokeThickness));
		if(rectMode_=="center"){
			image.x = strokeThickness; //x_-strokeThickness; 
			image.y = strokeThickness; //y_-strokeThickness;
		} else {
			image.x = 0; image.y = 0;
		}

		if(rectMode_=="center") image.centerOrigin();*/

		vectArray = new Array(); // init
		// return image;
		return buildShape();
	}


	////// Bonus ! //////
	//private static var prevPos:Vertex = new Vertex(0, 0);
	/*public static function startComplex(){
		applyStyle(); // clear et styles
	}
	public static function complexMoveTo(x_:Int, y_:Int){
		//prevPos = new Vertex(x_, y_);
		Lib_sprite.graphics.moveTo(x_+strokeThickness, y_+strokeThickness);
	}
	public static function complexLineTo(x_:Int, y_:Int){
		Lib_sprite.graphics.lineTo(x_+strokeThickness, y_+strokeThickness);
	}
	public static function endComplex():GImage {
		endStyle();
		trace("largeur du sprite : "+Lib_sprite.width);
		return createGImage(Std.int(Lib_sprite.width), Std.int(Lib_sprite.height));
	}*/


	/*
	public static function randomPolygon(L_:Int, H_:Int=0, nbSommets_:Int=0):GImage {
		// ploygon convexe aléatoire !
		// http://stackoverflow.com/questions/21690008/how-to-generate-random-vertices-to-form-a-convex-polygon-in-c
		
		if(nbSommets_ == 0) nbSommets_ = 3 + HXP.rand(6); // nb de sommets aléatoire
		if(H_ == 0) H_ = L_;

		var slices:Array<Float> = new Array(); // tranches genre camembert sur un cercle
		for (i in 0...nbSommets_) {
			slices.push(Math.random()*2*Math.PI);
		}
		slices.sort(function(x:Float, y:Float){ // ordre croissant
			if(x==y){ return 0;
			} else if(x<y){ return -1;
			} else { return 1; }
		});

		// juste pour pouvoir réutiliser la liste des sommets ensuite...
		sommets = new Array();

		for (i in 0...nbSommets_) {
			var x_:Float = L_*Math.cos(slices[i]);
			var y_:Float = H_*Math.sin(slices[i]);
			sommets.push(Std.int(x_));
			sommets.push(Std.int(y_));
		}

		// dessin
		GP5.beginShape();
		for (i in 0...nbSommets_) { GP5.vertex(sommets[2*i], sommets[2*i+1]); }		
		return GP5.endShape();
	}

	// Curves ???
	/* note : curveTo de 
	http://haxepunk.com/documentation/api/content/flash/display/Graphics.html
	semble correspondre directement avec les bézier.
	pour les curves il ya une "matrice" de transposition,
	pour passer de la liste des points aux courbes de bézier :)
	https://github.com/processing-js/processing-js/blob/master/src/Processing.js
	ligne 6904, // curveVertex
	dans Drawing2D.prototype.endShape
	et ça a l'air trop bien les curves de P5 !!!
	
	bezier()
	bezierDetail()
	bezierPoint()
	bezierTangent()
	curve()
	curveDetail()
	curvePoint()
	curveTangent()
	curveTightness()*/

	// Matrix stuff !!! 
	// est-ce utile ???
	/*applyMatrix()
	popMatrix()
	printMatrix()
	pushMatrix()
	resetMatrix()
	rotate()
	rotateX()
	rotateY()
	rotateZ()
	scale()
	translate()*/



	// private stuff
	
	/*private static function createGImage(w_:Float, h_:Float, rot:Float=0):GImage {
		// on transvase dans un flash.display.BitmapData natif du bon format
		var data:BitmapData = HXP.createBitmap(
			Math.ceil(w_+2*strokeThickness), 
			Math.ceil(h_+2*strokeThickness), true, 0);

		var matrice:Matrix = new Matrix();
		//matrice.scale(iTest.scaleX, iTest.scaleY);
		//matrice.translate(-(w_+2*strokeThickness)/2, -(h_+2*strokeThickness)/2);
		// matrice.rotate( rot );
		// matrice.translate(0,0);
		//matrice.translate(0, 0);

		data.draw(Lib_sprite, matrice);
		// et hop on en fait un haxepunk.graphics.GImage
		var image:GImage;
		if (HXP.renderMode == RenderMode.HARDWARE){
			image = new GImage(Atlas.loadImageAsRegion(data));
		} else {
			image = new GImage(data);
		}
		return image;
	}*/

	// styling
	private static var strokeColor:Int = 0x000000;
	private static var strokeThickness:Float = 1;
	private static var strokeAlpha:Float = 1;
	private static var fillColor:Int = 0xFFFFFF;
	private static var fillAlpha:Float = 1;
	private static var ellipseMode_:String = "center";
	private static var rectMode_:String = "center";

	public static function stroke(color_:Int, alpha_:Float=1){
		strokeColor = color_;
		strokeAlpha = alpha_;
	}
	public static function strokeWeight(thickness_:Float){
		strokeThickness = thickness_;
	}
	public static function noStroke(){
		strokeThickness = 0;
	}
	public static function fill(color_:Int, alpha_:Float=1){
		fillColor = color_;
		fillAlpha = alpha_;
	}
	public static function noFill(){
		fillAlpha = 0;
	}
	public static function ellipseMode(mode:String){
		if(mode == "center" || mode == "CENTER"){ ellipseMode_ = "center";
		} else { ellipseMode_ = "corner"; }
	}
	public static function rectMode(mode:String){
		if(mode == "center" || mode == "CENTER"){ rectMode_ = "center";
		} else { rectMode_ = "corner"; }
	}

	// storing current style to restore it later
	private static var storedStyle:Dynamic; 
	// {"strokeColor":0xFFFFFF, "strokeAlpha":1, "strokeWeight":1, "fillColor":0x000000, "fillAlpha":1, "ellipseMode":"center", "rectMode":"center"};
	public static function storeStyle(){
		storedStyle = {
			"strokeColor": strokeColor,
			"strokeAlpha": strokeAlpha,
			"strokeThickness": strokeThickness,
			"fillColor": fillColor,
			"fillAlpha": fillAlpha,
			"ellipseMode": ellipseMode_,
			"rectMode": rectMode_/*,
			"givingSprite": givingSprite_*/
		};
	}
	public static function restoreStyle(){
		strokeColor = storedStyle.strokeColor;
		strokeAlpha = storedStyle.strokeAlpha;
		strokeThickness = storedStyle.strokeThickness;
		fillColor = storedStyle.fillColor;
		fillAlpha = storedStyle.fillAlpha;
		ellipseMode_ = storedStyle.ellipseMode;
		rectMode_ = storedStyle.rectMode;
		// givingSprite_ = storedStyle.givingSprite;
	}
}