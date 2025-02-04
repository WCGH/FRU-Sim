# Copyright 2025
# All rights reserved.
# This file is released under "GNU General Public License 3.0".
# Please see the LICENSE file that should have been included as part of this package.

extends Node3D

class_name Oracle

@onready var animation_tree: AnimationTree = $AnimationTree
@onready var state_machine: AnimationNodeStateMachinePlayback = animation_tree["parameters/playback"]


func play_ur_cast() -> void:
	state_machine.travel("big_cast_start")


func play_flip_special() -> void:
	state_machine.travel("flip_cast")


func play_ct_cast() -> void:
	state_machine.travel("short_cast")


func play_hide() -> void:
	state_machine.travel("fade_out_idle")


func play_show() -> void:
	state_machine.travel("fade_in_idle")


func play_slash() -> void:
	state_machine.travel("slash_cast")
