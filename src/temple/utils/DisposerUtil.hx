package temple.utils;

import flambe.util.Disposable;
import haxe.macro.Context;
import haxe.macro.Expr;

/**
	Utility for disposing instances.

	Usage:

	```
	override function dispose()
	{
		super.dispose();

		_myDisposable = DisposerUtil.dispose(_myDisposable);
		_myArray = DisposerUtil.dispose(_myArray);
		_myMap = DisposerUtil.dispose(_myMap);
	}
	```

	@author Mark Knol
 */
class DisposerUtil {
	/**
		Safely disposes any value that:

		* is or implements `Disposable`
		* is `Map<Any, Disposable>`
		* is `Iterable<Disposable>`

		@return `null`
	**/
	static public macro function dispose<T:Expr>(value:ExprOf<T>):ExprOf<T> {
		var exprType = Context.typeof(value);
		var disposableType = Context.getType(Type.getClassName(Disposable));
		if (Context.unify(exprType, disposableType)) {
			return macro DisposerUtils.disposeObject($value);
		} else switch (exprType) {
			case TAbstract(_.get() => cl, u):
				if (Context.unify(Context.getType(cl.name), Context.getType("Map")) && Context.unify(u[1], disposableType)) {
					return macro DisposerUtils.disposeMap($value);
				}

			case TInst(_.get() => cl, u):
				if (Context.unify(Context.getType(cl.name), Context.getType("Iterable")) && Context.unify(u[0], disposableType)) {
					return macro DisposerUtils.disposeIterable($value);
				}

			default:
		}
		// Context.error("DisposerUtil: not valid disposable type:: " + exprType, Context.currentPos());
		return macro if ($value != null) {
			$value.dispose();
			$value = null;
		};
	}
}

class DisposerUtils {
	/**
		Disposes a `Disposable` and returns `null`.
	**/
	public static inline function disposeObject<A:Disposable>(disposable:A):A {
		if (disposable != null) {
			disposable.dispose();
		}
		return null;
	}

	/**
		Disposes a `Map<Any,Disposable>` and returns `null`.
	**/
	public static inline function disposeMap<A, B:Disposable>(map:Map<A, B>):Map<A, B> {
		if (map != null) {
			for (value in map) {
				value = disposeObject(value);
			}
		}
		return null;
	}

	/**
		Disposes a `Iterable<Disposable>` and returns `null`.
	**/
	public static inline function disposeIterable<A:Iterable<B>, B:Disposable>(iterable:A):A {
		if (iterable != null) {
			for (value in iterable) {
				value = disposeObject(value);
			}
		}
		return null;
	}
}
