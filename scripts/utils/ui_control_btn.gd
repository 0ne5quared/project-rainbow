extends Button

@export var ui: Node
@export var make_visible: bool = true


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pressed.connect(_on_pressed)


func _on_pressed() -> void:
	ui.visible = make_visible
