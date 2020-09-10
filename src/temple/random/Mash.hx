package temple.random;

/**
 * @author Pieter van de Sluis
 *
 * From http://baagoe.com/en/RandomMusings/javascript/
 * Johannes Baagøe <baagoe@baagoe.com>, 2010
 *
 * Used in generating random PRNGs
 */
class Mash {
	var n:Float = 0xefc8249d;

	public function new() {}

	public function update(data:Any):Float {
		var dataString = Std.string(data);

		for (i in 0...dataString.length) {
			n += dataString.charCodeAt(i);
			var h:Float = 0.02519603282416938 * n;
			n = Std.int(h) >>> 0;
			h -= n;
			h *= n;
			n = Std.int(h) >>> 0;
			h -= n;
			n += h * 4294967296; // 2^32
		}
		return (Std.int(n) >>> 0) * 2.3283064365386963e-10; // 2^-32
	};
}
