//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt
package flambe;

import flambe.animation.AnimatedFloat;

/**
 * Adjusts the update speed of an entity (and its components and children). Can be used for slow
 * motion and fast forward effects.
 */
class TimeScaleAdjuster extends Component {
	private var _entity:Entity;

	/**
	 * The scale that time should pass for the target entity and its children. Values lower than
	 * 1.0 will play slower than realtime, and values higher than 1.0 will play faster. When the
	 * scale is 0, the entity is basically paused.
	 */
	public var scale(default, null):AnimatedFloat;

	public function new(scale:Float = 1, ?targetEntity:Entity) {
		_entity = targetEntity;

		this.scale = new AnimatedFloat(scale);
	}

	override function onStart() {
		super.onStart();

		if (_entity == null) {
			_entity = owner;
		}
	}

	// Note that this may be called by MainLoop before onStarted!
	override public function onUpdate(dt:Float) {
		// Ensure this component is immune to its own time scaling
		if (_realDt > 0) {
			dt = _realDt;
			_realDt = 0;
		}

		scale.update(dt);
		_entity.timeScale = scale._;
	}

	@:allow(flambe) var _realDt:Float = 0;
}
