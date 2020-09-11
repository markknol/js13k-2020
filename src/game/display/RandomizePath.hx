package game.display;

import flambe.Component;
import flambe.math.FMath;
import game.display.WobblyPathComponent;
import temple.components.Cooldown;
import temple.geom.Vector2;
import temple.random.Random;

/**
 * @author Mark Knol
 */
class RandomizePath extends Component {
	@:component var _pathComponent:WobblyPathComponent;

	private var _cooldown:Cooldown;
	private var _rndVec2:Vector2;

	public function new() {
		reset();
	}

	override function onUpdate(dt:Float) {
		if (_cooldown.update(dt)) {
			reset();
		}

		_pathComponent.rotation += FMath.lerpMoveTo(_pathComponent.rotation, _rndVec2.x, dt, 3);
	}

	private function reset() {
		_rndVec2 = [Random.native.range(-1.0, 1.0), Random.native.range(-1.0, 1.0)];
		_cooldown.reset(Random.native.range(0.1, 1.0));
	}
}
