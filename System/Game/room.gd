@tool
extends Node3D

const SIDE_ANGLES := [0.0, -90.0, 180.0, 90.0]
const PIXEL := 0.025
const WALL_STRETCH := 1.414
const EXIT_DEPTH := 0.5
const PLAYER_RADIUS := 0.3

@export_tool_button("Odayı Yeniden Kur") var rebuild_button: Callable = _rebuild

@export_group("Room")
@export var room_width: float = 8.0:
	set(value):
		room_width = value
		_rebuild()
@export var room_depth: float = 6.0:
	set(value):
		room_depth = value
		_rebuild()
@export var wall_height: float = 3.0:
	set(value):
		wall_height = value
		_rebuild()
@export var floor_material: Material:
	set(value):
		floor_material = value
		_rebuild()
@export var wall_material: Material:
	set(value):
		wall_material = value
		_rebuild()
@export var openings: Array[RoomOpening] = []:
	set(value):
		openings = value
		_rebuild()

@export_group("Frame")
@export var frame_thickness: float = 0.15:
	set(value):
		frame_thickness = value
		_rebuild()
@export var frame_color: Color = Color.BLACK:
	set(value):
		frame_color = value
		_rebuild()
@export_range(0.0, 1.0) var stub_shadow: float = 0.7:
	set(value):
		stub_shadow = value
		_rebuild()

@export_group("Turn")
@export var turn_trans: Tween.TransitionType = Tween.TRANS_QUART
@export var turn_ease: Tween.EaseType = Tween.EASE_OUT
@export var turn_time: float = 0.3
@export_range(0.0, 90.0) var trim_hide_angle: float = 70.0
@export var arrival_gap: float = 0.2

@onready var pivot: Node3D = $CameraPivot

var walls: Array[Node3D] = []
var facing: int = 0
var _turning: bool = false
var _blocking_zones: int = 0
var _trims: Array[Node3D] = []
var _turn_old: int = -1
var _turn_start_y: float = 0.0
var _door_sprites: Dictionary = {}
var _doors: Array[DoorTrigger] = []
var _generated: Node3D


func _ready() -> void:
	_rebuild()
	if Engine.is_editor_hint():
		return
	Terminal.enabled = true
	GameState.scene_path = get_tree().current_scene.scene_file_path
	GameState.set_flag("newsense_unlocked")  # GEÇİCİ!!!!!! test için kalsın
	_place_arrival()

func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		return
	if _turn_old >= 0 and absf(pivot.rotation_degrees.y - _turn_start_y) >= trim_hide_angle:
		_trims[_turn_old].visible = false


func _unhandled_input(event: InputEvent) -> void:
	if Engine.is_editor_hint():
		return
	if not GameState.has_flag("newsense_unlocked"):
		return
	if _turning:
		return
	if _blocking_zones > 0:
		return
	if GameState.in_dialogue:
		return
	if Transition.busy:
		return
	if event.is_action_pressed("camera_right"):
		turn(1)
	elif event.is_action_pressed("camera_left"):
		turn(-1)

func turn(direction: int) -> void:
	_turning = true
	_turn_old = facing
	_turn_start_y = pivot.rotation_degrees.y
	facing = posmod(facing + direction, 4)
	_update_doors()
	walls[facing].visible = true
	var target := pivot.rotation_degrees.y - 90.0 * direction
	var tween := create_tween().set_trans(turn_trans).set_ease(turn_ease)
	tween.tween_property(pivot, "rotation_degrees:y", target, turn_time)
	await tween.finished
	_turn_old = -1
	_show_only_far_wall()
	_turning = false


func _show_only_far_wall() -> void:
	_update_doors()
	for i in walls.size():
		walls[i].visible = i == facing
		_trims[i].visible = true


# ---------- Kurulum ---------- #

func _rebuild() -> void:
	if not is_node_ready():
		return
	if _generated:
		remove_child(_generated)
		_generated.free()
	walls.clear()
	_trims.clear()
	_doors.clear()
	_door_sprites.clear()
	_blocking_zones = 0
	_generated = Node3D.new()
	_generated.name = "Generated"
	add_child(_generated)
	_build_frame()
	_show_only_far_wall()


func _build_frame() -> void:
	_fit_doors()
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	material.albedo_color = frame_color
	var h := wall_height
	var t := frame_thickness

	_add_part(_generated, PlaneMesh.new(), Vector2(room_width, room_depth), Vector3.ZERO, floor_material)

	for i in 4:
		var half_depth := (room_depth if i % 2 == 0 else room_width) / 2
		var wall := Node3D.new()
		wall.rotation_degrees.y = SIDE_ANGLES[i]
		wall.position = Vector3(0, h / 2, 0) + Vector3(0, 0, -half_depth).rotated(Vector3.UP, deg_to_rad(SIDE_ANGLES[i]))
		_generated.add_child(wall)
		walls.append(wall)

	for i in 4:
		_build_wall(i)
		var length := room_width if i % 2 == 0 else room_depth
		var trim := Node3D.new()
		walls[i].add_child(trim)
		_trims.append(trim)
		_add_part(trim, PlaneMesh.new(), Vector2(length + 2 * t, t), Vector3(0, h / 2, -t / 2), material)
		_add_part(trim, QuadMesh.new(), Vector2(t, h), Vector3(-length / 2 - t / 2, 0, 0), material)
		_add_part(trim, QuadMesh.new(), Vector2(t, h), Vector3(length / 2 + t / 2, 0, 0), material)

	for i in 4:
		_build_side(i, material)


func _add_part(parent: Node3D, mesh: PrimitiveMesh, size: Vector2, pos: Vector3, material: Material) -> void:
	mesh.size = size
	var part := MeshInstance3D.new()
	part.mesh = mesh
	part.material_override = material
	part.position = pos
	parent.add_child(part)


func _build_side(i: int, material: Material) -> void:
	var t := frame_thickness
	var length := room_width if i % 2 == 0 else room_depth
	var half_depth := (room_depth if i % 2 == 0 else room_width) / 2
	var side := Node3D.new()
	side.rotation_degrees.y = SIDE_ANGLES[i]
	_generated.add_child(side)
	var body := StaticBody3D.new()
	side.add_child(body)

	var gaps := _openings_on(i)

	var start := -length / 2 - t
	var col_start := -length / 2 - t
	for opening: RoomOpening in gaps:
		_add_edge(side, start, opening.offset - opening.width / 2, -half_depth - t / 2, material)
		start = opening.offset + opening.width / 2
		_build_stub(side, opening, half_depth, material)
		_add_wall_collision(body, col_start, opening.offset - opening.width / 2, half_depth)
		col_start = opening.offset + opening.width / 2
		_build_passage(side, body, opening, half_depth)
		if opening.has_door:
			_build_door(side, opening, half_depth)
	_add_edge(side, start, length / 2 + t, -half_depth - t / 2, material)
	_add_wall_collision(body, col_start, length / 2 + t, half_depth)


func _build_wall(i: int) -> void:
	var wall := walls[i]
	var h := wall_height
	var length := room_width if i % 2 == 0 else room_depth
	var start := -length / 2
	for opening: RoomOpening in _openings_on(i):
		var left := opening.offset - opening.width / 2
		if left > start:
			_add_part(wall, QuadMesh.new(), Vector2(left - start, h), Vector3((start + left) / 2, 0, 0), wall_material)
		var lintel := h - opening.hole_height
		if lintel > 0:
			_add_part(wall, QuadMesh.new(), Vector2(opening.width, lintel), Vector3(opening.offset, opening.hole_height / 2, 0), wall_material)
		if opening.has_door and opening.door_closed:
			var door := Sprite3D.new()
			door.texture = opening.door_closed
			door.pixel_size = PIXEL
			door.scale.y = WALL_STRETCH
			door.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
			door.alpha_cut = SpriteBase3D.ALPHA_CUT_DISCARD
			var floor_row := opening.hole_height / (PIXEL * WALL_STRETCH)
			var half_rows := opening.door_closed.get_height() / 2.0
			door.position = Vector3(opening.offset, -h / 2 + (floor_row - half_rows) * PIXEL * WALL_STRETCH, 0.01)
			wall.add_child(door)
			_door_sprites[opening] = door
		start = opening.offset + opening.width / 2
	if length / 2 > start:
		_add_part(wall, QuadMesh.new(), Vector2(length / 2 - start, h), Vector3((start + length / 2) / 2, 0, 0), wall_material)


func _build_stub(side: Node3D, opening: RoomOpening, half_depth: float, material: Material) -> void:
	var t := frame_thickness
	var w := opening.width
	var l := opening.stub_length
	var z := -half_depth - l / 2
	_add_part(side, PlaneMesh.new(), Vector2(w, l), Vector3(opening.offset, 0, z), floor_material)
	_add_part(side, PlaneMesh.new(), Vector2(t, l), Vector3(opening.offset - w / 2 - t / 2, 0.01, z), material)
	_add_part(side, PlaneMesh.new(), Vector2(t, l), Vector3(opening.offset + w / 2 + t / 2, 0.01, z), material)
	var gradient := Gradient.new()
	gradient.set_color(0, Color(0, 0, 0, 0))
	gradient.set_color(1, Color(0, 0, 0, 1))
	gradient.set_offset(0, 1.0 - stub_shadow)
	var texture := GradientTexture2D.new()
	texture.gradient = gradient
	texture.fill = GradientTexture2D.FILL_RADIAL
	texture.fill_from = Vector2(0.5, 1.0)
	texture.fill_to = Vector2(0.5, 0.0)
	var shadow := StandardMaterial3D.new()
	shadow.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	shadow.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	shadow.albedo_texture = texture
	shadow.texture_repeat = false
	_add_part(side, PlaneMesh.new(), Vector2(w, l), Vector3(opening.offset, 0.005, z), shadow)

func _build_passage(side: Node3D, body: StaticBody3D, opening: RoomOpening, half_depth: float) -> void:
	var w := opening.width
	var l := opening.stub_length
	var h := wall_height
	var z := -half_depth - l / 2
	# Koridorun iki yan duvarı ve ucu
	_add_box(body, Vector3(0.2, h, l), Vector3(opening.offset - w / 2 - 0.1, h / 2, z))
	_add_box(body, Vector3(0.2, h, l), Vector3(opening.offset + w / 2 + 0.1, h / 2, z))
	_add_box(body, Vector3(w, h, 0.2), Vector3(opening.offset, h / 2, -half_depth - l - 0.1))
	# Q/E kilit bölgesi
	var zone := Area3D.new()
	side.add_child(zone)
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(w, h, l)
	shape.shape = box
	shape.position = Vector3(opening.offset, h / 2, z)
	zone.add_child(shape)
	zone.body_entered.connect(_on_zone_entered)
	zone.body_exited.connect(_on_zone_exited)
		# Çıkış tetikleyicisi
	if opening.target_scene != "":
		var exit := Area3D.new()
		side.add_child(exit)
		var exit_shape := CollisionShape3D.new()
		var exit_box := BoxShape3D.new()
		exit_box.size = Vector3(w, h, EXIT_DEPTH)
		exit_shape.position = Vector3(opening.offset, h / 2, -half_depth - l + EXIT_DEPTH / 2)
		exit_shape.shape = exit_box
		exit_shape.position = Vector3(opening.offset, h / 2, -half_depth - l + 0.25)
		exit.add_child(exit_shape)
		exit.body_entered.connect(_on_exit_entered.bind(opening))

func _build_door(side: Node3D, opening: RoomOpening, half_depth: float) -> void:
	var door := DoorTrigger.new()
	door.opening = opening
	door.sprite = _door_sprites.get(opening)
	side.add_child(door)
	_add_box(door, Vector3(opening.width, wall_height, 0.2), Vector3(opening.offset, wall_height / 2, -half_depth - 0.1))
	_doors.append(door)


func _update_doors() -> void:
	for door: DoorTrigger in _doors:
		door.collision_layer = 1 if door.opening.wall == facing else 0


func _add_edge(parent: Node3D, from_x: float, to_x: float, z: float, material: Material) -> void:
	if to_x <= from_x:
		return
	_add_part(parent, PlaneMesh.new(), Vector2(to_x - from_x, frame_thickness), Vector3((from_x + to_x) / 2, 0.01, z), material)


func _add_wall_collision(body: StaticBody3D, from_x: float, to_x: float, half_depth: float) -> void:
	if to_x <= from_x:
		return
	_add_box(body, Vector3(to_x - from_x, wall_height, 0.2), Vector3((from_x + to_x) / 2, wall_height / 2, -half_depth - 0.1))


func _add_box(body: StaticBody3D, size: Vector3, pos: Vector3) -> void:
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = size
	shape.shape = box
	shape.position = pos
	body.add_child(shape)


func _on_zone_entered(body: Node3D) -> void:
	if body is CharacterBody3D:
		_blocking_zones += 1


func _on_zone_exited(body: Node3D) -> void:
	if body is CharacterBody3D:
		_blocking_zones -= 1


func _openings_on(i: int) -> Array[RoomOpening]:
	var result: Array[RoomOpening] = []
	for opening: RoomOpening in openings:
		if opening.wall == i:
			result.append(opening)
	result.sort_custom(func(a, b): return a.offset < b.offset)
	return result


func _fit_doors() -> void:
	for opening: RoomOpening in openings:
		if opening.has_door and opening.door_closed:
			var used := opening.door_closed.get_image().get_used_rect()
			opening.width = used.size.x * PIXEL
			opening.hole_height = used.end.y * PIXEL * WALL_STRETCH


func _on_exit_entered(body: Node3D, opening: RoomOpening) -> void:
	if Engine.is_editor_hint():
		return
	if body is CharacterBody3D:
		Transition.go(opening.target_scene, opening.target_id)


func _place_arrival() -> void:
	var id := Transition.arrival_id
	if id == "":
		return
	Transition.arrival_id = ""
	var player := get_tree().get_first_node_in_group("player")
	if player == null:
		return
	for opening: RoomOpening in openings:
		if opening.id == id:
			var angle := deg_to_rad(SIDE_ANGLES[opening.wall])
			var half_depth := (room_depth if opening.wall % 2 == 0 else room_width) / 2
			var z := -half_depth - opening.stub_length + EXIT_DEPTH + PLAYER_RADIUS + arrival_gap
			var local := Vector3(opening.offset, 0, z).rotated(Vector3.UP, angle)
			player.global_position = to_global(local)
			player.facing = Vector3.BACK.rotated(Vector3.UP, angle)
			return
	push_warning("Varış geçidi bulunamadı: " + id)
