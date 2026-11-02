extends Node

const DATA := {
	"Naran": preload("res://Groups/Group C/Naran Dorzhieva/Naran_Dorzhieva.tres"),
	"Chu-Jae": preload("res://Groups/Group C/Chu-Jae Dokgo/Chu-Jae_Dokgo.tres"),
	"Pietro": preload("res://Groups/Group C/Pietro Affrescuro/Pietro.tres"),
	"Cole": preload("res://Groups/Group C/Cole Markus/Cole.tres"),
	"Rodrigo": preload("res://Groups/Group C/Rodrigo Lounareth/Rodrigo.tres"),
	"Sarpa": preload("res://Groups/Group C/Sarpa Cascavel/Sarpa.tres"),
	"Sergio": preload("res://Groups/Group C/Sergio Villalobos/Sergio.tres"),
	"Yuli": preload("res://Groups/Group C/Yuli Estrelanches/Yuli.tres"),
	"Zeke": preload("res://Groups/Group C/Zeke Floranches/Zeke.tres"),
	"Reina": preload("res://Groups/Group C/Reina Floranches/Reina.tres"),
	"Niloas": preload("res://Groups/Group C/Niloas Stjarnberg/Niloas.tres"),
	"Lina": preload("res://Groups/Group C/Lina Saranis/Lina.tres"),
	"Fernanda": preload("res://Groups/Group C/Fernanda Graice/Fernanda.tres"),
	"Leon": preload("res://Groups/Group C/Leon d'Avingon/Leon.tres"),
	"Anton": preload("res://Groups/Group C/Anton Berisha/Anton.tres"),
	"Deria": preload("res://Groups/Group C/Deria Kayan/Deria.tres"),
	}

func get_data(speaker: String) -> CharacterData:
	return DATA.get (speaker)

func get_all_ids() -> Array:
	return DATA.keys()
