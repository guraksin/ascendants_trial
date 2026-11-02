extends CanvasLayer

@export var fade_time: float = 0.25

var busy: bool = false
var arrival_id: String = ""
var _rect: ColorRect


func _ready() -> void:
	layer = 100
	process_mode = Node.PROCESS_MODE_ALWAYS
	_rect = ColorRect.new()
	_rect.color = Color.BLACK
	_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_rect.modulate.a = 0.0
	add_child(_rect)


func go(scene_path: String, target_id: String) -> void:
	if busy:
		return
	busy = true
	arrival_id = target_id
	await _fade(1.0)
	get_tree().change_scene_to_file(scene_path)
	await get_tree().process_frame
	await get_tree().process_frame
	await _fade(0.0)
	busy = false


func _fade(alpha: float) -> void:
	var tween := create_tween()
	tween.tween_property(_rect, "modulate:a", alpha, fade_time)
	await tween.finished
