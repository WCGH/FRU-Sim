# Copyright 2025
# All rights reserved.
# This file is released under "GNU General Public License 3.0".
# Please see the LICENSE file that should have been included as part of this package.

extends Node3D

class_name WaveController

const WAVE_WIDTH := 11.855
const WAVE_LENGTH := 140.0
const MAX_HITS := 7
#const EXA_COLOR := Color.DARK_RED
const EXA_COLOR := Color.TRANSPARENT
const EXA_DURATION := 0.1

@onready var wave_position: Node3D = %WavePosition
@onready var wave_visual: Node3D = %WaveVisual
@onready var wave_anim: AnimationPlayer = %WaveAnim
@onready var ground_aoe_controller: GroundAoeController = get_tree().get_first_node_in_group("ground_aoe_controller")


func wave_hit():
	wave_anim.play("wave_hit")


# Snapshot happens at least 0.2s before hit.
func snapshot_hit():
	var pos = Vector2(wave_position.global_position.x, wave_position.global_position.z)
	var tar = Vector2(wave_visual.global_position.x, wave_visual.global_position.z)
	if !ground_aoe_controller:
		ground_aoe_controller = get_tree().get_first_node_in_group("ground_aoe_controller")
	ground_aoe_controller.spawn_line(pos, WAVE_LENGTH, WAVE_WIDTH, tar, EXA_DURATION, EXA_COLOR, [0, 0, "The Path of Light (Exaline)"])

# Move wave to next spot and await next hit.
func move_wave():
	wave_position.position.z -= WAVE_WIDTH
	
