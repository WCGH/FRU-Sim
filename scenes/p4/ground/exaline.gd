# Copyright 2025
# All rights reserved.
# This file is released under "GNU General Public License 3.0".
# Please see the LICENSE file that should have been included as part of this package.

extends Node3D

class_name Exaline

const ANIM_KEY := {"n": "exaline_N", "s": "exaline_S", "e": "exaline_E", "w": "exaline_W"}
const LINE_TARGETS := {"n": Vector2(-50, 0), "s": Vector2(50, 0), "e": Vector2(0, -50), "w": Vector2(0, 50)}
const STARTING_POS := Vector2(0, 47.48)

const EXALINE_LENGTH := 23.74
const EXALINE_WIDTH := 97.0
const EXALINE_LIFETIME := 0.7
const EXALINE_COLOR := Color(1, 0.647059, 0, 0.5)

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var ground_aoe_controller: GroundAoeController = get_tree().get_first_node_in_group("ground_aoe_controller")


func play_exaline(cardinal: String) -> void:
	animation_player.play(ANIM_KEY[cardinal])


func spawn_line(pos: Vector2, cardinal: String) -> void:
	ground_aoe_controller.spawn_line(pos, EXALINE_WIDTH, EXALINE_LENGTH, LINE_TARGETS[cardinal],
		EXALINE_LIFETIME, EXALINE_COLOR, [0, 0, "Tidal Light (Exawave)"])
