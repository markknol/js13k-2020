package flambe.animation;

import flambe.animation.Behavior;

/**
 * Switches between a sequence of values at a given interval
 *
 * @author Mark Knol
 */
class SequenceCycle implements Behavior {
	private var _cycles:Int;
	private var _interval:Float;
	private var _elapsed:Float;
	private var _values:Array<Float>;

	public function new(values:Array<Float>, ?interval:Float = 1.0, ?cycles:Int = 0) {
		_values = values;
		_interval = interval * values.length;
		_cycles = cycles;
		_elapsed = 0.0;
	}

	public function update(dt:Float):Float {
		_elapsed += dt * (1 / _interval);
		return 
			if (isComplete()) _values[_values.length - 1];
			else _values[Std.int((_elapsed * _values.length) % _values.length)];
	}

	public function isComplete():Bool {
		return _cycles > 0 && _elapsed >= _cycles;
	}
}
