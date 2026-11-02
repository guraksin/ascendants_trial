extends Control

@export var dialogue: DialogueResource
@export var balloon_scene: PackedScene
@export_file ("*.tscn") var first_scene: String
@export_file("*.tscn") var a_version_scene: String

@onready var plush: TextureButton = $Plush

var talking: bool = false
var greeted: bool = false

func _ready() -> void:
	Terminal.enabled = false
	plush.pressed.connect(_on_plush_pressed)
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)
	plush.grab_focus()

func _on_plush_pressed() -> void:
	if talking:
		return
	talking = true
	var cue := "menu" if greeted else "start"
	greeted = true
	DialogueManager.show_dialogue_balloon_scene(balloon_scene,dialogue, cue, [self])

func _on_dialogue_ended(_resource: DialogueResource) -> void:
	talking = false
	if is_inside_tree():
		plush.grab_focus()

func start_game() -> void:
	GameState.reset()
	get_tree().change_scene_to_file(first_scene)

func start_a_version() -> void:
	GameState.reset()
	GameState.protagonist = "Yumika"
	Transition.go(a_version_scene, "")

func quit_game() -> void:
	get_tree().quit()

func load_game(slot: int) -> void:
	if not SaveSystem.load_slot(slot):
		return
	if GameState.scene_path == "":
		push_warning("Cannot detect a scene way %d" % slot)
		return
	Transition.go(GameState.scene_path, "")
