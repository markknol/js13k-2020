package game.display;

import flambe.DisplayComponent;
import flambe.util.SignalConnection;
import flambe.util.Value;
import game.display.SVGs;

/**
 * @author Mark Knol
 */
class ScoreComponent extends DisplayComponent {
	private var color:Color;
	private var score:Value<Int>;
	@:disposable private var _connection:SignalConnection;

	public function new(color, score) {
		super();
		this.color = color;
		this.score = score;
	}

	override function onStart() {
		_connection = this.score.watch((to, from) -> {
			owner.disposeChildren();
			var scoreValue = '$to';
			for (charPos in 0...scoreValue.length) {
				var charNo = Std.parseInt(scoreValue.charAt(charPos));
				for (path in SVGs.getNumber(charNo)) {
					owner.add(new Entity().add(new WobblyPathComponent({
						color: color,
						path: scalePath(1.5, path),
					})
						.makeInteractive()
						.setXY((charPos - (scoreValue.length / 2)) * 45, 0)));
				}
			}
		});
	}
}
