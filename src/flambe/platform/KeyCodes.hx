//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt
package flambe.platform;

import flambe.input.Key;

/**
 * Key codes
 */
class KeyCodes {
	public static function toKey(keyCode:Int):Key {
		return cast keyCode;
	}

	public static function toKeyCode(key:Key):Int {
		return key;
	}
}
