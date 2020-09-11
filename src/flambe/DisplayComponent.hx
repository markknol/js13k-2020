package flambe;

import flambe.Component;
import js.html.CanvasRenderingContext2D;
import temple.geom.Vector2;

/**
 * @author Mark Knol
 */
class DisplayComponent extends Component {
	public static final interactionByColor:Map<String, DisplayComponent> = [];

	@:component(parents, optional) public var parent:DisplayComponent;

	public final pivot:Vector2 = [0.0, 0.0];
	public final position:Vector2 = [0.0, 0.0];
	public final scale:Vector2 = [1.0, 1.0];

	public var alpha:Float = 1.0;
	public var rotation:Float = 0.0;

	public var isPointerDown:Bool = false;
	public var interactive:Bool = false;

	final interactionColor:String = 'rgb(${Std.random(255)},${Std.random(255)},${Std.random(255)})';

	private var _alpha:Float = 1.0;

	public function new() {
		interactionByColor[interactionColor] = this;
	}

	override function onRemoved():Void {
		interactionByColor.remove(interactionColor);
	}

	public final function render(isInteraction:Bool, ctx:CanvasRenderingContext2D) {
		if (!isInteraction) _alpha = alpha;

		ctx.translate(pivot.x, pivot.y);
		ctx.translate(position.x, position.y);
		ctx.rotate(rotation);
		ctx.scale(scale.x, scale.y);
		ctx.translate(-pivot.x, -pivot.y);

		if (parent != null && !isInteraction) {
			_alpha *= parent._alpha;
		}

		if (!isInteraction) ctx.globalAlpha = _alpha;
	}

	public function draw(ctx:CanvasRenderingContext2D):Void {}

	public function drawInteraction(ctx:CanvasRenderingContext2D):Void {}

	public function setAlpha(v:Float) {
		alpha = v;
		return this;
	}

	public function setXY(x:Float, y:Float) {
		position.x = x;
		position.y = y;
		return this;
	}

	public function setPivot(x:Float, y:Float) {
		pivot.x = x;
		pivot.y = y;
		return this;
	}

	public function setAngle(radians:Float) {
		rotation = radians;
		return this;
	}

	public function makeInteractive() {
		interactive = true;
		return this;
	}
}
