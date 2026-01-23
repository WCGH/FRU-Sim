# Copyright 2025 by William Craycroft
# All rights reserved.
# This file is released under "GNU General Public License 3.0".
# Please see the LICENSE file that should have been included as part of this package.

extends Node

enum {NONE, SHORT, MED, LONG}  # Water debuff durations.
enum Strat {NAUR, LPDU, MUR, MANA}
enum Spread {STATIC, PERMA}   # Freepoc, Permaswap

const DARK_WATER_ICON = preload("res://scenes/ui/auras/debuff_icons/p3/dark_water_icon.tscn")

const SPIRIT_RADIUS := 10.0
const SPIRIT_LIFETIME := 0.3
const SPIRIT_COLOR := Color.REBECCA_PURPLE
const WATER_RADIUS := 15.5
const WATER_LIFETIME := 0.4
const WATER_COLOR := Color.DODGER_BLUE
const ERUPTION_RADIUS := 15.0
const ERUPTION_LIFETIME := 0.3
const ERUPTION_COLOR := Color(0.545098, 0, 0, 0.5)
const JUMP_BUFFER := 15.0
const JUMP_DURATION := 0.5
const JUMP_RADIUS := 16.0
const JUMP_LIFETIME := 0.3
const JUMP_COLOR := Color.REBECCA_PURPLE
const KB_DIST := 49.2
const KB_DURATION := 0.7
const FLANK_STACK_DIST := 11.0

# This matches the arena rotation to the player position rotations, depending on cw/ccw motion.
# Arena rotation at 0 deg is N/S lights. Player pos rotation at 0 deg is NE/SW for CW and NW/SE for CCW.
# All rotations are clockwise.
const CW_ROTATION_MAP := {0: -45, 45: 0, 90: -135, 135: -90}
const CCW_ROTATION_MAP := {0: -135, 45: -90, 90: -45, 135: 0}
# MANA rotations
const MANA_CW_ROTATION_MAP := {0: -45, 45: 0, 90: -135, 135: -90}
const MANA_CCW_ROTATION_MAP := {0: 45, 45: 90, 90: -45, 135: 0}
const MANA_ROTATION_OFFSET = 22.5
# Determines where T2 goes for bait (assuming no swap)
const T2_ROTATION_CW := {0: -45, 45: 0, 90: -135, 135: -90}
const T2_ROTATION_CCW := {0: -45, 45: 0, 90: 45, 135: 90}

# Base positions for NA and EU setups
const PARTY_SA_STATIC := {
	"nl_dps": "m1", "nr_dps": "m2", "fl_dps": "r1", "fr_dps": "r2",
	"nl_sup": "t1", "nr_sup": "t2", "fl_sup": "h1", "fr_sup": "h2"
}
# Base positions for MUR setup (LPs). Don't change keys, DPS group = LP2, Sup = LP1.
const PARTY_SA_STATIC_MUR := {
	"nl_dps": "t2", "nr_dps": "m2", "fl_dps": "h2", "fr_dps": "r2",
	"nl_sup": "t1", "nr_sup": "m1", "fl_sup": "h1", "fr_sup": "r1"
}
# Adjust prios for both NA and EU
const DPS_ADJUST_PRIO_NA := ["m1", "m2", "r1", "r2"]
const SUP_ADJUST_PRIO_NA := ["t1", "t2", "h1", "h2"]
# Adjust prio for MUR (Panto prio)
const DPS_ADJUST_PRIO_MUR := ["t2", "m2", "r2", "h2"] # LP2
const SUP_ADJUST_PRIO_MUR := ["t1", "m1", "r1", "h1"] # LP1

@onready var apoc_lights: ApocLights = %ApocLights
@onready var apoc_anim: AnimationPlayer = %ApocAnim
@onready var cast_bar: CastBar = %CastBar
@onready var clone_cast_bar: CloneCastBar = %CloneCastBar
@onready var ground_aoe_controller: GroundAoeController = %GroundAoEController
@onready var lockon_controller: LockonController = %LockonController
@onready var oracle: Oracle = %Oracle
@onready var boss: Node3D = %Boss
@onready var special_markers: Node3D = %SpecialMarkers
@onready var ground_markers: Node3D = %GroundMarkers
@onready var fail_list: FailList = %FailList

var party: Dictionary

# Square positions after adjust (near left/right, far left/right)
var party_keys_sa := {
	"nl_dps": "m1", "nr_dps": "m2", "fl_dps": "r1", "fr_dps": "r2",
	"nl_sup": "t1", "nr_sup": "t2", "fl_sup": "h1", "fr_sup": "h2"
}
var static_debuff_assignments := {
	NONE: {},
	SHORT: {DARK_WATER_ICON: 10},
	MED: {DARK_WATER_ICON: 29},
	LONG: {DARK_WATER_ICON: 38}
}

var party_debuff_key_arr := {NONE: [], SHORT: [], MED: [], LONG: []}
var party_debuff_lockon_arr := {SHORT: [], MED: [], LONG: []}
var party_keys_debuffs: Dictionary # [party_key][debuff_length]
var cw_light: bool   # Rotation direction for apoc lights
var arena_rotation_deg := 0
var jump_target: String
var strat: Strat
var apoc_spread: Spread
var t2_nw_bait_pos := Vector2(30, -30)
var t2_nw_bait_pos_close := Vector2(10, -10)
var t1_swapped := false
var t2_swapped := false
var bait_tank_key: String
var bait_rotation_dict: Dictionary
var bait_rotation_offset: float
var snap_jump_pos: Vector3


func start_sequence(new_party: Dictionary) -> void:
	assert(new_party != null, "Error. Where the party at?")
	ground_aoe_controller.preload_aoe(["circle"])
	lockon_controller.pre_load([LockonController.SPREAD_MARKER_APOC,
		LockonController.STACK_MARKER, LockonController.CD_COG])
	# Get Strat.
	strat = SavedVariables.save_data["settings"]["p3_sa_strat"]
	if strat is not int or strat >= Strat.size() or strat < 0:
		# Fix invalid SavedVariables, defaults to NA.
		GameEvents.emit_variable_saved("settings", "p3_sa_strat", 0)
		strat = Strat.NAUR
	# Get Apoc Spread.
	apoc_spread = SavedVariables.save_data["settings"]["p3_sa_swap"]
	if apoc_spread != Spread.STATIC and apoc_spread != Spread.PERMA:
		# Fix invalid SavedVariables, defaults to Static.
		GameEvents.emit_variable_saved("settings", "p3_sa_swap", 0)
		apoc_spread = Spread.STATIC
	instantiate_party(new_party)
	apoc_anim.play("apoc")


### START OF TIMELINE ###

## 2.10
# Cast Spell-in-Waiting-Refrain (1.7s)
func cast_refrain():
	cast_bar.cast("Spell-in-Waiting-Refrain", 1.7)


## 2.2
# Move to inital role positions.
func move_to_setup():
	if strat in [Strat.NAUR, Strat.MUR]:
		move_party_sa_static(ApocPos.ROLE_SETUP_NA)
	elif strat == Strat.MANA:
		move_party_sa_static_rotated(ApocPos.ROLE_SETUP_EU, MANA_ROTATION_OFFSET)
	else:
		move_party_sa_static(ApocPos.ROLE_SETUP_EU)

## 3.8
# Cast anim finish
func hands_out_cast():
	oracle.play_ct_cast()


## 7.2
# Show Stack marker lockons.
# Cast Dark Water III (4.7s)
func cast_dark_water():
	cast_bar.cast("Dark Water III", 4.7)
	# Stack markers
	for key in party_keys_debuffs:
		if party_keys_debuffs[key] != NONE:
			lockon_controller.add_marker(LockonController.STACK_MARKER, get_char(key))


## 12.1
# Hide stack markers
func hide_stack_markers():
	for key in party_keys_debuffs:
		if party_keys_debuffs[key] != NONE:
			lockon_controller.remove_marker(LockonController.STACK_MARKER, get_char(key))


## 12.8
# Add Water debuffs
# Show lockon markers.
# Cast anim finish
func add_water_debuffs():
	for key in party_keys_debuffs:
		var duration = party_keys_debuffs[key]
		for debuff_key in static_debuff_assignments[duration]:
			get_char(key).add_debuff(debuff_key, static_debuff_assignments[duration][debuff_key])
		# Lockon markers
		if duration != NONE:
			var lockon = lockon_controller.add_marker(LockonController.CD_COG, get_char(key))
			party_debuff_lockon_arr[duration].append(lockon)
	# Cast animation
	oracle.play_ct_cast()


## 15.3
# Cast Apocalypse (3.7s)
func cast_apoc():
	cast_bar.cast("Apocalypse", 3.7)


## 15.6
# Make swaps if needed
func move_to_swap_pos():
	if strat in [Strat.NAUR, Strat.MUR]:
		move_party_sa(ApocPos.SWAP_SETUP_NA)
	elif strat == Strat.MANA:
		move_party_sa_rotated(ApocPos.SWAP_SETUP_EU, MANA_ROTATION_OFFSET)
	else:
		move_party_sa(ApocPos.SWAP_SETUP_EU)


## 18.0
# Start short lockon countdown
func short_lock_cd():
	start_lock_cd(SHORT)


func start_lock_cd(duration):
	for lockon: CDCog in party_debuff_lockon_arr[duration]:
		lockon.start_countdown()


## 19.0
# Cast anim finish


## 20.2
# Move to stack pos
func move_stack_1():
	if strat in [Strat.NAUR, Strat.MUR]:
		move_party_sa(ApocPos.STACK_1_NA)
	elif strat == Strat.MANA:
		move_party_sa_rotated(ApocPos.STACK_1_EU, MANA_ROTATION_OFFSET)
	else:
		move_party_sa(ApocPos.STACK_1_EU)


## 21.5
# Cast Spirit Taker (2.6s)
func cast_spirit():
	cast_bar.cast("Spirit Taker", 2.6)


## 22.0
# Start Apoc Light Sequence
func start_apoc():
	apoc_lights.start_lights(cw_light)


## 23.1
# Short Water hit
func short_water_hit():
	water_hit(SHORT)


func water_hit(duration: int):
	for key in party_keys_debuffs:
		if party_keys_debuffs[key] == duration:
			ground_aoe_controller.spawn_circle(v2(get_char(key).global_position),
				WATER_RADIUS, WATER_LIFETIME, WATER_COLOR, [4, 4, "Dark Water III"])


## 23.8
# Return to spread pos.
func move_to_spread_pos():
	if strat in [Strat.NAUR, Strat.MUR]:
		move_party_sa(ApocPos.SPREAD_NA)
	elif strat == Strat.MANA:
		move_party_sa_rotated(ApocPos.SPREAD_EU, MANA_ROTATION_OFFSET)
	else:
		move_party_sa(ApocPos.SPREAD_EU)


## 24.5
# Cast anim finish (flip)
func cast_anim_flip():
	oracle.play_flip_special()


## 25.5
# Spirit Taker hit
func spirit_taker_hit():
	var key = party.keys().pick_random()
	ground_aoe_controller.spawn_circle(v2(get_char(key).global_position),
		SPIRIT_RADIUS, SPIRIT_LIFETIME, SPIRIT_COLOR, [1, 1, "Spirit Taker (Spread)"])


## 26.5
# Move swaps back if NA
func pre_move_swaps():
	if apoc_spread == Spread.STATIC:
		move_party_sa_static(ApocPos.SPREAD_NA)


## 28.0
# Move to Apoc Spread pos (move bots as late as possible).
func move_apoc_spread():
	# This works fine for all strats, I'm just being overly cautious.
	if strat == Strat.MANA:
		var check_cw = "CW" if cw_light else "CCW"
		var check_map = "MANA_%s_ROTATION_MAP" if strat == Strat.MANA else "%s_ROTATION_MAP"
		var ROTATION_MAP = get(check_map % check_cw)
		var APOC_SPREAD = ApocPos.APOC_SPREAD_CW if cw_light else ApocPos.APOC_SPREAD_CCW
		if apoc_spread == Spread.STATIC:
			move_party_sa_static_rotated(APOC_SPREAD, ROTATION_MAP[arena_rotation_deg])
		else:
			move_party_sa_rotated(APOC_SPREAD, ROTATION_MAP[arena_rotation_deg])
	
	else:
		if cw_light:
			if apoc_spread == Spread.STATIC:
				move_party_sa_static_rotated(ApocPos.APOC_SPREAD_CW, CW_ROTATION_MAP[arena_rotation_deg])
			else:
				move_party_sa_rotated(ApocPos.APOC_SPREAD_CW, CW_ROTATION_MAP[arena_rotation_deg])
		else:
			if apoc_spread == Spread.STATIC:
				move_party_sa_static_rotated(ApocPos.APOC_SPREAD_CCW, CCW_ROTATION_MAP[arena_rotation_deg])
			else:
				move_party_sa_rotated(ApocPos.APOC_SPREAD_CCW, CCW_ROTATION_MAP[arena_rotation_deg])


## 30.9
# Cast Dark Eruption (4.7s)
# Show spread markers
func cast_eruption():
	cast_bar.cast("Dark Eruption", 4.7)
	for key in party:
		lockon_controller.add_marker(LockonController.SPREAD_MARKER_APOC, get_char(key))

## 33.4
# First Apoc hit

## 35.4
# Second Apoc hit

## 35.9
# Eruptions hit
# Start med lockon countdown
func eruption_hit():
	for key in party:
		lockon_controller.remove_marker(LockonController.SPREAD_MARKER_APOC, get_char(key))
		ground_aoe_controller.spawn_circle(v2(get_char(key).global_position), ERUPTION_RADIUS,
			ERUPTION_LIFETIME, ERUPTION_COLOR, [1, 1, "Dark Eruption (Spread)"])


## 36.2
# Move to post eruption pos
func move_post_erupt():
	if strat == Strat.MANA:
		var check_cw = "CW" if cw_light else "CCW"
		var check_map = "MANA_%s_ROTATION_MAP" if strat == Strat.MANA else "%s_ROTATION_MAP"
		var ROTATION_MAP = get(check_map % check_cw)
		var APOC_SPREAD = ApocPos.POST_ERUPTION
		if apoc_spread == Spread.STATIC:
			move_party_sa_static_rotated(APOC_SPREAD, ROTATION_MAP[arena_rotation_deg])
		else:
			move_party_sa_rotated(APOC_SPREAD, ROTATION_MAP[arena_rotation_deg])
	
	else:
		if cw_light:
			if apoc_spread == Spread.STATIC:
				move_party_sa_static_rotated(ApocPos.POST_ERUPTION, CW_ROTATION_MAP[arena_rotation_deg])
			else:
				move_party_sa_rotated(ApocPos.POST_ERUPTION, CW_ROTATION_MAP[arena_rotation_deg])
		else:
			if apoc_spread == Spread.STATIC:
				move_party_sa_static_rotated(ApocPos.POST_ERUPTION, CCW_ROTATION_MAP[arena_rotation_deg])
			else:
				move_party_sa_rotated(ApocPos.POST_ERUPTION, CCW_ROTATION_MAP[arena_rotation_deg])


## 37.0
# Move to water stack 2
func move_stack_2():
	if cw_light:
		move_party_sa_rotated(ApocPos.STACK_2, CW_ROTATION_MAP[arena_rotation_deg])
	else:
		move_party_sa_rotated(ApocPos.STACK_2, CCW_ROTATION_MAP[arena_rotation_deg])


## 36.8
func med_lock_cd():
	start_lock_cd(MED)

## 37.4
# Third Apoc hit

## 38.5
# Cast Darkest Dance (4.7s)
func cast_dance():
	cast_bar.cast("Darkest Dance", 4.7)

## 39.4
# Fourth Apoc hit

## 41.4
# Fifth Apoc hit


##  41.9
# Med Water hit
func med_water_hit():
	water_hit(MED)


## 41.8
func move_t2_short():
	bait_tank_key = "t2" if !Global.p3_t1_bait else "t1"
	bait_rotation_dict = T2_ROTATION_CW if cw_light else T2_ROTATION_CCW
	bait_rotation_offset = 0
	# If tank swapped, send them to opposite side.
	if (!Global.p3_t1_bait and t2_swapped) or (Global.p3_t1_bait and t1_swapped):
		bait_rotation_offset += 180
	# If MUR strat, account for T2 starting on East side.
	if strat == Strat.MUR and !Global.p3_t1_bait:
		bait_rotation_offset += 180
	get_char(bait_tank_key).move_to(t2_nw_bait_pos_close.rotated(deg_to_rad(bait_rotation_dict[arena_rotation_deg] + bait_rotation_offset)))


## 42.1
# Move T2 out for bait, flip side if he's swapped. This timing is really tight without giving the bot sprint.
# Timing here is cheated a bit early to give tank a little more time to get out.
# In game it should come out to about the same timing with the late snapshot on jump.
func move_t2_out():
	#var tank_key = "t2" if !Global.p3_t1_bait else "t1"
	#var rotation_dict = T2_ROTATION_CW if cw_light else T2_ROTATION_CCW
	#var rotation_offset := 0
	#if (!Global.p3_t1_bait and t2_swapped) or (Global.p3_t1_bait and t1_swapped):
		#rotation_offset = 180
	get_char(bait_tank_key).move_to(t2_nw_bait_pos.rotated(deg_to_rad(bait_rotation_dict[arena_rotation_deg] + bait_rotation_offset)))


## 43.2
# Snapshot Jump hit position
func snapshot_jump():
	jump_target = get_farthest_target()
	snap_jump_pos = get_char(jump_target).global_position
	jump_hit()

## 43.5
# Sixth Apoc hit

## 44.1
# Start jump animation at farthest target
# TEST: Might need to push timing later to account for late snapshot.
func start_jump():
	# Get jump target, this is done during snapshot
	# jump_target = get_farthest_target()
	# Jump
	var target_pos: Vector3 = get_char(jump_target).global_position
	# We only want to jump to around the edge of the boss' hitbox.
	# If target is not far enough away, don't move.
	if target_pos.length() < JUMP_BUFFER:
		target_pos = target_pos.normalized() * 0.001
	else:
		target_pos = target_pos.normalized() * (target_pos.length() - JUMP_BUFFER)
	boss.look_at(target_pos)
	boss.rotation.y += deg_to_rad(90.0)
	var tween : Tween = get_tree().create_tween()
	tween.tween_property(boss, "global_position",
		Vector3(target_pos.x, 0, target_pos.z), JUMP_DURATION)\
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	oracle.play_flip_special()


## 44.9
# Jump hit
func jump_hit():
	var pc: PlayableCharacter = get_char(jump_target)
	ground_aoe_controller.spawn_circle(v2(snap_jump_pos), JUMP_RADIUS,
		JUMP_LIFETIME, JUMP_COLOR, [1, 1, "Darkest Dance (Oracle Jump)", [pc]])


## 45.8
# Start long lockon countdown
func long_lock_cd():
	start_lock_cd(LONG)


## 45.9
# Move to pre-kb position
func move_pre_kb():
	var flank_positions := get_oracle_flank_pos()
	for key: String in party_keys_sa:
		if key.contains("sup"):
			get_char_sa(key).move_to(flank_positions[0])
		else:
			get_char_sa(key).move_to(flank_positions[1])


## 47.1
# Start KB anim
func start_kb_anim():
	pass

## 47.6
# Knockback
func kb_hit():
	var kb_source = v2(oracle.global_position)
	for key in party:
		get_char(key).knockback(KB_DIST, kb_source, KB_DURATION)


## 50.9
# Long Water hit
func long_water_hit():
	water_hit(LONG)


## 51.2
# Cast Shockwave Pulsar (4.7s)
func cast_shockwave():
	cast_bar.cast("Shockwave Pulsar", 4.7)


### END OF TIMELINE ###


func instantiate_party(new_party: Dictionary) -> void:
	# Standard role keys
	party = new_party
	# NA Party setup
	party_setup()
	# Rotate arena
	arena_rotation_deg = 45 * randi_range(0, 3)
	assert(arena_rotation_deg in CW_ROTATION_MAP, "Invalid rotation value (needs to be int)")
	# Need to invert this because .rotated is CW and .rotate_y is CCW
	special_markers.rotate_y(deg_to_rad(arena_rotation_deg * -1))
	# Randomize Apoc Light Rotation (0=cw, 1=ccw)
	cw_light = randi() % 2 == 0


# Variable names match the NA/EU role based setups.
# For MUR, assume dps = LP1 and sup = LP2
func party_setup() -> void:
	var dps_adjust_prio: Array
	var sup_adjust_prio: Array
	var dps_keys: Array # LP1 keys for MUR
	#var sup_keys: Array # LP2 keys for MUR
	# Handle strat specific variables.
	if strat in [Strat.NAUR, Strat.LPDU, Strat.MANA]:
		party_keys_sa = PARTY_SA_STATIC.duplicate()
		dps_adjust_prio = DPS_ADJUST_PRIO_NA.duplicate()
		sup_adjust_prio = SUP_ADJUST_PRIO_NA.duplicate()
		dps_keys = Global.DPS_ROLE_KEYS
	elif strat == Strat.MUR:
		party_keys_sa = PARTY_SA_STATIC_MUR.duplicate()
		dps_adjust_prio = DPS_ADJUST_PRIO_MUR.duplicate()
		sup_adjust_prio = SUP_ADJUST_PRIO_MUR.duplicate()
		dps_keys = DPS_ADJUST_PRIO_MUR
	# Assign water debuffs
	var debuff_lengths := [NONE, NONE, SHORT, SHORT, MED, MED, LONG, LONG]
	var shuffle_list := party.keys()
	assert(shuffle_list.size() == debuff_lengths.size(), "Array size mismatch.")
	shuffle_list.shuffle()
	
	# User option to force swap. 
	if Global.p3_apoc_force_swap:
		var player_key = get_tree().get_first_node_in_group("player").get_role()
		# We can ignore this if player is lowest swap prio.
		if not (player_key == dps_adjust_prio.back() or player_key == sup_adjust_prio.back()):
			# Get lowest swap prio key in player's group.
			var low_prio_key = dps_adjust_prio.back() if dps_keys.has(player_key)\
				else sup_adjust_prio.back()
			var low_prio_index = shuffle_list.find(low_prio_key)
			# Get char with same duration as player
			var player_index := shuffle_list.find(player_key)
			var match_index = player_index + 1 if player_index % 2 == 0\
				else player_index - 1
			# Swap match with low prio
			var tmp = shuffle_list[match_index]
			shuffle_list[match_index] = shuffle_list[low_prio_index]
			shuffle_list[low_prio_index] = tmp
	
	# Used to find players by debuff duration.
	var dps_debuff_lists := {NONE: [], SHORT: [], MED: [], LONG: []}
	var sup_debuff_lists := {NONE: [], SHORT: [], MED: [], LONG: []}
	for i in shuffle_list.size():
		var key = shuffle_list[i]
		var duration = debuff_lengths[i]
		party_keys_debuffs[key] = duration
		# Populate lists
		if dps_keys.has(key):
			dps_debuff_lists[duration].append(key)
		else:
			sup_debuff_lists[duration].append(key)
		party_debuff_key_arr[duration].append(key)
	
	# Check if swaps are needed.
	var adjusters := {"dps": [], "sup": []}  # [role][array of swappers]
	# DPS/LP1
	for key in dps_debuff_lists:
		if dps_debuff_lists[key].size() > 1:
			# Find which dps adjusts
			if dps_adjust_prio.find(dps_debuff_lists[key][0]) < dps_adjust_prio.find(dps_debuff_lists[key][1]):
				adjusters["dps"].append(dps_debuff_lists[key][0])
			else:
				adjusters["dps"].append(dps_debuff_lists[key][1])
	# Supports/LP2
	for key in sup_debuff_lists:
		if sup_debuff_lists[key].size() > 1:
			# Find which dps adjusts
			if sup_adjust_prio.find(sup_debuff_lists[key][0]) < sup_adjust_prio.find(sup_debuff_lists[key][1]):
				adjusters["sup"].append(sup_debuff_lists[key][0])
			else:
				adjusters["sup"].append(sup_debuff_lists[key][1])
	# Handle swaps. If MUR, t2 is in dps adjust group (LP2).
	assert(adjusters["dps"].size() == adjusters["sup"].size(), "Array size mismatch.")
	if adjusters["sup"].has("t1"):
		t1_swapped = true
	if adjusters["dps"].has("t2") or adjusters["sup"].has("t2"):
		t2_swapped = true
	while adjusters["dps"].size() > 0:
		var dps_swap = adjusters["dps"].pop_front()
		var sup_swap = adjusters["sup"].pop_front()
		var sup_key = party_keys_sa.find_key(sup_swap)
		party_keys_sa[party_keys_sa.find_key(dps_swap)] = sup_swap
		party_keys_sa[sup_key] = dps_swap


# Return CharacterBody given its Apoc position key.
func get_char(party_key) -> PlayableCharacter:
	return party[party_key]


# Return CharacterBody given its Apoc position key.
func get_char_sa(sa_key) -> PlayableCharacter:
	return party[party_keys_sa[sa_key]]


# Return CharacterBody given its Apoc position key.
func get_char_sa_static(sa_key) -> PlayableCharacter:
	if strat == Strat.MUR:
		return party[PARTY_SA_STATIC_MUR[sa_key]]
	return party[PARTY_SA_STATIC[sa_key]]


# Moves Party based on standard role keys.
func move_party(pos: Dictionary) -> void:
	for key: String in pos:
		var pc := get_char(key)
		pc.move_to(pos[key])


# Moves Party based on standard role poskeys. Also rotates positions CW by rotation in deg.
func move_party_rotated(pos: Dictionary, rotation: float) -> void:
	for key: String in pos:
		var pc := get_char(key)
		pc.move_to(pos[key].rotated(deg_to_rad(rotation)))


# Moves Party based on Apoc position keys.
func move_party_sa(pos: Dictionary) -> void:
	for key: String in pos:
		var pc: PlayableCharacter = get_char_sa(key)
		pc.move_to(pos[key])


# Moves Party based on Apoc position keys. Also rotates positions CW by rotation in deg.
func move_party_sa_rotated(pos: Dictionary, rotation: float) -> void:
	for key: String in pos:
		var pc: PlayableCharacter = get_char_sa(key)
		pc.move_to(pos[key].rotated(deg_to_rad(rotation)))


# Moves Party based on static Apoc position keys. Also rotates positions CW by rotation in deg.
func move_party_sa_static(pos: Dictionary) -> void:
	for key: String in pos:
		var pc: PlayableCharacter = get_char_sa_static(key)
		pc.move_to(pos[key])


# Moves Party based on static Apoc position keys. Also rotates positions CW by rotation in deg.
func move_party_sa_static_rotated(pos: Dictionary, rotation: float) -> void:
	for key: String in pos:
		var pc: PlayableCharacter = get_char_sa_static(key)
		pc.move_to(pos[key].rotated(deg_to_rad(rotation)))


# Returns key of target farthest away from Oracle's position
func get_farthest_target() -> String:
	var oracle_pos = oracle.global_position
	var farthest_key: String
	var farthest_dist_sq := 0.0
	for key in party:
		var dist = get_char(key).global_position.distance_squared_to(oracle_pos)
		if dist > farthest_dist_sq:
			farthest_key = key
			farthest_dist_sq = dist
	assert(farthest_key, "Error finding farthest distance key.")
	return farthest_key


# Returns array of 2 vectors, back left and back right stack positions.
func get_oracle_flank_pos() -> Array:
	var oracle_pos := v2(oracle.global_position)
	var back_left := oracle_pos - ((oracle_pos.normalized() * FLANK_STACK_DIST).rotated(deg_to_rad(30)))
	var back_right := oracle_pos - ((oracle_pos.normalized() * FLANK_STACK_DIST).rotated(deg_to_rad(-30.0)))
	return [back_left, back_right]


func v2(vec3: Vector3) -> Vector2:
	return Vector2(vec3.x, vec3.z)


func v3(vec2: Vector2) -> Vector3:
	return Vector3(vec2.x, 0, vec2.y)
