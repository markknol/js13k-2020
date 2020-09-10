package game.display;
import temple.geom.Vector2;

/**
 * @author Mark Knol
 */
class SVGs {
	#if !macro
	public static var START = PathMacro.encode("svg/start.svg");
	public static var OWNER = PathMacro.encode("svg/owner.svg");
	#end
	public static function getNumber(no:Int):Array<Array<Vector2>> {
		return switch no {
			case 0: game.display.PathMacro.encode("svg/0.svg");
			case 1: game.display.PathMacro.encode("svg/1.svg");
			case 2: game.display.PathMacro.encode("svg/2.svg");
			case 3: game.display.PathMacro.encode("svg/3.svg");
			case 4: game.display.PathMacro.encode("svg/4.svg");
			case 5: game.display.PathMacro.encode("svg/5.svg");
			case 6: game.display.PathMacro.encode("svg/6.svg");
			case 7: game.display.PathMacro.encode("svg/7.svg");
			case 8: game.display.PathMacro.encode("svg/8.svg");
			default: game.display.PathMacro.encode("svg/9.svg");
		}
	}
	
	// decode array with data for numbers. format: [offsetX, offsetY, x,y,x,y,x,y...]
	public static function parsePath(data:Array<Array<Int>>):Array<Array<Vector2>> {
		var paths = [];
		for (numbers in data) {
			var path:Array<Vector2> = [];
			paths.push(path);
			var offsetY = numbers.shift();
			var offsetX = numbers.shift();
			
			for (idx => char in numbers) {
				if (idx % 2 == 0) {
					var x1:Float = char + offsetX;
					var y1:Float = numbers[idx + 1] + offsetY;
					path.push([x1, y1]);
					//trace(x1, y1);
				}
			}
		}
		return paths;
	}
}