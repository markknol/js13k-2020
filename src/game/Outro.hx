package game;

import flambe.DisplayComponent;
import game.display.SVGs;
import game.display.WobblyPathComponent;
import temple.components.Timeout;

/**
 * @author Mark Knol
 */
class Outro extends DisplayComponent {
	override function onStart() {
		var paths = SVGs.OWNER;
		for (idx => path in paths) {
			Timeout.create(owner, Math.random() * 2.5, () -> owner.addEntity(new Entity().addComponent(new WobblyPathComponent({
				color: GRAY,
				path: path,
			})
				.makeInteractive()
				.setXY(sceneMiddlePosition.x, sceneMiddlePosition.y))));
		}
	}
}
