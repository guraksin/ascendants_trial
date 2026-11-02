extends Node

signal changed

var flags: Dictionary = {}
var rules: Array = []
var known: Dictionary = {}
var bonds: Dictionary = {}
var scene_path: String = ""
var checkpoint: String = "start"
var protagonist: String= "Chu-Jae"
var in_dialogue: bool = false

func _ready() -> void:
	DialogueManager.dialogue_started.connect(_on_dialogue_started)
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)


func _on_dialogue_started(_resource: DialogueResource) -> void:
	in_dialogue = true


func _on_dialogue_ended(_resource: DialogueResource) -> void:
	await get_tree().process_frame
	in_dialogue = false

func reset() -> void:
	flags = {}
	rules = []
	known = {}
	bonds = {}
	scene_path = ""
	checkpoint = "start"
	protagonist = "Chu-Jae"
	changed.emit()

# ----- Flags ----- #

func learn_rule(id: String) -> void:
	if not rules.has(id):
		rules.append(id)
		changed.emit()

func set_flag(id: String, value: Variant = true) -> void:
	flags[id] = value
	changed.emit()

func has_flag(id: String) -> bool:
	return flags.get(id, false)

# ---- Character Info ---- #

func true_value(character: String, field: String) -> Variant:
	var data: CharacterData = Characters.get_data(character)
	if data == null:
		return null
	if field == "name":
		return data.display_name
	return data.get(field)

func learn(character: String, field: String, believed: Variant = null) -> void:
	if believed == null:
		believed = true_value(character, field)
	if not known.has(character):
		known [character] = {}
	known[character][field] = believed
	changed.emit()

func knows(character: String, field: String) -> bool:
	if not known.has(character) or not known[character].has(field):
		return false
	return known[character][field] == true_value(character, field)
	
func has_met(character: String) -> bool:
	return knows(character, "name")

# ---- Bond Function ---- #

func add_bond(character: String, amount: int) -> void:
	bonds[character] = get_bond(character) + amount
	changed.emit()

func get_bond(character: String) -> int:
	return bonds.get(character, 0)

# ---- Save/Load Function ---- #

func to_dict() -> Dictionary:
	return {
		"flags": flags,
		"rules": rules,
		"known": known,
		"bonds": bonds,
		"scene_path": scene_path,
		"checkpoint": checkpoint,
		"protagonist": protagonist,
	}

func from_dict(data: Dictionary) -> void:
	flags = data.get("flags", {})
	rules = data.get("rules", [])
	known = data.get("known", {})
	bonds = data.get("bonds", {})
	scene_path = data.get("scene_path", "")
	checkpoint = data.get("checkpoint", "start")
	protagonist = data.get("protagonist", "Chu-Jae")
	changed.emit()
