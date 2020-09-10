package temple.utils;

import flambe.Component;
import flambe.ComponentName;
import flambe.DisplayComponent;
import flambe.Entity;

/**
 * @author Mark Knol
 */
class EntityUtils {
	/**
		Puts entity on top of its parent Entity
	**/
	public inline static function bringToTop(entity:Entity):Void {
		entity.parent.addEntity(entity, true);
	}

	/**
		Puts entity on bottom of its parent Entity
	**/
	public inline static function bringToBottom(entity:Entity):Void {
		entity.parent.addEntity(entity, false);
	}

	/**
		Gets child at certain index from given Entity
	**/
	public static function getChildAt(entity:Entity, index:Int):Entity {
		if (entity == null) return null;
		var count = 0;
		var child = entity.firstChild;
		if (index == count) return child;
		while (child != null) {
			count++;
			child = child.next;
			if (index == count) return child;
		}
		return null;
	}

	public static inline function iter(entity:Entity, onEach:Entity->Void) {
		var child = entity.firstChild;
		while (child != null) {
			var next = child.next;
			onEach(child);
			child = next;
		}
	}

	/**
		Gets child index of given Entity. Must be attached to a parent, otherwise `null` is returned.
	**/
	public static function getIndex(entity:Entity):Null<Int> {
		if (entity == null || entity.parent == null) return null;
		var index = 0;
		var child = entity.parent.firstChild;
		while (child != null) {
			if (child == entity) return index;
			index++;

			child = child.next;
		}
		return null;
	}

	/**
		Gets total count of child entities+components of given entity
	**/
	public static function getEntityStats(entity:Entity, stats:EntityStats = null):EntityStats {
		if (stats == null) stats = {components: 0, entities: 0, displays: 0};

		if (entity == null) return stats;

		if (entity.has(DisplayComponent)) stats.displays++;
		stats.components += getComponentCount(entity, false);

		var child = entity.firstChild;
		while (child != null) {
			stats.entities++;
			getEntityStats(child, stats);
			child = child.next;
		}
		return stats;
	}

	/**
		Gets total count of child entities of given entity
	**/
	public static function getEntityCount(entity:Entity, recursive:Bool = false):Int {
		if (entity == null) return 0;
		var count = 0;
		var child = entity.firstChild;
		while (child != null) {
			count++;
			if (recursive) count += getEntityCount(child, recursive);
			child = child.next;
		}
		return count;
	}

	/**
		Gets total count of child entities of given entity
	**/
	public static function getChildrenAsArray(entity:Entity):Array<Entity> {
		var children = [];
		if (entity == null) return children;
		var child = entity.firstChild;
		while (child != null) {
			children.push(child);
			child = child.next;
		}
		return children;
	}

	/**
		Gets total count of components of given entity
	**/
	public static function getComponentCount(entity:Entity, recursive:Bool = false):Int {
		if (entity == null) return 0;
		var count = 0;
		var component = entity.firstComponent;
		while (component != null) {
			count++;
			component = component.next;
		}

		if (recursive) {
			var child = entity.firstChild;
			while (child != null) {
				count += getComponentCount(child, recursive);
				child = child.next;
			}
		}
		return count;
	}

	/**
	 * @return first entity with given component from list. `null` if nothing is found.
	**/
	public static function getEntityWithComponent(entities:Iterable<Entity>, componentName:ComponentName):Entity {
		for (entity in entities) {
			var component = entity.getByName(componentName);
			if (component != null) return entity;
		}
		return null;
	}

	/**
	 * Filter list of entities
	 * @return matched entities with given component. returns empty array if nothing is found.
	**/
	public static inline function getEntitiesWithComponent(entities:Iterable<Entity>, componentName:ComponentName):Array<Entity> {
		return [for (entity in entities) if (entity.getByName(componentName) != null) entity];
	}

	/**
	 * Gets list of components found inside children of given entity.
	 *
	 * Note: If you only need one component, consider just using `entity.getFromChildren`.
	 */
	static public inline function getComponentsFromChildren<A:Component>(entity:Entity, componentName:ComponentName, depth:Int = 1):Array<A> {
		return getEachComponent(entity, componentName, depth, 0);
	}

	/**
		Sorts an entity using specific components from children and given sort function.
		This is fast since it doesn't use `addChild` or `removeChild`.

		```
		// Example: Sort on sprite x
		EntityUtils.depthSort(myEntity, Sprite.NAME, function(a:Sprite, b:Sprite) return FMath.sign(a.x._ - b.x._));
		```
	**/
	@:access(flambe.Entity)
	public static function depthSort<T:Component>(target:Entity, componentName:ComponentName, sortFunc:T->T->Int) {
		var components:Array<T> = [];
		var rest:Array<Entity> = null;

		var child = target.firstChild;
		while (child != null) {
			var component = child.getByName(componentName);
			if (component != null) {
				components.push((cast component : T));
			} else {
				if (rest == null) rest = [];
				// collect anything that doesnt match componentName
				rest.push(child);
			}
			child = child.next;
		}
		components.sort(sortFunc);

		// reset first child of target since we're rebuilding the linked list
		target.firstChild = null;

		// prepend entities with matched components
		var layerIndex = components.length;
		if (rest != null) layerIndex += rest.length;

		while (components.length != 0) {
			var entity = components.pop().owner;
			entity.layerIndex = --layerIndex;
			entity.next = target.firstChild;
			target.firstChild = entity;
		}

		// prepend unmatched entities
		if (rest != null) while (rest.length != 0) {
			var entity = rest.pop();
			entity.layerIndex = --layerIndex;
			entity.next = target.firstChild;
			target.firstChild = entity;
		}

		return target;
	}

	static private function getEachComponent<A:Component>(entity:Entity, componentName:ComponentName, depth:Int, currentDepth:Int):Array<A> {
		var result:Array<A> = new Array<A>();
		var child:Entity = entity.firstChild;

		while (child != null) {
			if (depth > currentDepth) {
				result = result.concat(getEachComponent(child, componentName, depth, currentDepth++));
			}

			var component:A = cast child.getByName(componentName);
			if (component != null) {
				result.push(component);
			}

			child = child.next;
		}

		return result;
	}
}

typedef EntityStats = {components:Int, entities:Int, displays:Int};
