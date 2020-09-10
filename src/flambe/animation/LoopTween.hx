//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt
package flambe.animation;

import flambe.animation.Ease;

class LoopTween implements Behavior {
	public var elapsed(default, null):Float;

	private var _from:Float;
	private var _to:Float;
	private var _duration:Float;
	private var _easing:EaseFunction;
	private var _onComplete:Void->Void;
	private var _delay:Float;

	/** The number of times to animate between the starting value and the end value. */
	public var cycles(default, null):Int;

	private var _cyclesPassed:Int = 0;

	public function new(from:Float, to:Float, seconds:Float, ?cycles:Int = 0, ?easing:EaseFunction, delay:Float = 0, offset:Float = 0) {
		_from = from;
		_to = to;
		_duration = seconds;
		this.cycles = cycles;
		elapsed = offset;
		_easing = (easing != null) ? easing : Ease.linear;
		_delay = delay;
	}

	public function update(dt:Float):Float {
		elapsed += dt;

		if ((elapsed - _delay) >= _duration) {
			_cyclesPassed += 1;
			elapsed -= _duration;
			return _to;
		} else if (elapsed > _delay) {
			return _from + (_to - _from) * _easing((elapsed - _delay) / _duration);
		} else {
			return _from;
		}
	}

	public function isComplete():Bool {
		return (this.cycles != 0) && this.cycles >= _cyclesPassed;
	}
}
