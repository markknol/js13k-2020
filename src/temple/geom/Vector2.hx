package temple.geom;

import flambe.math.FMath;
import temple.units.Radians;

@:dox(show) private typedef Vector2Impl = {x:Float,y:Float};

/**
	Represents a two dimensional vector.

	@author Mark Knol
**/
abstract Vector2(Vector2Impl) from Vector2Impl to Vector2Impl {
	public static inline function empty() return new Vector2(0.0, 0.0);

	public var normalized(get, never):Vector2;
	// 90 degree rotation to the left
	public var rotatedLeft(get, never):Vector2;
	// 90 degree rotation to the right
	public var rotatedRight(get, never):Vector2;

	public var x(get, set):Float;
	inline function get_x() return this.x;
	inline function set_x(v) return this.x = v;
	
	public var y(get, set):Float;
	inline function get_y() return this.y;
	inline function set_y(v) return this.y = v;
	
	/** Construct a new vector instance. **/
	public inline function new(x:Float, y:Float) {
		this = {x:x, y:y};
	}

	private var self(get, never):Vector2;

	private inline function get_self():Vector2 {
		return (cast this : Vector2);
	}

	/** Sets component values of `this` values. If `y` is ommited, both components will be set to `x`. **/
	public inline function set(x:Float, ?y:Float):Vector2 {
		self.x = x;
		self.y = if (y == null) x else y;
		return self;
	}

	/** Sets component values to 0, 0 **/
	public inline function zero():Vector2 {
		return set(0, 0);
	}

	/** Sets component values to 1, 1 **/
	public inline function one():Vector2 {
		return set(1, 1);
	}

	/** Clone `this` vector into new Vector2 instance. **/
	public inline function clone():Vector2 {
		return new Vector2(self.x, self.y);
	}

	/** Copy component values from `target` vector to `this` vector. **/
	public inline function copy(target:Vector2):Vector2 {
		self.x = target.x;
		self.y = target.y;
		return self;
	}

	/** Round component values of `this` vector. **/
	public inline function round():Vector2 {
		self.x = Math.fround(self.x);
		self.y = Math.fround(self.y);
		return self;
	}

	/** floor (round down) component values of `this` vector. **/
	public inline function floor():Vector2 {
		self.x = Math.ffloor(self.x);
		self.y = Math.ffloor(self.y);
		return self;
	}

	/** Ceil (round up) component values of `this` vector. **/
	public inline function ceil():Vector2 {
		self.x = Math.fceil(self.x);
		self.y = Math.fceil(self.y);
		return self;
	}

	/** Convert `this` component values to absolute values. **/
	public inline function abs():Vector2 {
		self.x = Math.abs(self.x);
		self.y = Math.abs(self.y);
		return self;
	}

	/** @return Squared Length of this vector  `x*x + y*y`. **/
	public var lengthSquared(get, set):Float;

	private inline function get_lengthSquared():Float {
		return self.x * self.x + self.y * self.y;
	}

	private inline function set_lengthSquared(value:Float):Float {
		var length = get_lengthSquared();
		if (length == 0) return 0;
		var l = value / length;
		self.x *= l;
		self.y *= l;
		return value;
	}

	/** @return true if given vector is in range `(this-vector).length < range*range` **/
	public function inRange(vector:Vector2, range:Float):Bool {
		return (self - vector).lengthSquared < range * range;
	}

	/** @return Distance to given vector. Same as `(this-vector).length` **/
	public function distanceTo(vector:Vector2):Float {
		return (self - vector).length;
	}

	/** @return Distance to given vector. Same as `(this-vector).length` **/
	public function distanceToSquared(vector:Vector2):Float {
		return (self - vector).lengthSquared;
	}

	/** @return Distance of given vectors. Same as `a.distanceTo(b)` **/
	public inline static function distanceOf(a:Vector2, b:Vector2):Float {
		return a.distanceTo(b);
	}

	/** @return scalar number of dot product `x * vector.x + y * vector.y`. **/
	public inline function dot(vector:Vector2):Float {
		var component:Vector2 = self * vector;
		return component.x + component.y;
	}

	/** @return scalar number of vector product `x * vector.y - y * vector.x`. **/
	public inline function vector(vector:Vector2):Float {
		return self.x * vector.y - self.y * vector.x;
	}

	/** @return vector unit of this vector `this/length`. **/
	public function normalize():Vector2 {
		if (self.x != 0) self.x /= length;
		if (self.y != 0) self.y /= length;
		return self;
	}

	private inline function get_normalized():Vector2 {
		return self / length;
	}

	/**
	 * Normalize this vector and scale it to the specified length.
	 *
	 * @param newLength     The new length to normalize to.
	 * @return              The modified object.
	 */
	public inline function normalizeTo(newLength:Float):Vector2 {
		self.normalize();
		self *= newLength;

		return self;
	}

	private inline function get_rotatedLeft():Vector2 {
		return self.clone().rotateLeft();
	}

	private inline function get_rotatedRight():Vector2 {
		return self.clone().rotateRight();
	}

	/**
	 * Rotate this vector by 90 degrees to the left/counterclockwise.
	 *
	 * @return  The modified object. (-y, x)
	 */
	public inline function rotateLeft():Vector2 {
		var newX = -self.y;
		self.y = self.x;
		self.x = newX;

		return self;
	}

	/**
	 * Rotate this vector by 90 degrees to the right/clockwise.
	 *
	 * @return  The modified object. (y, -x)
	 */
	public inline function rotateRight():Vector2 {
		var newX = self.y;
		self.y = -self.x;
		self.x = newX;

		return self;
	}

	/** Obtains the projection of current vector on a given axis. **/
	public inline function projection(to:Vector2):Float {
		return dot(to.normalized);
	}

	/** Obtain angle of `this` vector. **/
	public function angle():Radians {
		return Math.atan2(self.y, self.x);
	}

	/** Obtains the smaller angle (radians) sandwiched from current to given vector. **/
	public inline function angleTo(to:Vector2):Radians {
		// get normalized vectors
		var norm1:Vector2 = normalized;
		var norm2:Vector2 = to.normalized;

		// dot product of vectors to find angle
		var product = norm1.dot(norm2);
		product = Math.min(1, product);
		var angle = Math.acos(product);

		// sides of angle
		if (vector(to) < 0) angle *= -1;

		return angle;
	}

	public function rotateAroundAngle(angle:Radians):Vector2 {
		var x = self.x;
		var y = self.y;
		self.x = x * Math.cos(angle) - y * Math.sin(angle);
		self.y = y * Math.cos(angle) + x * Math.sin(angle);
		return self;
	}

	/** Obtains the smaller angle (radians) sandwiched from current to given vector. **/
	public inline function moveTo(angle:Float, distance:Float):Vector2 {
		self.x += Math.cos(angle) * distance;
		self.y += Math.sin(angle) * distance;
		return self;
	}

	/** @return New vector instance that is made from the smallest components of two vectors. **/
	public static function minOf(a:Vector2, b:Vector2):Vector2 {
		return a.clone().min(b);
	}

	/** @return New vector instance that is made from the largest components of two vectors. **/
	public static function maxOf(a:Vector2, b:Vector2):Vector2 {
		return a.clone().max(b);
	}

	/** @return Sets this vector instance components to the smallest components of given vectors. **/
	public function min(v:Vector2):Vector2 {
		self.x = Math.min(self.x, v.x);
		self.y = Math.min(self.y, v.y);
		return self;
	}

	/** @return Sets this vector instance components to the largest components of given vectors. **/
	public function max(v:Vector2):Vector2 {
		self.x = Math.max(self.x, v.x);
		self.y = Math.max(self.y, v.y);
		return self;
	}

	/** Obtains the projection of `this` vector on a given axis. **/
	public inline function polar(length:Float, angle:Radians) {
		self.x = length * Math.cos(angle);
		self.y = length * Math.sin(angle);
	}

	/** @return Length of vector **/
	public var length(get, set):Float;

	private inline function get_length():Float {
		return Math.sqrt(lengthSquared);
	}

	private inline function set_length(value:Float):Float {
		polar(value, angle());
		return value;
	}

	/** Invert x component of `this` vector `x *= -1`. **/
	public inline function invertX():Void self.x *= -1;

	/** Invert y component of `this` vector `y *= -1`. **/
	public inline function invertY():Void self.y *= -1;

	/**
	 * Clamp this vector's length to the specified range.
	 *
	 * @param min   The min length.
	 * @param max   The max length.
	 * @return      The modified object.
	 */
	public function clamp(min:Float, max:Float):Vector2 {
		var length = self.length;

		if (length < min) {
			self.normalizeTo(min);
		} else if (length > max) {
			self.normalizeTo(max);
		}

		return self;
	}

	/**
	 * Clamp this vector's length to a max of 1.
	 *
	 * @return      The modified object.
	 */
	public inline function clamp01():Vector2 {
		return clamp(0, 1);
	}

	/** Invert both component values of `this` vector `this *= -1`. **/
	public inline function invertAssign():Vector2 {
		self.x *= -1;
		self.y *= -1;
		return self;
	}

	/** Interpolates between two vectors by t. t is clamped between 0 and 1. **/
	inline public static function lerp(from:Vector2, to:Vector2, t:Float):Vector2 {
		return from + (to - from) * FMath.clamp01(t);
	}

	/** Time based lerp that returns the interval necessary to move one vector to another **/
	inline public static function lerpMoveTo(from:Vector2, to:Vector2, deltaTime:Float, duration:Float):Vector2 {
		return (to - from) * (1 - Math.pow(0.01, deltaTime / duration));
	}

	/**
		Gradually changes a Vector2 towards a desired goal over time.
		The Vector2 is smoothed by some spring-damper like function, which will never overshoot.
		The function can be used to smooth any kind of value, positions, colors, scalars.
	**/
	public static function smoothDamp(current:Vector2, target:Vector2, currentVelocity:Vector2, smoothTime:Float, deltaTime:Float,
			maxSpeed:Float = FMath.FLOAT_MAX):Vector2 {
		// Ported from https://github.com/Unity-Technologies/UnityCsReference/blob/master/Runtime/Export/Math/Vector2.cs
		// Based on Game Programming Gems 4 Chapter 1.10

		smoothTime = Math.max(0.0001, smoothTime);
		var omega:Float = 2 / smoothTime;

		var x:Float = omega * deltaTime;
		var exp:Float = 1.0 / (1.0 + x + 0.48 * x * x + 0.235 * x * x * x);

		var change:Vector2 = current - target;
		var originalTo:Vector2 = target.clone();

		// Clamp maximum speed
		var maxChange:Float = maxSpeed * smoothTime;

		var maxChangeSq:Float = maxChange * maxChange;
		var sqDist:Float = change.x * change.x + change.y * change.y;
		if (sqDist > maxChangeSq) {
			change = change / Math.sqrt(sqDist) * maxChange;
		}

		target = current - change;

		var temp:Vector2 = (currentVelocity + omega * change) * deltaTime;

		currentVelocity.x = (currentVelocity.x - omega * temp.x) * exp;
		currentVelocity.y = (currentVelocity.y - omega * temp.y) * exp;

		var output:Vector2 = target + (change + temp) * exp;

		// Prevent overshooting
		var origMinusCurrent:Vector2 = originalTo - current;
		var outMinusOrig:Vector2 = output - originalTo;

		if (origMinusCurrent.x * outMinusOrig.x + origMinusCurrent.y * outMinusOrig.y > 0) {
			output.copy(originalTo);

			currentVelocity = (output - originalTo) / deltaTime;
		}

		return output;
	}

	/** (new instance) Invert both component values of `this` vector. **/
	@:commutative @:op(-A) public inline function invert():Vector2 {
		return clone().invertAssign();
	}

	/** Sum given vector to `this` component values. Modifies this instance. Can also be used with `a+=b` operator. **/
	@:commutative @:op(A += B) public inline function addAssign(by:Vector2):Vector2 {
		self.x += by.x;
		self.y += by.y;
		return self;
	}

	/** Substract given vector from `this` component values. Modifies this instance. Can also be used with `a-=b` operator. **/
	@:commutative @:op(A -= B) public inline function substractAssign(by:Vector2):Vector2 {
		self.x -= by.x;
		self.y -= by.y;
		return self;
	}

	/** Multiply `this` component values by given vector. Modifies this instance. Can also be used with `a*=b` operator. **/
	@:commutative @:op(A *= B) public inline function multiplyAssign(by:Vector2):Vector2 {
		self.x *= by.x;
		self.y *= by.y;
		return self;
	}

	/** Divide `this` component values by given vector. Modifies this instance. Can also be used with `a/=b` operator. **/
	@:commutative @:op(A /= B) public inline function divideAssign(by:Vector2):Vector2 {
		self.x /= by.x;
		self.y /= by.y;
		return self;
	}

	/** Sets the remainder on `this` component values from given vector. Modifies this instance. Can also be used with `a/=b` operator. **/
	@:commutative @:op(A %= B) public inline function moduloAssign(by:Vector2):Vector2 {
		self.x %= by.x;
		self.y %= by.y;
		return self;
	}

	/** Clone `this` and sum given vector. Returns new vector instance. Can also be used with `a+b` operator. **/
	@:commutative @:op(A + B) public inline function add(vector:Vector2):Vector2 {
		return clone().addAssign(vector);
	}

	/** Clone `this` and substract the given vector. Returns new instance. Can also be used with `a-b` operator. **/
	@:commutative @:op(A - B) public inline function substract(vector:Vector2):Vector2 {
		return clone().substractAssign(vector);
	}

	/** Clone `this` and multiply with given vector. Returns new instance. Can also be used with `a*b` operator. **/
	@:commutative @:op(A * B) public inline function multiply(vector:Vector2):Vector2 {
		return clone().multiplyAssign(vector);
	}

	/** Clone `this` and divide by given vector. Returns new instance. Can also be used with `a/b` operator. **/
	@:commutative @:op(A / B) public inline function divide(vector:Vector2):Vector2 {
		return clone().divideAssign(vector);
	}

	/** Clone `this` and sets remainder from given vector. Returns new instance. Can also be used with `a%b` operator. **/
	@:commutative @:op(A % B) public inline function modulo(vector:Vector2):Vector2 {
		return clone().moduloAssign(vector);
	}

	/** Sum given value to both of `this` component values. Modifies this instance. Can also be used with `a+=b` operator. **/
	@:commutative @:op(A += B) public inline function addFloatAssign(v:Float):Vector2 {
		self.x += v;
		self.y += v;
		return self;
	}

	/** Substract given value to both of `this` component values. Modifies this instance. Can also be used with `a-=b` operator. **/
	@:commutative @:op(A -= B) public inline function substractFloatAssign(v:Float):Vector2 {
		self.x -= v;
		self.y -= v;
		return self;
	}

	/** Multiply `this` component values with given value. Modifies this instance. Can also be used with `a*=b` operator. **/
	@:commutative @:op(A *= B) public inline function multiplyFloatAssign(v:Float):Vector2 {
		self.x *= v;
		self.y *= v;
		return self;
	}

	/** Divide `this` component values with given value. Modifies this instance. Can also be used with `a/=b` operator. **/
	@:commutative @:op(A /= B) public inline function divideFloatAssign(v:Float):Vector2 {
		self.x /= v;
		self.y /= v;
		return self;
	}

	/** Sets remainder of `this` component values from given value. Modifies this instance. Can also be used with `a%=b` operator. **/
	@:commutative @:op(A %= B) public inline function moduloFloatAssign(v:Float):Vector2 {
		self.x %= v;
		self.y %= v;
		return self;
	}

	/** Clone `this` and sum given value. Returns new vector instance. Can also be used with `a+b` operator. **/
	@:commutative @:op(A + B) public inline function addFloat(value:Float):Vector2 {
		return clone().addFloatAssign(value);
	}

	/** Clone `this` and substract given value. Returns new vector instance. Can also be used with `a-b` operator. **/
	@:commutative @:op(A - B) public inline function substractFloat(value:Float):Vector2 {
		return clone().substractFloatAssign(value);
	}

	/** Clone `this` and multiply given value. Returns new vector instance. Can also be used with `a*b` operator. **/
	@:commutative @:op(A * B) public inline function multiplyFloat(value:Float):Vector2 {
		return clone().multiplyFloatAssign(value);
	}

	/** Clone `this` and divide given value. Returns new vector instance. Can also be used with `a/b` operator. **/
	@:commutative @:op(A / B) public inline function divideFloat(value:Float):Vector2 {
		return clone().divideFloatAssign(value);
	}

	/** Clone `this` set remainder from given value. Returns new vector instance. Can also be used with `a%b` operator. **/
	@:commutative @:op(A % B) public inline function moduloFloat(value:Float):Vector2 {
		return clone().moduloFloatAssign(value);
	}

	/** @return `true` if both component values of `this` are same of given vector. **/
	@:commutative @:op(A == B) public inline function equals(v:Vector2):Bool {
		return self.x == v.x && self.y == v.y;
	}

	/** @return `true` if a component values of `this` is not the same at given vector. **/
	@:commutative @:op(A != B) public inline function notEquals(v:Vector2):Bool {
		return !(this == v);
	}

	/** Converts `this` vector to array `[x,y]`. **/
	@:to public inline function toArray():Array<Float> {
		return [self.x, self.y];
	}

	/** @return `true` if `this` is `null`. **/
	@:op(!a) public inline function isNil() return self == null;

	/** @return typed Vector2 `null` value **/
	static public inline function nil<A, B>():Vector2 return null;

	#if pixijs
	/** Cast PIXI Point to Vector2. They unify because both have same component values. **/
	@:from public static inline function fromPixiPoint(point:pixi.core.math.Point):Vector2 return cast point;

	/** Cast this Vector2 to PIXI Point. They unify because both have same component values. **/
	@:to public inline function toPixiPoint():pixi.core.math.Point return cast this;
	#end

	#if openfl
	/** Cast OpenFL Point to Vector2. They unify because both have same component values. **/
	@:from public static inline function fromOpenFLPoint(point:openfl.geom.Point):Vector2 return cast point;

	/** Cast this Vector2 to OpenFL Point. They unify because both have same component values. **/
	@:to public inline function toOpenFLPoint():openfl.geom.Point return cast this;
	#end

	#if heaps
	/** Cast Heaps Point to Vector2. They unify because both have same component values. **/
	@:from public static inline function fromHeapsPoint(point:h2d.col.Point):Vector2 return cast point;

	/** Cast this Vector2 to Heaps Point class. They unify because both have same component values. **/
	@:to public inline function toHeapsPoint():h2d.col.Point return cast this;
	#end

	#if kha
	/** Cast Kha Vector2 to Vector2. They unify because both have same component values. **/
	@:from public static inline function fromKhaVector2(point:kha.math.Vector2):Vector2 return cast point;

	/** Cast this Vector2 to Kha Vector2. They unify because both have same component values. **/
	@:to public inline function toKhaVector2():kha.math.Vector2 return cast this;
	#end

	@:from public static inline function fromFloatArray(vec:Array<Float>):Vector2 return new Vector2(vec[0], vec[1]);
	@:from public static inline function fromIntArray(vec:Array<Int>):Vector2 return new Vector2(vec[0], vec[1]);

	public inline function toString(prefix:String = null):String {
		return (if (prefix != null) '${prefix}=' else '') + '{x:${self.x}, y:${self.y}}';
	}
}
