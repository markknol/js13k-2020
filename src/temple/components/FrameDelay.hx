package temple.components;

import flambe.Component;
import flambe.Entity;
import flambe.util.Disposable;

/**
 * @author Mark Knol
 */
class FrameDelay extends Component {
	private var _currentFrame:Int;
	private var _callback:() -> Void;
	private var isDone(get, never):Bool;

	private function new(frameCount:Int = 1, callback:Void->Void) {
		_currentFrame = frameCount;
		_callback = callback;
	}

	public static function create(owner:Entity, frameCount:Int = 1, callback:() -> Void, append:Bool = true):Disposable {
		var entity = new Entity()
			.addComponent(new FrameDelay(frameCount, callback));

		owner.addEntity(entity, append);

		return entity;
	}

	override public function onUpdate(dt:Float):Void {
		if (isDone) {
			if (_callback != null) {
				_callback();
			}
			dispose();
		} else {
			_currentFrame--;
		}
	}

	inline function get_isDone():Bool {
		return _currentFrame <= 1;
	}

	override public function dispose():Void {
		_callback = null;
		super.dispose();
	}
}
