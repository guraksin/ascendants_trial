extends CanvasLayer

signal closed

var saved: bool = false
var _list: VBoxContainer


func _ready() -> void:
	layer = 150
	process_mode = Node.PROCESS_MODE_ALWAYS
	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(center)
	var panel := PanelContainer.new()
	center.add_child(panel)
	_list = VBoxContainer.new()
	panel.add_child(_list)
	hide()


func open() -> void:
	saved = false
	for child in _list.get_children():
		child.queue_free()
	var title := Label.new()
	title.text = "Save your session"
	_list.add_child(title)
	var first: Button = null
	for i in SaveSystem.SLOT_COUNT:
		var slot := i + 1
		var button := Button.new()
		button.text = "Slot %d: %s" % [slot, SaveSystem.describe(slot)]
		button.pressed.connect(_on_slot_pressed.bind(slot))
		_list.add_child(button)
		if first == null:
			first = button
	var cancel := Button.new()
	cancel.text = "Never mind"
	cancel.pressed.connect(_close)
	_list.add_child(cancel)
	show()
	await get_tree().process_frame
	first.grab_focus()
	await closed


func _unhandled_input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		_close()


func _on_slot_pressed(slot: int) -> void:
	saved = SaveSystem.save_slot(slot)
	_close()


func _close() -> void:
	hide()
	closed.emit()
