package flambe;

/**
 * @author Mark Knol
 */
abstract ComponentName(String) {
	@:allow(flambe) private inline function new(name:String) this = name;

	public inline function toString() return this;
}
