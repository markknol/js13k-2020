package flambe.platform;

import flambe.System;

using flambe.util.BitSets;

/**
 * Updates all components and renders.
 */
class MainLoop {
	public var enabled:Bool = true;

	public function new() {}

	public function update(dt:Float) {
		if (!enabled) return;

		if (dt <= 0) {
			// This can happen on platforms that don't have monotonic timestamps and are prone to
			// system clock adjustment
			// trace("Zero or negative time elapsed since the last frame!", ["dt", dt]);
			return;
		}
		if (dt > 1) {
			// Clamp deltaTime to a reasonable limit. Games tend not to cope well with huge
			// deltaTimes. Platforms should skip the next frame after unpausing to prevent sending
			// huge deltaTimes, but not all environments support detecting an unpause
			dt = 1;
		}

		updateEntity(System.root, dt);
		System.renderer.render(System.root);
	}

	private static function updateEntity(entity:Entity, dt:Float) {
		// Handle update time scale adjuster
		var timeScaleAdjuster:TimeScaleAdjuster = entity.get(TimeScaleAdjuster);
		if (timeScaleAdjuster != null) {
			timeScaleAdjuster._realDt = dt;
			dt *= timeScaleAdjuster.scale._;

			if (dt <= 0) {
				// This entity is paused, avoid descending into children. But do update the speed
				// adjuster (so it can still be animated)
				timeScaleAdjuster.onUpdate(dt);
				return;
			}
		}

		// Update components
		var p:Component = entity.firstComponent;

		while (p != null) {
			var next = p.next;
			if (entity.parent != null || entity == System.root) {
				if (!p._flags.contains(Component.STARTED)) {
					p._flags = p._flags.add(Component.STARTED);
					p.onStart();
				}
				p.onUpdate(dt * entity.timeScale);
			}
			p = next;
		}

		// Update children
		var index = 0;
		var p = entity.firstChild;
		while (p != null) {
			var next = p.next;
			p.layerIndex = index++; // update layer index
			updateEntity(p, dt * entity.timeScale);
			p = next;
		}
	}
}
