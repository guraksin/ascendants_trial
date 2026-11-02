extends CharacterBody3D

@export var speed: float = 3.0

@export_group("Interact")
@export var interact_length: float = 0.6
@export var interact_width: float = 0.4
@export var interact_height: float = 0.5

@onready var sprite: AnimatedSprite3D = $AnimatedSprite3D
@onready var interact_zone: Area3D = $InteractZone
@onready var interact_shape: BoxShape3D = $InteractZone/CollisionShape3D.shape

var facing: Vector3 = Vector3.BACK
var view: String = "down"

const CAMERA_PITCH := -45.0

func _physics_process(_delta: float) -> void:
	sprite.rotation.y = get_viewport().get_camera_3d().global_rotation.y
	if GameState.in_dialogue:
		sprite.play("idle_" + view)
		return
	var input := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var yaw := _snapped_yaw()
	var direction := Vector3(input.x, 0, input.y).rotated(Vector3.UP, yaw)

	velocity = direction * speed
	move_and_slide()

	if direction.length() > 0.1:
		facing = direction.normalized()
	_update_view(yaw)
	sprite.play(("walk_" if direction.length() > 0.1 else "idle_") + view)
	interact_shape.size = Vector3(interact_width, 1.0, interact_length)
	interact_zone.basis = Basis.looking_at(facing)
	interact_zone.position = facing * (0.3 + interact_length / 2) + Vector3(0, interact_height, 0)


func _update_view(yaw: float) -> void:
	var local := facing.rotated(Vector3.UP, -yaw)
	var margin := 0.15
	if absf(local.z) > absf(local.x) + margin:
		view = "down" if local.z > 0 else "up"
	elif absf(local.x) > absf(local.z) + margin:
		view = "right" if local.x > 0 else "left"


func _snapped_yaw() -> float:
	var raw := get_viewport().get_camera_3d().global_rotation.y
	return round(raw / (PI / 2.0)) * (PI / 2.0)


func _unhandled_input(event: InputEvent) -> void:
	if GameState.in_dialogue:
		return
	if event.is_action_pressed("interact"):
		for body in interact_zone.get_overlapping_bodies():
			if body.has_method("interact"):
				body.interact()
				return
