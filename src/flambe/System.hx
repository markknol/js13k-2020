package flambe;

import flambe.DisplayComponent;
import flambe.Disposer;
import flambe.input.Key;
import flambe.input.KeyboardEvent;
import flambe.platform.Platform;
import flambe.subsystem.KeyboardSystem;
import flambe.util.Disposable;
import js.html.Element;
import js.html.audio.AudioContext;

/**
 * @author Mark Knol
 */
class System {
	public static var keyboard(get,null):KeyboardSystem;
	
	/** The entity at the root of the hierarchy. **/
	public static var root(default, null):Entity;

	/** The renderer draws the scene and all its content onto a canvas (uses webGL where possible). **/
	public static var renderer(default, null):Renderer;

	private static var platform(default, null):Platform;
	
	public static var audioContext(default, null):AudioContext;

	public static function init(element:Element) {
		// root should always have one DisplayComponent, this is the starting point for rendering
		root = new Entity()
			.addComponent(new TimeScaleAdjuster())
			.addComponent(new DisplayComponent());

		// create custom renderer
		renderer = new Renderer(element);
		renderer.onFirstTap = e -> audioContext = js.Syntax.code("new(window.AudioContext || window.webkitAudioContext)");
		// create platform
		platform = new Platform();
		
		#if debug
		addSpeedAdjusterKeys();
		#end
	}

	static private inline function get_keyboard():KeyboardSystem {
		if (keyboard == null) keyboard = platform.getKeyboard();
		return keyboard;
	}

	private static inline function addSpeedAdjusterKeys() {
		keyboard.down.connect(function(event:KeyboardEvent) {
			var scale = System.root.get(TimeScaleAdjuster).scale;
			var old = scale._;
			switch event.key {
				case Key.LeftBracket:
					scale._ /= 1.61803398875;
				case Key.RightBracket:
					scale._ *= 1.61803398875;
				case Key.R:
					scale._ = 1;
				case Key.P:
					scale._ = 0;
					
				default:
			}

			if (old != scale._) trace("Speed Adjuster scale: " + scale._);
		});
	}
	
}
