class_name PlayerListing
extends MarginContainer

var player_name := "GUEST"
var pfp := "res://asset/portraits/MISSING.png"
var is_host := false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	%Name.text = player_name
	%Pfp.texture = load(pfp)
	%Status.text = (
		"[color=%s]%s[/color]" % ["#fadd4d" if is_host else "", "H" if is_host else "R"]
	)
