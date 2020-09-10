package flambe.animation;

import flambe.animation.Ease.EaseFunction;

/**
 * @author Mark Knol
 */
class TweenColor implements Behavior {
	public var r:AnimatedFloat;
	public var g:AnimatedFloat;
	public var b:AnimatedFloat;

	public function new(fromColor:Float, toColor:Float, duration:Float, ?ease:EaseFunction, ?delay:Float = 0) {
		var fromColor = Std.int(fromColor);
		var toColor = Std.int(toColor);
		r = AnimatedFloat.take((fromColor >> 16) & 0xFF);
		g = AnimatedFloat.take((fromColor >> 8) & 0xFF);
		b = AnimatedFloat.take(fromColor & 0xFF);
		tweenTo(toColor, duration, ease, delay);
	}

	inline function tweenTo(color:Int, duration:Float, ?ease:EaseFunction = null, ?delay:Float = 0) {
		r.animateTo((color >> 16) & 0xFF, duration, ease, null, delay);
		g.animateTo((color >> 8) & 0xFF, duration, ease, null, delay);
		b.animateTo((color) & 0xFF, duration, ease, null, delay);
	}

	inline function getValue():Float {
		return ((Std.int(r._) & 0xFF) << 16) | ((Std.int(g._) & 0xFF) << 8) | (Std.int(b._) & 0xFF);
	}

	public function update(dt:Float):Float {
		r.update(dt);
		g.update(dt);
		b.update(dt);

		return getValue();
	}

	public function isComplete():Bool {
		var complete = r.behavior == null;
		if (complete) {
			AnimatedFloat.put(r);
			AnimatedFloat.put(g);
			AnimatedFloat.put(b);
		}
		return complete;
	}
}
