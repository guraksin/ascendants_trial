@tool
class_name BoxProp
extends StaticBody3D

const PIXEL := 0.025
const WALL_STRETCH := 1.414

@export var object_name: String = "Object"
@export var dialogue: DialogueResource
@export var cue: String = "start"

@export_group("Faces")
@export var front: Texture2D:
	set(value):
		front = value
		_rebuild()
@export var side: Texture2D:
	set(value):
		side = value
		_rebuild()
@export var back: Texture2D:
	set(value):
		back = value
		_rebuild()
@export var top: Texture2D:
	set(value):
		top = value
		_rebuild()
@export var body_color: Color = Color(0.25, 0.25, 0.28):
	set(value):
		body_color = value
		_rebuild()

var _generated: Node3D
var _shape: CollisionShape3D


func _ready() -> void:
	_rebuild()


func _rebuild() -> void:
	if not is_node_ready():
		return
	if _generated:
		remove_child(_generated)
		_generated.free()
		_generated = null
	if _shape:
		remove_child(_shape)
		_shape.free()
		_shape = null
	if front == null:
		return
	_generated = Node3D.new()
	add_child(_generated)

	var w := front.get_width() * PIXEL
	var h := front.get_height() * PIXEL * WALL_STRETCH
	var d := side.get_width() * PIXEL if side else w

	_face(QuadMesh.new(), Vector2(w, h), Vector3(0, h / 2, d / 2), 0.0, front)
	_face(QuadMesh.new(), Vector2(w, h), Vector3(0, h / 2, -d / 2), 180.0, back)
	_face(QuadMesh.new(), Vector2(d, h), Vector3(w / 2, h / 2, 0), 90.0, side)
	_face(QuadMesh.new(), Vector2(d, h), Vector3(-w / 2, h / 2, 0), -90.0, side)
	_face(PlaneMesh.new(), Vector2(w, d), Vector3(0, h, 0), 0.0, top)

	_shape = CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(w, h, d)
	_shape.shape = box
	_shape.position.y = h / 2
	add_child(_shape)


func _face(mesh: PrimitiveMesh, size: Vector2, pos: Vector3, angle: float, texture: Texture2D) -> void:
	mesh.size = size
	var part := MeshInstance3D.new()
	part.mesh = mesh
	part.position = pos
	part.rotation_degrees.y = angle
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
	if texture:
		material.albedo_texture = texture
	else:
		material.albedo_color = body_color
	part.material_override = material
	_generated.add_child(part)


func interact() -> void:
	if dialogue == null:
		print("No Dialogue Attached: ", object_name)
		return
	DialogueManager.show_dialogue_balloon(dialogue, cue)
