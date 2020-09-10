package game.elements;

import flambe.Component;
import flambe.DisplayComponent;
import temple.components.AutoDisposer;

/**
 * @author Mark Knol
 */
class AutoRemover extends Component {
	@:component var display:DisplayComponent;
	public final range:Float;

	public function new(range:Float) {
		this.range = range;
	}

	override function onUpdate(dt:Float) {
		if (display.position.x < -range 
			|| display.position.x > sceneSize.x + range 
			|| display.position.y < -range 
			|| display.position.y > sceneSize.y + range) {
			AutoDisposer.create(owner);
		}
	}
}