package game;

import game.Color;
import game.display.PathComponent;
import game.display.PathComponent.Path;
import game.display.PathFollower;

/**
 * @author Mark Knol
 */
class Factory {
	public static function addDots(target:Entity, amount:Int, color:Color) {
		for (idx in 0...amount) {
			final r = idx / amount;
			target.addEntity(new Entity().add([
				new PathFollower(r, true),
				new PathComponent({
					color: color,
					path: getSquare(8),
				}),
			]));
		}
	}

	public static function getRect(w:Float, h:Float):Path {
		final w = w.half();
		final h = h.half();
		return [[-w, -h], [w, -h], [w, h], [-w, h]];
	}

	public static inline function getSquare(size:Int):Path {
		return getRect(size, size);
	}

	public static function getTriangle(size:Int):Path {
		return [[0, size], [-size * 1 / 3, 0], [size * 2 / 3, size * 1 / 3]];
	}
}
