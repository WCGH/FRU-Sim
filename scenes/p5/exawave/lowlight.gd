extends Node3D

@onready var lowlight_anim: AnimationPlayer = %LowlightAnim


func play_fade_in():
	lowlight_anim.play("fade_in")


func play_fade_out():
	lowlight_anim.play("fade_out")
