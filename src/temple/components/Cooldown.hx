package temple.components;

/**
 * Inlined float cooldown. Optimal performance since it doesnt allocate an object.
 * Cannot be stored in maps/arrays since its just a abstract type; Use HeavyCooldown instead if thats a requirement.
 *
 * @author Mark Knol
 */
abstract Cooldown(Null<Float>) {
	/**
	 * Get current cooldown time
	 */
	public var time(get, never):Float;

	/**
	 * Check if cooldown time < 0. Returns false if disabled.
	 */
	public var isExpired(get, never):Bool;

	/**
	 * - If enabled, the cooldown can expire.
	 * - If not enabled, the cooldown will not expire.
	 */
	public var isEnabled(get, never):Bool;

	public inline function new(time:Float = null) {
		this = time;
	}

	/**
	 * Enables and resets cooldown to given time
	 */
	public inline function reset(time:Float) {
		this = time;
	}

	/**
	 * Should be called every time in onUpdate of components.
	 * @return true when expired
	**/
	public inline function update(dt:Float):Bool {
		return isEnabled && ((this -= dt) <= 0);
	}

	/**
	 * @return true when enabled
	**/
	private inline function get_isEnabled() {
		return this != null;
	}

	/**
	 * @return true when expired
	**/
	private inline function get_isExpired() {
		return isEnabled && this <= 0;
	}

	public inline function disable() {
		this = null;
	}

	private inline function get_time():Float return this;
}
