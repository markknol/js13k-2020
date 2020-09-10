//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt
package flambe.platform;

import flambe.util.Disposable;
import js.html.EventTarget in IEventDispatcher;
import js.html.Event;

private typedef Listener = Dynamic->Void;

/**
 * Manages a group of event listeners. When the group is disposed, all listeners are removed.
 */
class EventGroup  {
	public inline function new() {
	}

	/** Register a listener with this group. */
	public inline function addListener<D:IEventDispatcher>(dispatcher:D, type:String, listener:Listener, useCapture:Bool = false) {
		dispatcher.addEventListener(type, listener, useCapture);
	}
}
