//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt
package flambe.util;

/**
 * Simple runtime assertions. A failed assertion throws an error, which should NOT be caught and
 * handled. Assertions are stripped from release builds, unless the -D flambe_keep_asserts compiler
 * flag is used.
 */
class Assert {
	#if (debug || flambe_keep_asserts)
	/**
	 * Asserts that a condition is true.
	 * @param message If this assertion fails, the message to include in the thrown error.
	 * @param fields Optional fields to be formatted with the message, see Strings.withFields.
	 */
	public static function that(condition:Bool, ?message:String, ?infos:haxe.PosInfos) {
		if (!condition) {
			fail(message, infos);
		}
	}

	/**
	 * Immediately fails an assertion. Same as Assert.that(false).
	 * @param message The message to include in the thrown error.
	 * @param fields Optional fields to be formatted with the message, see Strings.withFields.
	 */
	public static function fail<T>(?message:String, ?infos:haxe.PosInfos):T {
		var error = "Assertion failed!";
		if (message != null) {
			error += " " + message;
		}
		if (infos != null) {
			error += "\n" + infos.className + "." + infos.methodName + "#" + infos.lineNumber + " (" + infos.fileName + ")";
		}

		throw error;
		return null;
	}
	#else
	// In release builds, assertions are stripped out
	inline public static function that(condition:Bool, ?message:String) {}

	inline public static function fail<T>(?message:String):T return null;
	#end
}
