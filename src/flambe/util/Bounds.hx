package flambe.util;

import flambe.math.FMath;

/**
 * @author Pieter van de Sluis
 */
class Bounds {
	/**
	 * Translates a value within two bounds to target bounds.
	 * The input value is automatically constrained to the source bounds.
	 *
	 * @method translateValue
	 * @static
	 * @param value {Float} The value that is to be translated
	 * @param sourceFrom {Float} The first boundary value of the source bounds
	 * @param sourceTo {Float} The second boundary value of the source bounds
	 * @param [targetFrom=0] {Float} The first boundary value of the target bounds
	 * @param [targetTo=1] {Float} The second boundary value of the target bounds
	 * @return {Float} The translated value
	 */
	public static function translateValue(value:Float, sourceFrom:Float, sourceTo:Float, targetFrom:Float = 0, targetTo:Float = 1):Float {
		return new Bounds(sourceFrom, sourceTo).translate(value, new Bounds(targetFrom, targetTo));
	}

	private var _from:Float;

	public var from(get, set):Float;

	private var _to:Float;

	public var to(get, set):Float;

	private var _size:Float;

	public var size(get, null):Float;

	private var _direction:Int;

	/**
	 * Constructs a new Bounds instance. The from/to values don't necessarily have to be in lower/higher order,
	 * the Bounds class works with both ascending and descending ranges.
	 *
	 * @constructor
	 * @param from {Float} The first boundary value
	 * @param to {Float} The second boundary value
	 */
	public function new(from:Float = 0, to:Float = 1) {
		_from = from;
		_to = to;

		updateSize();
		updateDirection();
	}

	public function set(from:Float, to:Float):Void {
		_from = from;
		_to = to;

		updateSize();
		updateDirection();
	}

	/**
	 * Translates a value within the bounds to a factor (0-1).
	 * The input value is automatically constrained to the bounds.
	 *
	 * @method getFactorFromValue
	 * @param value {Float} A value within the bounds
	 * @return {Float} The factor within the bounds
	 */
	public function getFactorFromValue(value:Float):Float {
		return Math.abs((clamp(value) - _from) / _size);
	}

	/**
	 * Translates a factor (0-1) to a value within the bounds.
	 * The input value is by default constrained to 0-1.
	 *
	 * @method getValueFromFactor
	 * @param factor {Float} The factor
	 * @return {Float} The value within the bounds
	 */
	public function getValueFromFactor(factor:Float):Float {
		return _from + _direction * (factor * _size);
	}

	/**
	 * Translates a value within this bounds to a target bounds
	 *
	 * @method translate
	 * @param value {Float} A value within the bounds
	 * @param targetBounds {Bounds} The target bounds that the value should be translated to
	 * @return {Float} The translated value
	 */
	public function translate(value:Float, targetBounds:Bounds):Float {
		return targetBounds.getValueFromFactor(getFactorFromValue(value));
	}

	/**
	 * Constrains a value to the bounds
	 *
	 * @method constrain
	 * @param value {Float} The value that should be constrained
	 * @return {Float} The constrained value
	 */
	public function clamp(value:Float):Float {
		return if (_to > _from) {
			clampTo(value, _from, _to);
		} else {
			clampTo(value, _to, _from);
		}
	}

	/**
	 * Constrains a value to an upper and lower limit
	 *
	 * @private
	 * @method constrainTo
	 * @param value {Float} The value that should be constrained
	 * @param lower {Float} The lower limit
	 * @param upper {Float} The upper limit
	 * @return {Float} The constrained value
	 */
	private function clampTo(value:Float, lower:Float, upper:Float):Float {
		return FMath.clamp(value, lower, upper);
	}

	/**
	 * Wrap a value between the bounds
	 *
	 * @method wrap
	 * @param value {Float} The value that should be wrapped
	 * @return {Float} The wrapped value
	 */
	public function wrap(value:Float):Float {
		return if (_direction == 1) {
			wrapBetween(value, _from, _to);
		} else {
			wrapBetween(value, _to, _from);
		}
	}

	/**
	 * Wrap a value between an upper and lower limit
	 *
	 * @private
	 * @method wrapBetween
	 * @param value {Float} The value that should be wrapped
	 * @param lower {Float} The lower limit
	 * @param upper {Float} The upper limit
	 * @return {Float} The wrapped value
	 */
	private function wrapBetween(value:Float, lower:Float, upper:Float):Float {
		return if (value < lower) upper - (lower - value) else if (value > upper) lower + (value - upper) else value;
	}

	/**
	 * Scales the size of the bounds
	 *
	 * @method scale
	 * @param scaleFactor {Float} The amount that the bounds should be scaled. 1.0 equals 100% scale.
	 * @return {Float} The new size of the bounds
	 */
	public function scale(scaleFactor:Float):Float {
		if (scaleFactor < 0) {
			// Flip from-to values
			var tempTo:Float = _to;
			_to = _from;
			_from = tempTo;

			_direction *= -1;

			scaleFactor *= -1;
		}

		var newSize:Float = _size * scaleFactor;
		var boundaryChange:Float = (newSize - _size) * 0.5;

		_from -= _direction * boundaryChange;
		_to += _direction * boundaryChange;

		return updateSize();
	}

	/**
	 * Get a random value within the bounds
	 *
	 * @method getRandomValue
	 * @return {Float} the random number
	 */
	public inline function getRandomValue():Float {
		return getValueFromFactor(Math.random());
	}

	/**
	 * Checks whether a value is within the bounds
	 *
	 * @method contains
	 * @param value {Float} The value
	 * @return {boolean} Whether the value is within the bounds
	 */
	public inline function contains(value:Float):Bool {
		return (_from <= value && value <= _to) || (_to <= value && value <= _from);
	}

	/**
	 * Calculates the size of the bounds and updates the step size accordingly
	 *
	 * @private
	 * @method updateSize
	 * @return {Float} The new size
	 */
	private function updateSize():Float {
		_size = Math.abs(_from - _to);

		return _size;
	}

	/**
	 * Updates the direction of the bounds. 1 for ascending, -1 for descending.
	 *
	 * @private
	 * @method updateDirection
	 */
	private inline function updateDirection():Void {
		_direction = (_to > _from) ? 1 : -1;
	}

	/**
	 * Gets the size of the bounds (the distance between from and to values)
	 *
	 * @method getSize
	 * @return {Float} The size of the bounds
	 */
	private inline function get_size():Float {
		return _size;
	}

	/**
	 * Gets the _from_ value
	 *
	 * @method getFrom
	 * @return The _from_ value
	 */
	private inline function get_from():Float {
		return _from;
	}

	/**
	 * Sets the _from_ value
	 *
	 * @method setFrom
	 * @param value {Float} The _from_ value
	 */
	private function set_from(value:Float):Float {
		_from = value;

		updateSize();
		updateDirection();

		return value;
	}

	/**
	 * Gets the _to_ value
	 *
	 * @method getTo
	 * @return The _to_ value
	 */
	private inline function get_to():Float {
		return _to;
	}

	/**
	 * Sets The _to_ value
	 *
	 * @method setTo
	 * @param value {Float} The _to_ value
	 */
	private function set_to(value:Float):Float {
		_to = value;

		updateSize();
		updateDirection();

		return value;
	}
}
