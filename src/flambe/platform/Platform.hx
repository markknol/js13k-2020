package flambe.platform;

import flambe.platform.MainLoop;
import flambe.subsystem.KeyboardSystem;
import js.html.KeyboardEvent;

/**
 * @author Mark Knol
 */
class Platform {
	public var mainLoop(default, never):MainLoop = new MainLoop();

	private var _events:EventGroup = new EventGroup();
	private var _lastUpdate:Float;

	public function new() {
		addMainLoop();
		
	}

	function addMainLoop() {
		var performance = window.performance;
		_lastUpdate = performance.now();
		(function loop(?_) {
			update(performance.now());
			window.requestAnimationFrame(loop);
		})();
	}
	
	inline function update(now:Float) {
		var dt = (now - _lastUpdate) / 1000;
		_lastUpdate = now;
		mainLoop.update(dt);
	}

	public function getKeyboard():KeyboardSystem {
		var keyboard = new BasicKeyboard();
		var onKey = function(event:KeyboardEvent) {
			switch (event.type) {
				case "keydown":
					if (keyboard.submitDown(event.keyCode)) {
						// event.preventDefault();
					}

				case "keyup":
					keyboard.submitUp(event.keyCode);
			}
		}
		
		_events.addListener(window, "keydown", onKey);
		_events.addListener(window, "keyup", onKey);

		return keyboard;
	}
}
