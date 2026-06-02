extends PanelContainer

var tween: Tween


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global._show_popup.connect(appear)
	Global._hide_popup.connect(disappear)


func appear(txt: String, type: Global.PopupType, closeable: bool) -> void:
	visible = true
	%Text.text = txt
	match type:
		Global.PopupType.ERR:
			%Popup.theme_type_variation = &"ErrorPopup"
			%Title.text = "ERROR"
		Global.PopupType.INFO:
			%Popup.theme_type_variation = &"InfoPopup"
			%Title.text = "INFO"
		_:
			%Popup.theme_type_variation = &"BasicPopup"
			%Title.text = ""
	%ClosePopupBtn.visible = closeable


func loading(txt: String) -> void:
	%Popup.theme_type_variation = &"InfoPopup"
	%Title.text = ""
	%Text.text = ""
	%ClosePopupBtn.visible = false
	tween = create_tween().set_loops()
	tween.tween_method(_loading_state.bind(txt), 0, 3, 1)


func _loading_state(dot_count: int, txt: String) -> void:
	%Text.text = txt + ".".repeat(dot_count)


func disappear() -> void:
	visible = false
	if tween != null:
		tween.kill()


func _on_button_pressed() -> void:
	disappear()
