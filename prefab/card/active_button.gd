extends TextureButton


func _process(_delta: float) -> void:
	var child: TextureRect = get_child(0)
	if child == null:
		return
	child.position = Vector2(2, 2)
	if button_pressed:
		child.position += Vector2.DOWN * 3
