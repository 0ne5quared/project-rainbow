class_name RulesetSelector

extends PanelContainer

var ruleset_button := preload("res://prefab/ruleset_button/ruleset_btn.tscn")

var first_time := true
var selected_ruleset: Dictionary


class RulesetIcon:
	var name: String
	var description: String
	var url: String
	var icon: String
	var installed: bool

	@warning_ignore("untyped_declaration")
	func _init(json: Dictionary):
		name = json.name
		description = json.description
		url = json.url
		icon = json.portrait
		installed = FileAccess.file_exists("user://rulesets/%s.json" % name)
		# TODO: unhardcode this
		if name.begins_with("IMF Standard"):
			icon = "res://asset/ruleset_icon/scales.png"
		elif name.begins_with("IMF Eternal"):
			icon = "res://asset/ruleset_icon/hourglass.png"
		elif name.begins_with("IMF Vanilla"):
			icon = "res://asset/ruleset_icon/vanilla.png"
		elif name.begins_with("Mr.Egg's Goofy"):
			icon = "res://asset/ruleset_icon/egg.png"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$HTTPRequest.request_completed.connect(_on_request_complete)
	$HTTPRequest.request(
		"https://raw.githubusercontent.com/107zxz/inscr-onln-ruleset/refs/heads/main/featured.json"
	)
	var ruleset_path := "user://rulesets"
	for file in DirAccess.open(ruleset_path).get_files():
		var txt := FileAccess.open(ruleset_path.path_join(file), FileAccess.READ).get_as_text()
		var ruleset := JSON.parse_string(txt) as Dictionary
		if "schema" in ruleset:
			Global.validate_schema(ruleset, Ruleset.RULESET_SCHEMA)
			add_ruleset(
				RulesetIcon.new(
					{
						name = ruleset.name,
						description = ruleset.description,
						portrait = "res://asset".path_join(ruleset.icon as String),
						url = ""
					}
				)
			)
		else:
			add_ruleset(
				RulesetIcon.new(
					{
						name = ruleset.ruleset,
						description = ruleset.description,
						portrait = "res://asset/ruleset_icon/simple.png",
						url = ""
					}
				)
			)


func add_ruleset(ruleset: RulesetIcon) -> void:
	var button: RulesetButton = ruleset_button.instantiate()
	button.ruleset = ruleset
	button.horvered.connect(_on_button_horvered)
	button.mouse_exited.connect(_on_button_unhorvered)
	button.selected.connect(_on_button_selected)
	%RulesetList.add_child(button)


func _on_request_complete(
	_result: int, _response_code: int, _headers: PackedStringArray, body: PackedByteArray
) -> void:
	# TODO implement error handling
	return
	var response: Dictionary = JSON.parse_string(body.get_string_from_utf8())
	if first_time:
		for ruleset: Dictionary in response.rulesets:
			add_ruleset(RulesetIcon.new(ruleset))
		first_time = false
		_on_button_unhorvered()
		return
	var file := FileAccess.open(
		Global.rulesets_path.path_join("%s.json" % response.ruleset), FileAccess.WRITE
	)
	file.store_string(JSON.stringify(response))
	selected_ruleset = response


func _on_button_horvered(name_: String, description: String) -> void:
	%RulesetName.text = name_
	%RulesetDescription.text = description


func _on_button_unhorvered() -> void:
	_on_button_horvered("Select a ruleset", "Select a ruleset to start playing")


func _on_button_selected(ruleset: RulesetIcon) -> void:
	if not ruleset.installed:
		$HTTPRequest.request(ruleset.url)
		await $HTTPRequest.request_completed
	else:
		var file := FileAccess.open("user://rulesets/%s.json" % ruleset.name, FileAccess.READ)
		selected_ruleset = JSON.parse_string(file.get_as_text())
	Global.ruleset = RulesetParser.parse_ruleset(selected_ruleset)
	visible = false
