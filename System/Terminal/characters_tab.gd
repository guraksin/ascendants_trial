extends Control

@onready var icons_left: VBoxContainer = %IconsLeft
@onready var icons_right: VBoxContainer = %IconsRight
@onready var picture: TextureRect = %Picture
@onready var detail: RichTextLabel = %Detail

var _ids: Array = []
var _buttons: Array = []
var _index: int = 0

func _ready() -> void:
	GameState.changed.connect(refresh)
	refresh()


func _input(event: InputEvent) -> void:
	if not is_visible_in_tree():
		return
	if event.is_action_pressed("terminal_down"):
		get_viewport().set_input_as_handled()
		select(_index + 1)
	elif event.is_action_pressed("terminal_up"):
		get_viewport().set_input_as_handled()
		select(_index - 1)

func refresh() -> void:
	_ids = Characters.get_all_ids()
	for button in _buttons:
		button.get_parent().remove_child(button)
		button.queue_free()
	_buttons.clear()
	var half := ceili(_ids.size() / 2.0)
	for i in _ids.size():
		var button := _make_icon(i)
		_buttons.append(button)
		if i < half:
			icons_left.add_child(button)
		else:
			icons_right.add_child(button)
	select(_index)


func _make_icon(i: int) -> Button:
	var id: String = _ids[i]
	var button := Button.new()
	button.custom_minimum_size = Vector2(56, 56)
	button.toggle_mode = true
	button.focus_mode = Control.FOCUS_NONE
	if GameState.has_met(id):
		var data: CharacterData = Characters.get_data(id)
		if data.icon != null:
			button.icon = data.icon
			button.expand_icon = true
		else:
			button.text = data.display_name.left(1)
	else:
		button.text = "?"
	button.pressed.connect(select.bind(i))
	return button


func select(index: int) -> void:
	if _ids.is_empty():
		return
	_index = posmod(index, _ids.size())
	for i in _buttons.size():
		_buttons[i].button_pressed = i == _index
	_show(_ids[_index])


func _show(id: String) -> void:
	if not GameState.has_met(id):
		picture.texture = null
		detail.text = "[b]???[/b]\nBorn: ???\nRegion: ???\n\nNo data."
		return
	var data: CharacterData = Characters.get_data(id)
	var year := str(data.birth_year) if GameState.knows(id, "birth_year") else "???"
	var region := data.region if GameState.knows(id, "region") else "???"
	var bio := data.bio if GameState.knows(id, "bio") else "No further data."
	picture.texture = data.default_portrait
	detail.text = "[b]%s[/b]\nBorn: %s\nRegion: %s\n\n%s" % [data.display_name, year, region, bio]
