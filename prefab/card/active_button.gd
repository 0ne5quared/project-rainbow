extends TextureButton


func _process(_delta: float) -> void:
	if get_child_count() <= 0:
		return
	var child: TextureRect = get_child(0)
	child.position = Vector2(2, 2)
	if button_pressed:
		child.position += Vector2.DOWN * 3
