package music;

@:structInit class AudioPitchedNote {
	public final note:music.AudioNote;
	public final pitch:Int;

	public inline function new(note:music.AudioNote, pitch:Int) {
		this.note = note;
		this.pitch = pitch;
	}

	public inline function getMidi() return note.toMidi(pitch);
}
