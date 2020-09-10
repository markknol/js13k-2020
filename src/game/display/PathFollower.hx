package game.display;

import flambe.Component;

/**
 * @author Mark Knol
 */
class PathFollower extends Component {
	var parentPath:PathComponent;
	@:component var currentPath:PathComponent;
	
	private var r:Float;
	private var doOrient:Bool;
	
	public function new(r:Float,doOrient:Bool) {
		this.doOrient = doOrient;
		this.r = r;
	}
	
	override public function onStart():Void {
		currentPath.updateModifiers.clear();
		
		parentPath = owner.parent.get(PathComponent);
	}
	
	override public function onUpdate(dt:Float):Void {
		var parentPath = parentPath.path;
		
		var idx = Std.int((parentPath.length+1) * r);
		
		var nextAttachment1 = parentPath[positiveModulo(idx + 1, parentPath.length)];
		var attachment = parentPath[positiveModulo(idx, parentPath.length)];
		if (attachment != null) {
			if (doOrient) currentPath.rotation = (attachment - nextAttachment1).angle();
			currentPath.position.copy(attachment);
		}
	}
	
	public inline function positiveModulo(value, mod) {
		var v = value % mod;
		while (v < 0) v += mod;
		return v;
	}
}