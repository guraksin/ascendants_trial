extends Control

const SAVE_OBJECTS := {
	"Chu-Jae": {"tab": "Notebook", "hint": "Find a burgundy notebook around somewhere..."},
	"Shou": {"tab": "Trashcan", "hint": "Find a trash container..."},
	"Yumika": {"tab": "Trashcan", "hint": "Find a trash container..."}, 
}

@export_file("*.tscn") var main_menu_scene: String

@onready var notebook_button: Button = %NotebookButton
@onready var slots: VBoxContainer = %Slots
@onready var trash_button: Button = %TrashButton
@onready var confirm: Control = %Confirm
@onready var confirm_yes: Button = %ConfirmYes
@onready var confirm_no: Button = %ConfirmNo
@onready var status: Label = %Status

func _ready() -> void:
	notebook_button.pressed.connect(_on_notebook_pressed)
	trash_button.pressed.connect(confirm.show)
	confirm_yes.pressed.connect(_on_confirm_yes)
	confirm_no.pressed.connect(confirm.hide)
	visibility_changed.connect(_reset)
	for i in SaveSystem.SLOT_COUNT:
		var button := Button.new()
		button.pressed.connect(_on_slot_pressed.bind(i + 1))
		slots.add_child(button)
	_reset()

func save_object() -> Dictionary:
	return SAVE_OBJECTS.get(GameState.protagonist, SAVE_OBJECTS["Chu-Jae"])

func _reset() -> void:
	slots.hide()
	confirm.hide()
	notebook_button.disabled = not owner.save_allowed
	status.text = "" if owner.save_allowed else save_object()["hint"]

func _on_notebook_pressed() -> void:
	for i in SaveSystem.SLOT_COUNT:
		var button := slots.get_child(i) as Button
		button.text = "Slot %d: %s" % [i + 1, SaveSystem.describe(i + 1)]
	slots.show()

func _on_slot_pressed(slot: int) -> void:
	slots.hide()
	if SaveSystem.save_slot(slot):
		status.text = "Saved to slot %d." % slot
	else:
		status.text = "Save failed."

func _on_confirm_yes() -> void:
	Terminal.close()
	Terminal.enabled = false
	get_tree().change_scene_to_file(main_menu_scene)
