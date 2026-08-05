extends Control

@export var label: Label

var tween: Tween
var max_scroll: float


func _ready() -> void:
	call_deferred("_update_max_scroll")
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		call_deferred("_update_max_scroll")


func _update_max_scroll() -> void:
	max_scroll = max(0.0, label.size.x - size.x)

	if max_scroll <= 0.0:
		label.position.x = 0.0


func _on_mouse_entered() -> void:
	if max_scroll <= 0.0:
		return

	if tween:
		tween.kill()

	var current_scroll := -label.position.x
	var percentage := 1.0 - (current_scroll / max_scroll)

	tween = create_tween()
	var duration := label.text.length() / 12.0 * percentage
	tween.tween_property(label, "position:x", -max_scroll, duration)


func _on_mouse_exited() -> void:
	if tween:
		tween.kill()

	var current_scroll := -label.position.x
	var percentage := current_scroll / max_scroll if max_scroll > 0.0 else 1.0

	tween = create_tween()
	var duration := label.text.length() / 12.0 * percentage
	tween.tween_property(label, "position:x", 0.0, duration)
