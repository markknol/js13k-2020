//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt
package flambe.animation;

import flambe.util.Value;

typedef BindingFunction = Float->Float;

class Binding implements Behavior {
	private var _target:Value<Float>;
	private var _fn:BindingFunction;

	public function new(target:Value<Float>, ?fn:BindingFunction) {
		_target = target;
		_fn = fn;
	}

	public function update(dt:Float):Float {
		var value = _target._;
		if (_fn != null) {
			return _fn(value);
		} else {
			return value;
		}
	}

	public function isComplete():Bool {
		return false;
	}
}
