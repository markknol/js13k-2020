//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt
package flambe.animation;

import flambe.animation.Binding;
import flambe.animation.Ease;
import flambe.util.Pool;
import flambe.util.Signal2;
import flambe.util.SignalConnection;
import flambe.util.Value;
import flambe.util.Bounds;

/**
 * A Float value that may be animated over time.
 */
class AnimatedFloat extends Value<Float> {
	/**
	 * The behavior that is currently animating the value, or null if the value is not being
	 * animated.
	 */
	public var behavior(get, set):Behavior;

	private var _behavior:Behavior = null;

	public var bounds:Bounds;

	private var leader:AnimatedFloat;
	private var leaderConnection:SignalConnection;

	public function new(value:Float, ?boundary1:Float, ?boundary2:Float) {
		super(value);

		if (boundary1 != null && boundary2 != null) {
			this.setBounds(boundary1, boundary2);
		}
	}

	public function setBounds(boundary1:Float, boundary2:Float) {
		if (bounds != null) {
			bounds.set(boundary1, boundary2);
		} else {
			bounds = new Bounds(boundary1, boundary2);
		}

		// Yes really. Bounds may cause value to change, so we trigger
		// the bounds by using the value setter.
		_ = _;
	}

	public function clearBounds():Void {
		bounds = null;
	}

	override private function set__(value:Float):Float {
		_behavior = null;

		if (bounds == null) {
			return super.set__(value);
		} else {
			return super.set__(bounds.clamp(value));
		}
	}

	private function onLeaderValueChanged(newValue:Float, oldValue:Float):Void {
		if (bounds != null && leader.bounds != null) {
			_ = leader.bounds.translate(newValue, bounds);
		} else {
			_ = newValue;
		}
	}

	public function follow(leader:AnimatedFloat, getInitialValue:Bool = true):Void {
		if (leaderConnection != null) {
			leaderConnection.dispose();
		}

		this.leader = leader;

		if (getInitialValue) {
			this.leaderConnection = this.leader.watch(this.onLeaderValueChanged);
		} else {
			this.leaderConnection = this.leader.changed.connect(this.onLeaderValueChanged);
		}
	}

	public function unfollow():Void {
		if (leaderConnection != null) {
			leaderConnection.dispose();
			leaderConnection = null;
			leader = null;
		}
	}

	public function update(dt:Float) {
		if (_behavior != null) {
			super.set__(_behavior.update(dt));
			if (_behavior != null && _behavior.isComplete()) {
				_behavior = null;
			}
		}
	}

	/**
	 * Animates between the two given values.
	 *
	 * @param from The initial value.
	 * @param to The target value.
	 * @param seconds The animation duration, in seconds.
	 * @param easing The easing function to use, defaults to `Ease.linear`.
	 * @param onComplete The callback function when animation completed
	 * @param delay The animation delay, in seconds.
	 */
	public function animate(from:Float, to:Float, seconds:Float, ?easing:EaseFunction, ?onComplete:Void->Void, ?delay:Float = 0) {
		set__(from);
		animateTo(to, seconds, easing, onComplete, delay);
	}

	/**
	 * Animates from the given value to the current value.
	 *
	 * @param from The initial value.
	 * @param seconds The animation duration, in seconds.
	 * @param easing The easing function to use, defaults to `Ease.linear`.
	 * @param onComplete The callback function when animation completed
	 * @param delay The animation delay, in seconds.
	 */
	public function animateFrom(from:Float, seconds:Float, ?easing:EaseFunction, ?onComplete:Void->Void, ?delay:Float = 0) {
		behavior = new Tween(from, _value, seconds, easing, onComplete, delay);
	}

	/**
	 * Animates between the current value and the given value.
	 *
	 * @param to The target value.
	 * @param seconds The animation duration, in seconds.
	 * @param easing The easing function to use, defaults to `Ease.linear`.
	 * @param onComplete The callback function when animation completed
	 * @param delay The animation delay, in seconds.
	 */
	public function animateTo(to:Float, seconds:Float, ?easing:EaseFunction, ?onComplete:Void->Void, ?delay:Float = 0) {
		behavior = new Tween(_value, to, seconds, easing, onComplete, delay);
	}

	/**
	 * Animates the current value by the given delta.
	 *
	 * @param by The delta added to the current value to get the target value.
	 * @param seconds The animation duration, in seconds.
	 * @param easing The easing function to use, defaults to `Ease.linear`.
	 * @param onComplete The callback function when animation completed
	 * @param delay The animation delay, in seconds.
	 */
	public function animateBy(by:Float, seconds:Float, ?easing:EaseFunction, ?onComplete:Void->Void, ?delay:Float = 0) {
		behavior = new Tween(_value, _value + by, seconds, easing, onComplete, delay);
	}

	inline public function bindTo(to:Value<Float>, ?fn:BindingFunction) {
		behavior = new Binding(to, fn);
	}

	private function set_behavior(behavior:Behavior):Behavior {
		_behavior = behavior;
		update(0);
		return behavior;
	}

	inline private function get_behavior():Behavior {
		return _behavior;
	}

	override function dispose() {
		_behavior = null;
		super.dispose();
	}

	@:allow(flambe)
	private static var POOL:Pool<AnimatedFloat> = new Pool<AnimatedFloat>(allocate);

	/**
	 * Take an object from the pool. If the pool is empty, a new AnimatedFloat
	 * will be allocated.
	 */
	public static function take(value:Float, ?boundary1:Float, ?boundary2:Float, ?listener:Listener2<Float, Float>):AnimatedFloat {
		var animatedFloat:AnimatedFloat = POOL.take();
		animatedFloat.setValue(value);

		if (boundary1 != null && boundary2 != null) {
			animatedFloat.setBounds(boundary1, boundary2);
		} else {
			animatedFloat.clearBounds();
		}

		if (listener != null) {
			animatedFloat.changed.connect(listener);
		}

		return animatedFloat;
	}

	/**
	 * Put an AnimatedFloat into the pool.
	 */
	public static function put(animatedFloat:AnimatedFloat):AnimatedFloat {
		if (animatedFloat != null) {
			animatedFloat.dispose();
			POOL.put(animatedFloat);
		}
		return null;
	}

	private static function allocate():AnimatedFloat {
		return new AnimatedFloat(Math.NaN);
	}
}
