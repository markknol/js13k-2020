package game.elements;

import flambe.Component;
import flambe.DisplayComponent;
import game.Game;
import game.display.PathFollower;
import game.display.WobblyPathComponent;
import game.elements.Force;
import temple.components.AutoDisposer;
import temple.components.Timeout;
import temple.random.Random;
import temple.utils.EntityUtils;

/**
 * @author Mark Knol
 */
class Moment extends Component {
	@:component(parents) var _game:Game;
	@:component var _force:Force;
	@:component var _pathComponent:WobblyPathComponent;

	public var value:Int;
	public var isDead = false;

	// I am one or the other
	public final one:Bool;

	public function new(one:Bool, value:Float) {
		this.value = Std.int(value);
		this.one = one;
	}

	public function kill() {
		if (!isDead) {
			_pathComponent.data.color = YELLOW;
			Timeout.create(owner, 0.05, () -> _pathComponent.data.color = GRAY);
			Timeout.create(owner, 0.10, () -> _pathComponent.data.color = WHITE);
			Timeout.create(owner, 0.15, () -> _pathComponent.data.color = GRAY);

			for (dot in EntityUtils.getEntitiesWithComponent(EntityUtils.getChildrenAsArray(owner), PathFollower.NAME)) {
				dot.add(new AutoDisposer(Math.random() * 1));
			}

			isDead = true;
			for (i in 0...40) {
				Timeout.create(owner, Math.random() * 0.3, () -> {
					_game.owner.add(_game.getMoment(_pathComponent.data.color, [10, 10], _pathComponent.position - [Math.random() * 50, Math.random() * 20],
						[Random.native.range(-60, 60) * 3, Random.native.range(-60, 60) * 3])
						.add(new AutoDisposer(Random.native.range(.2, .7)))
						.map((display:DisplayComponent) -> display.alpha = _pathComponent.alpha));
				});
			}
		}
	}

	override public function onUpdate(dt:Float):Void {
		if (isDead) {
			_pathComponent.isScared = true;
			if (Math.abs(_force.velocity.x) < 60) {
				_pathComponent.alpha *= (1.0 - dt);
			}
			if (Math.abs(_force.velocity.x) > 10) {
				_force.velocity *= (1.0 - dt);
				_pathComponent.data.path = scalePath(1 - dt, _pathComponent.data.path);
			} else {
				if (!owner.has(AutoDisposer)) {
					owner.add(new AutoDisposer());
				}
			}
		}
	}
}
