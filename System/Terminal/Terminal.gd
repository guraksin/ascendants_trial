extends CanvasLayer

var enabled: bool = false
var current: int = 0
var _previous_focus: Control = null
var save_allowed: bool = false

@onready var save_tab: Control = %SaveTab
@onready var save_tab_button: Button = %SaveTabButton
@onready var tab_buttons: Container = %TabButtons
@onready var pages: Control = %Pages


func _ready() -> void:
	hide()
	for i in tab_buttons.get_child_count():
		tab_buttons.get_child(i).pressed.connect(select_tab.bind(i))
	select_tab(0)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("terminal") and enabled:
		get_viewport().set_input_as_handled()
		if visible:
			close()
		else:
			open()
	elif visible and event.is_action_pressed("terminal_next"):
		get_viewport().set_input_as_handled()
		select_tab(current + 1)
	elif visible and event.is_action_pressed("terminal_prev"):
		get_viewport().set_input_as_handled()
		select_tab(current - 1)


func select_tab(index: int) -> void:
	current = posmod(index, pages.get_child_count())
	for i in pages.get_child_count():
		pages.get_child(i).visible = i == current
		tab_buttons.get_child(i).button_pressed = i == current


func open() -> void:
	_previous_focus = get_viewport().gui_get_focus_owner()
	save_tab_button.text = save_tab.save_object()["tab"]
	get_tree().paused = true
	show()


func close() -> void:
	hide()
	get_tree().paused = false
	if is_instance_valid(_previous_focus):
		_previous_focus.grab_focus()
