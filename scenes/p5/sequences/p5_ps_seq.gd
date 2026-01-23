# Copyright 2025
# All rights reserved.
# This file is released under "GNU General Public License 3.0".
# Please see the LICENSE file that should have been included as part of this package.

extends Node

const STRIKE_LIFETIME = 3.5
const ECHO_LIFETIME = 0.3
const STRIKE_WIDTH = 12
const STRIKE_LENGTH = 50
const DARK_COLOR := Color.DARK_VIOLET
const LIGHT_COLOR := Color.GOLD


@onready var p5_ps_anim: AnimationPlayer = %P5PSAnim
@onready var cast_bar: CastBar = %CastBar
@onready var ground_aoe_controller: GroundAoeController = %GroundAoEController
@onready var oracle_boss: Node3D = %OracleBoss
@onready var oracle: Oracle = %Oracle
@onready var fail_list: FailList = %FailList
@onready var hide_bots_check_button: CheckButton = %HideBotsCheckButton
@onready var encounter_controller: EncounterController = %EncounterController
@onready var light_wing_anim: AnimationPlayer = %LightWingAnim
@onready var dark_wing_anim: AnimationPlayer = %DarkWingAnim
@onready var light_wing_effect: Node3D = %LightWingEffect
@onready var dark_wing_effect: Node3D = %DarkWingEffect


var party: Dictionary  # Standard role keys (m1, r1, etc.)
var dark_tar_pos: Vector2
var light_tar_pos: Vector2

func start_sequence(new_party: Dictionary) -> void:
	assert(new_party != null, "Error. Where the party at?")
	ground_aoe_controller.preload_aoe(["line"])
	party = new_party
	hide_bots_check_button.disabled = true
	hide_bots_check_button.set_bots_visible()
	
	p5_ps_anim.play("p5_ps_seq")


### START OF POLARIZING STRIKES TIMELINE ###


## 0.5
# Move to pre pos
func move_pre_pos():
	move_party(PSPos.PRE_POS)


## 3.5
# Cast Polarizing Strikes (6.7s)
func cast_polarizing():
	cast_bar.cast("Polarizing Strikes", 6.7)


## 5.0
# Move to hit 1 in pos
func move_hit_1_in():
	move_party(PSPos.HIT_1_IN)


## 10.0
# Boss swing anim
func oracle_swing():
	oracle.play_slash()


## 10.3
# Strike 1 (3.7s)
func strike_hit():
	# Get valid light/dark targets (picks a random target on left and right side of the boss)
	var shuffle_keys = party.keys()
	shuffle_keys.shuffle()
	var light_target_key := ""
	var dark_target_key := ""
	for key in shuffle_keys:
		if v2(party[key].global_position).y > 0:
			if dark_target_key == "":
				dark_target_key = key
				if light_target_key != "":
					break
		else:
			if light_target_key == "":
				light_target_key = key
				if dark_target_key != "":
					break
	# Warning if no valid targets are found on one side (shouldn't be possible).
	if dark_target_key == "" or light_target_key == "":
		push_warning("Could not find valid Akh Morn targets.")
		light_target_key = shuffle_keys[0]
		dark_target_key = shuffle_keys[1]
	
	dark_tar_pos = v2(party[dark_target_key].global_position)
	light_tar_pos = v2(party[light_target_key].global_position)
	
	# Lines Hit
	ground_aoe_controller.spawn_line(Vector2(0, 0), STRIKE_WIDTH, STRIKE_LENGTH, dark_tar_pos,
		STRIKE_LIFETIME, DARK_COLOR, [4, 4, "Path of Darkness"])
	ground_aoe_controller.spawn_line(Vector2(0, 0), STRIKE_WIDTH, STRIKE_LENGTH, light_tar_pos,
		STRIKE_LIFETIME, LIGHT_COLOR, [4, 4, "Path of Light"])


## 11.3
# Move to hit 1 out pos
func move_hit_1_out():
	move_party(PSPos.HIT_1_OUT)


## 12.2
# Start Polarizing Paths Cast (2.4s)
func cast_paths():
	cast_bar.cast("Polarizing Paths", 2.4)


## 12.4
# Echo 1 Hit
func echo_hit():
	ground_aoe_controller.spawn_line(Vector2(0, 0), STRIKE_WIDTH, STRIKE_LENGTH, dark_tar_pos,
		ECHO_LIFETIME, DARK_COLOR, [0, 0, "Path of Darkness (Echo)"])
	ground_aoe_controller.spawn_line(Vector2(0, 0), STRIKE_WIDTH, STRIKE_LENGTH, light_tar_pos,
		ECHO_LIFETIME, LIGHT_COLOR, [0, 0, "Path of Light (Echo)"])


## 13.4
# Move to hit 2 in pos
func move_hit_2_in():
	move_party(PSPos.HIT_2_IN)


## 14.7
# Boss swing anim

## 15.0
# Strike 2


## 16.0
# Move to hit 2 out pos
func move_hit_2_out():
	move_party(PSPos.HIT_2_OUT)


## 16.9
# Start Polarizing Paths Cast (2.4s)

## 17.1
# Echo 2 Hit

## 18.1
# Move to hit 3 in pos
func move_hit_3_in():
	move_party(PSPos.HIT_3_IN)


## 19.4
# Boss swing anim

## 19.7
# Strike 3


## 20.7
# Move to hit 3 out pos
func move_hit_3_out():
	move_party(PSPos.HIT_3_OUT)


## 21.6
# Start Polarizing Paths Cast (2.4s)

## 21.8
# Echo 3 Hit

## 22.8
# Move to hit 4 in pos
func move_hit_4_in():
	move_party(PSPos.HIT_4_IN)


## 24.1
# Boss swing anim

## 24.4
# Strike 4


## 25.4
# Move to hit 4 out pos
func move_hit_4_out():
	move_party(PSPos.HIT_4_OUT)

## 26.7
# Echo 3 Hit


## END OF POLARIZING STRIKES TIMELINE ##


func v2(v3: Vector3) -> Vector2:
	return Vector2(v3.x, v3.z)


# Moves given party of CharacterBodies to given positions, make sure keys match.
func move_party(pos: Dictionary) -> void:
	for key: String in pos:
		party[key].move_to(pos[key])
