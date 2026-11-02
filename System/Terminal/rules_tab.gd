extends Control

const RULES := {
	"witness_threshold": {
		"title": "Witness Threshold",
		"text": "When a groups current population of 4/1 see a corpse, the System announces it to make everybody know where and what exactly happened.",
	},
}

@onready var rules_text: RichTextLabel = %RulesText


func _ready() -> void:
	GameState.changed.connect(refresh)
	refresh()


func refresh() -> void:
	var entries: Array = []
	for id in GameState.rules:
		var rule: Dictionary = RULES.get(id, {})
		entries.append("[b]%s[/b]\n%s" % [rule.get("title", id), rule.get("text", "")])
	rules_text.text = "No entries." if entries.is_empty() else "\n\n".join(entries)
