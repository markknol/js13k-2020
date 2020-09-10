package temple.random;

/**
 * @author Pieter van de Sluis
 */
@:remove interface ISeededRandom {
	@:isVar public var seed(default, set):Int;

	/**
	 * Returns a pseudo-random floating point number in range [0, 1).
	 */
	function next():Float;
}
