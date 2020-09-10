package music;

import js.html.audio.AudioContext;
import js.lib.Promise;
import music.AudioConnection;

class AudioPlayer {
	static inline final TOTAL_OSCILLATORS = 7;
	static final NOTE_DURATION = 1.0;

	public final audioContext:AudioContext = null;
	private final effect:music.AudioConnection;

	public var totalNodes = 0;

	// has to be created on a user event
	public function new(audioContext:AudioContext, onReady:() -> Void) {
		this.audioContext = audioContext;
		
		final delay = music.AudioEffects.createDelay(audioContext, {
			feedback: 0.5, 
			time: NOTE_DURATION * 0.75,
			mix: 0.2,
		});
		
		delay.outputNode.connect(audioContext.destination);
		
		this.effect = delay;
	
		if (audioContext!=null) window.setTimeout(onReady, 1);
	}

	public function playNotes(isChord:Bool, noteNumbers:Array<Int>, noteDuration = 2.0, offset:Float = 0.0, volumeScale:Float = 0.85):Void {
		for (noteNumber in noteNumbers) {
			playNote(noteNumber, offset, volumeScale);
			if (!isChord) offset += noteDuration * (NOTE_DURATION/4);
		}
	}

	public function playNote(noteNumber:Int, offset:Float = 0.0, volumeScale:Float = 0.85):Void {
		if (audioContext.state == SUSPENDED) audioContext.resume();
		
		final frequency = midiNoteToFrequency(noteNumber);

		final soundNode = audioContext.createGain();
		final startTime = offset;
		final stopTime = startTime + NOTE_DURATION;

		soundNode.connect(effect.inputNode);

		var TOTAL_OSCILLATORS = 2 + Std.random(4);
		soundNode.gain.setValueAtTime((1 * volumeScale) / TOTAL_OSCILLATORS, startTime);
		soundNode.gain.linearRampToValueAtTime(0, stopTime);

		//var detune = { from: -Std.random(10), to: Std.random(10) };
		var detune = { from: -10, to: -10 };
		for (index in 0...TOTAL_OSCILLATORS) {
			totalNodes++;
			var osc = audioContext.createOscillator();
			var oscGainNode = audioContext.createGain();
			oscGainNode.connect(soundNode);
			var t = (index + 1) / (TOTAL_OSCILLATORS + 1);
			oscGainNode.gain.value = 1 - t * (2.0 - t);

			osc.connect(oscGainNode);
			osc.type =  if (index % 2 == 0) SINE else TRIANGLE;
			
			osc.detune.setValueAtTime(detune.from*t, startTime);
			//osc.detune.linearRampToValueAtTime(detune.to * t, stopTime);
			
			osc.frequency.value = frequency * (index + 1);
			osc.start(startTime);
			osc.stop(stopTime);
			osc.onended = () -> {
				oscGainNode.disconnect();
				osc.disconnect();
				soundNode.disconnect();
				osc.onended = null;
				totalNodes--;
			}
		}
	}

	inline static function midiNoteToFrequency(noteNumber:Int) {
		return Math.pow(2, (noteNumber - 69) / 12) * 440;
	}

	/**
	 * Loads and decodes an audio-file, resulting in an AudioBuffer and the fileSize of the loaded file.
	 */
	public inline function loadAudioBuffer(context:AudioContext, url:String):Promise<js.html.audio.AudioBuffer> {
		return window.fetch(url)
			.then(response -> response.arrayBuffer())
			.then(arrayBuffer -> context.decodeAudioData(arrayBuffer));
	}
}