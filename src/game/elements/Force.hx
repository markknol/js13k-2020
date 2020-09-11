package game.elements;

import flambe.Component;
import flambe.DisplayComponent;
import temple.geom.Vector2;

/**
 * @author Mark Knol
 */
class Force extends Component {
	@:component var display:DisplayComponent;

	public final velocity:Vector2;

	public function new(velocity:Vector2) {
		this.velocity = velocity;
	}

	override function onUpdate(dt:Float) {
		display.position += velocity * dt;
	}
}
