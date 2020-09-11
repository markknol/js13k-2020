package temple.components;

import flambe.Component;
import flambe.math.FMath;
import temple.components.Cooldown;

/**
	Dispose its owner entity after a given delay.

	Example:
	`myEntity.add(new AutoDisposer(5);`

	Example with callback:
	`myEntity.add(new AutoDisposer(5, () -> trace("gone")));`

	@author Mark Knol [mediamonks]
 */
class AutoDisposer extends Component {
	private var _delay:Float;
	private var _cooldown:Cooldown;
	private var _callbacks = [];

	public function new(delay:Float = 0.0, ?onBeforeDispose:() -> Void) {
		_cooldown = new Cooldown(FMath.max(delay, 0.0));
		_callbacks.push(onBeforeDispose);
	}

	override public function onUpdate(dt:Float) {
		if (_cooldown.update(dt)) {
			for (cb in _callbacks)
				if (cb != null) cb();
			if (owner != null) owner.dispose();
			_cooldown.disable();
		}
	}

	/**
	 * Convenience method to add AutoDisposer to Entity.
	 * If auto disposer already exists in current entity:
	 *  - delay will set to max(current, delay)
	 *  - callback will be pushed
	 */
	public static function create(owner:Entity, delay:Float = 0.0, ?onBeforeDispose:() -> Void):AutoDisposer {
		if (!owner.has(AutoDisposer)) {
			owner.add(new AutoDisposer(delay, onBeforeDispose));
		} else {
			var current = owner.get(AutoDisposer);
			if (current._cooldown.isEnabled) {
				current._cooldown.reset(Math.min(delay, current._cooldown.time));
				current._callbacks.push(onBeforeDispose);
			}
		}
		return owner.get(AutoDisposer);
	}
}
