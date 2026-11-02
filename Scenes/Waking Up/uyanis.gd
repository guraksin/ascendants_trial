extends Control

@onready var cg: TextureRect = $CG

const CGS := {
	"corpse": preload("res://Scenes/Waking Up/corpse.png"),
	"tavan": preload("res://Scenes/Waking Up/tavan.png"),
}

func _ready() -> void:
	Terminal.enabled = true
	GameState.scene_path = scene_file_path
	Terminal.save_allowed = true #GEÇİCİ!!!! NOTEBOOK EKLENİNCE SİLİNECEK!!!!
	cg.visible = false
	var dialogue := load("res://Scenes/Waking Up/WakingUp.dialogue")
	DialogueManager.show_dialogue_balloon(dialogue, "start", [self])

func show_cg(id: String) -> void:
	cg.texture = CGS[id]
	cg.modulate.a = 0.0
	cg.visible = true
	var tween := create_tween()
	tween.tween_property(cg, "modulate:a", 1.0, 0.6)
	await tween.finished
