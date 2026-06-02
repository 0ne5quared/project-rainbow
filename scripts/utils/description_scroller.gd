extends ScrollContainer


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	@warning_ignore("integer_division")
	scroll_vertical = scroll_vertical / 13 * 13
	var max_scroll: int = max(0, $RichTextLabel.size.y - size.y)
	if max_scroll - scroll_vertical < 13:
		scroll_vertical = max_scroll
