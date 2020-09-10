package game.display;

import flambe.Component;
import flambe.DisplayComponent;
import game.display.PathComponent;
import game.display.WobblyPathComponent;

/**
 * @author Mark Knol
 */
class ProgressBar extends DisplayComponent {
	private var _line:PathComponent;
	private var _width:Float;
	
	public function new(width:Float) {
		super();
		_width = width;
	}
	
	override public function onStart():Void {
		super.onStart();
		
		// background
		var _bg:PathComponent;
		owner.add(new Entity().addComponent(_bg = cast new PathComponent({
			isClosedPath: true,
			path: getRect(_width, 15),
			color: PINK,
		}).setXY(_width.half(), 0).setAlpha(0.5)));
		// progress line
		owner.add(new Entity().addComponent(_line = cast new PathComponent({
			isClosedPath: true,
			path: getRect(1,1),
			color: PINK,
		}).setXY(_width.half(), 0)));
		
		_bg.updateModifiers.push(normalizePath.bind(() -> 20 +Std.random(3)));
		_bg.updateModifiers.push(randomizePathAngle.bind(1.0));
		_bg.updateModifiers.push(normalizePath.bind(8.0));
		_line.updateModifiers.push(randomizePath.bind(1.0));
		
		_line.updateModifiers.push(normalizePath.bind(8.0));
		_line.updateModifiers.push(randomizePath.bind(1.0));
	}
	
	public function setProgress(progress:Float) {
		if (_line != null) {
			var w = ((_width - 30) * progress).half();
			var h = (5).half();
			var path = _line.data.path;
			path[0].set(-w, -h);
			path[1].set(w, -h);
			path[2].set(w, h);
			path[3].set(-w, h);
		}
	}
}