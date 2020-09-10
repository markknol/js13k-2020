package music;

import music.AudioPitchedNote;
import music.AudioPlayer;
using music.ReverseArrayIterator;

enum abstract AudioScheduler(Array<{time:Float, fn:(time:Float) -> Void}>) {
	static inline final timeAhead = 3.0;

	public inline function new() this = [];

	public inline function add(time:Float, fn:(time:Float) -> Void) {
		this.push({ time:time, fn:fn });
	}

	public inline function update(player:music.AudioPlayer, currentTime:Float) {
		for (item in this.reversedValues()) {
			if (item.time < currentTime + timeAhead) {
				item.fn(item.time);
				this.remove(item);
			}
		}
	}
}

@:structInit class ScheduleItem {
	public var time:Float = 0.0; 
	public var notes:Array<music.AudioPitchedNote>;
}