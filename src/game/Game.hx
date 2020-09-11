package game;

import flambe.*;
import flambe.math.FMath;
import game.Color;
import game.display.*;
import game.elements.*;
import haxe.ds.ReadOnlyArray;
import js.html.SpeechSynthesisUtterance;
import js.lib.Math;
import music.*;
import temple.components.Cooldown;
import temple.geom.Vector2;
import temple.random.Random;

/**
 * @author Mark Knol
 */
class Game extends Component {
	public final moments:Entity = new Entity();
	public final soundPlayer:AudioPlayer;
	
	private final _scheduler:AudioScheduler = new AudioScheduler();
	private final _soundPlayerCooldown:Cooldown = new Cooldown(1.0);
	
	private final _theWord:js.html.SpeechSynthesisUtterance;
	private final _randomElementCooldown:Cooldown = new Cooldown(1.0);
	
	///private var _lines = ["4 0 4!", "I think you've found it"];
	
	private var _lines = ["4 0 4!", "I think you've found it", "Passing moments",
	"You have to capture.", "Surround them.", "But do not judge", "What do you choose?", "Red or green? Big or small? A lot or nothing?",
	"We are all sensitive, vulnerable.", "But the truth is:", "This is it!", 
	"This is about you", "about perspective", "You are here.", "Wandering around.",
	"Flying through the space that we call space.", "Capturing", "Once you fly, You decide what you are looking for.",
	"Take this journey. Take everything! Take nothing!", "You can't get away from your heart",
	"Live in the mystery", "Live in the moment!", "You will find it!", "This is the memory!",
	"You have found!", "A brand new story.", "Somehow..", "Someday!", "4 0 4!"];
	
	
	private var _progress:Float = 0.0;
	private var _progressTarget:Float = 0.0;
	private var _totalWords:Int;
	private var _totalWordsCollected:Int = 0;
	
	private final _isSpeechSynesisSupported:Bool;
	
	private final _progressBar:ProgressBar = new ProgressBar(sceneSize.x - 50);
	private final _textCooldown = new Cooldown(4.0);
	private final _player:Snake = new Snake();
	
	public function new() {
		this.soundPlayer = new AudioPlayer(System.audioContext, createMusic);
		_theWord = try new SpeechSynthesisUtterance() catch (e) null;
		_isSpeechSynesisSupported = _theWord != null;
		
		_totalWordsCollected = 0;
		_totalWords = 0;
		for (line in _lines) {
			_totalWords += line.split(" ").length;
		}
	}

	override function onStart() {
		super.onStart();
		
		owner.add(moments);
		owner.addEntity(new Entity()
			.addComponent(_player));
			
		owner.addEntity(new Entity()
			.addComponent(new WobblyRect(200, 80)
				.setXY(175 - 25, 75)
				.setAlpha(0.5)));
		
		owner.addEntity(new Entity()
			.addComponent(new WobblyRect(200, 80)
				.setXY(sceneSize.x - 125 - 25, 75)
				.setAlpha(0.5)));
		
		owner.addEntity(new Entity()
			.add(new ScoreComponent(RED, _player.collection.value1)
				.setXY(175, 85)));
		
		owner.addEntity(new Entity()
			.add(new ScoreComponent(GREEN, _player.collection.value2)
				.setXY(sceneSize.x - 125, 85)));
		
		owner.addEntity(new Entity()
			.add(_progressBar
				.setXY(25, sceneSize.y - 30)));
	}

	override public function onUpdate(dt:Float):Void {
		super.onUpdate(dt);
		
		var isSpeaking = (_isSpeechSynesisSupported && window.speechSynthesis.speaking);
		if (!_isSpeechSynesisSupported) isSpeaking = false;
		
		if (!isSpeaking && _textCooldown.update(dt)) {
			if (_lines.length > 0) {
				final text = _lines.shift();
				if (_isSpeechSynesisSupported) {
					_theWord.text = text;
					_theWord.lang = 'en-US';
					_theWord.rate = 0.75;
					// say it
					window.speechSynthesis.speak(_theWord);
				}
				
				var words = text.split(" ");
				for (i in 0...words.length) {
					if (i % 2 == 0) {
						// we share the same colors, still we are different
						final size:Vector2 = [Random.native.range(20, 150), Random.native.range(20, 150)];
						// do not judge me
						moments.addEntity(getMoment(
							RED,
							size,
							[sceneSize.x + 100, Random.native.range(200, sceneSize.y - 200)],
							[Random.native.range(-1, -4) * 60, Random.native.range(-40, 40)]
						).add(new Moment(true, size.length))
							.map((d:DisplayComponent) -> if (Math.random() > 0.5) addDots(d.owner, 1+Std.random(5), RED)));
					} else {
						// do not judge me neither
						final size:Vector2 = [Random.native.range(20, 150), Random.native.range(20, 150)];
						moments.addEntity(getMoment(
							GREEN,
							size,
							[sceneSize.x + 100, Random.native.range(200, sceneSize.y - 200)],
							[Random.native.range(-1, -4) * 60, Random.native.range( -40, 40)]
						)
						.add(new Moment(false, size.length))
						.map((d:DisplayComponent) -> if (Math.random() > 0.5) addDots(d.owner, 1+Std.random(5), GREEN)));
					}
				}
				
				_totalWordsCollected += words.length;
				_progressTarget = _totalWordsCollected / _totalWords;
				
				// take a breath
				_textCooldown.reset(_isSpeechSynesisSupported ? 1.5 + Math.random() : 4.5);
			} else {
				_player.kill();
				_textCooldown.disable();
			}
		}
		
		if (!_player.isDead && _soundPlayerCooldown.update(dt)) {
			_scheduler.update(soundPlayer, soundPlayer.audioContext.currentTime);
			_soundPlayerCooldown.reset(1.0);
		}
	
		if (_randomElementCooldown.update(dt)){
			owner.addEntity(getRandomElement(
				GRAY,
				[10 + Std.random(30), 10+ Std.random(30)],
				[sceneSize.x + 30, Random.native.range(100, sceneSize.y - 30)],
				[Random.native.range(-1, -4) * 60, Random.native.range( -40, 40)]
			));
			_randomElementCooldown.reset(1 + Math.random());
		}
		_progress += FMath.lerpMoveTo(_progress, _progressTarget, dt, 5.0);
		_progressBar.setProgress(_progress);
		
	}

	public function getMoment(color:Color, size:Vector2, position:Vector2, velocity:Vector2):Entity {
		return new Entity().add([
			new WobblyPathComponent({
				color: color,
				path: getRect(size.x, size.y),
			}, {
				normalize1: 5,
				normalize2: 5,
				smooth1: Random.native.or(1,2),
				smooth2: Random.native.intRange(1,5),
				addScareComponent: false,
			})
				.setAngle(Math.random()*4)
				.setXY(position.x, position.y),
			new Force(velocity),
			new RandomizePath(),
			new AutoRemover(200),
		]);
	}

	public function getRandomElement(color:Color, size:Vector2, position:Vector2, velocity:Vector2):Entity {
		return new Entity().add([
			new WobblyPathComponent({
				color: color,
				path: Random.native.or(
					Random.native.or(getTriangle(Random.native.intRange(10, 35)), getRect(10, 35)),
					Random.native.or(SVGs.getNumber(6).first(), SVGs.getNumber(8).first())
				),
			}, {
				smooth1: Random.native.or(1,2),
				smooth2: Random.native.intRange(1, 5),
				addScareComponent: false,
			})
				.setAlpha(Random.native.range(0.4, 0.5))
				.setAngle(Math.random()*4)
				.setXY(position.x, position.y),
			new Force(velocity),
			new RandomizePath(),
			new AutoRemover(200),
		]).map((p:WobblyPathComponent) -> p.isScared = true);
	}

	private function createMusic() {
		final chords:ReadOnlyArray<Array<AudioNote>> = [
			[C, G], [G, D],
			[C, E, G], [C, E, G], [C, E, G, B],
			[E, G, B], [F, A, C], [G, B, D],  
			[B, D, F, A],
			[C, F, G], [C, D, G], [C, DSharp, G],
			[G, C, D],
		];

		final totalChords = 97;
		var delay = 0.0;
		for (i in 0 ... totalChords) {
			final r = i / totalChords;
			final notes = chords[Std.random(chords.length)];
			
			notes.sort((_, _) -> Std.random(2) - 1);
			final duration = (0.5 + Std.random(4) / 2) * 0.5;
			_scheduler.add(delay, time -> {
				final notes = notes.map(note -> new AudioPitchedNote(note, Std.random(5)).getMidi());
				soundPlayer.playNotes(Math.random() > r, notes, duration, time);
			});
			
			if (Math.random() < r) {
				notes.sort((_, _) -> Std.random(2) - 1);
				final duration = (0.5 + Std.random(4) / 2) * 0.5;
				
				_scheduler.add(delay + (notes.length - 2) * duration, time -> {
					final notes = notes.map(note -> new AudioPitchedNote(note, 3 + Std.random(5)).getMidi());
					soundPlayer.playNotes(false, notes, duration, time);
				});
			}
			delay += duration * 2;
		}
		_scheduler.update(soundPlayer, soundPlayer.audioContext.currentTime);
	}

	public inline function end() {
		System.root.add(new Entity().add(new Outro()));
		// window.location.reload.bind(false);
	}
	
}