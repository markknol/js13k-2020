//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt
package flambe;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;

using haxe.macro.ExprTools;
#end

import haxe.ds.Either;
import flambe.Component;
import flambe.util.Assert;
import flambe.util.Disposable;

using Lambda;
using flambe.util.BitSets;

/**
 * A node in the entity hierarchy, and a collection of components.
 *
 * To iterate over the hierarchy, use the parent, firstChild, next and firstComponent fields. For
 * example:
 *
 * ```haxe
 * // Iterate over entity's children
 * var child = entity.firstChild;
 * while (child != null) {
 *     var next = child.next; // Store in case the child is removed in process()
 *     process(child);
 *     child = next;
 * }
 * ```
 */
@:final class Entity implements Disposable {
	#if debug
	private static var INSTANCE_ID:Int = 0;

	/** Debug only identifier of entity. */
	public var instanceId(default, never):Int = INSTANCE_ID++;
	#end

	/** This entity's parent. */
	public var parent(default, null):Entity = null;

	/** This entity's first child. */
	public var firstChild(default, null):Entity = null;

	/** This entity's next sibling, for iteration. */
	public var next(default, null):Entity = null;

	/** This entity's first component. */
	public var firstComponent(default, null):Component = null;

	#if !js
	private var _components:Map<ComponentName, Component> = new Map<ComponentName, Component>();
	#end

	/** This entity's layer index, used for display ordering. Is set each frame by MainLoop. */
	public var layerIndex:Int;

	/** Time scale that is applied as a multiplier to the delta time of all children updates. */
	public var timeScale:Float = 1.0;

	public function new() {}

	/**
	 * Convenience method to set time
	 */
	public function setTimeScale(scale:Float):Entity {
		this.timeScale = scale;
		return this;
	}

	/**
	 * Add a component, entity or array.
	 * @returns This instance, for chaining.
	**/
	public function add(item:EntityOrComponent):Entity {
		switch item {
			case E(entity):
				addEntity(entity);
			case C(component):
				addComponent(component);
			case A(list):
				for (item in list) {
					add(item);
				}
		}
		return this;
	}

	/**
	 * Add a component to this entity. Any previous component of this type will be replaced.
	 * @returns This instance, for chaining.
	 */
	public function addComponent(component:Component):Entity {
		// Remove the component from any previous owner. Don't just call dispose, which has
		// additional behavior in some components (like Disposer).
		if (component.owner != null) {
			component.owner.removeComponent(component);
		}

		var name = component.name;
		var prev = getByName(name);
		if (prev != null) {
			// Remove the previous component under this name
			removeComponent(prev);
		}

		#if js
		js.Syntax.code("{0}[{1}] = {2}", this, name, component);
		#else
		_components[name] = component;
		#end

		// Append it to the component list
		var tail = null, p = firstComponent;
		while (p != null) {
			tail = p;
			p = p.next;
		}
		if (tail != null) {
			tail.next = component;
		} else {
			firstComponent = component;
		}

		component.owner = this;
		component.next = null;
		// component.onAdded();

		return this;
	}

	/**
	 * Remove a component from this entity.
	 * @return Whether the component was removed.
	 */
	public function removeComponent(component:Component):Bool {
		var prev:Component = null, p = firstComponent;
		while (p != null) {
			var next = p.next;
			if (p == component) {
				// Splice out the component
				if (prev == null) {
					firstComponent = next;
				} else {
					prev.owner = this;
					prev.next = next;
				}

				#if js
				// Remove it from the _compMap
				js.Syntax.delete(this, p.name.toString());
				#else
				_components.remove(p.name);
				#end

				// Notify the component it was removed
				if (p._flags.contains(Component.STARTED)) {
					p.onStop();
					p._flags = p._flags.remove(Component.STARTED);
				}
				p.onRemoved();
				p.owner = null;
				p.next = null;
				return true;
			}
			prev = p;
			p = next;
		}
		return false;
	}

	/**
	 * Gets a component of a given type from this entity.
	 */
	#if (display || dox)
	public static function get<A:Component>(self:Entity, componentClass:Class<A>):A return null;
	#else
	macro public static function get<A:Component>(self:ExprOf<Entity>, componentClass:ExprOf<Class<A>>):ExprOf<A> {
		var type = requireComponentType(componentClass);
		var name = macro $componentClass.NAME;
		return needSafeCast(type) ? macro Std.downcast($self.getByName($name),
			$componentClass) : macro $self._internal_unsafeCast($self.getByName($name), $componentClass);
	}
	#end

	/**
	 * Checks if this entity has a component of the given type.
	 */
	#if (display || dox)
	public static function has<A:Component>(self:Entity, componentClass:Class<A>):Bool return false;
	#else
	macro static public function has<A>(self:ExprOf<Entity>, componentClass:ExprOf<Class<A>>):ExprOf<Bool> {
		return macro @:pos(componentClass.pos) $self.get($componentClass) != null;
	}
	#end

	/**
	 * Maps a function to a components.
	 * If one argument is null, callback isn't called.
	 * Arguments should be explicitly typed.
	 *
	 * Example usage:
	 * ```
	 * entity.map((display:DisplayComponent, animator:TransformAnimator) -> trace(display, animator));
	 * ```
	 */
	#if (display || dox)
	public static function map<A:Component>(self:Entity, componentClass:Class<A>, f:haxe.extern.Rest<A>->Void):Entity return self;
	#else
	macro public static function map<A:Component>(self:ExprOf<Entity>, callback:ExprOf<haxe.extern.Rest<A>->Void>):ExprOf<Entity> {
		var asserts:Array<Expr> = [];
		var components:Array<Expr> = [];
		switch callback.expr {
			case EFunction(_, fn):
				for (arg in fn.args) {
					if (arg.type == null) Context.error('Entity.map function requires explicit argument types', self.pos);
					var componentClass = switch arg.type {
						case TPath(p): macro $i{p.name};
						default: null;
					}
					asserts.push(macro if (!scope.has($componentClass)) return scope);
					components.push(macro scope.get($componentClass));
				}
			default:
				Context.error('Entity.map argument "callback" should be a function', self.pos);
		}
		return macro(function(scope:Entity) {
			$b{asserts};
			$callback($a{components});
			return scope;
		})($self);
	}
	#end

	/**
	 * Gets a component of a given type from this entity, or any of its parents. Searches upwards in
	 * the hierarchy until the component is found, or returns null if not found.
	 */
	#if (display || dox)
	public static function getFromParents<A:Component>(self:Entity, componentClass:Class<A>):A return null;
	#else
	macro public static function getFromParents<A>(self:ExprOf<Entity>, componentClass:ExprOf<Class<A>>):ExprOf<A> {
		var type = requireComponentType(componentClass);
		var name = macro $componentClass.NAME;
		return needSafeCast(type) ? macro $self._internal_getFromParents($name,
			$componentClass) : macro $self._internal_unsafeCast($self._internal_getFromParents($name), $componentClass);
	}
	#end

	/**
	 * Gets a component of a given type from this entity, or any of its children. Searches downwards
	 * in a depth-first search until the component is found, or returns null if not found.
	 */
	#if (display || dox)
	public static function getFromChildren<A:Component>(self:Entity, componentClass:Class<A>):A return null;
	#else
	macro public static function getFromChildren<A>(self:ExprOf<Entity>, componentClass:ExprOf<Class<A>>):ExprOf<A> {
		var type = requireComponentType(componentClass);
		var name = macro $componentClass.NAME;
		return needSafeCast(type) ? macro $self._internal_getFromChildren($name,
			$componentClass) : macro $self._internal_unsafeCast($self._internal_getFromChildren($name), $componentClass);
	}
	#end

	/**
	 * Gets a component by name from this entity.
	 */
	inline public function getByName(name:ComponentName):Component {
		#if js
		return js.Syntax.code("{0}[{1}]", this, name.toString());
		#else
		return _components[name];
		#end
	}

	/**
	 * Adds a child to this entity.
	 * @param append Whether to add the entity to the end or beginning of the child list.
	 * @returns This instance, for chaining.
	 */
	public function addEntity(entity:Entity, append:Bool = true):Entity {
		if (entity.parent != null) {
			entity.parent.removeEntity(entity);
		}
		entity.parent = this;

		if (append) {
			// Append it to the child list
			var tail = null, p = firstChild;
			while (p != null) {
				tail = p;
				p = p.next;
			}
			if (tail != null) {
				tail.next = entity;
			} else {
				firstChild = entity;
			}
		} else {
			// Prepend it to the child list
			entity.next = firstChild;
			firstChild = entity;
		}

		#if heavy_entity
		var child = entity.firstComponent;
		while (child != null) {
			var next = child.next;
			child.onEntityAdded();
			child = next;
		}
		#end
		return this;
	}

	public function removeEntity(entity:Entity) {
		var prev:Entity = null, p = firstChild;
		while (p != null) {
			var next = p.next;
			if (p == entity) {
				// Splice out the entity
				if (prev == null) {
					firstChild = next;
				} else {
					prev.next = next;
				}
				p.parent = null;
				p.next = null;
				break;
			}
			prev = p;
			p = next;
		}
		#if heavy_entity
		var child = entity.firstComponent;
		while (child != null) {
			var next = child.next;
			child.onEntityRemoved();
			child = next;
		}
		#end
	}

	/**
	 * Dispose all of this entity's children, without touching its own components or removing itself
	 * from its parent.
	 */
	public function disposeChildren() {
		while (firstChild != null) {
			firstChild.dispose();
		}
	}

	/**
	 * Removes this entity from its parent, and disposes all its components and children.
	 */
	public function dispose() {
		if (parent != null) {
			parent.removeEntity(this);
		}

		while (firstComponent != null) {
			firstComponent.dispose();
		}
		disposeChildren();
	}

	#if debug @:keep #end public function toString():String {
		return toStringImpl("");
	}

	private function toStringImpl(indent:String):String {
		// Oof, Haxe doesn't support escaped unicode in string literals
		var u2514 = String.fromCharCode(0x2514); // └
		var u241c = String.fromCharCode(0x251c); // ├
		var u2500 = String.fromCharCode(0x2500); // ─
		var u2502 = String.fromCharCode(0x2502); // │

		var output = #if debug 'Entity#$instanceId $u2500 ' #else 'Entity: $u2500 ' #end;

		var displayCount = 0;
		var count = 0;
		var p = firstChild;
		while (p != null) {
			count++;
			#if js
			if (p.getByName(DisplayComponent.NAME) != null) displayCount++;
			#end
			p = p.next;
		}
		output += 'children=$count $u2500 ';
		output += 'displays=$displayCount $u2500 ';

		output += 'components=';
		var p = firstComponent;
		while (p != null) {
			output += p.name;
			if (p.next != null) {
				output += ", ";
			}

			p = p.next;
		}

		return output;
	}

	// Semi-private helper methods
	#if !display
	@:extern // Inline even in debug builds
	inline public function _internal_unsafeCast<A:Component>(component:Component, cl:Class<A>):A {
		return cast component;
	}

	public function _internal_getFromParents<A:Component>(name:ComponentName, ?safeCast:Class<A>):A {
		var entity = this;
		do {
			var component = entity.getByName(name);
			if (safeCast != null) {
				component = Std.downcast(component, safeCast);
			}
			if (component != null) {
				return cast component;
			}
			entity = entity.parent;
		} while (entity != null);

		return null; // Not found
	}

	public function _internal_getFromChildren<A:Component>(name:ComponentName, ?safeCast:Class<A>):A {
		var component = getByName(name);
		if (safeCast != null) {
			component = Std.downcast(component, safeCast);
		}
		if (component != null) {
			return cast component;
		}

		var child = firstChild;
		while (child != null) {
			var component = child._internal_getFromChildren(name, safeCast);
			if (component != null) {
				return component;
			}

			child = child.next;
		}

		return null; // Not found
	}
	#end

	#if macro
	// Gets the ClassType from an expression, or aborts if it's not a component class
	private static function requireComponentType(componentClass:Expr):ClassType {
		var path = getClassName(componentClass);
		if (path != null) {
			var type = Context.getType(path.join("."));
			switch (type) {
				case TInst(ref, _):
					var cl = ref.get();
					if (Context.unify(type, Context.getType("flambe.Component")) && cl.superClass != null) {
						return cl;
					}
				default:
			}
		}

		Context.error("Expected a class that extends Component, got " + componentClass.toString(), Context.currentPos());
		return null;
	}

	// Gets a class name from a given expression
	private static function getClassName<A>(componentClass:Expr):Array<String> {
		switch (componentClass.expr) {
			case EConst(CIdent(name)):
				return [name];
			case EField(expr, name):
				var path = getClassName(expr);
				if (path != null) {
					path.push(name);
				}
				return path;
			default:
				return null;
		}
	}

	private static function needSafeCast(componentClass:ClassType):Bool {
		return !componentClass.superClass.t.get().meta.has(":componentBase");
	}
	#end
}

@:native("ET")
@:noCompletion private enum EntityType {
	E(entity:Entity);
	C<A:Component>(component : A);
	A(structure:Array<EntityOrComponent>);
}

@:noCompletion private abstract EntityOrComponent(EntityType) from EntityType {
	@:from inline static function fromEntity(a:Entity):EntityOrComponent return EntityType.E(a);

	@:from inline static function fromComponent<A:Component>(a:A):EntityOrComponent return EntityType.C(a);

	@:from inline static function fromArray(a:Array<EntityOrComponent>):EntityOrComponent return EntityType.A(a);
}
