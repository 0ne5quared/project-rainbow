extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for child in get_children():
		child.visible = false
	$TitleScreen.visible = true
	$RulesetSelector.visible = true
	#%DeckTabContainer.current_tab = 0
