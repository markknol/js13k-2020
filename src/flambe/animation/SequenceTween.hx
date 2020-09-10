package flambe.animation;

import flambe.animation.AnimatedFloat;
import flambe.animation.Behavior;
import flambe.animation.Ease.EaseFunction;

/**
 * Tweens from one to next value of array between a sequence of values at a given interval
 *
 * @author Mark Knol
 */
class SequenceTween implements Behavior {
	private var _cycles:Int;
	private var _interval:Float;
	private var _elapsed:Float;
	private var _values:Array<Float>;
	private var _easing:EaseFunction;

	public var speed(default, null):AnimatedFloat = new AnimatedFloat(1);

	public function new(values:Array<Float>, ?interval:Float = 1.0, ?cycles:Int = 0, ?offset:Float = 0, ?ease:EaseFunction) {
		_easing = ease == null ? Ease.linear : ease;
		_values = values;
		_interval = interval * values.length;
		_cycles = cycles;
		_elapsed = offset;
	}

	public function update(dt:Float):Float {
		speed.update(dt);
		_elapsed += dt * speed._;

		var index = Std.int(((_elapsed % _interval) / _interval) * _values.length);
		var _from = _values[index];
		var _to = _values[(index + 1) % _values.length];

		var intervalPerEl = _interval / _values.length;
		return _from + (_to - _from) * _easing((_elapsed % intervalPerEl) / intervalPerEl);
	}

	public function isComplete():Bool {
		return _cycles > 0 && _elapsed >= _cycles;
	}
}
