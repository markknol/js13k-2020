package music;

import js.html.audio.AudioBuffer;
import js.html.audio.AudioContext;
import music.AudioConnection;

/**
 * @author Mark Knol
 */
class AudioEffects {
	public static function createDelay(audioContext:AudioContext, config:{mix:Float, time:Float, feedback:Float}):music.AudioConnection {
		final connection = new music.AudioConnection(audioContext);

		final dryGainNode = audioContext.createGain();
		final wetGainNode = audioContext.createGain();
		final feedbackGainNode = audioContext.createGain();
		final delayNode = audioContext.createDelay();

		// line in to dry mix
		connection.inputNode.connect(dryGainNode);
		// dry line out
		dryGainNode.connect(connection.outputNode);

		// feedback loop
		delayNode.connect(feedbackGainNode);
		feedbackGainNode.connect(delayNode);

		// line in to wet mix
		connection.inputNode.connect(delayNode);
		// wet out
		delayNode.connect(wetGainNode);

		// wet line out
		wetGainNode.connect(connection.outputNode);

		dryGainNode.gain.value = 1 - config.mix;
		wetGainNode.gain.value = config.mix;

		delayNode.delayTime.value = config.time;
		feedbackGainNode.gain.value = config.feedback;

		return connection;
	}

	public static function createReverb(audioContext:AudioContext, config:{asset:AudioBuffer, mix:Float}):music.AudioConnection {
		final connection = new music.AudioConnection(audioContext);

		final dryGainNode = audioContext.createGain();
		dryGainNode.gain.value = 1 - config.mix;

		final reverb = audioContext.createConvolver();
		final wetGainNode = audioContext.createGain();
		wetGainNode.gain.value = config.mix;
		reverb.buffer = config.asset;

		connection.inputNode.connect(reverb);
		reverb.connect(wetGainNode);
		connection.inputNode.connect(dryGainNode);

		wetGainNode.connect(connection.outputNode);
		dryGainNode.connect(connection.outputNode);

		return connection;
	}
}
