package flambe;

import flambe.DisplayComponent;
import js.html.CanvasElement;
import js.html.CanvasRenderingContext2D;
import js.html.Element;
import js.html.PointerEvent;
import js.html.TouchEvent;
import temple.geom.Vector2;

/**
 * @author Mark Knol
 */
class Renderer {
	public static final sceneSize:Vector2 = new Vector2(900,900);
	public static final sceneMiddlePosition:Vector2 = sceneSize * 0.5;
	
	public final pointerPosition:Vector2 = [sceneMiddlePosition.x,sceneMiddlePosition.y];
	public var isPointerDown(default, null):Bool = false;
	public var backgroundColor = "#fcebd9";
	
	private var _visualCanvas:CanvasElement;
	private var _visualCtx:CanvasRenderingContext2D;
	
	private var _interactionCanvas:CanvasElement;
	private var _interactionCtx:CanvasRenderingContext2D;
	private var _isFirstTap = true;
	
	public var flip:Bool = true;
	
	public function new(element:Element) {
		_visualCanvas = document.createCanvasElement();
		_visualCanvas.width = Std.int(sceneSize.x);
		_visualCanvas.height = Std.int(sceneSize.y);
		
		_visualCtx =  _visualCanvas.getContext2d();
		
		
		var canvasSize:Vector2 = [_visualCanvas.width, _visualCanvas.height];
		function updatePointerPos(clientX:Int, clientY:Int) {
			var rect = _visualCanvas.getBoundingClientRect();
			var pos:Vector2 = [clientX - rect.left, clientY - rect.top];
			var scale:Vector2 = [canvasSize.x / rect.width, canvasSize.y / rect.height];
			pos *= scale;
			pointerPosition.set(pos.x, pos.y);
		}
		
		_visualCanvas.onpointermove = function(e:PointerEvent) {
			updatePointerPos(e.clientX, e.clientY);
			e.preventDefault();
			e.stopPropagation();
		}
		
		_visualCanvas.ontouchmove = function(e:TouchEvent) {
			var touch = e.touches[0];
			updatePointerPos(touch.clientX, touch.clientY);
			e.preventDefault();
			e.stopPropagation();
		}
		
		var currentDisplayDown:DisplayComponent = null;
		_visualCanvas.onpointerup = _visualCanvas.onpointerdown = function(e:PointerEvent) {
			if (_isFirstTap) {
				onFirstTap(e);
				_isFirstTap = false;
			}
			final isPointerDownEvent = e.type == "pointerdown";
			isPointerDown = isPointerDownEvent;
			if (!isPointerDownEvent && currentDisplayDown != null && currentDisplayDown.isPointerDown) {
				currentDisplayDown.isPointerDown = false;
				currentDisplayDown = null;
			}
			updatePointerPos(e.clientX, e.clientY);
			var pixel = _interactionCtx.getImageData(pointerPosition.x, pointerPosition.y, 1, 1).data;
			var rgb:String = 'rgb(${pixel[0]},${pixel[1]},${pixel[2]})';
			if (DisplayComponent.interactionByColor.exists(rgb)) {
				var display:DisplayComponent = DisplayComponent.interactionByColor[rgb];
				if (display.interactive) {
					display.isPointerDown = isPointerDownEvent;
					currentDisplayDown = display;
				}
			}
			e.preventDefault();
			e.stopPropagation();
		}
		
		_interactionCanvas = document.createCanvasElement();
		_interactionCanvas.width = Std.int(sceneSize.x);
		_interactionCanvas.height = Std.int(sceneSize.y);
		_interactionCtx =  _interactionCanvas.getContext2d();
		
		var appendChild = document.body.appendChild;
		appendChild(_visualCanvas);
	}
	
	public dynamic function onFirstTap(e:PointerEvent):Void {
		
	}

	public function render(root:Entity) {
		// Handle update time scale adjuster
		var timeScaleAdjuster:TimeScaleAdjuster = root.get(TimeScaleAdjuster);
		if (timeScaleAdjuster != null) {
			if (timeScaleAdjuster.scale._ <= 0) {
				return;
			}
		}
		
		if (flip) {
			_visualCtx.fillStyle = backgroundColor;
			_visualCtx.fillRect(0, 0, sceneSize.x, sceneSize.y);
			iter(root, _visualCtx, (display, ctx) -> {
				display.render(false, ctx); 
				display.draw(ctx); 
			});
		} else {
			_interactionCtx.fillStyle = backgroundColor;
			_interactionCtx.fillRect(0, 0, sceneSize.x, sceneSize.y);
			iter(root, _interactionCtx, (display, ctx) -> {
				display.render(true, ctx); 
				display.drawInteraction(ctx); 
			});
		}
		flip = !flip;
	}
	
	private function iter(entity:Entity,ctx:CanvasRenderingContext2D, onEachDisplay:(display:DisplayComponent, ctx:CanvasRenderingContext2D)->Void) {
		var p = entity.firstChild;
		while (p != null) {
			var next = p.next;
			ctx.save();
			p.map((display:DisplayComponent) -> onEachDisplay(display, ctx));
			iter(p, ctx, onEachDisplay);
			ctx.restore();
			p = next;
		}
	}
}