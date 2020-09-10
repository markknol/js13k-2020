package temple.random;

/**
 * @author Pieter van de Sluis
 *
 * Ported from JavaScript version:
 * https://gist.github.com/blixt/f17b47c62508be59987b
 *
 * Uses an optimized version of the Park-Miller PRNG.
 * http://www.firstpr.com.au/dsp/rand31/
 */
class ParkMillerRandom implements ISeededRandom {
	@:isVar public var seed(default, set):Int;

	public function new(?seed:Int) {
		this.seed = (seed != null) ? seed : Math.round(Date.now().getTime());
	}

	/**
	 * Returns a pseudo-random value between 1 and 2^32 - 2.
	 */
	private function nextInt():Int {
		return this.seed = this.seed * 16807 % 2147483647;
	}

	/**
	 * Returns a pseudo-random floating point number in range [0, 1).
	 */
	public function next():Float {
		// We know that result of next() will be 1 to 2147483646 (inclusive).
		return (this.nextInt() - 1) / 2147483646;
	}

	public function set_seed(value:Int):Int {
		this.seed = value % 2147483647;
		if (this.seed <= 0) this.seed += 2147483646;

		return this.seed;
	}
}
