extends Node

const VERSION := 1
const SLOT_COUNT :=3


func slot_path(slot: int) -> String:
	return "user://save_%d.json" % slot

func has_slot(slot: int) -> bool:
	return not _read_json(slot_path(slot)).is_empty()

func describe(slot: int) -> String:
	var data := _read_json(slot_path(slot))
	if data.is_empty():
		return "Empty"
	return str(data.get("saved_at", "Unknown"))

func save_slot(slot: int) -> bool:
	var data := {
		"version": VERSION,
		"saved_at": Time.get_datetime_string_from_system(false, true),
		"state": GameState.to_dict(),
	}
	return _write_json(slot_path(slot), data)

func load_slot(slot: int) -> bool:
	var data := _read_json(slot_path(slot))
	if data.is_empty() or not data.has("state"):
		return false
	GameState.from_dict(data["state"])
	return true

func _write_json(path: String, data: Dictionary) -> bool:
	var tmp := path + ".tmp"
	var file := FileAccess.open(tmp, FileAccess.WRITE)
	if file == null:
		return false
	file.store_string(JSON.stringify(data, "\t"))
	file.close()
	if FileAccess.file_exists(path):
		DirAccess.rename_absolute(path, path + ".bak")
	return DirAccess.rename_absolute(tmp, path) == OK

func _read_json(path: String) -> Dictionary:
	for candidate in [path, path + ".bak"]:
		if not FileAccess.file_exists(candidate):
			continue
		var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(candidate))
		if parsed is Dictionary:
			return parsed
	return {}

func has_any() -> bool:
	for slot in range(1, SLOT_COUNT + 1):
		if has_slot(slot):
			return true
	return false
