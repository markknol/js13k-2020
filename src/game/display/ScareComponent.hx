package game.display;

import flambe.Component;
import temple.utils.EntityUtils;

/**
 * @author Mark Knol
 */
class ScareComponent extends Component {
	@:component var _wobbly:WobblyPathComponent;

	public function new() {
		
	}
	
	override function onUpdate(dt:Float) {
		if (_wobbly.isPointerDown && _wobbly.interactive) {
			_wobbly.isScared = true;
		} else {
			_wobbly.isScared = false; 
		}
		var childPaths:Array<WobblyPathComponent> = EntityUtils.getComponentsFromChildren(owner, WobblyPathComponent.NAME, 10);
		for (child in childPaths) {
			child.isScared = _wobbly.isScared;
		}
	}
}