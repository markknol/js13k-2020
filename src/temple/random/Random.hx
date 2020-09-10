package temple.random;

import temple.random.ISeededRandom;
import temple.utils.ArrayUtils;

/**
 * Wrapper around ISeededRandom with nice methods
 *
 * @author Mark Knol
 */
enum abstract Random(ISeededRandom) to ISeededRandom {
	/*
	 * Uses native random
	 */
	public static final native:Random = new Random(new NativeRandom());

	public var seed(never, set):Int;

	public function new(random:ISeededRandom) {
		this = random;
	}

	public inline function range(boundary1:Float, boundary2:Float):Float {
		return boundary1 + next() * (boundary2 - boundary1);
	}

	/** from `0` to `value` */
	public inline function to(value:Float):Float {
		return next() * value;
	}

	/** from `boundary1` to `boundary2`, inclusive of both boundaries */
	public inline function intRange(boundary1:Int, boundary2:Int):Int {
		return boundary1 + Std.int(next() * (boundary2 - boundary1 + 1));
	}

	/** from `value` + range between `boundary1` to `boundary2`  */
	public inline function offsetRange(value:Float, boundary1:Float, boundary2:Float):Float {
		return value + range(boundary1, boundary2);
	}

	/** from `value` + range between `-offset` to `offset`  */
	public inline function offset(value:Float, offset:Float):Float {
		return offsetRange(value, -offset, offset);
	}

	public function setSeedFromString(value:String):Void {
		var s = 0;
		if (value != null) {
			for (i in 0...value.length) {
				s += StringTools.fastCodeAt(value, i);
			}
		}
		this.seed = s;
	}

	public function getString(length:Int, letters:String = "abcdefghijklmnopqrstuvwxyz"):String {
		var name = "";
		for (i in 0...length) {
			name += letters.charAt(Std.int(next() * letters.length));
		}
		return name;
	}

	/** Either `x` or `y` */
	public inline function or<T>(x:T, y:T, chance:Float = .5):T {
		return next() > chance ? x : y;
	}

	/** Either `-1` or `1` */
	public inline function sign(chance:Float = .5):Int {
		return or(-1, 1, chance);
	}

	/** Either `true` or `false` */
	public inline function bool(chance:Float = .5):Bool {
		return next() <= chance;
	}
	
	/** get random value from array **/
	public inline function fromArray<T>(array:Array<T>, doSplice:Bool = false):T {
		return ArrayUtils.randomElement(array, cast this, doSplice);
	}

	/* Next value between 0-1 */
	public inline function next():Float return this.next();

	inline function set_seed(value:Int):Int return this.seed = value;
}
