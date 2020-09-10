package temple.geom;

import flambe.math.FMath;

@:dox(show) private typedef Vector3Impl = {x:Float, y:Float, z:Float}

/**
	Represents a three dimensional vector.

	@author Mark Knol
**/
@:forward abstract Vector3(Vector3Impl) from Vector3Impl to Vector3Impl {
	public static function empty() return new Vector3(0, 0, 0);

	public var normalized(get, never):Vector3;

	/** Construct a new vector instance. **/
	public inline function new(x:Float, y:Float, z:Float) {
		this = {x: x, y: y, z: z};
	}

	private var self(get, never):Vector3;

	private inline function get_self():Vector3 {
		return (this : Vector3);
	}

	/** Sets component values of `this` values. If `y` is ommited, both components will be set to `x`. **/
	public inline function set(x:Float, ?y:Float, ?z:Float):Vector3 {
		this.x = x;
		this.y = if (y == null) x else y;
		this.z = if (z == null) y else z;
		return this;
	}

	/** Sets component values to 0, 0, 0 **/
	public inline function zero():Vector3 {
		return set(0, 0, 0);
	}

	/** Sets component values to 1, 1, 1 **/
	public inline function one():Vector3 {
		return set(1, 1, 1);
	}

	/** Clone `this` vector into new Vector3 instance. **/
	public inline function clone():Vector3 {
		return new Vector3(this.x, this.y, this.z);
	}

	/** Copy component values from `target` vector to `this` vector. **/
	public inline function copy(target:Vector3):Vector3 {
		this.x = target.x;
		this.y = target.y;
		this.z = target.z;
		return this;
	}

	/** Round component values of `this` vector. **/
	public inline function round():Vector3 {
		this.x = Math.fround(this.x);
		this.y = Math.fround(this.y);
		this.z = Math.fround(this.z);
		return this;
	}

	/** floor (round down) component values of `this` vector. **/
	public inline function floor():Vector3 {
		this.x = Math.ffloor(this.x);
		this.y = Math.ffloor(this.y);
		this.z = Math.ffloor(this.z);
		return this;
	}

	/** Ceil (round up) component values of `this` vector. **/
	public inline function ceil():Vector3 {
		this.x = Math.fceil(this.x);
		this.y = Math.fceil(this.y);
		this.z = Math.fceil(this.z);
		return this;
	}

	/** Convert `this` component values to absolute values. **/
	public inline function abs():Vector3 {
		this.x = Math.abs(this.x);
		this.y = Math.abs(this.y);
		this.z = Math.abs(this.z);
		return this;
	}

	/** @return Squared length of this vector  `x*x + y*y + z*z`. **/
	public var lengthSquared(get, set):Float;

	private inline function get_lengthSquared():Float {
		return this.x * this.x + this.y * this.y + this.z * this.z;
	}

	private inline function set_lengthSquared(value:Float):Float {
		var length = get_lengthSquared();
		if (length == 0) return 0;
		var l = value / length;
		this.x *= l;
		this.y *= l;
		this.z *= l;
		return value;
	}

	/** @return true if given vector is in range `(this-vector).length < range*range` **/
	public function inRange(vector:Vector3, range:Float):Bool {
		return (self - vector).lengthSquared < range * range;
	}

	/** @return Distance to given vector. Same as `(this-vector).length` **/
	public function distanceTo(vector:Vector3):Float {
		return (self - vector).length;
	}

	/** @return Distance to given vector. Same as `(this-vector).length` **/
	public function distanceToSquared(vector:Vector3):Float {
		return (self - vector).lengthSquared;
	}

	/** @return Distance of given vectors. Same as `a.distanceTo(b)` **/
	public inline static function distanceOf(a:Vector3, b:Vector3):Float {
		return a.distanceTo(b);
	}

	/** @return scalar number of dot product `x * vector.x + y * vector.y + z * vector.z`. **/
	public inline function dot(vector:Vector3):Float {
		var component:Vector3 = self * vector;
		return component.x + component.y + component.z;
	}

	/** @return vector unit of this vector `this/length`. **/
	public function normalize():Vector3 {
		if (this.x == 0 && this.y == 0 && this.z == 0) return self;

		self /= length;

		return self;
	}

	private inline function get_normalized():Vector3 {
		return self / length;
	}

	/**
	 * Normalize this vector and scale it to the specified length.
	 *
	 * @param newLength     The new length to normalize to.
	 * @return              The modified object.
	 */
	public inline function normalizeTo(newLength:Float):Vector3 {
		self.normalize();
		self *= newLength;

		return self;
	}

	/** Obtains the projection of current vector on a given axis. **/
	public inline function projection(to:Vector3):Float {
		return dot(to.normalized);
	}

	/** @return New vector instance that is made from the smallest components of two vectors. **/
	public static function minOf(a:Vector3, b:Vector3):Vector3 {
		return a.clone().min(b);
	}

	/** @return New vector instance that is made from the largest components of two vectors. **/
	public static function maxOf(a:Vector3, b:Vector3):Vector3 {
		return a.clone().max(b);
	}

	/** @return Sets this vector instance components to the smallest components of given vectors. **/
	public function min(v:Vector3):Vector3 {
		this.x = Math.min(this.x, v.x);
		this.y = Math.min(this.y, v.y);
		this.z = Math.min(this.z, v.z);
		return this;
	}

	/** @return Sets this vector instance components to the largest components of given vectors. **/
	public function max(v:Vector3):Vector3 {
		this.x = Math.max(this.x, v.x);
		this.y = Math.max(this.y, v.y);
		this.z = Math.max(this.z, v.z);
		return this;
	}

	/** @return Length of the vector **/
	public var length(get, never):Float;

	private inline function get_length():Float {
		return Math.sqrt(lengthSquared);
	}

	private inline function set_length(value:Float):Float {
		normalizeTo(value);

		return value;
	}

	/** Invert x component of `this` vector `x *= -1`. **/
	public inline function invertX():Void this.x *= -1;

	/** Invert y component of `this` vector `y *= -1`. **/
	public inline function invertY():Void this.y *= -1;

	/** Invert z component of `this` vector `z *= -1`. **/
	public inline function invertZ():Void this.z *= -1;

	/** Invert both component values of `this` vector `this *= -1`. **/
	public inline function invertAssign():Vector3 {
		this.x *= -1;
		this.y *= -1;
		this.z *= -1;
		return this;
	}

	/** Interpolates between two vectors by t. t is clamped between 0 and 1. **/
	inline public static function lerp(from:Vector3, to:Vector3, t:Float):Vector3 {
		return from + (to - from) * FMath.clamp01(t);
	}

	/** Time based lerp that returns the interval necessary to move one vector to another **/
	inline public static function lerpMoveTo(from:Vector3, to:Vector3, deltaTime:Float, duration:Float):Vector3 {
		return (to - from) * (1 - Math.pow(0.01, deltaTime / duration));
	}

	/**
		Gradually changes a Vector3 towards a desired goal over time.
		The Vector3 is smoothed by some spring-damper like function, which will never overshoot.
		The function can be used to smooth any kind of value, positions, colors, scalars.
	**/
	public static function smoothDamp(current:Vector3, target:Vector3, currentVelocity:Vector3, smoothTime:Float, deltaTime:Float,
			maxSpeed:Float = FMath.FLOAT_MAX):Vector3 {
		// Ported from https://github.com/Unity-Technologies/UnityCsReference/blob/master/Runtime/Export/Math/Vector3.cs
		// Based on Game Programming Gems 4 Chapter 1.10

		smoothTime = Math.max(0.0001, smoothTime);
		var omega:Float = 2 / smoothTime;

		var x:Float = omega * deltaTime;
		var exp:Float = 1.0 / (1.0 + x + 0.48 * x * x + 0.235 * x * x * x);

		var change:Vector3 = current - target;
		var originalTo:Vector3 = target.clone();

		// Clamp maximum speed
		var maxChange:Float = maxSpeed * smoothTime;

		var maxChangeSq:Float = maxChange * maxChange;
		var sqDist:Float = change.x * change.x + change.y * change.y + change.z * change.z;
		if (sqDist > maxChangeSq) {
			change = change / Math.sqrt(sqDist) * maxChange;
		}

		target = current - change;

		var temp:Vector3 = (currentVelocity + omega * change) * deltaTime;

		currentVelocity.x = (currentVelocity.x - omega * temp.x) * exp;
		currentVelocity.y = (currentVelocity.y - omega * temp.y) * exp;
		currentVelocity.z = (currentVelocity.z - omega * temp.z) * exp;

		var output:Vector3 = target + (change + temp) * exp;

		// Prevent overshooting
		var origMinusCurrent:Vector3 = originalTo - current;
		var outMinusOrig:Vector3 = output - originalTo;

		if (origMinusCurrent.x * outMinusOrig.x + origMinusCurrent.y * outMinusOrig.y + origMinusCurrent.z * outMinusOrig.z > 0) {
			output.copy(originalTo);

			currentVelocity = (output - originalTo) / deltaTime;
		}

		return output;
	}

	/** (new instance) Invert both component values of `this` vector. **/
	@:commutative @:op(-A) public inline function invert():Vector3 {
		return clone().invertAssign();
	}

	/** Sum given vector to `this` component values. Modifies this instance. Can also be used with `a+=b` operator. **/
	@:commutative @:op(A += B) public inline function addAssign(by:Vector3):Vector3 {
		this.x += by.x;
		this.y += by.y;
		this.z += by.z;
		return this;
	}

	/** Substract given vector from `this` component values. Modifies this instance. Can also be used with `a-=b` operator. **/
	@:commutative @:op(A -= B) public inline function substractAssign(by:Vector3):Vector3 {
		this.x -= by.x;
		this.y -= by.y;
		this.z -= by.z;
		return this;
	}

	/** Multiply `this` component values by given vector. Modifies this instance. Can also be used with `a*=b` operator. **/
	@:commutative @:op(A *= B) public inline function multiplyAssign(by:Vector3):Vector3 {
		this.x *= by.x;
		this.y *= by.y;
		this.z *= by.z;
		return this;
	}

	/** Divide `this` component values by given vector. Modifies this instance. Can also be used with `a/=b` operator. **/
	@:commutative @:op(A /= B) public inline function divideAssign(by:Vector3):Vector3 {
		this.x /= by.x;
		this.y /= by.y;
		this.z /= by.z;
		return this;
	}

	/** Sets the remainder on `this` component values from given vector. Modifies this instance. Can also be used with `a/=b` operator. **/
	@:commutative @:op(A %= B) public inline function moduloAssign(by:Vector3):Vector3 {
		this.x %= by.x;
		this.y %= by.y;
		this.z %= by.z;
		return this;
	}

	/** Clone `this` and sum given vector. Returns new vector instance. Can also be used with `a+b` operator. **/
	@:commutative @:op(A + B) public inline function add(vector:Vector3):Vector3 {
		return clone().addAssign(vector);
	}

	/** Clone `this` and substract the given vector. Returns new instance. Can also be used with `a-b` operator. **/
	@:commutative @:op(A - B) public inline function substract(vector:Vector3):Vector3 {
		return clone().substractAssign(vector);
	}

	/** Clone `this` and multiply with given vector. Returns new instance. Can also be used with `a*b` operator. **/
	@:commutative @:op(A * B) public inline function multiply(vector:Vector3):Vector3 {
		return clone().multiplyAssign(vector);
	}

	/** Clone `this` and divide by given vector. Returns new instance. Can also be used with `a/b` operator. **/
	@:commutative @:op(A / B) public inline function divide(vector:Vector3):Vector3 {
		return clone().divideAssign(vector);
	}

	/** Clone `this` and sets remainder from given vector. Returns new instance. Can also be used with `a%b` operator. **/
	@:commutative @:op(A % B) public inline function modulo(vector:Vector3):Vector3 {
		return clone().moduloAssign(vector);
	}

	/** Sum given value to both of `this` component values. Modifies this instance. Can also be used with `a+=b` operator. **/
	@:commutative @:op(A += B) public inline function addFloatAssign(v:Float):Vector3 {
		this.x += v;
		this.y += v;
		this.z += v;
		return this;
	}

	/** Substract given value to both of `this` component values. Modifies this instance. Can also be used with `a-=b` operator. **/
	@:commutative @:op(A -= B) public inline function substractFloatAssign(v:Float):Vector3 {
		this.x -= v;
		this.y -= v;
		this.z -= v;
		return this;
	}

	/** Multiply `this` component values with given value. Modifies this instance. Can also be used with `a*=b` operator. **/
	@:commutative @:op(A *= B) public inline function multiplyFloatAssign(v:Float):Vector3 {
		this.x *= v;
		this.y *= v;
		this.z *= v;
		return this;
	}

	/** Divide `this` component values with given value. Modifies this instance. Can also be used with `a/=b` operator. **/
	@:commutative @:op(A /= B) public inline function divideFloatAssign(v:Float):Vector3 {
		this.x /= v;
		this.y /= v;
		this.z /= v;
		return this;
	}

	/** Sets remainder of `this` component values from given value. Modifies this instance. Can also be used with `a%=b` operator. **/
	@:commutative @:op(A %= B) public inline function moduloFloatAssign(v:Float):Vector3 {
		this.x %= v;
		this.y %= v;
		this.z %= v;
		return this;
	}

	/** Clone `this` and sum given value. Returns new vector instance. Can also be used with `a+b` operator. **/
	@:commutative @:op(A + B) public inline function addFloat(value:Float):Vector3 {
		return clone().addFloatAssign(value);
	}

	/** Clone `this` and substract given value. Returns new vector instance. Can also be used with `a-b` operator. **/
	@:commutative @:op(A - B) public inline function substractFloat(value:Float):Vector3 {
		return clone().substractFloatAssign(value);
	}

	/** Clone `this` and multiply given value. Returns new vector instance. Can also be used with `a*b` operator. **/
	@:commutative @:op(A * B) public inline function multiplyFloat(value:Float):Vector3 {
		return clone().multiplyFloatAssign(value);
	}

	/** Clone `this` and divide given value. Returns new vector instance. Can also be used with `a/b` operator. **/
	@:commutative @:op(A / B) public inline function divideFloat(value:Float):Vector3 {
		return clone().divideFloatAssign(value);
	}

	/** Clone `this` set remainder from given value. Returns new vector instance. Can also be used with `a%b` operator. **/
	@:commutative @:op(A % B) public inline function moduloFloat(value:Float):Vector3 {
		return clone().moduloFloatAssign(value);
	}

	/** @return `true` if both component values of `this` are same of given vector. **/
	@:commutative @:op(A == B) public inline function equals(v:Vector3):Bool {
		return this.x == v.x && this.y == v.y && this.z == v.z;
	}

	/** @return `true` if a component values of `this` is not the same at given vector. **/
	@:commutative @:op(A != B) public inline function notEquals(v:Vector3):Bool {
		return !(this == v);
	}

	/** Converts `this` vector to array `[x,y,z]`. **/
	@:to public inline function toArray():Array<Float> {
		return [this.x, this.y, this.z];
	}

	/** @return `true` if `this` is `null`. **/
	@:op(!a) public inline function isNil() return this == null;

	/** @return typed Vector3 `null` value **/
	static public inline function nil<A, B>():Vector3 return null;

	@:from public static inline function fromArray(vec:Array<Float>):Vector3 return new Vector3(vec[0], vec[1], vec[2]);

	public inline function toString(prefix:String = null):String {
		return (if (prefix != null) '${prefix}=' else '') + '{x:${this.x}, y:${this.y}, z:${this.z}}';
	}
}
