package game.display;

import flambe.Component;

/**
 * @author Mark Knol
 */
class WobblyRect extends PathComponent {
	public function new(width, height) {
		super({
			isClosedPath: true,
			path: getRect(width, height),
			color: PINK,
		});
		updateModifiers.push(normalizePath.bind(() -> 20 + Std.random(3)));
		updateModifiers.push(randomizePathAngle.bind(1.0));
		updateModifiers.push(normalizePath.bind(8.0));
	}
}
