package temple.random;

/**
 * @author Pieter van de Sluis
 *
 * Based on Johannes Baagøe's Alea PRNG:
 * http://baagoe.com/en/RandomMusings/javascript/
 * Johannes Baagøe <baagoe@baagoe.com>, 2010
 *
 * And this implementation of it:
 * https://github.com/coverslide/node-alea
 */
class AleaRandom implements ISeededRandom {
	private var s0:Float;
	private var s1:Float;
	private var s2:Float;
	private var c:Float;

	@:isVar public var seed(default, set):Int;

	public function new(?seed:Int) {
		this.seed = (seed != null) ? seed : Math.round(Date.now().getTime());
	}

	public function set_seed(value:Int):Int {
		this.seed = value;

		s0 = 0;
		s1 = 0;
		s2 = 0;
		c = 1;

		var mash = new Mash();
		s0 = mash.update(' ');
		s1 = mash.update(' ');
		s2 = mash.update(' ');

		s0 -= mash.update(value);
		if (s0 < 0) {
			s0 += 1;
		}
		s1 -= mash.update(value);
		if (s1 < 0) {
			s1 += 1;
		}
		s2 -= mash.update(value);
		if (s2 < 0) {
			s2 += 1;
		}

		return value;
	}

	public function next():Float {
		var t = 2091639 * s0 + c * 2.3283064365386963e-10; // 2^-32
		s0 = s1;
		s1 = s2;
		return s2 = t - (c = Std.int(t));
	}
}
