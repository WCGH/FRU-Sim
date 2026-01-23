# Copyright 2025 by William Craycroft
# All rights reserved.
# This file is released under "GNU General Public License 3.0".
# Please see the LICENSE file that should have been included as part of this package.

extends Node

enum Strat {NA, EU, GREY}

# Debuff Icon Scenes
const STUN_ICON = preload("res://scenes/ui/auras/debuff_icons/common/stun_icon.tscn")
const DARK_BLIZZARD_ICON = preload("res://scenes/ui/auras/debuff_icons/p3/dark_blizzard_icon.tscn")
const DARK_ERUPTION = preload("res://scenes/ui/auras/debuff_icons/p3/dark_eruption.tscn")
const DARK_FIRE_ICON = preload("res://scenes/ui/auras/debuff_icons/p3/dark_fire_icon.tscn")
const DARK_WATER_ICON = preload("res://scenes/ui/auras/debuff_icons/p3/dark_water_icon.tscn")
const RETURN_ICON = preload("res://scenes/ui/auras/debuff_icons/p3/return_icon.tscn")
const RETURN_ICON_2 = preload("res://scenes/ui/auras/debuff_icons/p3/return_icon_2.tscn")
const SHADOWEYE_ICON = preload("res://scenes/ui/auras/debuff_icons/p3/shadoweye_icon.tscn")
const UNHOLY_DARKNESS_ICON = preload("res://scenes/ui/auras/debuff_icons/p3/unholy_darkness_icon.tscn")
const REWIND_MARKER = preload("res://scenes/p3/arena/rewind_marker.tscn")

const FIRE_RADIUS := 23.0
const FIRE_LIFETIME := 0.3
const FIRE_COLOR := Color(1, 0.270588, 0, 0.35)
const UD_RADIUS := 9.0
const UD_LIFETIME := 0.3
const UD_COLOR := Color.REBECCA_PURPLE
const ICE_RADIUS_INNER := 7.0
const ICE_RADIUS_OUTTER := 28.0
const ICE_LIFETIME := 0.3
const ICE_COLOR := Color.SKY_BLUE
const WATER_RADIUS := 9.0
const WATER_LIFETIME := 0.3
const WATER_COLOR := Color.DODGER_BLUE
const ERUPTION_RADIUS := 15.0
const ERUPTION_LIFETIME := 0.3
const ERUPTION_COLOR := Color(0.545098, 0, 0, 0.5)
const SHELL_RADIUS := 9.0
const SHELL_LIFETIME := 0.3
const SHELL_COLOR := Color.NAVY_BLUE
const SLIDE_TIME := 0.4

@onready var ult_relativity_anim: AnimationPlayer = %UltRelativityAnim
@onready var cast_bar: CastBar = %CastBar
@onready var clone_cast_bar: CloneCastBar = %CloneCastBar
@onready var ground_aoe_controller: GroundAoeController = %GroundAoEController
@onready var lockon_controller: LockonController = %LockonController
@onready var oracle: Node3D = %Oracle
@onready var special_markers: Node3D = %SpecialMarkers
@onready var ground_markers: Node3D = %GroundMarkers
@onready var fail_list: FailList = %FailList
@onready var hide_bots_button: CheckButton = %HideBotsCheckButton

var party: Dictionary
var na_dps_prio := ["r2", "r1", "m1", "m2"]
var na_sup_prio := ["h2", "h1", "t1", "t2"]
var eu_dps_prio := ["r1", "m1", "m2", "r2"]
var eu_sup_prio := ["h1", "t1", "t2", "h2"]
var grey_dps_prio := ["r2", "m2", "m1", "r1"]
var grey_sup_prio := ["h2", "t2", "t1", "h1"]
var party_keys_ur := {
	"f1_dps_sw": "", "f1_dps_se": "", "f1_sup": "",
	"f2_dps": "", "f2_sup": "",
	"f3_sup_nw": "", "f3_sup_ne": "","f3_dps": ""
	}
var static_debuff_assignments := {
	"f1_dps_sw": {DARK_FIRE_ICON: 11, RETURN_ICON: 16, DARK_ERUPTION: 43},
	"f1_dps_se": {DARK_FIRE_ICON: 11, RETURN_ICON: 16, DARK_ERUPTION: 43},
	"f2_dps": {DARK_FIRE_ICON: 21, RETURN_ICON: 16, DARK_WATER_ICON: 43},
	"f2_sup": {DARK_FIRE_ICON: 21, RETURN_ICON: 16, DARK_ERUPTION: 43},
	"f3_sup_nw": {DARK_FIRE_ICON: 31, RETURN_ICON: 26, SHADOWEYE_ICON: 43},
	"f3_sup_ne": {DARK_FIRE_ICON: 31, RETURN_ICON: 26, SHADOWEYE_ICON: 43}
}
var dps_ice_debuff_assignments := {
	"f1_sup": {DARK_FIRE_ICON: 11, RETURN_ICON: 16, DARK_ERUPTION: 43},
	"f3_dps": {DARK_BLIZZARD_ICON: 21, RETURN_ICON: 26, SHADOWEYE_ICON: 43}
}
var sup_ice_debuff_assignments := {
	"f1_sup": {DARK_BLIZZARD_ICON: 21, RETURN_ICON: 16, DARK_ERUPTION: 43},
	"f3_dps": {DARK_FIRE_ICON: 31, RETURN_ICON: 26, SHADOWEYE_ICON: 43}
}
# Valid targets for unholy darkness. 0=short, 1=med, 2=long.
var valid_ud_keys := [
	["f2_dps", "f2_sup", "f3_sup_nw", "f3_sup_ne", "f3_dps"],
	["f1_dps_sw", "f1_dps_se", "f1_sup", "f3_sup_nw", "f3_sup_ne", "f3_dps"],
	["f1_dps_sw", "f1_dps_se", "f1_sup", "f2_dps", "f2_sup"]
]
@onready var hourglasses := {
	"n": %HourglassN, "s": %HourglassS, "e": %HourglassE, "w": %HourglassW, 
	"ne": %HourglassNE, "se": %HourglassSE, "nw": %HourglassNW, "sw": %HourglassSW
}
var hourglass_soakers := {
	"n": "f1_sup", "s": "f3_dps", "e": "f2_dps", "w": "f2_sup", 
	"ne": "f3_sup_ne", "se": "f1_dps_se", "nw": "f3_sup_nw", "sw": "f1_dps_sw"
}
var hourglass_rotations: Dictionary   # 0=cw, 1=ccw
var ud_keys := []
var arena_rotation_deg := 0
var dps_ice: bool
var active_hg_keys: Array
var rewind_positions: Dictionary
var rewind_ground_markers: Array
var valid_targets: Array
var selected_strat: int


func start_sequence(new_party: Dictionary) -> void:
	assert(new_party != null, "Error. Where the party at?")
	ground_aoe_controller.preload_aoe(["line", "circle", "donut"])
	lockon_controller.pre_load([12])
	instantiate_party(new_party)
	on_toggle_bots_visible()
	hide_bots_button.toggle_bots_visible.connect(on_toggle_bots_visible)
	ult_relativity_anim.play("ult_relativity")


### START OF TIMELINE ###

## 1.00
# Start Ultimate Relativity cast (9.7s)
# Start boss animation
func start_ur_cast() -> void:
	cast_bar.cast("Ultimate Relativity", 9.7)
	oracle.play_ur_cast()

## 11.8
# Assign debuffs
# Spawn lockons
# Spawn hourglasses
func assign_debuffs() -> void:
	# Static debuffs
	for key in static_debuff_assignments:
		for debuff_icon in static_debuff_assignments[key]:
			get_ur_player(key).add_debuff(debuff_icon, static_debuff_assignments[key][debuff_icon])
	# Variable debuffs
	if dps_ice:
		for key in dps_ice_debuff_assignments:
			for debuff_icon in dps_ice_debuff_assignments[key]:
				get_ur_player(key).add_debuff(debuff_icon, dps_ice_debuff_assignments[key][debuff_icon])
	else:
		for key in sup_ice_debuff_assignments:
			for debuff_icon in sup_ice_debuff_assignments[key]:
				get_ur_player(key).add_debuff(debuff_icon, sup_ice_debuff_assignments[key][debuff_icon])
	# Unholy Darkness
	for i: int in ud_keys.size():
		get_ur_player(ud_keys[i]).add_debuff(UNHOLY_DARKNESS_ICON, (i * 10 + 11))
	
	# If GREY strat, swap med fire dps and supp.
	#if selected_strat == Strat.GREY:
		#var tmp = party_keys_ur["f2_sup"]
		#party_keys_ur["f2_sup"] = party_keys_ur["f2_dps"]
		#party_keys_ur["f2_dps"] = tmp
	
	spawn_hourglasses()


func spawn_hourglasses() -> void:
	for key in hourglasses:
		hourglasses[key].show_hourglass()

## 15.0
# Start Speed cast (5.3).
# Spawn hourglass tethers.
func spawn_tethers() -> void:
	cast_bar.cast("Speed", 5.3)
	hourglasses["nw"].show_yellow_tether()
	hourglasses["ne"].show_yellow_tether()
	hourglasses["s"].show_yellow_tether()
	hourglasses["w"].show_purple_tether()
	hourglasses["e"].show_purple_tether()

## 19.2
# 1st Fire/Stack.
# Move short fires out.
func move_first_fire() -> void:
	if dps_ice:
		move_party_ur_rotated(UltRelativityPcPos.fire_1_dps_ice)
	else:
		move_party_ur_rotated(UltRelativityPcPos.fire_1_sup_ice)

## 20.3
# Hide tethers
func hide_tethers() -> void:
	for key in hourglasses:
		hourglasses[key].hide_tether()

## 22.9
# Short fires hit. Short Middle stack hits.
func first_fire_hit() -> void:
	var fire_targets := []
	fire_targets.append(get_ur_player("f1_dps_sw"))
	fire_targets.append(get_ur_player("f1_dps_se"))
	if dps_ice:
		fire_targets.append(get_ur_player("f1_sup"))
	for target in fire_targets:
		ground_aoe_controller.spawn_circle(v2(target.global_position), FIRE_RADIUS,
			FIRE_LIFETIME, FIRE_COLOR, [1, 1, "Dark Fire III", [target]])
	# UD hit
	var ud_target: PlayableCharacter = get_ur_player(ud_keys[0])
	ground_aoe_controller.spawn_circle(v2(ud_target.global_position),
		UD_RADIUS, UD_LIFETIME, UD_COLOR, [5, 8, "Unholy Darkness (Group Stack)"])


## 23.9
# Start clone cast SinboundMeltdown x3 (3.7s).
# Start Rotate telegraphs on yellow hourglasses.
# Move to 1st Bait/Rewind positions (short fires in, 1st baits out).
func first_rotate() -> void:
	start_sinbound(["nw", "ne", "s"])
	move_first_bait()


func start_sinbound(hourglass_keys: Array) -> void:
	active_hg_keys = hourglass_keys
	# Clone casts
	clone_cast_bar.cast_clone("Sinbound Meltdown", 3.7, active_hg_keys.size())
	# Start hourglass rotations.
	for key in active_hg_keys:
		if hourglass_rotations[key] == 0:
			hourglasses[key].play_rotate_cw()
		else:
			hourglasses[key].play_rotate_ccw()


func move_first_bait() -> void:
	# Move everyone to base positions (CW)
	move_party_ur_rotated(UltRelativityPcPos.bait_rewind_1_cw)
	# Adjust baits if CCW
	for key in active_hg_keys:
		if hourglass_rotations[key] == 1:
			var pc: PlayableCharacter = get_ur_player(hourglass_soakers[key])
			pc.move_to(UltRelativityPcPos.bait_rewind_1_ccw[hourglass_soakers[key]]\
				.rotated(deg_to_rad(arena_rotation_deg)))


## 27.6
# Snapshot rewind positions.
# Spawn rewind ground markers.
# Start first hourglass line AoE's.
func first_rewind_snapshot() -> void:
	# Snapshot rewinds
	var first_rewinds := ["f1_dps_sw", "f1_dps_se", "f2_dps", "f1_sup", "f2_sup"]
	rewind_snapshot(first_rewinds)
	for key in first_rewinds:
		get_ur_player(key).add_debuff(RETURN_ICON_2, 23)

func rewind_snapshot(rewind_keys: Array) -> void:
	rewind_ground_markers = []
	# Snapshot rewinds
	for key in rewind_keys:
		var pos: Vector3 = get_ur_player(key).global_position
		rewind_positions[key] = v2(pos)
		# Drop ground aoe
		var new_marker = REWIND_MARKER.instantiate()
		ground_markers.add_child(new_marker)
		new_marker.global_position = pos
		rewind_ground_markers.append(new_marker)
	# Start hourglass lasers
	for hg_key in active_hg_keys:
		hourglasses[hg_key].fire_laser(valid_targets, hourglass_rotations[hg_key])


## 28.6
# Move to 2nd Fire/Stack+Ice positions (fires move to intermediate pos).
func move_second_fire() -> void:
	move_party_ur_rotated(UltRelativityPcPos.fire_2_inter)


## 30.6
# Move 2nd Fires all the way out.
func move_second_fire_out() -> void:
	move_party_ur_rotated(UltRelativityPcPos.fire_2)
	# Remove short rewind ground markers.
	for aoe: Node3D in rewind_ground_markers:
		aoe.queue_free()


## 32.8
# 2nd Fire + middle Ice/UD hits
func second_fire_hit() -> void:
	# Fires
	var fire_targets = [get_ur_player("f2_dps"), get_ur_player("f2_sup")]
	for target in fire_targets:
		ground_aoe_controller.spawn_circle(v2(target.global_position), FIRE_RADIUS,
			FIRE_LIFETIME, FIRE_COLOR, [1, 1, "Dark Fire III", [target]])
	# Ice
	var ice_target: PlayableCharacter
	if dps_ice:
		ice_target = get_ur_player("f3_dps")
	else:
		ice_target = get_ur_player("f1_sup")
	ground_aoe_controller.spawn_donut(v2(ice_target.global_position), ICE_RADIUS_INNER,
		ICE_RADIUS_OUTTER, ICE_LIFETIME, ICE_COLOR, [0, 0, "Dark Blizzard III (Donut)"])
	# UD
	var ud_target: PlayableCharacter = get_ur_player(ud_keys[1])
	ground_aoe_controller.spawn_circle(v2(ud_target.global_position),
		UD_RADIUS, UD_LIFETIME, UD_COLOR, [5, 8, "Unholy Darkness (Group Stack)"])


## 34.0
# Move 2nd Bait/Rewind positions (short fires bait, eyes MID NE/NW/S, others cheat out for clarity)
# Start clone cast SinboundMeltdown x3 (3.7s).
# Start Rotate telegraphs on no-tether hourglasses.
func second_rotate() -> void:
	start_sinbound(["sw", "se", "n"])
	move_second_bait()


func move_second_bait() -> void:
	# Move everyone to base positions (CW)
	move_party_ur_rotated(UltRelativityPcPos.bait_rewind_2_cw)
	# Adjust baits if CCW
	for key in active_hg_keys:
		if hourglass_rotations[key] == 1:
			var pc: PlayableCharacter = get_ur_player(hourglass_soakers[key])
			pc.move_to(UltRelativityPcPos.bait_rewind_2_ccw[hourglass_soakers[key]]\
				.rotated(deg_to_rad(arena_rotation_deg)))


## 37.7
# Snapshot long rewind positions.
# Spawn rewind ground markers.
# Start hourglass line AoE's.
func second_rewind_snapshot() -> void:
	var second_rewinds := ["f3_sup_nw", "f3_sup_ne", "f3_dps"]
	rewind_snapshot(second_rewinds)
	for key in second_rewinds:
		get_ur_player(key).add_debuff(RETURN_ICON_2, 13)


## 38.7
# Move to 3rd Fire/Stack positions (long fires out, everyone else mid).
func move_third_fire() -> void:
	move_party_ur_rotated(UltRelativityPcPos.fire_3)


## 42.8
# 3rd Fires hit.
func third_fires_hit() -> void:
	# Fires
	var fire_targets := []
	fire_targets.append(get_ur_player("f3_sup_nw"))
	fire_targets.append(get_ur_player("f3_sup_ne"))
	if !dps_ice:
		fire_targets.append(party[party_keys_ur["f3_dps"]])
	for target in fire_targets:
		ground_aoe_controller.spawn_circle(v2(target.global_position), FIRE_RADIUS,
			FIRE_LIFETIME, FIRE_COLOR, [1, 1, "Dark Fire III", [target]])
	# UD hit
	var ud_target: PlayableCharacter = get_ur_player(ud_keys[2])
	ground_aoe_controller.spawn_circle(v2(ud_target.global_position),
		UD_RADIUS, UD_LIFETIME, UD_COLOR, [5, 8, "Unholy Darkness (Group Stack)"])
	# Remove long rewind ground markers.
	for aoe: Node3D in rewind_ground_markers:
		aoe.queue_free()


## 45.0
# Start clone cast SinboundMeltdown x3 (3.7s).
# Start Rotate telegraphs on yellow hourglasses.
# Move to 3rd Bait positions.
func third_rotate() -> void:
	start_sinbound(["e", "w"])
	move_third_bait()


func move_third_bait() -> void:
	# Move everyone to base positions (CW)
	move_party_ur_rotated(UltRelativityPcPos.bait_rewind_3_cw)
	# Adjust baits if CCW
	for key in active_hg_keys:
		if hourglass_rotations[key] == 1:
			var pc: PlayableCharacter = get_ur_player(hourglass_soakers[key])
			var pos_key = hourglass_soakers[key]
			# Need to swap E/W soaker keys if Grey-9
			if selected_strat == Strat.GREY and pos_key in ["f2_dps", "f2_sup"]:
				if pos_key == "f2_dps":
					pc = get_ur_player("f2_sup")
					pos_key = "f2_sup_g9"
				elif pos_key == "f2_sup":
					pc = get_ur_player("f2_dps")
					pos_key = "f2_dps_g9"
			
			pc.move_to(UltRelativityPcPos.bait_rewind_3_ccw[pos_key]\
				.rotated(deg_to_rad(arena_rotation_deg)))


## 48.7
# Start hourglass line AoE's.
# Move 3rd baits in.
func move_final() -> void:
	# Start hourglass lasers
	for hg_key in active_hg_keys:
		hourglasses[hg_key].fire_laser(valid_targets, hourglass_rotations[hg_key])
	# Move to pre-slide positions
	move_party_ur_rotated(UltRelativityPcPos.pre_slide)

## 51.0
# Look at "out" positions.
func look_out() -> void:
	for key in party_keys_ur:
		var pos_key = String(key)
		if selected_strat == Strat.GREY and pos_key in ["f2_dps", "f2_sup"]:
			pos_key = str(pos_key + "_g9")
		get_ur_player(key).look_at_direction(v3(UltRelativityPcPos.look_direction[pos_key].rotated(deg_to_rad(arena_rotation_deg))))


## 51.9
# Assign stun debuffs (4s), freeze player.
func stun_players() -> void:
	for key in party_keys_ur:
		var pc: PlayableCharacter = get_ur_player(key)
		pc.add_debuff(STUN_ICON, 4.0)
		if pc.is_player():
			pc.freeze_player()


## 53.4
# Slide players to rewind positions
func slide_players() -> void:
	for key in party_keys_ur:
		get_ur_player(key).slide(rewind_positions[key], SLIDE_TIME)


## 54.8
# AoE's hit
func final_hit() -> void:
	# Gazes
	var gaze_keys := ["f3_dps", "f3_sup_ne", "f3_sup_nw"]
	for key in gaze_keys:
		lockon_controller.add_marker(LockonController.GAZE, get_ur_player(key))
	check_gazes(gaze_keys)
	# Eruptions
	var eruptions_keys := ["f1_dps_se", "f1_dps_sw", "f1_sup", "f2_sup"]
	for key in eruptions_keys:
		ground_aoe_controller.spawn_circle(v2(get_ur_player(key).global_position),
			ERUPTION_RADIUS, ERUPTION_LIFETIME, ERUPTION_COLOR, [1, 1, "Dark Eruption"])
	# Water
	var water_target: PlayableCharacter = get_ur_player("f2_dps")
	ground_aoe_controller.spawn_circle(v2(water_target.global_position), WATER_RADIUS,
		WATER_LIFETIME, WATER_COLOR, [4, 4, "Dark Water III"])
	# Unfreeze player
	get_tree().get_first_node_in_group("player").unfreeze_player()


# Ported from DSR Sim, I completely forgot how this works.
func check_gazes(gaze_keys: Array) -> void:
	for key in party_keys_ur:
		var pc: PlayableCharacter = get_ur_player(key)
		var pc_rotation := fposmod((rad_to_deg(pc.get_model_rotation().y) + 180), 360.0)
		for gaze_key in gaze_keys:
			# Can't get hit by our own gaze
			if key == gaze_key:
				continue
			var angle_to_gaze_target = fposmod(rad_to_deg(v2(pc.global_position).angle_to_point(
				v2(get_ur_player(gaze_key).global_position))) * -1 + 90, 360.0)
			if angle_to_gaze_target < 45:
				if pc_rotation < angle_to_gaze_target + 45 or pc_rotation > 315 + angle_to_gaze_target:
					fail_list.add_fail(str(pc.get_name(), " looked at ", get_ur_player(gaze_key).get_name(),"'s Gaze."))
			elif angle_to_gaze_target > 315:
				if pc_rotation > angle_to_gaze_target - 45 or pc_rotation < angle_to_gaze_target - 315:
					fail_list.add_fail(str(pc.get_name(), " looked at ", get_ur_player(gaze_key).get_name(),"'s Gaze."))
			elif pc_rotation > angle_to_gaze_target - 45 and pc_rotation < angle_to_gaze_target + 45:
				fail_list.add_fail(str(pc.get_name(), " looked at ", get_ur_player(gaze_key).get_name(),"'s Gaze."))

## 55.8
# Start Shell Crusher cast (2.8s)
# Move players in for stack.
func cast_shell_crusher() -> void:
	cast_bar.cast("Shell Crusher", 2.8)
	move_party_ur_rotated(UltRelativityPcPos.final_stack)
	# Clear Gaze markers
	for key in ["f3_dps", "f3_sup_ne", "f3_sup_nw"]:
		lockon_controller.remove_marker(12, get_ur_player(key))


## 57.8
func play_flip_anim() -> void:
	oracle.play_flip_special()


## 58.6
# Shell Crusher hit (8 player shared)
func shell_crusher_hit() -> void:
	var rand_key = party.keys().pick_random()
	ground_aoe_controller.spawn_circle(v2(party[rand_key].global_position),
		SHELL_RADIUS, SHELL_LIFETIME, SHELL_COLOR, [8, 8, "Shell Crusher (Party Stack)"])
	



### END OF TIMELINE ###


func instantiate_party(new_party: Dictionary) -> void:
	# Standard role keys
	party = new_party
	valid_targets = party.values()
	# NA Party setup
	party_setup()
	# Rotate arena
	arena_rotation_deg = 45 * randi_range(0, 7)
	# Need to invert this because .rotated is CW and .rotate_y is CCW :D
	special_markers.rotate_y(deg_to_rad(arena_rotation_deg * -1))
	# Randomize Ice role
	dps_ice = randi() % 2 == 0
	# Pick Unholy Darkness targets
	for valid_keys: Array in valid_ud_keys:
		var rand_key: String = valid_keys.pick_random()
		# Avoid duplicate keys
		while (ud_keys.has(rand_key)):
			rand_key = valid_keys.pick_random()
		ud_keys.append(rand_key)
	# Randomize Hourglass rotations (0=cw, 1=ccw)
	for key in hourglasses:
		hourglass_rotations[key] = randi_range(0, 1)


func party_setup() -> void:
	var dps_prio: Array
	var sup_prio: Array
	
	selected_strat = SavedVariables.save_data["settings"]["p3_ur_strat"]
	if selected_strat == Strat.NA:
		dps_prio = na_dps_prio.duplicate()
		sup_prio = na_sup_prio.duplicate()
	elif selected_strat == Strat.EU:
		dps_prio = eu_dps_prio.duplicate()
		sup_prio = eu_sup_prio.duplicate()
	elif selected_strat == Strat.GREY:
		dps_prio = grey_dps_prio.duplicate()
		sup_prio = grey_sup_prio.duplicate()
	else:
		# If user changes saved_variable to something invalid, reset it.
		GameEvents.emit_variable_saved("settings", "p3_ur_strat", 0)
		dps_prio = na_dps_prio.duplicate()
		sup_prio = na_sup_prio.duplicate()
	
	# Shuffle dps/sup roles
	var shuffle_list := dps_prio.duplicate()
	shuffle_list.shuffle()
	
	# Handle manual debuff selection for player
	var supp_key  # Placeholder to use later if we need to swap a support key
	if Global.p3_selected_debuff != 0:
		var player_role_key = get_tree().get_first_node_in_group("player").get_role()
		if Global.DPS_ROLE_KEYS.has(player_role_key):
			# Remove player index and insert at selected key
			shuffle_list.erase(player_role_key)
			# For DPS need to convert 1,2,3 index to 3,2,1
			shuffle_list.insert(abs(Global.p3_selected_debuff - 3), player_role_key)
		else:
			supp_key = player_role_key
	
	# DPS assignments: 0=f3, 1= f2, 2=f1sw, 3=f1se
	# Check if 2/3 are in prio order, otherwise swap them.
	if dps_prio.find(shuffle_list[2]) > dps_prio.find(shuffle_list[3]):
		shuffle_list.append(shuffle_list.pop_at(2))
	# Add dps roles to dictionary
	party_keys_ur["f3_dps"] = shuffle_list[0]
	party_keys_ur["f2_dps"] = shuffle_list[1]
	party_keys_ur["f1_dps_sw"] = shuffle_list[2]
	party_keys_ur["f1_dps_se"] = shuffle_list[3]
	
	# Repeat for supports. Supp assignments: 0=f1, 1=f2, 2=f3nw, 3=f3ne
	shuffle_list = sup_prio.duplicate()
	shuffle_list.shuffle()
	
	# Handle manual debuff selection for player
	if supp_key:  # Should only be true if random is not selected and player is a support
		# Remove player index and insert at selected key
		shuffle_list.erase(supp_key)
		shuffle_list.insert(Global.p3_selected_debuff - 1, supp_key)
	
	if sup_prio.find(shuffle_list[2]) > sup_prio.find(shuffle_list[3]):
		shuffle_list.append(shuffle_list.pop_at(2))
	party_keys_ur["f1_sup"] = shuffle_list[0]
	party_keys_ur["f2_sup"] = shuffle_list[1]
	party_keys_ur["f3_sup_nw"] = shuffle_list[2]
	party_keys_ur["f3_sup_ne"] = shuffle_list[3]


# Returns the PlayableCharacter for the assigned key.
func get_ur_player(ur_key) -> PlayableCharacter:
	return party[party_keys_ur[ur_key]]


# Moves given party of CharacterBodies to given positions, make sure keys match.
func move_party(party_dict: Dictionary, pos: Dictionary) -> void:
	for key: String in party_dict:
		var pc: PlayableCharacter = party_dict[key]
		if pc.is_player() and !Global.spectate_mode:
			continue
		pc.move_to(pos[key])


# Moves UR Party to gives pos dictionary (must match UR keys). Also rotates positions by arena_rotation_deg.
func move_party_ur_rotated(pos: Dictionary) -> void:
	for key: String in party_keys_ur:
		var pos_key = String(key)
		if selected_strat == Strat.GREY and key in ["f2_dps", "f2_sup"]:
			pos_key = str(pos_key + "_g9")
		var pc: PlayableCharacter = get_ur_player(key)
		if pc.is_player() and !Global.spectate_mode:
			continue
		pc.move_to(pos[pos_key].rotated(deg_to_rad(arena_rotation_deg)))


func on_toggle_bots_visible() -> void:
	var bots_visible = !Global.p3_ur_hide_bots
	for key in party:
		var pc: PlayableCharacter = party[key]
		if pc.is_player():
			continue
		pc.visible = bots_visible


func v2(vec3: Vector3) -> Vector2:
	return Vector2(vec3.x, vec3.z)


func v3(vec2: Vector2) -> Vector3:
	return Vector3(vec2.x, 0, vec2.y)
