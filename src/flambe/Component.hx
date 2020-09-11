//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt
package flambe;

import flambe.util.Disposable;

/**
 * Components are bits of data and logic that can be added to entities.
 */
#if (!macro)
@:autoBuild(flambe.platform.ComponentBuilder.build())
#end
@:componentBase
class Component implements Disposable {
	// Component flags
	@:allow(flambe) static inline var STARTED = 1 << 0;
	private static inline var NEXT_FLAG = 1 << 1; // Must be last!

	@:allow(flambe) var _flags:Int = 0;

	/** The entity this component is attached to, or null. */
	@:allow(flambe)
	public var owner(default, null):Entity = null;

	/** The owner's next component, for iteration. */
	@:allow(flambe)
	public var next(default, null):Component = null;

	/**
	 * The component's name, generated based on its class. Components with the same name replace
	 * eachother when added to an entity.
	 */
	public var name(get, null):ComponentName;

	/**
	 * Called after this component has been added to an entity.
	 */
	// public function onAdded():Void {}

	/**
	 * Called just before this component has been removed from its entity.
	 */
	public function onRemoved():Void {}

	/**
	 * Called just before this component's first update after being added. This is the best place to
	 * put initialization logic that requires accessing other components/entities, since it waits
	 * until the rest of the entity hierarchy is accessible.
	 *
	 * Note that onStart may be delayed until the next frame after adding a component, depending on
	 * where in the update step it was added.
	 */
	public function onStart():Void {}

	/**
	 * Called just before this component will be removed from its entity, if onStart was previously
	 * called.
	 */
	public function onStop():Void {}

	/**
	 * Called when this component receives a game update.
	 * @param dt The time elapsed since the last frame, in seconds.
	 */
	public function onUpdate(dt:Float):Void {}

	/**
	 * Removes this component from its owning entity.
	 */
	public function dispose():Void {
		if (owner != null) {
			owner.removeComponent(this);
		}
	}

	private function get_name():ComponentName {
		return null; // Subclasses will automagically implement this
	}
}
