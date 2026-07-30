## This script can be run using Ctrl-Shift-X and it just scan ever file for type error. Useful for
## large refactoring cus the game have alot of dynamically loaded script
@tool
extends EditorScript


func _run() -> void:
	scan("res://")


func scan(path: String) -> void:
	var dir := DirAccess.open(path)
	if dir == null:
		return

	dir.list_dir_begin()

	while true:
		var file := dir.get_next()
		if file == "":
			break

		if file.begins_with("."):
			continue

		var full := path.path_join(file)

		if dir.current_is_dir():
			scan(full)
		elif full.ends_with(".gd"):
			print("Loading ", full)
			load(full)

	dir.list_dir_end()
