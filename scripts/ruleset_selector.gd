class_name RulesetSelector

extends PanelContainer

var ruleset_button := preload("res://prefab/ruleset_button/ruleset_btn.tscn")

var first_time := true
var selected_ruleset: Dictionary


class Ruleset:
	var name: String
	var description: String
	var url: String
	var portrait: String
	var installed: bool

	@warning_ignore("untyped_declaration")
	func _init(json: Dictionary):
		name = json.name
		description = json.description
		url = json.url
		portrait = json.portrait
		installed = FileAccess.file_exists("user://rulesets/%s.json" % name)
		if name.begins_with("IMF Standard"):
			portrait = "res://asset/ruleset_icon/scales.png"
		elif name.begins_with("IMF Eternal"):
			portrait = "res://asset/ruleset_icon/hourglass.png"
		elif name.begins_with("IMF Vanilla"):
			portrait = "res://asset/ruleset_icon/vanilla.png"
		elif name.begins_with("Mr.Egg's Goofy"):
			portrait = "res://asset/ruleset_icon/egg.png"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$HTTPRequest.request_completed.connect(_on_request_complete)
	$HTTPRequest.request(
		"https://raw.githubusercontent.com/107zxz/inscr-onln-ruleset/refs/heads/main/featured.json"
	)


func add_ruleset(ruleset: Ruleset) -> void:
	var button: RulesetButton = ruleset_button.instantiate()
	button.ruleset = ruleset
	button.horvered.connect(_on_button_horvered)
	button.mouse_exited.connect(_on_button_unhorvered)
	button.selected.connect(_on_button_selected)
	%RulesetList.add_child(button)
	%RulesetList.move_child(%AddBtn, -1)


func _on_request_complete(
	_result: int, _response_code: int, _headers: PackedStringArray, body: PackedByteArray
) -> void:
	# TODO implement error handling
	return
	var response: Dictionary = JSON.parse_string(body.get_string_from_utf8())
	if first_time:
		for ruleset: Dictionary in response.rulesets:
			add_ruleset(Ruleset.new(ruleset))
		first_time = false
		_on_button_unhorvered()
		return
	var file := FileAccess.open("user://rulesets/%s.json" % response.ruleset, FileAccess.WRITE)
	file.store_string(JSON.stringify(response))
	selected_ruleset = response


func _on_button_horvered(name_: String, description: String) -> void:
	%RulesetName.text = name_
	%RulesetDescription.text = description


func _on_button_unhorvered() -> void:
	_on_button_horvered("Select a ruleset", "Select a ruleset to start playing")


func _on_button_selected(ruleset: Ruleset) -> void:
	if not ruleset.installed:
		$HTTPRequest.request(ruleset.url)
		await $HTTPRequest.request_completed
	else:
		var file := FileAccess.open("user://rulesets/%s.json" % ruleset.name, FileAccess.READ)
		selected_ruleset = JSON.parse_string(file.get_as_text())
	Global.ruleset = selected_ruleset
	visible = false
