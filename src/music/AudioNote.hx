package music;

enum abstract AudioNote(Int) {
	final C = 0;
	final CSharp;
	final D;
	final DSharp;
	final E;
	final F;
	final FSharp;
	final G;
	final GSharp;
	final A;
	final ASharp;
	final B;
	
	// allow operators
	@:op(a < b) static function lt(a:AudioNote, b:AudioNote):Bool;
	@:op(a > b) static function gt(a:AudioNote, b:AudioNote):Bool;
	
	public inline function toMidi(octave:Int):Int {
		return  (octave * 12) + this;
	}
}