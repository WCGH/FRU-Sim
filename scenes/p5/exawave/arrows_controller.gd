extends Node3D

class_name ArrowsController

@onready var arrows_anim: AnimationPlayer = $ArrowsAnim


func play_arrow_arc():
	arrows_anim.play("arrow_arc")
