package temple.utils;

import temple.random.ISeededRandom;
import temple.random.Random;

/**
 * @author Mark Knol
 */
class ArrayUtils {
	static public function randomElement<A>(array:Array<A>, ?random:Random, doSplice:Bool = false):Null<A> {
		if (random == null) random = Random.native;
		if (array != null && array.length > 0) {
			var index:Int = Std.int(random.next() * array.length);
			var element:A = array[index];
			if (doSplice) array.splice(index, 1);
			return element;
		}
		return null;
	}

	/// Fisher-Yates Shuffle
	static public function shuffle<A>(array:Array<A>, random:ISeededRandom):Array<A> {
		var m = array.length, t, i;
		// While there remain elements to shuffle…
		while (m > 0) {
			// Pick a remaining element…
			i = Math.floor(random.next() * m--);
			// And swap it with the current element.
			t = array[m];
			array[m] = array[i];
			array[i] = t;
		}
		return array;
	}

	/**
		@return first item of the array
	**/
	static public inline function clear<A>(array:Array<A>):Array<A> {
		while (array.length > 0) {
			array.pop();
		}
		return array;
	}

	/**
		@return first item of the array
	**/
	static public inline function first<A>(array:Array<A>):Null<A> {
		return array[0];
	}

	/**
		@return last item of the array
	**/
	static public inline function last<A>(array:Array<A>):Null<A> {
		return array[array.length - 1];
	}

	/**
		@return `true` if array does not contain any element.
	**/
	public static inline function empty<T>(it:Array<T>):Bool {
		return it.length == 0;
	}
}
