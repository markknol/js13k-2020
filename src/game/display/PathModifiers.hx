package game.display;

import flambe.Component;
import flambe.math.FMath;
import game.display.PathComponent;
import temple.random.Random;

/**
 * @author Mark Knol
 */
class PathModifiers extends Component {

	public static function normalizePath(minDist:PathModifierParam<Float>, path:Path) {
		var minDist = minDist();
		final newPath = [];
		//var  prev = path.first().clone();
		//newPath.push(prev);
		for (i in 1 ... path.length) {
			var prev = path[i-1].clone();
			var curr = path[i].clone();
			var delta = curr - prev;
			var l = delta.length;
			var a = delta.angle();
			while (l > minDist) {
				prev.x += Math.cos(a) * minDist;
				prev.y += Math.sin(a) * minDist;
				newPath.push(prev.clone());
				l -= minDist;
			}
		}
		return newPath;
	}

	public static function simplifyPath(minAngle:PathModifierParam<Float>, path:Path) {
		var minAngle = minAngle();
		var idx = 0;
		while (idx < path.length - 1) {
			var prev = path[idx ==0 ? path.length-1 : idx-1];
			var curr = path[idx];
			var p0 = (prev - curr).normalize();
			
			var idx2 = idx + 1;
			while (true) {
				var next = path[idx2];
				if (next == null) break;
				
				var p1 = (curr - next).normalize();
				
				if (p1.dot(p0) > minAngle) {
					path.remove(next);
				} else {
					break;
				}
			}
			idx++;
		}
		return path;
	}

	public static function closePath(path:Path) {
		path.push(path.first());
		return path;
	}
	
	public static function smoothPath(smoothness:PathModifierParam<Int>, wrap:Bool, path:Path) {
		var smoothness = smoothness();
		for (_ in 0 ... smoothness) {
			for(idx => pos in path) {
				var prevPos = idx == 0  ? (if (wrap) path[path.length-1] else path[idx]) : path[idx-1];
				path[idx] = (prevPos + pos) * 0.5;
			}
		}
		return path;
	}
	
	public static function clonePath(path:Path) {
		return [for(p in path) p.clone()];
	}
	
	public static function randomizePath(amount:PathModifierParam<Float>, path:Path) {
		var amountX = amount();
		var amountY = amount();
		for (idx => pos in path) {
			pos.x += -amountX / 2 + amountX * Math.random();
			pos.y += -amountY / 2 + amountY * Math.random();
		}
		return path;
	}
	
	public static function scalePath(amount:Float, path:Path) {
		if (path == null) return [];
		for (pos in path) {
			pos *= amount;
		}
		return path;
	}
	
	public static function randomizePathSin(time:PathModifierParam<Float>, amount:PathModifierParam<Float>, path:Path) {
		for (idx => pos in path) {
			pos.x += Math.sin(time()) * amount();
			pos.y += Math.cos(time()) * amount();
		}
		return path;
	}
	
	public static function randomizePathAngle(amount:PathModifierParam<Float>, path:Path) {
		var amountX = amount();
		var amountY = amount();
		var halfPi = Math.PI.half();
		var quartPi = halfPi.half();
		for (idx => pos in path) {
			if (idx > 0) {
				var prevPos = path[idx - 1];
				switch (idx % 4) {
					case 0 | 2:
						var angle = (pos - prevPos).angle() + (((idx/2) % 2 == 0 ? -1 : 1) * halfPi);
						pos.x += Math.cos(Random.native.range(angle-quartPi, angle+quartPi)) * amountX;
						pos.y += Math.sin(Random.native.range(angle-quartPi, angle+quartPi)) * amountY;
					case _:
				}
				
			} else {
				pos.x += -amountX / 2 + amountX * Math.random();
				pos.y += -amountY / 2 + amountY * Math.random();
			}
		}
		return path;
	}
	
	public static function movePathAway(dt:Float, path:Path):Path {
		for (idx => curr in path) {
			var r = 1 - FMath.clamp01(idx*1.25 / path.length);
			curr += [-5 * r * dt * 60, 0];
		}
		return path;
	}
	
	public static function extrude(thickness:(t:Float) -> Float, path:Path):Path {
		var newPath = [];
		
		function extrudePathSide(forward:Bool) {
			for (idx => curr in path) {
				var thickness = thickness(idx / path.length);
				//if (!forward) thickness = 1 - thickness;
				var addAngle = Math.PI.half();
				if (!forward) addAngle *= -1;
				if (idx == 0) {
					var next = path[idx + 1];
					var diff = (next - curr);
					var angle = diff.angle() + addAngle;
					var ribbonPos = curr.clone().moveTo(angle, thickness);
					newPath.push(ribbonPos);
				} else {
					var next = path[idx + 1];
					var prev = path[idx - 1];
					if (next == null) {
						next = curr;
					}
					var diff = (next - prev);
					var angle = diff.angle() + addAngle;
					var ribbonPos = curr.clone().moveTo(angle, thickness);
					newPath.push(ribbonPos);
				}
			}
		}
		
		extrudePathSide(true);
		path.reverse();
		extrudePathSide(false);
		
		var halfLength = (newPath.length - 0.25).half();
		var a = newPath[Math.floor(halfLength)];
		var b = newPath[Math.ceil(halfLength)];
		var c = (a + b) / 2;
		newPath.insert(Math.floor(halfLength), c);
		closePath(newPath);
		return newPath;
	}
}