//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt
package flambe.math;

import flambe.util.Value;
import temple.geom.Vector2;
import temple.units.Degrees;
import temple.units.Radians;

/**
 * Some handy math functions, and inlinable constants.
 */
class FMath {
	public static inline var E = 2.718281828459045;
	public static inline var LN2 = 0.6931471805599453;
	public static inline var LN10 = 2.302585092994046;
	public static inline var LOG2E = 1.4426950408889634;
	public static inline var LOG10E = 0.43429448190325176;
	public static inline var SQRT1_2 = 0.7071067811865476;
	public static inline var SQRT2 = 1.4142135623730951;
	public static var HALF_PI = Math.PI * 0.5;

	// Haxe doesn't specify the size of an int or float, in practice it's 32 bits

	/** The lowest integer value in Flash and JS. */
	public static inline var INT_MIN:Int = -2147483648;

	/** The highest integer value in Flash and JS. */
	public static inline var INT_MAX:Int = 2147483647;

	/** The lowest float value in Flash and JS. */
	public static inline var FLOAT_MIN = -1.79769313486231e+308;

	/** The highest float value in Flash and JS. */
	public static inline var FLOAT_MAX = 1.79769313486231e+308;

	/** Returns the absolute value of `v`. **/
	inline public static function abs(v:Float):Float {
		return Math.abs(v);
	}

	/** Returns largest of two values. **/
	#if !js
	@:generic
	#end
	inline public static function max<T:Float>(a:T, b:T):T {
		return (a > b) ? a : b;
	}

	/** Returns smallest of two values. **/
	#if !js
	@:generic
	#end
	inline public static function min<T:Float>(a:T, b:T):T {
		return (a < b) ? a : b;
	}

	/** Clamps a value between a minimum float and maximum float value. **/
	#if !js
	@:generic
	#end
	inline public static function clamp<T:Float>(value:T, min:T, max:T):T {
		return if (value < min) min else if (value > max) max else value;
	}

	/** Clamps value between `0` and `1` and returns value. **/
	inline public static function clamp01(value:Float):Float {
		return if (value < 0.0) 0.0; else if (value > 1.0) 1.0; else value;
	}

	/** Return value is `1` when value is positive or zero, `-1` when value is negative. **/
	inline public static function sign(value:Float):Int {
		return if (value < 0) -1 else if (value > 0) 1 else 0;
	}

	/**
		Interpolates between min and max with smoothing at the limits.
		This function interpolates between min and max in a similar way to `lerp`.
		However, the interpolation will gradually speed up from the start and slow down toward the end.
		This is useful for creating natural-looking animation, fading and other transitions.
	**/
	inline public static function smoothStep(from:Float, to:Float, t:Float):Float {
		t = clamp01(t);
		t = (-2.0 * t * t * t + 3.0 * t * t);
		return (to * t + from * (1.0 - t));
	}

	/** Snap to grid size value **/
	inline public static function snapTo(value:Float, gridSize:Int):Int {
		return Math.round(value / gridSize) * gridSize;
	}

	/**
		Compares two floating point values if they are similar.
		Due to floating point imprecision it is not recommended to compare floats using the equal operator.
		eg. `1.0 == 10.0 / 10.0` might not return true.
	**/
	public static inline function approximately(a:Float, b:Float):Bool {
		return abs(b - a) < max(1E-06 * max(abs(a), abs(b)), FLOAT_MIN * 8.0);
	}

	/** Loops the value `t`, so that it is never larger than length and never smaller than 0. **/
	inline public static function repeat(t:Float, length:Float):Float {
		return t - Math.ffloor(t / length) * length;
	}

	/** pingpongs the value `t`, so that it is never larger than length and never smaller than 0. **/
	inline public static function pingPong(t:Float, length:Float):Float {
		t = repeat(t, length * 2.0);
		return length - abs(t - length);
	}

	// https://stackoverflow.com/a/4787257 by Quasimondo
	inline public static function lerpColors(color1:Int, color2:Int, lerp:Float):Int {
		var f2:Int = Math.round(256 * lerp);
		var f1:Int = 256 - f2;

		return (((((color1 & 0xff00ff) * f1) + ((color2 & 0xff00ff) * f2)) >> 8) & 0xff00ff) | (((((color1 & 0x00ff00) * f1) +
			((color2 & 0x00ff00) * f2)) >> 8) & 0x00ff00);
	}

	/** Interpolates between a and b by t. t is clamped between 0 and 1. **/
	inline public static function lerp(from:Float, to:Float, t:Float):Float {
		return from + (to - from) * clamp01(t);
	}

	/** Time based lerp that returns the interval necessary to move one value to another **/
	inline public static function lerpMoveTo(from:Float, to:Float, deltaTime:Float, duration:Float):Float {
		return (to - from) * (1 - Math.pow(0.01, deltaTime / duration));
	}

	/** Same as lerp but makes sure the values interpolate correctly when they wrap around 360 degrees. **/
	inline public static function lerpAngle(a:Float, b:Float, t:Float):Float {
		var value = repeat(b - a, 360.0);
		if (value > 180.0) value -= 360.0;
		return a + value * clamp01(t);
	}

	/** Calculates the shortest difference between two given angles given in degrees. **/
	inline public static function deltaAngle(current:Float, target:Float):Float {
		var value = repeat(target - current, Math.PI * 2);
		if (value > Math.PI) value -= Math.PI * 2;
		return value;
	}

	/**
		Moves a value current towards target.
		This is essentially the same as `lerp` but instead the function will ensure that the speed never exceeds maxDelta.
		Negative values of maxDelta pushes the value away from target.
	**/
	inline public static function moveTowards(current:Float, target:Float, maxDelta:Float):Float {
		if (abs(target - current) <= maxDelta) return target; else return current + sign(target - current) * maxDelta;
	}

	/**
		Same as `moveTowards` but makes sure the values interpolate correctly when they wrap around 360 degrees.
		Variables current and target are assumed to be in degrees.
		For optimization reasons, negative values of maxDelta are not supported and may cause oscillation.
		To push current away from a target angle, add 180 to that angle instead.
	**/
	inline public static function moveTowardsAngle(current:Float, target:Float, maxDelta:Float):Float {
		target = current + deltaAngle(current, target);
		return moveTowards(current, target, maxDelta);
	}

	/**
		Gradually changes a value towards a desired goal over time.
		The value is smoothed by some spring-damper like function, which will never overshoot.
		The function can be used to smooth any kind of value, positions, colors, scalars.
	**/
	public static function smoothDamp(current:Float, target:Float, currentVelocity:Value<Float>, smoothTime:Float, deltaTime:Float,
			maxSpeed:Float = FMath.FLOAT_MAX):Float {
		smoothTime = max(0.0001, smoothTime);
		var omega:Float = 2.0 / smoothTime;
		var x:Float = omega * deltaTime;
		var exp:Float = (1.0 / (1.0 + x + 0.48 * x * x + 0.235 * x * x * x));
		var change:Float = current - target;
		var originalTarget:Float = target;
		var maxChange:Float = maxSpeed * smoothTime;

		change = clamp(change, -maxChange, maxChange);
		target = current - change;

		var temp:Float = (currentVelocity._ + omega * change) * deltaTime;

		currentVelocity._ = (currentVelocity._ - omega * temp) * exp;

		var output:Float = target + (change + temp) * exp;
		if ((originalTarget - current > 0.0) == (output > originalTarget)) {
			output = originalTarget;
			currentVelocity._ = (output - originalTarget) / deltaTime;
		}
		return output;
	}

	/** Calculates the Lerp parameter between of two values. **/
	public static function inverseLerp(from:Float, to:Float, value:Float):Float {
		if (from < to) {
			if (value < from) return 0.0;
			if (value > to) return 1.0;

			value -= from;
			value /= to - from;

			return value;
		} else {
			if (from <= to) return 0.0;
			if (value < to) return 1.0;
			if (value > from) return 0.0; else return (1.0 - (value - to) / (from - to));
		}
	}

	/** Check if two lines intersect (at infinity, so not just the actual line segments). When `true` store intersection point in result. (optional) **/
	public static function lineIntersection(line1a:Vector2, line1b:Vector2, line2a:Vector2, line2b:Vector2, result:Vector2 = null):Bool {
		var dx1 = line1b.x - line1a.x;
		var dy1 = line1b.y - line1a.y;
		var dx2 = line2b.x - line2a.x;
		var dy2 = line2b.y - line2a.y;
		var d1 = (dx1 * dy2 - dy1 * dx2);
		if (d1 == 0.0) return false;

		if (result != null) {
			var dx3 = line2a.x - line1a.x;
			var dy3 = line2a.y - line1a.y;
			var d2 = (dx3 * dy2 - dy3 * dx2) / d1;

			result.set(line1a.x + d2 * dx1, line1a.y + d2 * dy1);
		}
		return true;
	}

	/** Check if two lines segments intersect. When `true` store intersection point in result (optional) **/
	public static function lineSegmentIntersection(line1a:Vector2, line1b:Vector2, line2a:Vector2, line2b:Vector2, result:Vector2 = null):Bool {
		var dx1 = line1b.x - line1a.x;
		var dy1 = line1b.y - line1a.y;
		var dx2 = line2b.x - line2a.x;
		var dy2 = line2b.y - line2a.y;
		var d1 = (dx1 * dy2 - dy1 * dx2);
		if (d1 == 0.0) return false;

		var dx3 = line2a.x - line1a.x;
		var dy3 = line2a.y - line1a.y;
		var d2 = (dx3 * dy2 - dy3 * dx2) / d1;
		if (d2 < 0.0 || d2 > 1.0) return false;

		var d3 = (dx3 * dy1 - dy3 * dx1) / d1;
		if (d3 < 0.0 || d3 > 1.0) return false;

		if (result != null) result.set(line1a.x + d2 * dx1, line1a.y + d2 * dy1);

		return true;
	}

	public static inline function distance(x1:Float, y1:Float, x2:Float, y2:Float):Float {
		return Math.sqrt(Math.pow(x1 - x2, 2) + Math.pow(y1 - y2, 2));
	}

	public static inline function distancePow(x1:Float, y1:Float, x2:Float, y2:Float):Float {
		return Math.pow(x1 - x2, 2) + Math.pow(y1 - y2, 2);
	}

	/** Converts an angle in degrees to radians. Serves mostly as a convenience method to convert floats and remain backwards compatible */
	inline public static function degreesToRadians(degrees:Degrees):Radians {
		return degrees.toRadians();
	}

	/** Converts an angle in radians to degrees. Serves mostly as a convenience method to convert floats and remain backwards compatible */
	inline public static function radiansToDegrees(radians:Radians):Degrees {
		return radians.toDegrees();
	}
}
