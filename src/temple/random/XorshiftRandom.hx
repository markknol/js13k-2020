package temple.random;

/**
 * @author Pieter van de Sluis
 *
 * Based on George Marsaglia Xorshift PRNG
 *
 * And this implementation of it:
 * https://gist.githack.com/kirbysayshi/1342599/raw/3a54bf50924a53154f99370e343feeddad2b601b/xorshift03.js
 */
class XorshiftRandom implements ISeededRandom {
	private var x:Int;
	private var y:Int;
	private var z:Int;
	private var w:Int;
	private var v:Int;

	@:isVar public var seed(default, set):Int;

	public function new(?seed:Int) {
		this.seed = (seed != null) ? seed : Math.round(Date.now().getTime());
	}

	public function set_seed(value:Int):Int {
		this.seed = value;

		// George Marsaglia, 13 May 2003
		// http://groups.google.com/group/comp.lang.c/msg/e3c4ea1169e463ae
		x = 123456789;
		y = 362436069;
		z = 521288629;
		w = 88675123;
		v = 886756453;

		var mash = new Mash();
		x ^= Std.int(mash.update(value) * 4294967296); // 2^32
		y ^= Std.int(mash.update(value) * 4294967296);
		z ^= Std.int(mash.update(value) * 4294967296);
		v ^= Std.int(mash.update(value) * 4294967296);
		w ^= Std.int(mash.update(value) * 4294967296);

		return value;
	}

	private inline function nextInt():Int {
		var t = (x ^ (x >>> 7)) >>> 0;
		x = y;
		y = z;
		z = w;
		w = v;
		v = (v ^ (v << 6)) ^ (t ^ (t << 13)) >>> 0;
		return ((y + y + 1) * v) >>> 0;
	}

	public function next():Float {
		return nextInt() * 2.3283064365386963e-10; // 2^-32
	};
}
