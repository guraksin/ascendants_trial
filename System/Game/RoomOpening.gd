class_name  RoomOpening
extends Resource

@export_enum("North", "East", "South", "West") var wall: int = 2
@export var offset: float = 0.0
@export var width: float = 1.2
@export var stub_length: float = 1.5
@export var has_door: bool = true
@export var hole_height: float = 2.0

@export var door_closed: Texture2D
@export var door_open: Texture2D
@export var id: String = ""
@export_file("*.tscn") var target_scene: String = ""
@export var target_id: String = ""
