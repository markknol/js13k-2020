package game.display;

import flambe.DisplayComponent;
import game.Color;
import js.html.CanvasRenderingContext2D;
import temple.geom.Vector2;

/**
 * @author Mark Knol
 */

class PathComponent extends DisplayComponent {
	public static #if debug inline #end var debug:Bool = false;
	public var data:GraphicsData;
	
	public final startModifiers:Array<PathModifier> = [];
	public final updateModifiers:Array<PathModifier> = [];
	
	public var path(default, null):Path;
	
	private var _time:Float = 0.0;
	
	public function new(data:GraphicsData) {
		this.data = data;
		this.data.path = clonePath(this.data.path);
		super();
		
		if (data.isClosedPath) startModifiers.insert(0, closePath);
	}
	
	override public function onStart():Void {
		for (modifier in startModifiers) {
			this.data.path = modifier(this.data.path);
		}
	}
	
	override public function onUpdate(dt:Float):Void {
		_time += dt;
		path = clonePath(this.data.path);
		for (modifier in updateModifiers) {
			path = modifier(path);
		}
	}
	
	override function draw(ctx:CanvasRenderingContext2D):Void {
		if (path == null) return;
		ctx.beginPath();
		for(idx => pos in path) {
			if (idx == 0) {
				ctx.moveTo(pos.x, pos.y);
			} else {
				ctx.lineTo(pos.x, pos.y);
			}
		}
		
		if (data.isClosedPath) {
			ctx.closePath();
			ctx.fillStyle = 'rgba(${data.color}, 0.4)';
			ctx.fill();
		}
		
		ctx.strokeStyle = 'rgb(${data.color})';
		ctx.lineWidth = 2;
		ctx.lineCap = "round";
		ctx.stroke();
		
		if (debug) {
			ctx.save();
			ctx.strokeStyle = 'rgba(255,0,0,1)';
			ctx.lineWidth = 1;
			for(idx => pos in path) {
				ctx.beginPath();
				ctx.arc(pos.x, pos.y, 2, 0, Math.PI*2);
				ctx.closePath();
				ctx.stroke();
			}
			ctx.restore();
		}
	}
	
	override function drawInteraction(ctx:CanvasRenderingContext2D):Void {
		if (path == null) return;
		if (interactive) {
			ctx.beginPath();
			for(idx => pos in path) {
				if (idx == 0) {
					ctx.moveTo(pos.x, pos.y);
				} else {
					ctx.lineTo(pos.x, pos.y);
				}
			}
			ctx.closePath();
			
			ctx.fillStyle = interactionColor;
			ctx.fill();
		}
	}
}

@:structInit
class GraphicsData {
	public var isClosedPath:Bool = true;
	public var color:Color;
	public var path:Path;
}

typedef Path = Array<Vector2>;
typedef PathModifier = (path:Path) -> Path;

@:callable
abstract PathModifierParam<T>(() -> T) from () -> T {
	@:from static inline function fromVal<V>(v:V):PathModifierParam<V> {
		return cast (() -> v);
	}
}

