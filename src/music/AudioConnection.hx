package music;

import js.html.audio.AudioContext;
import js.html.audio.GainNode;

/**
 * @author Mark Knol
 */
class AudioConnection {
	public var inputNode:GainNode;
	public var outputNode:GainNode;

	public inline function new(audioContext:AudioContext) {
		inputNode = audioContext.createGain();
		outputNode = audioContext.createGain();
	}
}
