extends Button

# This script don't actually have filtering fucntionality it just a string to refer to the deck
# editor filters

@export var filter_name: String
@export var deck_editor: DeckEditor


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	toggled.connect(_on_toggled)
	toggle_mode = true


func _on_toggled(toggle_on: bool) -> void:
	if toggle_on:
		deck_editor.enabled_filters.append(filter_name)
		deck_editor.update_filters()
	else:
		deck_editor.enabled_filters.remove_at(deck_editor.enabled_filters.find(filter_name))
		deck_editor.update_filters()
