class_name DoorTrigger
extends StaticBody3D

var opening: RoomOpening
var sprite: Sprite3D


func interact() -> void:
	if sprite and opening.door_open:
		sprite.texture = opening.door_open
	print("Door Opened")
