package temple;

import flambe.util.Assert;

/**
 * @author <https://code.haxe.org/category/principles/null-safety.html>
 */
abstract Maybe<T>(Null<T>) from T from Null<T> {
	public inline function exists():Bool {
		return this != null;
	}

	public inline function sure():T {
		#if debug
		return if (exists()) this else Assert.fail('No value for $this');
		#else
		return this;
		#end
	}

	public inline function or(fallback:T):T {
		return if (exists()) this else fallback;
	}

	public inline function orSet(fallback:T):T {
		return if (exists()) this else this = fallback;
	}

	public inline function may(fn:T->Void):Void {
		if (exists()) fn(this);
	}

	public inline function map<S>(fn:T->S):Maybe<S> {
		return if (exists()) fn(this) else null;
	}

	public inline function mapDefault<S>(fn:T->S, fallback:S):S {
		return if (exists()) fn(this) else fallback;
	}
}

/** Designed for `using` **/
class MaybeUtil {
	public static inline function exists<T>(value:Maybe<T>):Bool {
		return value.exists();
	}

	public static inline function sure<T>(value:Maybe<T>):T {
		return value.sure();
	}

	public static inline function or<T>(value:Maybe<T>, fallback:T):T {
		return value.or(fallback);
	}

	public static inline function may<T>(value:Maybe<T>, fn:T->Void):Void {
		value.may(fn);
	}

	public static inline function map<T, S>(value:Maybe<T>, fn:T->S):Maybe<S> {
		return value.map(fn);
	}

	public static inline function mapDefault<T, S>(value:Maybe<T>, fn:T->S, fallback:S):S {
		return value.mapDefault(fn, fallback);
	}
}
