package temple.utils;

/**
 * @author Thijs Broerse
 */
class FloatUtils {
	/**
	 * Rounds a Float to the nearest multiple of an input. For example, by rounding
	 * 16 to the nearest 10, you will receive 20. Similar to the built-in function Math.round().
	 *
	 * @param float the float to round
	 * @param nearest the float whose mutiple must be found
	 * @return the rounded float
	 */
	inline static public function roundToNearest(float:Float, nearest:Float = 1):Float {
		if (nearest == 0) {
			return float;
		}
		var roundedNumber:Float = Math.fround(roundToPrecision(float / nearest, 10)) * nearest;
		return roundToPrecision(roundedNumber, 10);
	}

	/**
	 * Rounds a Float <em>up</em> to the nearest multiple of an input. For example, by rounding
	 * 16 up to the nearest 10, you will receive 20. Similar to the built-in function Math.ceil().
	 *
	 * @param float the float to round up
	 * @param nearest the float whose mutiple must be found
	 * @return the rounded float
	 */
	inline static public function roundUpToNearest(float:Float, nearest:Float = 1):Float {
		if (nearest == 0) {
			return float;
		}
		return Math.fceil(roundToPrecision(float / nearest, 10)) * nearest;
	}

	/**
	 * Rounds a Float <em>down</em> to the nearest multiple of an input. For example, by rounding
	 * 16 down to the nearest 10, you will receive 10. Similar to the built-in function Math.floor().
	 *
	 * @param float the float to round down
	 * @param nearest the float whose mutiple must be found
	 * @return the rounded float
	 */
	inline static public function roundDownToNearest(float:Float, nearest:Float = 1):Float {
		if (nearest == 0) {
			return float;
		}
		return Math.ffloor(roundToPrecision(float / nearest, 10)) * nearest;
	}

	/**
	 * Formats a number to a specific format.
	 * @param number the number to format
	 * @param thousandDelimiter the characters used to delimit thousands, millions, etcetera; "." if not specified
	 * @param decimalDelimiter the characters used to delimit the fractional portion from the whole number; "," if not specified
	 * @param precision the total number of decimals
	 * @param fillLength  minimal length of the part *before* the decimals delimiter, if the length is less it will be filled up
	 * @param fillChar the character to use to fill with; zero ("0") if not specified
	 */
	static public function format(number:Float, decimalDelimiter:String = ',', thousandDelimiter:String = '.', ?precision:Int = -1, ?fillLength:Int = -1,
			?fillChar:String = '0'):String {
		if (precision != -1) {
			number = FloatUtils.roundToPrecision(number, precision);
		}

		var str:String = Std.string(number);
		var p:Int = str.indexOf('.');
		if (number < 0) str = str.substr(1);

		var decimals:String = (p != -1) ? str.substr(p + 1) : '';
		while (decimals.length < precision)
			decimals = decimals + '0';

		var floored:String = Std.string(Math.floor(Math.abs(number)));
		var formatted:String = '';

		if (thousandDelimiter != null) {
			var len:Int = Math.ceil(floored.length / 3) - 1;
			var count:Int = 0;
			for (i in 0...len) {
				formatted = thousandDelimiter + floored.substr(floored.length - (3 * (i + 1)), 3) + formatted;
				++count;
			}
			formatted = floored.substr(0, floored.length - (3 * count)) + formatted;
		} else {
			formatted = floored;
		}

		if (fillLength != -1 && fillChar != null && fillChar != '') {
			if (number < 0) fillLength--;
			while (formatted.length < fillLength)
				formatted = fillChar + formatted;
		}

		if (precision > 0) formatted = formatted + (decimals != '' ? decimalDelimiter + decimals : '');

		if (number < 0) formatted = "-" + formatted;

		return formatted;
	}

	/**
	 * Rounds a float to a certain level of precision. Useful for limiting the float of decimal places on a fractional float.
	 *
	 * @param float the input float to round.
	 * @param precision	the float of decimal digits to keep
	 * @return the rounded float, or the original input if no rounding is needed
	 */
	inline static public function roundToPrecision(float:Float, ?precision:Int = 0):Float {
		var n:Float = Math.pow(10, precision);
		return Math.fround(float * n) / n;
	}

	/**
	 * Divide a float in half.
	 *
	 * @param float the input float
	 * @return the float, divided in half
	 */
	inline static public function half(float:Float):Float {
		return float * 0.5;
	}

	/**
	 * Get the sign (negative/positive) of the float
	 *
	 * @param float the input float
	 * @return 1 when 0 or positive, -1 when negative
	 */
	inline static public function sign(float:Float):Int {
		return float >= 0 ? 1 : -1;
	}
}
