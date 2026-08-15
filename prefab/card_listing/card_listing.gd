class_name CardListing
extends Button

var card_data: Ruleset.CardData:
	set(new):
		card_data = new
		redraw()
var amount: int = 1:
	set(new):
		amount = new
		redraw()


func redraw() -> void:
	name = card_data.name

	$TextureRect.texture = Global.ruleset.rarities[card_data.rarity].listing_underlay

	%Amount.text = str(amount) + "x"

	var portrait_path := "res://asset/portraits/%s.png" % card_data.name
	if FileAccess.file_exists(portrait_path):
		%Portrait.texture = load(portrait_path)
	else:
		push_warning(
			'Portrait can\'t be found for "%s" so using missing texture instead' % card_data.name
		)
		%Portrait.texture = load("res://asset/portraits/MISSING.png")

	%CardName.text = card_data.name

	for child in %CostContainer.get_children():
		%CostContainer.remove_child(child)
		child.queue_free()

	for n in Card.cost_string(card_data.costs):
		%CostContainer.add_child(n)
