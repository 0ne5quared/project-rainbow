class_name RulesetParser
extends Object

const latest_version := "v1"


static func parse_ruleset(ruleset: Dictionary) -> Ruleset:
	if "schema" in ruleset:
		match ruleset.schema:
			latest_version:
				return Ruleset.new(ruleset)
			_:
				return Ruleset.new(ruleset)
	else:
		return IMFRuleset.new(ruleset)
