extends ScrollContainer

@export var label: Label

var tween: Tween
var max_length: float


func _ready() -> void:
	call_deferred("_set_max_length")
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_SHOW_NEVER


func _set_max_length() -> void:
	max_length = max(0, label.size.x - size.x)


func _on_mouse_entered() -> void:
	if tween != null and tween.is_running():
		tween.kill()
	tween = create_tween()
	var percentage := 1 - (scroll_horizontal as float / max_length)
	var duration := len(label.text) as float / 12.0 * percentage
	tween.tween_property(self, "scroll_horizontal", max_length as int, duration)


func _on_mouse_exited() -> void:
	if tween != null and tween.is_running():
		tween.kill()
	tween = create_tween()
	var percentage := scroll_horizontal as float / max_length
	var duration := len(label.text) as float / 12.0 * percentage
	tween.tween_property(self, "scroll_horizontal", 0, duration)
