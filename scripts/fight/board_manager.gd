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

	signal card_changed

	## This value can actually be null if the spot is empty.
	var card: Card:
		set(new):
			card = new
			card_changed.emit()
	var pos: Vector2i

	func _init(p: Vector2i) -> void:
		pos = p


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i in range(columns * 4):
		@warning_ignore("integer_division")  # actually good to normalize the column number
		var row := i / 4
		# TODO change this when we implement backrow
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
		btn.card_changed.connect(position_card)
		slots.push_back(btn)
		self.add_child(btn)


func _on_slot_pressed(slot: Slot) -> void:
	slot_selected.emit(slot)


func position_card() -> void:
	for slot in slots:
		if slot == null or slot.card == null:
			continue
		create_tween().tween_property(slot.card, ^"position", slot.global_position, 0.2)
		#slot.card.position = slot.global_position + Global.CARD_SIZE / 2


func is_slot_empty(pos: Vector2i) -> bool:
	return get_slot(pos).card == null


func get_slot(pos: Vector2i) -> Slot:
	return slots[pos.x + pos.y * columns]


func get_row(row: Row) -> Array[Slot]:
	return slots.slice(row * columns, (row + 1) * columns)
