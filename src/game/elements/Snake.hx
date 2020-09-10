package game.elements;

import flambe.System;
import flambe.math.FMath;
import flambe.util.Value;
import game.Game;
import game.display.PathComponent;
import game.display.PathFollower;
import game.display.WobblyPathComponent;
import game.elements.Moment;
import js.html.CanvasRenderingContext2D;
import music.AudioNote;
import temple.components.AutoDisposer;
import temple.geom.Line;
import temple.geom.Vector2;
import temple.random.Random;
import temple.components.Cooldown;

/**
 * @author Mark Knol
 */
class Snake extends PathComponent {
	@:component(parents) var _game:Game;
	
	public var isDead:Bool = false;
	
	private final _targetUpdateCooldown:Cooldown = new Cooldown(0.001);
	private final _growCooldown:Cooldown = new Cooldown(.2);
	private final _target:Vector2 = new Vector2(0,0);
	private var _head1:WobblyPathComponent;
	private var _head2:WobblyPathComponent;
	
	private final _pathThickness:Map<Vector2, Float> = [];
	
	public var collection = {
		amount1: new Value(0),
		value1: new Value(0),
		amount2: new Value(0),
		value2: new Value(0),
	}
	
	public function new() {
		var t = 40;
		super({
			isClosedPath: false,
			color: GRAY,
			path: [for(i in 0...t) sceneMiddlePosition + [Math.sin(i/t*Math.PI*2) * 200, Math.cos(Math.sin(i/t)*Math.PI*2) * 200]],
		});
	}
	
	public function kill() {
		if (!isDead) {
			isDead = true;
		}
	}

	override function onStart() {
		super.onStart();
		data.isClosedPath = true;
		
		owner.addEntity(new Entity().add([
			new PathFollower(0.5, false),
			_head1 = cast new WobblyPathComponent({
				color: data.color,
				path: getSquare(34)
			}).setAngle(Math.PI/4)
		]));
		owner.addEntity(new Entity().add([
			new PathFollower(0.5, false),
			_head2 = cast new WobblyPathComponent({
				color: data.color,/*"135, 44, 18",*/
				path: getSquare(24)
			}).setAngle(Math.PI/4)
		]));
		addDots(owner, 8, GRAY);
		
		_target.copy(sceneMiddlePosition); 
		//addDots(owner, 20, data.color);
		
		var smooth1 = 2 + Std.random(3);
		var smooth2 = 2 + Std.random(3);
		
		this.updateModifiers.push(normalizePath.bind(15.0));
		//this.updateModifiers.push(simplifyPath.bind(0.999));
		this.updateModifiers.push(smoothPath.bind(smooth1, false));
		this.updateModifiers.push(randomizePath.bind(1.0));
		this.updateModifiers.push(path -> this._pathToTest = path);
		this.updateModifiers.push(extrude.bind(r -> 0.75 + (r *.5) * 35));
		this.updateModifiers.push(smoothPath.bind(smooth2, false));
		this.updateModifiers.push(randomizePathAngle.bind(2.0));
	}
	
	override function onUpdate(dt:Float) {
		this.data.path = movePathAway(dt, data.path);
		
		if (!isDead) {
			_target.copy(System.renderer.pointerPosition);
		} else {
			_target.copy(sceneMiddlePosition);
		}
	
		//detectLoopCollision();
		if (_growCooldown.update(dt)) {
			var head = data.path.last().clone();
			var diff = (_target - head);
			var angle = diff.angle();
			if (diff.length > 40) {
				head.moveTo(angle, 40);
				data.path.push(head);
				data.path.shift();
			}
			_head1.rotation = angle;
			_head2.rotation = angle;
			_growCooldown.reset(1/40);
		}
		
		if (isDead) {
			alpha *= (1 - dt / 2);
			if (alpha < 0.1) {
				if (!owner.has(AutoDisposer)) {
					owner.add(new AutoDisposer(_game.end));
				}
			}
		}
		
		super.onUpdate(dt);
		
		if (!isDead) {
			detectLoopCollision();
		}
	}
	
	private var _line1:Line = new Line();
	private var _line2:Line = new Line();
	private function detectLoopCollision():Bool {
		#if debug_collision
		_linesTest.clear();
		#end
		
		var path = _pathToTest;
		for (id1 in 0...path.length - 2) {
			_line1.copyFromVectors(path[id1], path[id1 + 1]);
			for (id2 in id1 + 2 ... path.length - 1) {
				_line2.copyFromVectors(path[id2], path[id2 + 1]);
				if (_line1.lineSegmentIntersection(_line2)) {
					/*var id1 = id1;
					var id2 = id2;
					if (id2 < id1) {
						var tmp = id1;
						id1 = id2;
						id2 = tmp;
					}*/
					
					for(_ in 0...3) {
					
						var rndId1 = Random.native.intRange(id1, id2 + 1);
						var rndId2 = Random.native.intRange(id1, id2 + 1);
						
						var id1 = FMath.min(rndId1, rndId2);
						var id2 = FMath.max(rndId1, rndId2);
						if (id1 == id2) continue;
						
						//for (idx in id1...id2+1) {
							var a = path[id1];
							var b = path[id2];
							if (b != null && a != b) {
								_line2.copyFromVectors(a, b);
								
								#if debug_collision
								_linesTest.push(_line2.clone());
								#end
								
								if (testLineToElementCollision(_line2)) {
									return true;
								}
							}
						//}
					}
				}
			}
		}
		//trace("loops: " +  loops);
		return false;
	}
	#if debug_collision
	private var _linesTest:Array<Line> = [];
	#end
	
	private var _hittestLine:Line = new Line();
	private var _intersectionPoint:Vector2 = [0, 0];
	private var _pathToTest:Path;
	
	private function testLineToElementCollision(line:Line):Bool {
		var child = _game.moments.firstChild;
		while (child != null) {
			var next = child.next;
			var hasHit = false;
			child.map((pathComponent:PathComponent, element:Moment) -> {
				if (!element.isDead) {
					var path = pathComponent.data.path;
					var position = pathComponent.position;
					for (idx => currPathPos in path) {
						var nextPathPos = path[idx + 1];
						if (nextPathPos != null) {
							_hittestLine.copyFromVectors(currPathPos + position, nextPathPos + position);
							#if debug_collision
							_linesTest.push(_hittestLine.clone());
							#end
							if (line.lineSegmentIntersection(_hittestLine, _intersectionPoint)) {
								hasHit = true;
								var element = child.get(Moment);
								if (element.one) {
									collection.amount1._ ++;
									collection.value1._ += element.value;
									playSound(Random.native.or(C,E));
								} else {
									collection.amount2._ ++;
									collection.value2._ += element.value;
									playSound(Random.native.or(G,B));
								}
								
								element.kill();
								break;
							}
						}
					}
				}
			});
			if (hasHit) {
				return true;
			}
			child = next;
		}
		return false;
	}
	
	private function playSound(note:AudioNote):Void {
		_game.soundPlayer.playNote(note.toMidi(Random.native.or(6,7)), _game.soundPlayer.audioContext.currentTime, 0.3);
	}
	
	#if debug_collision
	override function draw(ctx:CanvasRenderingContext2D):Void {
		super.draw(ctx);
		
		ctx.save();
		ctx.strokeStyle = "rgba(255,0,0,.5)";
		ctx.lineWidth = 1;
		
		for (l in _linesTest) {
			ctx.beginPath();
			ctx.moveTo(l.point1.x, l.point1.y);
			ctx.lineTo(l.point2.x, l.point2.y);
			ctx.stroke();
		}
		ctx.restore();
	}
	#end
}