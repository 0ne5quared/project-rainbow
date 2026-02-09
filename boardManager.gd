extends GridContainer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i in range(self.columns * 2):
		var btn := Button.new()
		btn.custom_minimum_size = Global.CARD_SIZE
		self.add_child(btn)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
