# Copyright 2025
# All rights reserved.
# This file is released under "GNU General Public License 3.0".
# Please see the LICENSE file that should have been included as part of this package.

extends Node

const AKH_MORN_RADIUS := 12.0
const AKH_MORN_LIFETIME := 0.3
const AKH_MORN_LIGHT_COLOR := Color.GOLD
const AKH_MORN_DARK_COLOR := Color.DARK_VIOLET

const EXAWAVE_POS = [Vector2(0, 17), Vector2(0, -17), Vector2(17, 0), Vector2(-17, 0)]
const EXAWAVE_ROTA_DEG = [-90, 90, 180, 0]


@onready var p5_anim: AnimationPlayer = %P5FBAnim
@onready var cast_bar: CastBar = %CastBar
@onready var ground_aoe_controller: GroundAoeController = %GroundAoEController
@onready var oracle_boss: Node3D = %OracleBoss
@onready var oracle: Oracle = %Oracle
@onready var fail_list: FailList = %FailList
@onready var exawave_controller: ExawaveController = %ExawaveController
@onready var hide_bots_check_button: CheckButton = %HideBotsCheckButton
@onready var encounter_controller: EncounterController = %EncounterController

var party: Dictionary  # Standard role keys (m1, r1, etc.)
var hide_bots := false
var exawave_variables: Dictionary
var boss_angle: float
#var bots_hideable := false
#var current_seq_index: int

func start_sequence(new_party: Dictionary) -> void:
	assert(new_party != null, "Error. Where the party at?")
	ground_aoe_controller.preload_aoe(["circle"])
	party = new_party
	hide_bots_check_button.disabled = false
	hide_bots_check_button.toggle_bots_visible.connect(on_toggle_bots_visible)
	on_toggle_bots_visible()
	p5_anim.play("p5_fb_seq")


### START OF EXAWAVE TIMELINE ###

## 2.1
# Start Oracle Swing animation
func oracle_swing():
	oracle.play_slash()

## 4.0
# Start Exaline seq
func start_exalines():
	exawave_variables = exawave_controller.start_exawaves()

## 8.0
# Pre-position for exawaves
func move_exa_pre():
	for key in party:
		party[key].move_to(EXAWAVE_POS[exawave_variables["pos_index"]])


## Exawave Dodges
## 0=12.0, 1=16.0, 2=18.0, 3=20.0, 4=22.0, 5=24.0
func move_exa_dodge(move_index: int):
	for key in party:
		var tar: Vector2
		if exawave_variables["east_first"]:
			tar = FBPos.EXA_DODGES[FBPos.EAST_DODGE_PATTERN[move_index]]
		else:
			tar = FBPos.EXA_DODGES[FBPos.WEST_DODGE_PATTERN[move_index]]
		tar = tar.rotated(-1 * exawave_variables["rota_y_rad"])
		tar = tar + EXAWAVE_POS[exawave_variables["pos_index"]]
		party[key].move_to(tar)

## 21.0
# Start AM Cast (7.5s)
# Look at MT and lock into place
func cast_akh_morn():
	cast_bar.cast("Akh Morn", 7.5)
	boss_angle = v2(oracle_boss.global_position).angle_to_point(v2(party["t1"].global_position))
	var tween = get_tree().create_tween()
	tween.tween_property(oracle_boss, "rotation", Vector3(0, boss_angle, 0), 0.6)


## 26.0
# Move to AM positions
func move_am():
	hide_bots_check_button.set_bots_visible()
	for key in party:
		var tar: Vector2 = FBPos.AKH_MORN_SOUTH[key]
		tar = tar.rotated(deg_to_rad(EXAWAVE_ROTA_DEG[exawave_variables["pos_index"]]))
		party[key].move_to(tar)


## 28.5
# Akh Morn hit
func akh_morn_hit():
	# Get valid light/dark targets (picks a random target on left and right side of the boss)
	var shuffle_keys = party.keys()
	shuffle_keys.shuffle()
	var light_target_key := ""
	var dark_target_key := ""
	for key in shuffle_keys:
		if v2(party[key].global_position).rotated(-1 * boss_angle).y > 0:
			if dark_target_key == "":
				dark_target_key = key
				if light_target_key != "":
					break
		else:
			if light_target_key == "":
				light_target_key = key
				if dark_target_key != "":
					break
	# Warning if no valid targets are found on one side (should only happen if T1 is off in BFE).
	if dark_target_key == "" or light_target_key == "":
		push_warning("Could not find valid Akh Morn targets.")
		light_target_key = shuffle_keys[0]
		dark_target_key = shuffle_keys[1]
	
	# AM Hit
	ground_aoe_controller.spawn_circle(v2(party[light_target_key].global_position),
		AKH_MORN_RADIUS, AKH_MORN_LIFETIME, AKH_MORN_LIGHT_COLOR, [4, 4, "Akh Morn"])
	ground_aoe_controller.spawn_circle(v2(party[dark_target_key].global_position),
		AKH_MORN_RADIUS, AKH_MORN_LIFETIME, AKH_MORN_DARK_COLOR, [4, 4, "Akh Morn"])

## 30.0
# Play Paradise Regained Sequence
# Reset boss facing to North (optional in practice, but keeps starting point consistent across pulls)
func play_pr_seq():
	var tween = get_tree().create_tween()
	tween.tween_property(oracle_boss, "rotation", Vector3(0, 0, 0), 0.6)
	encounter_controller.play_sequence_by_index(1)


### END OF EXAWAVE TIMELINE ###


func on_toggle_bots_visible():
	for key in party:
		if key != Global.player_role_key:
			party[key].visible = !Global.p5_ew_hide_bots


func v2(vec3: Vector3) -> Vector2:
	return Vector2(vec3.x, vec3.z)


func v3(vec2: Vector2) -> Vector3:
	return Vector3(vec2.x, 0, vec2.y)
