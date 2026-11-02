@tool
extends StaticBody3D

@export var object_name: String = "Object"
@export var texture: Texture2D:
	set(value):
		texture = value
		_apply_texture()
@export var right_texture: Texture2D:
	set(value):
		right_texture = value
		_apply_texture()
@export var left_texture: Texture2D
@export var back_texture: Texture2D
@export var footprint: Vector2 = Vector2.ZERO:
	set(value):
		footprint = value
		_apply_texture()
@export var dialogue: DialogueResource
@export var cue: String = "start"

func _ready() -> void:
	_apply_texture()

func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		return
	var camera := get_viewport().get_camera_3d()
	if camera == null:
		return
	var sprite: Sprite3D = $Sprite3D
	var relative := wrapf(camera.global_rotation.y - global_rotation.y, -PI, PI)
	sprite.rotation.y = relative
	var view := posmod(roundi(relative / (PI / 2.0)), 4)
	sprite.flip_h = false
	sprite.flip_h = false
	match view:
		0:
			sprite.texture = texture
		2:
			sprite.texture = back_texture if back_texture else texture
		1:
			_show_side(sprite, left_texture, right_texture)
		3:
			_show_side(sprite, right_texture, left_texture)

func _apply_texture() -> void:
	var sprite := get_node_or_null("Sprite3D") as Sprite3D
	var collision := get_node_or_null("CollisionShape3D") as CollisionShape3D
	if sprite == null or collision == null:
		return
	sprite.texture = texture
	if texture == null:
		return
	var w := texture.get_width() * sprite.pixel_size
	var h := texture.get_height() * sprite.pixel_size
	sprite.position.y = h / 2
	var side := right_texture if right_texture else left_texture
	var depth := side.get_width() * sprite.pixel_size if side else w
	var base := footprint if footprint != Vector2.ZERO else Vector2(w, depth)
	var box := BoxShape3D.new()
	box.size = Vector3(base.x, h, base.y)
	collision.shape = box
	collision.position.y = h / 2

func interact() -> void:
	if dialogue == null:
		print("No Dialogue Attached: ", object_name)
		return
	DialogueManager.show_dialogue_balloon(dialogue, cue)


func _show_side(sprite: Sprite3D, own: Texture2D, other: Texture2D) -> void:
	if own:
		sprite.texture = own
	elif other:
		sprite.texture = other
		sprite.flip_h = true
	else:
		sprite.texture = texture
