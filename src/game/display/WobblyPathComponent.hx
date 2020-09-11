package game.display;

import game.display.PathComponent;
import temple.geom.Vector2;

/**
 * @author Mark Knol
 */
class WobblyPathComponent extends PathComponent {
	public var isScared:Bool = false;

	private var _scaredTime:Float = 0.0;
	private var _sineId:Float = 0;
	private var _settings:WobblyPathComponentSettings;

	public function new(data:GraphicsData, ?settings:WobblyPathComponentSettings) {
		super(data);
		_settings = settings != null ? settings : {};

		var pathBounds:{topLeft:Vector2, bottomRight:Vector2} = {
			topLeft: this.data.path.first().clone(),
			bottomRight: this.data.path.first().clone(),
		};
		for (pos in this.data.path) {
			pathBounds.topLeft.x = Math.min(pathBounds.topLeft.x, pos.x);
			pathBounds.topLeft.y = Math.min(pathBounds.topLeft.y, pos.y);
			pathBounds.bottomRight.x = Math.max(pathBounds.bottomRight.x, pos.x);
			pathBounds.bottomRight.y = Math.max(pathBounds.bottomRight.y, pos.y);
		}
		var size = (pathBounds.bottomRight - pathBounds.topLeft);

		// debug = true;

		for (m in [
			randomizePath.bind(_settings.randomizeAmount),
			normalizePath.bind(_settings.normalize1),
			randomizePath.bind(_settings.randomizeAmount),
			smoothPath.bind(_settings.smooth1, data.isClosedPath),
		])
			startModifiers.push(m);

		if (data.isClosedPath) startModifiers.insert(0, closePath);

		var scareAmp = 2 + Std.random(4);
		var scareMod = 2 + Std.random(15);
		for (m in [
			// randomizePath.bind(2.0),
			makeScared.bind(() -> isScared ? scareAmp : 1, 1.0, () -> isScared ? scareMod : 9999999),
			randomizePathSin.bind(() -> _time * 6 + (_sineId += .35), 2.0),
			normalizePath.bind(_settings.normalize2),
			smoothPath.bind(_settings.smooth2, data.isClosedPath),
		])
			updateModifiers.push(m);
	}

	override public function onStart():Void {
		super.onStart();
		if (_settings.addScareComponent) owner.add(new ScareComponent());
	}

	override public function onUpdate(dt:Float):Void {
		_sineId = 0;
		super.onUpdate(dt);

		if (isScared) {
			_scaredTime += dt;
		} else {
			_scaredTime = 0.0;
		}
	}

	private function makeScared(amp:PathModifierParam<Float>, scale:PathModifierParam<Float>, mod:PathModifierParam<Int>, path:Path) {
		var scale = scale();
		var mod = mod();
		var amp = amp();
		for (idx => pos in path) {
			if (idx % mod == mod - 1) {
				pos *= (1 + Math.sin((idx + _time) * amp) / 2) * scale;
			}
		}
		return path;
	}
}

@:structInit
class WobblyPathComponentSettings {
	public var randomizeAmount:Float = 5.0;
	public var smooth1:Int = 1;
	public var smooth2:Int = 3;
	public var normalize1:Float = 2.0;
	public var normalize2:Float = 2.0;
	public var addScareComponent:Bool = true;
}
