package opengp;

/*
 * source :
 * http://fr.openclassrooms.com/informatique/cours/les-shaders-en-glsl/le-produit-scalaire-dot-product
 * mais il y aussi le code source de Processing.js
 * où pomper !!!
 * */

class Vector {

	public var x:Float;
	public var y:Float;
	
	public function new(x_:Float=0, y_:Float=0) {
		this.x = x_;
		this.y = y_;
	}
	
	public function set(x_:Float, y_:Float) {
		this.x = x_; this.y = y_;
	}
	public function get(v:Vector) {
		this.x = v.x; this.y = v.y;
	}
	public function mag():Float { // longueur du vecteur
		var mag = Math.sqrt(this.x*this.x + this.y*this.y);
		return mag;
	}
	public function dist(v:Vector):Float { // distance entre 2 points
		var dx = v.x - this.x; 
		var dy = v.y - this.y;
		var d = Math.sqrt(dx * dx + dy * dy);
		return d;
	}
	public function addCoords(x_:Float, y_:Float) {
		this.x = x_; this.y += y_;
	}
	public function add(v:Vector) {
		this.x += v.x; this.y += v.y;
	}
	public function sub(v:Vector) {
		this.x -= v.x; this.y -= v.y;
	}
	public function subCoords(x_:Float, y_:Float) {
		this.x -= x_; this.y -= y_;
	}
	public function mult(n:Float) {
		this.x *= n; this.y *= n;
	}
	public function div(n:Float) {
		this.x /= n; this.y /= n;
	}
	public function invert() { // retourne le vecteur
		this.mult(-1);
	}
	public function norm() { // vecteur unitaire
		var d = this.mag();
		if (d > 0) { this.div(d); }
	}
	public function returnNorm():Vector {
		var d = this.mag();
		var n = new Vector(this.x, this.y);
		if (d > 0) {
			n.div(d);
		}
		return n;
	}
	public function limit(n:Float) { // longueur max du vecteur
		if (this.mag() > n) {
			this.setMag(n);
		}
	}
	public function setMag(n:Float) { // fixe la longueur du vecteur
		this.norm();
		this.mult(n);
	}
	public function dot(v:Vector):Float { // produit scalaire
		return (this.x * v.x + this.y * v.y);
	}
	public function rotate(rad:Float) { // tourner un vecteur
		var nx = this.x * Math.cos(rad) - this.y * Math.sin(rad);
		var ny = this.x * Math.sin(rad) + this.y * Math.cos(rad);
		this.x = nx; this.y = ny;
	}
	public function getAngle():Float { // l'angle du vecteur, en radians
		var a = Math.PI / 2 + Math.atan(this.y / this.x);
		if (this.x < 0) {
			a += Math.PI;
		}
		return a;
	}
	/*public function getAngle() { // la version P5... à tester.
		return (-1 * Math.atan2( -1 * this.y, this.x));
	}*/
	public function angleBetween(v:Vector):Float { // angle entre 2 vecteurs		
		return Math.acos(this.dot(v) / (this.mag() * v.mag())); // merci P5js
	}
	public function vectBetween(v:Vector):Vector { // le vecteur formé entre 2 points
		var b = new Vector(0, 0);
		b.x = v.x - this.x; b.y = v.y - this.y;
		return b;
	}
	
	
	public function toObj():Dynamic {
		return {x:this.x, y:this.y};
	}
	public function toArray():Array<Float> { // traduit en Array<Float>
		var res:Array<Float> = [this.x, this.y];
		return res;
	}
	public function debug() {
		trace(this.x + ' / ' + this.y);
	}
	public function drawDebug(posx:Float, posy:Float, mult:Float = 1) { // dessine le vecteur à partir d'un point
		/*var dx:Float;
		var dy:Float;
	
		dx = posx; dy = posy;
		
		var tx = dx + this.x * mult;
		var ty = dy + this.y * mult;
		var root : flash.display.MovieClip = flash.Lib.current;
		root.graphics.clear();
		root.graphics.lineStyle(1, 0xFF0000, 0.5);
		root.graphics.moveTo(dx, dy);
		root.graphics.lineTo(tx, ty); // mult permet d'agrandir la visu
		root.graphics.drawCircle(tx, ty, 3);*/
	}	
	
	
	public function rad2Deg(rad:Float):Float { // rad -> deg
		return 180 * rad / Math.PI;
	}
	public function deg2Rad(deg:Float):Float { // deg -> rad
		return Math.PI * deg / 180;
	}
	
	
	public function getAngleDeg():Float {
		return this.rad2Deg(this.getAngle());
	}
	public function rotateDeg(deg:Float) { // tourner un vecteur, en degrés :)
		var rad = this.deg2Rad(deg);
		this.rotate(rad);
	}
	public function angleBetweenDeg(v:Vector):Float {
		var a = this.angleBetween(v);
		return this.rad2Deg(a);
	}
	
}