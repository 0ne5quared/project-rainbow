class_name BoardManager
extends GridContainer

signal slot_selected(slot: Slot)

## list of slots, when there is no back row some of the value here can be null
var slots: Array[Slot] = []

@onready var card_manager: CardsManager = %CardsManager

## If you are ever confuse which row belong to
enum Row { OPP_BACK, OPP, MINE, MINE_BACK }


class Slot:
	extends TextureButton

	signal card_changed(from: Card, to: Card)

	## This value can actually be null if the spot is empty.
	var card: Card:
		set(new):
			var old_card := card
			card = new
			card_changed.emit(old_card as Card, new as Card)

	var attack_buf: int = 0

	var pos: Vector2i

	func _init(p: Vector2i) -> void:
		pos = p

	func is_empty() -> bool:
		return card == null


func _ready() -> void:
	for i in range(columns * 4):
		@warning_ignore("integer_division")  # Actually good to normalize the column number
		var row := i / 4
		# TODO: Change this when we implement backrow
		# Mainly that hard coded false
		var is_back := row in [Row.OPP_BACK, Row.MINE_BACK]
		if true and is_back:
			slots.push_back(null)
			continue

		var btn := Slot.new(Vector2i(i % columns, row))
		var texture := load("res://asset/ui/beast_slot.png")
		var normal_atlas := AtlasTexture.new()
		var pressed_atlas := AtlasTexture.new()

		normal_atlas.atlas = texture
		normal_atlas.region = Rect2(Vector2.ZERO, Global.CARD_SIZE)
		btn.texture_normal = normal_atlas

		pressed_atlas.atlas = texture
		pressed_atlas.region = Rect2(Vector2.RIGHT * Global.CARD_SIZE, Global.CARD_SIZE)

		btn.texture_hover = pressed_atlas
		btn.custom_minimum_size = Global.CARD_SIZE
		if row >= Row.MINE:
			btn.flip_v = true
		btn.pressed.connect(_on_slot_pressed.bind(btn))
		btn.card_changed.connect(_forward_select.bind(btn))
		btn.card_changed.connect(position_card)
		slots.push_back(btn)
		self.add_child(btn)


func _forward_select(
	from: Card,
	to: Card,
	slot: Slot,
) -> void:
	if from != null:
		from.pressed.disconnect(_on_slot_pressed)
	if to != null:
		to.pressed.connect(_on_slot_pressed.bind(slot))


func _on_slot_pressed(slot: Slot) -> void:
	slot_selected.emit(slot)


func position_card(_from: Card, _to: Card) -> void:
	for slot in slots:
		if slot == null or slot.is_empty():
			continue
		create_tween().tween_property(slot.card, ^"position", slot.global_position, 0.2)
		#slot.card.position = slot.global_position + Global.CARD_SIZE / 2


func is_slot_empty(pos: Vector2i) -> bool:
	var slot := get_slot(pos)
	return slot != null and slot.is_empty()


func get_slot(pos: Vector2i) -> Slot:
	if pos.x not in range(0, columns) or pos.y not in range(0, 4):
		return null
	return slots[pos.x + pos.y * columns]


func get_row(row: Row) -> Array[Slot]:
	return slots.slice(row * columns, (row + 1) * columns)


## Get the "active" row from the current client perspective. If [param is_active] is true, return
## [enum Row.MIME] else [enum Row.OPP].
func get_active_row(is_active: bool) -> Array[Slot]:
	return get_row(BoardManager.Row.MINE if is_active else BoardManager.Row.OPP)


static func oppose_pos(pos: Vector2i) -> Vector2i:
	pos.y = 3 - pos.y
	return pos


## Return the position of card with [param card_id]. If the card doesn't exist on the board return
## [code]Vector2i(-1, -1)[/code]
func get_card_pos(card_id: String) -> Vector2i:
	var slot := get_slot_with_card(card_id)
	return slot.pos if slot != null else (Vector2i.ONE * -1)


## Return the slot containing the card with [param card_id]. If the card doesn't exist on the board
## return [code]null[/code]
func get_slot_with_card(card_id: String) -> Slot:
	for slot in slots:
		if slot != null and not slot.is_empty() and slot.card.id == card_id:
			return slot
	return null
