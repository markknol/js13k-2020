//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt
package flambe.platform;

import haxe.macro.Expr;
import haxe.macro.Context;
import haxe.macro.Type;
import flambe.util.Macros;

using Lambda;
using haxe.macro.Tools;

// using flambe.util.Iterables;
class ComponentBuilder {
	public static function build():Array<Field> {
		var pos = Context.currentPos();
		var cl:ClassType = Context.getLocalClass().get();

		var name = Context.makeExpr(getComponentName(cl), pos);
		// var componentType = TPath({pack: cl.pack, name: cl.name, params: []});

		var fields:Array<Field> = Context.getBuildFields();
		#if !debug
		for (field in fields) {
			if (field.access.has(APrivate)) {
				if (!field.meta.exists(v -> v.name == ":native")) {
					field.meta.push({
						name: ":native",
						params: [macro $v{@:privateAccess HxObfuscator.getId(field.name)}],
						pos: pos,
					});
				}
			}
		}
		#end

		fields = fields.concat(Macros.buildFields(macro {
			#if doc
			@:noDoc
			#end
			var public__static__inline__NAME = @:privateAccess new flambe.ComponentName($name);
		}));

		// Only override get_name if this component directly extends a @:componentBase and creates a
		// new namespace
		if (extendsComponentBase(cl)) {
			fields = fields.concat(Macros.buildFields(macro {
				function override__private__get_name():flambe.ComponentName {
					return @:privateAccess new flambe.ComponentName($name);
				}
			}));
		}

		/** Add required components to onStart/onAdded function, create function if doesnt exist **/
		// Fields can be marked with `@:component`, `@:component(parents)` or `@:component(children)`
		// Only `@:component` fields get added to onAdded

		var onStart = null;

		var onAdded = null;
		var onDispose = null;
		var requiredSelf = [];
		var requiredParents = [];
		var requiredChildren = [];
		var optionalComponents = [];

		var disposeExprs = [];

		for (field in fields) {
			switch [field.name, field.kind] {
				case ["onStart", FFun(fun)]:
					onStart = fun;
				case ["onAdded", FFun(fun)]:
					onAdded = fun;
				case ["dispose", FFun(fun)]:
					onDispose = fun;
				case [name, FVar(TPath(tp), _) | FProp(_, _, TPath(tp), _)]:
					var meta:MetadataEntry = field.meta.find(function(m) return m.name == ":component");
					if (meta != null) {
						if (tp.name == "String" || tp.name == "Int" || tp.name == "Float") {
							Context.error('${tp.name} is not a Component', field.pos);
						}
						var expr = {name: name, path: tp.pack.concat([tp.name]), pos: field.pos};
						if (meta.params.length == 0) requiredSelf.push(expr); else for (param in meta.params)
							switch (param.expr) {
								case EConst(CIdent("children")):
									requiredChildren.push(expr);
								case EConst(CIdent("parents")):
									requiredParents.push(expr);
								case EConst(CIdent("owner")):
									requiredSelf.push(expr);
								case EConst(CIdent("optional")):
									optionalComponents.push(expr);
									if (meta.params.length == 1) requiredSelf.push(expr);
								case unknown:
									Context.error('${cl.name}.$name : $unknown is not a "@:component" parameter option', field.pos);
							}
					}

					var meta:MetadataEntry = field.meta.find(function(m) return m.name == ":disposable");
					if (meta != null) {
						var fieldName = field.name;
						if (meta.params.length == 0) disposeExprs.push(macro if (this.$fieldName != null) {
							this.$fieldName.dispose();
							this.$fieldName = null;
						});
					}
				default:
					var meta:MetadataEntry = field.meta.find(function(m) return m.name == ":disposable");
					if (meta != null) {
						var fieldName = field.name;
						if (meta.params.length == 0) disposeExprs.push(macro if (this.$fieldName != null) {
							this.$fieldName.dispose();
							this.$fieldName = null;
						});
					}
			}
		}

		// construct expressions like `if(_field==null) _field= owner.get(Type)`
		var requiredOnAddedInits = [];
		var requiredOnStartInits = [];
		for (r in requiredSelf) {
			var name = r.name;
			var dotPath = haxe.macro.MacroStringTools.toFieldExpr(r.path);
			// requiredOnAddedInits.push(macro @:pos(r.pos) if (this.$name == null) this.$name = cast this.owner.getByName($dotPath.NAME));
			requiredOnStartInits.push(macro @:pos(r.pos) if (this.$name == null) this.$name = cast this.owner.getByName($dotPath.NAME));
			if (!optionalComponents.has(r)) {
				requiredOnStartInits.push(macro flambe.util.Assert.that(this.$name != null, $v{cl.name} + "." + $v{name} + " cannot be null"));
			}
		}
		for (r in requiredChildren) {
			var name = r.name;
			var dotPath = haxe.macro.MacroStringTools.toFieldExpr(r.path);
			requiredOnStartInits.push(macro @:pos(r.pos) if (this.$name == null) this.$name = this.owner.getFromChildren($dotPath));
			if (!optionalComponents.has(r)) {
				requiredOnStartInits.push(macro flambe.util.Assert.that(this.$name != null, $v{cl.name} + "." + $v{name} + " cannot be null"));
			}
		}
		for (r in requiredParents) {
			var name = r.name;
			var dotPath = haxe.macro.MacroStringTools.toFieldExpr(r.path);
			requiredOnStartInits.push(macro @:pos(r.pos) if (this.$name == null) this.$name = this.owner.getFromParents($dotPath));
			if (!optionalComponents.has(r)) {
				requiredOnStartInits.push(macro flambe.util.Assert.that(this.$name != null, $v{cl.name} + "." + $v{name} + " cannot be null"));
			}
		}

		if (requiredOnStartInits.length > 0) {
			if (onStart == null) {
				fields.push({
					name: "onStart",
					access: [Access.APublic, Access.AOverride],
					kind: FieldType.FFun({
						expr: macro {
							$b{requiredOnStartInits}; // add block of required fields
							super.onStart(); // call super
						},
						ret: (macro:Void),
						args: []
					}),
					pos: pos,
				});
			} else {
				onStart.expr = macro {
					$b{requiredOnStartInits};
					${onStart.expr};
				};
			}
		}

		if (requiredOnAddedInits.length > 0) {
			if (onAdded == null) {
				fields.push({
					name: "onAdded",
					access: [Access.APublic, Access.AOverride],
					kind: FieldType.FFun({
						expr: macro {
							$b{requiredOnAddedInits}; // add block of required fields
							super.onAdded(); // call super
						},
						ret: (macro:Void),
						args: []
					}),
					pos: pos,
				});
			} else {
				onAdded.expr = macro {
					$b{requiredOnAddedInits};
					${onAdded.expr};
				};
			}
		}

		if (disposeExprs.length > 0) {
			if (onDispose == null) {
				fields.push({
					name: "dispose",
					access: [Access.APublic, Access.AOverride],
					kind: FieldType.FFun({
						expr: macro {
							$b{disposeExprs}; // add block of disposals
							super.dispose(); // call super
						},
						ret: (macro:Void),
						args: []
					}),
					pos: pos,
				});
			} else {
				onDispose.expr = macro {
					$b{disposeExprs};
					${onDispose.expr};
				};
			}
		}

		return fields;
	}

	private static function getComponentName(cl:ClassType):String {
		// Traverse up to the last non-component base
		while (true) {
			if (extendsComponentBase(cl)) {
				break;
			}
			cl = cl.superClass.t.get();
		}

		// Look up the ID, otherwise generate one
		var fullName = cl.pack.concat([cl.name]).join(".");
		var name = _nameCache.get(fullName);
		if (name == null) {
			name = cl.name + "_" + _nextId;
			_nameCache.set(fullName, name);
			++_nextId;
		}

		#if (debug || !hxobfuscator)
		return name;
		#else
		return @:privateAccess HxObfuscator.getId(name);
		#end
	}

	private static function extendsComponentBase(cl:ClassType) {
		var superClass = cl.superClass.t.get();
		return superClass.meta.has(":componentBase");
	}

	private static var _nameCache = new Map<String, String>();
	private static var _nextId = 0;
}
