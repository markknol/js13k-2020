package temple.components;

import flambe.Entity;
import flambe.util.Disposable;
import temple.components.AutoDisposer;

/**
 * @author Mark Knol
 */
class Timeout {
	public static inline function create(owner:Entity, delay:Float = 0, onComplete:Void->Void, append:Bool = true):Disposable {
		var entity = new Entity()
			.addComponent(new AutoDisposer(delay, onComplete));
		owner.addEntity(entity, append);

		return entity;
	}
}
