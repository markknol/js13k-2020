package game;

import flambe.Component;
import flambe.DisplayComponent;
import flambe.System;
import game.display.SVGs;
import game.display.WobblyPathComponent;
import temple.components.OnUpdate;
import temple.components.Timeout;
import temple.utils.EntityUtils;

/**
 * @author Mark Knol
 */
class Intro extends Component {
	public function new() {}

	override function onStart() {
		super.onStart();

		final root = System.root;
		final no404 = new Entity()
			.add(new DisplayComponent()
				.setXY(sceneMiddlePosition.x, 220));

		for (path in SVGs.getNumber(4)) {
			no404.add(new Entity().add(new WobblyPathComponent({
				color: PINK,
				path: scalePath(7, path),
			}, {
				smooth1: Std.random(3),
				smooth2: 2,
			})
				.setXY(-175, 50)
				.makeInteractive()));
		}
		for (path in SVGs.getNumber(4)) {
			no404.add(new Entity()
				.add(new WobblyPathComponent({
					color: PINK,
					path: scalePath(7, path),
				}, {
					smooth1: Std.random(3),
					smooth2: 2,
				})
					.setXY(190, 50)
					.makeInteractive()));
		}
		for (idx => path in SVGs.getNumber(0)) {
			var zero:Entity;
			no404.add(zero = new Entity()
				.add(new WobblyPathComponent({
					color: GRAY,
					path: scalePath(5, path),
				}, {
					smooth1: idx + 1,
					smooth2: 2,
				})
					.setXY(0, 50)
					.makeInteractive()));
			if (idx == 1) {
				addDots(zero, 8, GRAY);
			}
		}

		for (_ => path in SVGs.OWNER) {
			no404.add(new Entity().add(new WobblyPathComponent({
				color: GRAY,
				path: path,
			})
				.makeInteractive()
				.setAngle(-0.05)
				.setXY(0, sceneMiddlePosition.y.half())));
		}
		root.add(no404);

		final button = new Entity().add([
			// head
			new WobblyPathComponent({
				color: PINK,
				path: getRect(450, 140),
			},
				{
					normalize1: 25,
					normalize2: 15,
					smooth1: 6,
					smooth2: 0,
				})
				.setAlpha(.8)
				.setXY(sceneMiddlePosition.x, sceneSize.y * 0.79)
				.makeInteractive(),
			new OnUpdate((owner, dt) -> {
				if (owner.get(WobblyPathComponent).isPointerDown) {
					var children = EntityUtils.getChildrenAsArray(root);
					for (_ => child in children) {
						var children = EntityUtils.getChildrenAsArray(child);
						for (idx => child in children)
							Timeout.create(root, (1 - idx / children.length) * 0.5, child.dispose);
					}
					Timeout.create(root, 1.0, () -> {
						root.disposeChildren();
						root.add(new Entity().add(new Game()));
					});
				}
			}),
		]);
		for (path in SVGs.START) {
			final letter = new Entity().add(new WobblyPathComponent({
				color: GRAY,
				path: path,
			}));

			button.add(letter);
			addDots(letter, 4, GRAY);
		}
		root.add(button);
	}
}
