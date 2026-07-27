extends Node

## Global scope, contain constant or globally use variable, also have a bunch of utility
## that might be helpful

signal _show_popup(txt: String, type: PopupType, closeable: bool)
signal _show_loading(txt: String)
signal _hide_popup

signal ruleset_changed(ruleset: Dictionary)

enum PopupType { ERR, INFO, WARN }

const CARD_SIZE := Vector2(73.0, 93.0)
const SCREEN_SIZE := Vector2(758.0, 495.0)
const VERSION := "v0.0.1"

var player_name := "NO_NAME"
var pfp := "res://asset/portraits/Stoat.png"
var uuid: StringName
var is_host := false

var ruleset: Ruleset:
	get:
		return ruleset
	set(val):
		ruleset = val
		ruleset_changed.emit(val)

var enable_backrow := false


func _ready() -> void:
	var user_dir := DirAccess.open("user://")
	if not user_dir.dir_exists("rulesets"):
		print("Rulesets dir not found creating it...")
		user_dir.make_dir("rulesets")


func quadratic_bezier(start: Vector2, end: Vector2, mid: Vector2) -> Callable:
	return func(t: float) -> Array:
		print(t)
		var q0 := start.lerp(mid, t)
		var q1 := mid.lerp(end, t)

		return [q0.lerp(q1, t), (q1 - q0).angle()]


func show_error(txt: String) -> void:
	_show_popup.emit(txt, PopupType.ERR, true)


func show_info(txt: String, closeable: bool) -> void:
	_show_popup.emit(txt, PopupType.INFO, closeable)


func show_loading(txt: String) -> void:
	_show_loading.emit(txt)


func hide_popup() -> void:
	_hide_popup.emit()


func get_card_by_name(card_name: String) -> Ruleset.CardData:
	return ruleset.cards[card_name]


func gen_id() -> String:
	return String.num_uint64(floor(randf() * 1e9) as int, 16)


## This modify the original data in place.
func validate_schema(
	data: Dictionary, schema: Dictionary[String, Dictionary], show_warning := false
) -> void:
	@warning_ignore("shadowed_global_identifier", "confusable_local_usage")
	var push_warning := push_warning if show_warning else func(_x: String) -> void: pass
	for prop: String in schema:
		var s := schema[prop]
		if (
			TYPE_DICTIONARY in s.types
			and (prop not in data or typeof(data[prop]) == TYPE_DICTIONARY)
		):
			var dict: Dictionary = data[prop] if prop in data else {}
			var ds: Dictionary[String, Dictionary]
			ds.assign(s.schema as Dictionary)
			validate_schema(dict, ds)
			data[prop] = dict
			continue

		if prop not in data:
			push_warning.call('Data missing "%s" component using default: %s' % [prop, s.default])
			data[prop] = s.default
			continue
		if typeof(data[prop]) not in s.types:
			push_warning.call(
				'Data\'s "%s" component is of the wrong type, using default: %s' % [prop, s.default]
			)

		if typeof(data[prop]) == TYPE_ARRAY and TYPE_ARRAY in s.types:
			var array: Array = data[prop]
			for i: int in range(array.size() - 1, -1, -1):
				if typeof(array[i]) != s.sub_type:
					push_warning.call(
						'A value inside of data\'s "%s" is of the wrong type, removing it'
					)
					array.erase(array[i])
