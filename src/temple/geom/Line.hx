package temple.geom;

import flambe.math.FMath;
import temple.geom.Vector2;

/**
 * @author Pieter van de Sluis
 */
class Line {
	public var point1(default, null):Vector2;
	public var point2(default, null):Vector2;

	public inline function new(?point1:Maybe<Vector2>, ?point2:Maybe<Vector2>) {
		this.point1 = point1.or(Vector2.empty());
		this.point2 = point2.or(Vector2.empty());
	}

	/** Set values of point1 with given components **/
	public inline function setPoint1(x:Float, y:Float):Line {
		this.point1.x = x;
		this.point1.y = y;
		return this;
	}

	/** Set values of point2 with given components **/
	public inline function setPoint2(x:Float, y:Float):Line {
		this.point2.x = x;
		this.point2.y = y;
		return this;
	}

	/** Translate both point positions with given components **/
	public inline function translate(x:Float, y:Float):Line {
		point1.x += x;
		point1.y += y;

		point2.x += x;
		point2.y += y;
		return this;
	}

	public inline function lineSegmentIntersection(targetLine:Line, ?result:Vector2):Bool {
		return FMath.lineSegmentIntersection(this.point1, this.point2, targetLine.point1, targetLine.point2, result);
	}

	public inline function lineIntersection(targetLine:Line, ?result:Vector2):Bool {
		return FMath.lineIntersection(this.point1, this.point2, targetLine.point1, targetLine.point2, result);
	}

	public inline function getAngle():Float {
		// return point1.angleTo(point2);
		return Math.atan2(this.point2.y - this.point1.y, this.point2.x - this.point1.x);
	}

	/** Copy component values from `target` line to `this` line. **/
	public inline function copyFromLine(target:Line):Line {
		this.setPoint1(target.point1.x, target.point1.y);
		this.setPoint2(target.point2.x, target.point2.y);
		return this;
	}

	/** Copy component values from `target` line to `this` line. **/
	public inline function copyFromVectors(point1:Vector2, point2:Vector2):Line {
		this.setPoint1(point1.x, point1.y);
		this.setPoint2(point2.x, point2.y);
		return this;
	}

	/** Clone `this` line into new Line instance. Inner points are also cloned. **/
	public inline function clone():Line {
		return new Line(point1.clone(), point2.clone());
	}
}
