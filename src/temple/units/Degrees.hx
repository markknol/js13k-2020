package temple.units;

abstract Degrees(Float) from Float to Float {
	private static var _DEG_TO_RAD_MULTIPLIER:Float = (Math.PI / 180);

	inline public function new(f:Float) {
		this = f;
	}

	@:op(-A) public static function neg(s:Degrees):Degrees;

	@:op(A + B) public static function add(lhs:Degrees, offset:Degrees):Degrees;

	@:op(A - B) public static function sub(lhs:Degrees, offset:Degrees):Degrees;

	@:op(A > B) public static function gt(lhs:Degrees, rhs:Degrees):Bool;

	@:op(A >= B) public static function gte(lhs:Degrees, rhs:Degrees):Bool;

	@:op(A < B) public static function lt(lhs:Degrees, rhs:Degrees):Bool;

	@:op(A <= B) public static function lte(lhs:Degrees, rhs:Degrees):Bool;

	@:op(A == B) public static function eq(lhs:Degrees, rhs:Degrees):Bool;

	inline public function float() return this;

	@:commutative @:op(A * B) public static function add(lhs:Degrees, scalar:Float):Degrees;

	@:commutative @:op(A / B) public static function add(lhs:Degrees, scalar:Float):Degrees;

	@:commutative @:op(A + B) inline public static function adds(lhs:Degrees, offset:Radians):Radians {
		return lhs.toRadians() + offset;
	}

	@:commutative @:op(A - B) inline public static function subs(lhs:Degrees, offset:Radians):Radians {
		return lhs.toRadians() + offset;
	}

	inline public function toRadians():Radians {
		return this * _DEG_TO_RAD_MULTIPLIER;
	}

	inline public function toString():String {
		return '$this(deg)';
	}
}
