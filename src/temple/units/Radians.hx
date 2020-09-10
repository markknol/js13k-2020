package temple.units;

abstract Radians(Float) from Float to Float {
	private static var _RAD_TO_DEG_MULTIPLIER:Float = (180 / Math.PI);

	inline public function new(f:Float) {
		this = f;
	}

	@:op(-A) public static function neg(s:Radians):Radians;

	@:op(A + B) public static function add(lhs:Radians, offset:Radians):Radians;

	@:op(A - B) public static function sub(lhs:Radians, offset:Radians):Radians;

	@:op(A > B) public static function gt(lhs:Radians, rhs:Radians):Bool;

	@:op(A >= B) public static function gte(lhs:Radians, rhs:Radians):Bool;

	@:op(A < B) public static function lt(lhs:Radians, rhs:Radians):Bool;

	@:op(A <= B) public static function lte(lhs:Radians, rhs:Radians):Bool;

	@:op(A == B) public static function eq(lhs:Radians, rhs:Radians):Bool;

	@:op(A % B) public static function mod(lhs:Radians, rhs:Radians):Radians;

	inline public function float() return this;

	@:commutative @:op(A * B) public static function add(lhs:Radians, scalar:Float):Radians;

	@:commutative @:op(A / B) public static function add(lhs:Radians, scalar:Float):Radians;

	public static function fromPoints(x1:Float, y1:Float, x2:Float, y2:Float):Radians {
		var d = x1 * x2 + y1 * y2;
		var m1 = Math.sqrt(x1 * x1 + y1 * y1);
		var m2 = Math.sqrt(x2 * x2 + y2 * y2);
		return acos(d / (m1 * m2));
	}

	inline public static function acos(cos:Float):Radians {
		return Math.acos(cos);
	}

	inline public function toDegrees():Degrees {
		return this * _RAD_TO_DEG_MULTIPLIER;
	}

	inline public function toString():String {
		return '$this(rad)';
	}
}
