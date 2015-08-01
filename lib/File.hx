package	opengp;

import sys.FileSystem;
import sys.FileStat;
import sys.io.File;

/*
Available on Linux, Mac, Windows, Neko
Gestion des dossiers et fichiers, lecture-écriture, tout en 1 !
*/

class File {

	// directories

	public static function isDir(file:String):Bool {
		return FileSystem.isDirectory(file);
	}
	public static function readDir(path:String):Array<String> {
		return FileSystem.readDirectory(path);
	}
	public static function processDir(path:String, func:String->Void):Void { // func(file) is applied to every file found
		var liste:Array<String> = readDir(path);
		for (i in 0 ... liste.length) {
			func(path+'/'+liste[i]);
		}
	}
	public static function countDir(path:String):Int { // files count in directory
		var files:Array<String> = readDir(path);
		return files.length;
	}
	public static function makeDir(path:String):Void {
		FileSystem.createDirectory(path);
	}
	/*public static function renameDir(path:String, newName:String):Void {

	}*/


	// general

	public static function exists(file:String):Bool {
		return FileSystem.exists(file);
	}
	public static function del(file:String):Void { // delete directory or file
		if(isDir(file)){
			FileSystem.deleteDirectory(file);
		} else {
			FileSystem.deleteFile(file);
		}
	}
	public static function fullPath(path:String):String {
		return FileSystem.fullPath(path);
	}
	public static function absolutePath(path:String):String { // fullPath() alias
		return FileSystem.fullPath(path);
	}


	// files

	public static function isFile(file:String):Bool {
		return !FileSystem.isDirectory(file);
	}
	public static function basename(file:String):String { // String operation, no check if file exists
		var cut:Int = file.lastIndexOf('/');
		if(cut<0){
			return file;
		} else {
			return file.substr(file.length-cut+1, cut-1);
		}
	}
	public static function path(file:String):String { // String operation, no check if file exists
		var cut:Int = file.lastIndexOf('/');
		if(cut<0){
			return '.';
		} else {
			return file.substr(0, file.length-cut);
		}
	}
	public static function ext(file:String):String { // String operation, no check if file exists
		if(file.length<3){
			return '';
		} else {
			var cut:Int = file.lastIndexOf('.');
			if(cut<0){
				return '';
			} else {
				return file.substr(file.length-cut+1, cut-1); // without '.' char
			}			
		}		
	}
	public static function size(file:String):Int {
		if(!exists(file)){
			return 0;
		} else {
			return FileSystem.stat(file).size;
		}
	}
	public static function readableSize(file:String, decimals:Int=1):String { // returns like '11.3 Mo'
		var rawsize:Int = size(file);
		var strsize:String = '';
		var mult:Int = 1;
		for (i in 0 ... decimals) {
			mult *= 10;
		}
		if (rawsize >= 1073741824){
			strsize = Math.round(rawsize / 1073741824 * mult) / mult + " Go";
		} else if (rawsize >= 1048576){
			strsize = Math.round(rawsize / 1048576 * mult) / mult + " Mo";
		} else if (rawsize >= 0){
			strsize = Math.round(rawsize / 1024 * mult) / mult + " Ko";
		}
		return strsize;
	}
	public static function copy(file:String, dest:String):Void {
		if(exists(file)){
			sys.io.File.copy(file, dest);
		}
	}
	public static function move(file:String, dest:String=''):Void {
		if(exists(file)){
			copy(file, dest); // duplicate file
			del(file); // deletes original file
		}			
	}
	public static function rename(file:String, newname:String):Void {
		// newname doesn't include the file's path
		// ex : File.rename('../snap/game01.png', 'supagame.png');
		move(file, path(file)+newname);
	}
	public static function cut(file:String, dest:String=''):Void { // move() alias
		move(file, dest);
	}
	public static function load(file:String):String { // getContent() alias
		return getContent(file);
	}
	public static function save(file:String, content:String):Void { // saveContent() alias
		saveContent(file, content);
	}
	public static function getContent(file:String):String {
		if(!exists(file)){
			return '';
		} else {
			return sys.io.File.getContent(file);
		}		
	}
	public static function saveContent(file:String, content:String):Void {
		sys.io.File.saveContent(file, content);
	}

	/*
	Not included :

	- directory renaming (?)

	sys.io.File
	- getBytes / saveBytes
	- read > FileInput
	- write > FileOutput

	sys.FileSystem
	- stat > FileStat

	sys.FileStat
	- uid
	- mtime
	- lots of stuff...

	il y a aussi sys.FileStat pour le poids, etc
	*/
}