class_name FilterButton
extends Button

# This script don't actually have filtering fucntionality it just a string to refer to the deck
# editor filters

enum FilterGroup { COST, RARITY, TRAIT, TEMPLE, TRIBE }

@export var filter_name: String
@export var filter_group: FilterGroup
@export var deck_editor: DeckEditor


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	toggled.connect(_on_toggled)
	toggle_mode = true


func _on_toggled(toggle_on: bool) -> void:
	if toggle_on:
		deck_editor.enabled_filters[filter_group].append(filter_name)
		deck_editor.update_filters()
	else:
		var idx := deck_editor.enabled_filters[filter_group].find(filter_name)
		if idx == -1:
			return
		deck_editor.enabled_filters[filter_group].remove_at(idx)
		deck_editor.update_filters()
