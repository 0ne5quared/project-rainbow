class_name DeckListing
extends Button

var deck_name: String
var deck_icon: Texture
var main: Dictionary[String, int]
var side: Dictionary[String, int]
var sideboard: Dictionary[String, int]
var is_side_draft: bool = false
var side_max: int = 0
var deck_dict: Dictionary
var wrong_ruleset: bool = false

signal on_deleted
signal on_duplicated
signal on_copied


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	%Icon.texture = deck_icon
	%Name.text = deck_name
	if wrong_ruleset:
		%SizeContainer.visible = false
		%ErrLabel.visible = true
	var main_size := Global.sum(main.values())
	var side_size := Global.sum(side.values())
	var main_size_min := Global.ruleset.settings.deck_size_min
	%MainSizeLabel.text = (
		"Main: %s%s%s/%s+ Cards"
		% [
			"[color=#82051e]" if main_size < main_size_min else "",
			main_size,
			"[/color]" if main_size < main_size_min else "",
			main_size_min
		]
	)
	%SideSizeLabel.text = (
		("Side: %s/%s Cards" % [side_size, side_max])
		if is_side_draft
		else ("Side: %s Cards" % side_size)
	)

	%DupBtn.pressed.connect(_on_duplicated)
	%ClipBtn.pressed.connect(_on_copied)
	%DeleteBtn.pressed.connect(_on_deleted)


func _on_duplicated() -> void:
	var dup := FileAccess.open(
		Global.decks_path.path_join("%s Copy.json" % deck_name), FileAccess.WRITE
	)
	var dup_dict := deck_dict.duplicate_deep()
	dup_dict.name = deck_name + " Copy"
	dup.store_string(JSON.stringify(dup_dict))
	dup.close()
	on_duplicated.emit()


func _on_copied() -> void:
	DisplayServer.clipboard_set(JSON.stringify(deck_dict))
	on_copied.emit()


func _on_deleted() -> void:
	DirAccess.remove_absolute(Global.decks_path.path_join("%s.json" % deck_name))
	on_deleted.emit()
