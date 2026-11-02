class_name CharacterData
extends Resource

@export var display_name: String
@export var default_portrait: Texture2D
@export var portraits: Dictionary[String, Texture2D] = {}
@export var icon: Texture2D

@export_group("Terminal")
@export_multiline var bio: String
@export var birth_year: int
@export var region: String
