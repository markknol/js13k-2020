package temple.components;

import flambe.Component;
import flambe.Entity;
import flambe.util.Signal2;

/**
 * @author Mark Knol
 */
class OnUpdate extends Component {
	public var update(default, null):Signal2<Entity, Float>;

	public function new(callback:(entity:Entity, dt:Float) -> Void) {
		update = new Signal2(callback);
	}

	override public function onUpdate(dt:Float) {
		update.emit(owner, dt);
	}
}
