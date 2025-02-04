# Copyright 2025
# All rights reserved.
# This file is released under "GNU General Public License 3.0".
# Please see the LICENSE file that should have been included as part of this package.

extends Node3D

@onready var baselight_anim: AnimationPlayer = %BaselightAnim


func play_fade_in():
	baselight_anim.play("fade_in")


func play_fade_out():
	baselight_anim.play("fade_out")
