extends Node3D

@onready var highlight_anim: AnimationPlayer = %HighlightAnim


func play_fade_in():
	highlight_anim.play("fade_in")


func play_fade_out():
	highlight_anim.play("fade_out")
