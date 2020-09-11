package game.display;

import flambe.math.FMath;
import game.display.SVGs;
import temple.geom.Vector2;

/**
 * @author Mark Knol
 */
class PathMacro {
	/**
	 * Encode svg path data to tiny format
	 * @return `game.display.SVGs.parsePath([offsetX, offsetY, x,y,x,y,x,y...])`
	 */
	public static macro function encode(path:String) {
		var file = sys.io.File.getContent(path);
		var svgPath = file.split('<path fill="#000000" stroke="none" d="').pop().split('"/>').shift();

		var points:Array<Array<Vector2>> = [];
		var moves = svgPath.replace("\n", "").replace("L", "").split("M ");
		for (move in moves) {
			var pts:Array<Vector2> = [];
			var s = move.split(" ");
			while (true) {
				var x = Std.parseFloat(s.shift());
				var y = Std.parseFloat(s.shift());
				if (x == null || y == null) break;
				pts.push([x, y]);
			}
			if (pts.length > 0) {
				points.push(pts);
			}
		}
		final magicalOffset = 5;
		var pointsExpr = points.map(pts -> {
			var lowest:Vector2 = {x: 10000.0, y: 10000.0};
			var highest:Vector2 = {x: -10000.0, y: -10000.0};
			for (p in pts) {
				lowest.x = FMath.min(Std.int(p.x), lowest.x);
				lowest.y = FMath.min(Std.int(p.y), lowest.y);
				highest.x = FMath.max(Std.int(p.x), highest.x);
				highest.y = FMath.max(Std.int(p.y), highest.y);
			}

			var numbers = [];
			for (p in pts) {
				var x = Std.int(p.x - lowest.x);
				var y = Std.int(p.y - lowest.y);
				numbers.push(x);
				numbers.push(y);
			}

			var size:Vector2 = (highest - lowest);
			numbers.unshift(Std.int(lowest.x - magicalOffset));
			numbers.unshift(Std.int(lowest.y - magicalOffset));
			return macro $v{numbers};
		});
		return macro game.display.SVGs.parsePath(cast $a{pointsExpr});
	}
}
