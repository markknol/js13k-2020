//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt
package flambe.platform.html;

import flambe.util.Logger.LogHandler;
import flambe.util.Logger.LogLevel;
import js.Browser;

class HtmlLogHandler implements LogHandler {
	private var _tagPrefix:String;

	public static function isSupported():Bool {
		return Browser.console != null;
	}

	public function new(tag:String) {
		_tagPrefix = tag + ": ";
	}

	public function log(level:LogLevel, message:String) {
		message = _tagPrefix + message;

		switch (level) {
			case Info:
				Browser.console.info(message);
			case Warn:
				Browser.console.warn(message);
			case Error:
				Browser.console.error(message);
		}
	}
}
