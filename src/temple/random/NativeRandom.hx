package temple.random;

import flambe.math.FMath;

/**
 * @author Mark KNol
 */
class NativeRandom implements ISeededRandom {
	@:isVar public var seed(default, set):Int = -1;

	public function new() {}

	private function nextInt():Int return Std.random(FMath.INT_MAX);

	public function next():Float return Math.random();

	public function set_seed(value:Int):Int return this.seed;
}
