//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt
package flambe.animation;

import flambe.animation.Ease;

class QuadTween implements Behavior {
	public var elapsed(default, null):Float = 0.0;

	private var _from:Float;
	private var _control:Float;
	private var _to:Float;
	private var _duration:Float;
	private var _delay:Float;
	private var _easing:EaseFunction;

	public function new(from:Float, control:Float, to:Float, seconds:Float, ?easing:EaseFunction, delay:Float = 0.0) {
		_from = from;
		_control = control;
		_to = to;
		_duration = seconds;
		_easing = (easing != null) ? easing : Ease.linear;
		_delay = delay;
	}

	public function update(dt:Float):Float {
		elapsed += dt;
		if ((elapsed - _delay) >= _duration) {
			return _to;
		} else if (elapsed > _delay) {
			var t:Float = _easing((elapsed - _delay) / _duration);
			var q:Float = 1 - t;
			return (q * q) * _from + 2 * q * t * _control + (t * t) * _to;
		} else {
			return _from;
		}
	}

	public function isComplete():Bool {
		return (elapsed - _delay) >= _duration;
	}
}
