//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt
package flambe.util;

import flambe.util.Signal2;

/**
 * Wraps a single value, notifying listeners when the value changes.
 */
class Value<A> {
	/**
	 * The wrapped value, setting this to a different value will fire the `changed` signal.
	 */
	public var _(get, set):A;

	/**
	 * Emitted when the value has changed. The first listener parameter is the new current value,
	 * the second parameter is the old previous value.
	 */
	public var changed(get, null):Signal2<A, A>;

	private var _value:A;
	private var _changed:Signal2<A, A>;

	public function new(value:A, ?listener:Listener2<A, A>) {
		_value = value;
		_changed = (listener != null) ? new Signal2(listener) : null;
	}

	/**
		Create new value, notifying listeners when `this` changes,
		set new value to result from given `handler(new,old)` function.
	**/
	public inline function map<B>(handler:A->A->B):Value<B> {
		var b = new Value<B>(handler(_value, _value));
		changed.connect(function(to, from) b._ = handler(to, from));
		return b;
	}

	/**
		Create new value, notifying listeners when `a` value and `b` value value changes,
		set new value to result of `combinator(a,b):c` function.
	**/
	public static inline function merge<A, B, C>(a:Value<A>, b:Value<B>, combinator:A->B->C):Value<C> {
		var c = new Value<C>(combinator(a._, b._));
		a.changed.connect(function(to, from) c._ = combinator(to, b._));
		b.changed.connect(function(to, from) c._ = combinator(a._, to));
		return c;
	}

	/**
		Convert to Signal0, with condition function.
	**/
	public inline function toSignal(condition:A->A->Bool):Signal0 {
		var s = new Signal0();
		changed.connect(function(to, from) if (condition(to, from)) s.emit());
		return s;
	}

	/**
		Convenience method for `merge(this, value, combinator);`
	**/
	public inline function mergeWith<B, C>(value:Value<B>, combinator:A->B->C):Value<C> {
		return merge(this, value, combinator);
	}

	/**
	 * Watch when this value changes.
	 *
	 * The first listener parameter is the new current value,
	 * the second parameter is the old previous value.
	 *
	 * @param immediateCallListener Immediately calls a listener with the current value.
	 * @returns A handle that can be disposed to stop watching for changes.
	 */
	public function watch(listener:Listener2<A, A>, immediateCallListener:Bool = true):SignalConnection {
		if (immediateCallListener) listener(_value, _value);
		return changed.connect(listener);
	}

	inline private function get__():A {
		return _value;
	}

	private function set__(newValue:A):A {
		var oldValue = _value;
		if (newValue != oldValue) {
			_value = newValue;
			if (_changed != null) {
				_changed.emit(newValue, oldValue);
			}
		}
		return newValue;
	}

	private function get_changed() {
		if (_changed == null) {
			_changed = new Signal2();
		}
		return _changed;
	}

	#if debug @:keep #end public function toString():String {
		return cast _value;
	}

	public function dispose() {
		_value = null;
		if (_changed != null) {
			_changed.dispose();
		}
	}

	@:allow(flambe) function setValue(value:A) {
		_value = value;
	}
}
