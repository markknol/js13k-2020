//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt
package flambe.input;

/**
 * All the possible keyboard keys that can be handled. Use Unknown to handle any platform-specific
 * key codes not yet supported here.
 */
@:enum abstract Key(Int) to Int {
	public var A = 65;
	public var B = 66;
	public var C = 67;
	public var D = 68;
	public var E = 69;
	public var F = 70;
	public var G = 71;
	public var H = 72;
	public var I = 73;
	public var J = 74;
	public var K = 75;
	public var L = 76;
	public var M = 77;
	public var N = 78;
	public var O = 79;
	public var P = 80;
	public var Q = 81;
	public var R = 82;
	public var S = 83;
	public var T = 84;
	public var U = 85;
	public var V = 86;
	public var W = 87;
	public var X = 88;
	public var Y = 89;
	public var Z = 90;
	public var Number0 = 48;
	public var Number1 = 49;
	public var Number2 = 50;
	public var Number3 = 51;
	public var Number4 = 52;
	public var Number5 = 53;
	public var Number6 = 54;
	public var Number7 = 55;
	public var Number8 = 56;
	public var Number9 = 57;
	public var Numpad0 = 96;
	public var Numpad1 = 97;
	public var Numpad2 = 98;
	public var Numpad3 = 99;
	public var Numpad4 = 100;
	public var Numpad5 = 101;
	public var Numpad6 = 102;
	public var Numpad7 = 103;
	public var Numpad8 = 104;
	public var Numpad9 = 105;
	public var NumpadAdd = 107;
	public var NumpadDecimal = 110;
	public var NumpadDivide = 111;
	public var NumpadEnter = 108;
	public var NumpadMultiply = 106;
	public var NumpadSubtract = 109;
	public var F1 = 112;
	public var F2 = 113;
	public var F3 = 114;
	public var F4 = 115;
	public var F5 = 116;
	public var F6 = 117;
	public var F7 = 118;
	public var F8 = 119;
	public var F9 = 120;
	public var F10 = 121;
	public var F11 = 122;
	public var F12 = 123;
	public var F13 = 124;
	public var F14 = 125;
	public var F15 = 126;
	public var Left = 37;
	public var Up = 38;
	public var Right = 39;
	public var Down = 40;
	public var Alt = 18;
	public var Backquote = 192;
	public var Backslash = 220;
	public var Backspace = 8;
	public var Capslock = 20;
	public var Comma = 188;
	public var Command = 15;
	public var Control = 17;
	public var Delete = 46;
	public var End = 35;
	public var Enter = 13;
	public var Equals = 187;
	public var Escape = 27;
	public var Home = 36;
	public var Insert = 45;
	public var LeftBracket = 219;
	public var Minus = 189;
	public var PageDown = 34;
	public var PageUp = 33;
	public var Period = 190;
	public var Quote = 222;
	public var RightBracket = 221;
	public var Semicolon = 186;
	public var Shift = 16;
	public var Slash = 191;
	public var Space = 32;
	public var Tab = 9;
	// Android keys (AIR only)
	public var Back = 0x01000016;
	public var Menu = 0x01000012;
	public var Search = 0x0100001f;
}
