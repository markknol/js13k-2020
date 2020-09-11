package music;

using haxe.macro.Tools;

class ListEnumAbstract {
	public static macro function list(e:haxe.macro.Expr) {
		return macro $a{
			getFields(e)
				.map(function(s) {
					final name = s.name;
					return macro $e.$name;
				})
		}
	}

	public static macro function count(e:haxe.macro.Expr) {
		return macro $v{getFields(e).length};
	}

	static function getFields(e:haxe.macro.Expr) {
		return switch haxe.macro.Context.follow(haxe.macro.Context.getType(e.toString())) {
			case TAbstract(_.get() => {meta: meta, impl: impl}, _) if (meta.has(':enum')):
				impl.get().statics.get()
					.filter(function(s) return s.meta.has(':enum') && s.meta.has(':impl'));
			default:
				haxe.macro.Context.error('Only applicable to @:enum abstract', e.pos);
		}
	}
}
