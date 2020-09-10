package temple.components;

import flambe.Component;
import flambe.Entity;
import flambe.util.Disposable;

/**
 * @author Mark Knol
 */
class Interval extends Component {
	private var _cooldown:Cooldown = new Cooldown();
	private var _interval:Float;
	private var _repeat:Int;
	private var _callback:Void->Void;

	private function new(interval:Float, repeat:Int, callback:Void->Void) {
		_repeat = repeat;
		_interval = interval;
		_callback = callback;
		_cooldown.reset(interval);
	}

	public static function create(owner:Entity, interval:Float = 0.1, repeat:Int = -1, callback:Void->Void, append:Bool = true):Disposable {
		var entity = new Entity()
			.addComponent(new Interval(interval, repeat, callback));
		owner.addEntity(entity, append);
		return entity;
	}

	override public function onUpdate(dt:Float):Void {
		if (_cooldown.update(dt)) {
			if (_repeat-- != 0) {
				_cooldown.reset(_interval);
				_callback();
			} else {
				owner.dispose();
			}
		}
	}

	override public function dispose():Void {
		_callback = null;
		super.dispose();
	}
}
