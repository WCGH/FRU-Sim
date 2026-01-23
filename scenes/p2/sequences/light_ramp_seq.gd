# Copyright 2025 by William Craycroft
# All rights reserved.
# This file is released under "GNU General Public License 3.0".
# Please see the LICENSE file that should have been included as part of this package.

extends Node

enum Strat {NA, EU, ELE, MANA}

# Debuff Icon Scenes
const CHAINS_LOCKED = preload("res://scenes/ui/auras/debuff_icons/p2/chains_locked.tscn")
const CHAINS = preload("res://scenes/ui/auras/debuff_icons/p2/chains.tscn")
const LIGHTSTEEPED = preload("res://scenes/ui/auras/debuff_icons/p2/lightsteeped.tscn")
const WEIGHT_OF_LIGHT = preload("res://scenes/ui/auras/debuff_icons/p2/weight_of_light.tscn")

const CHAINS_MAX_DIST := 100.0
const CHAINS_MIN_DIST := 65.0
const CHAINS_WIDTH := 0.15
const LR_SOLO_TOWER_DURATION := 8.0
const LIGHTSTEEPED_DURATION := 36.0

const PUDDLE_COUNT := 6
const PUDDLE_DROP_DELAY := 1.6
const PUDDLE_DURATION := 10.0
const PUDDLE_RADIUS := 14.5
const PUDDLE_COLOR := Color(1, 1, 0, 0.165)
const PUDDLE_TARGET_FAIL_COUNT := 2

const ORB_AOE_RADIUS := 10
const ORB_AOE_LIFETIME := 0.5
const ORB_AOE_COLOR := Color.ORANGE_RED

const LARGE_ORB_RADIUS := 25.5
const LARGE_ORB_DURATION := 0.1
const LARGE_ORB_COLOR := Color(1, 0.643, 0.227, 0.13)

const SPREAD_AOE_RADIUS := 11
const SPREAD_AOE_LIFETIME := 0.3
const SPREAD_AOE_COLOR := Color.ALICE_BLUE

const PAIRS_AOE_RADIUS := 13
const PAIRS_AOE_LIFETIME := 0.3
const PAIRS_AOE_COLOR := Color.ALICE_BLUE

const PROTEAN_ANGLE := 90
const PROTEAN_LENGTH := 150
const PROTEAN_LIFETIME := 0.3
const PROTEAN_COLOR := Color(0.8, 0.647059, 0, 0.12)

@onready var light_ramp_anim: AnimationPlayer = %LightRampAnim
@onready var cast_bar: CastBar = %CastBar
@onready var ground_aoe_controller: GroundAoeController = %GroundAoEController
@onready var lockon_controller: LockonController = %LockonController
@onready var lr_chains_controller: LRChainsController = %LRChainsController
@onready var puddle_controller: PuddleController = %PuddleController
@onready var fail_list: FailList = %FailList
@onready var n_orb_list := [%LargeOrb1, %LargeOrb3, %LargeOrb5]
@onready var s_orb_list := [%LargeOrb2, %LargeOrb4, %LargeOrb6]
@onready var shiva: Node3D = %Shiva


var party: Dictionary
var lr_party: Dictionary
var support_keys := ["t2", "t1", "h2", "h1"]
var dps_keys := ["r1", "r2", "m1", "m2"]
var lr_north_lineup := ["t2", "t1", "h2", "h1"]
var lr_south_lineup := ["r1", "r2", "m1", "m2"]
var lr_south_lineup_ele := ["m1", "m2", "r1", "r2"]
var orb_keys := []
var spread_keys := []
var na_we_spread_prio := [4, 3, 5, 2, 6, 1, 7, 0] # W > E Prio [r1, h1, r2, h2, m1, t1, m2, t2]
var eu_ns_spread_prio := [3, 2, 1, 0, 4, 5, 6, 7] # N > S Prio [h1, h2, t1, t2, r1, r2, m1, m2]
#var ele_we_spread_prio := [6, 3, 7, 2, 4, 1, 5, 0] # W > E Prio [m1, h1, m2, h2, r1, t1, r2, t2]
# Will be randomized. First 4 get 1 stacks of debuff, last 4 are quad tower soakers.
var lightsteeped_keys := ["t2", "t1", "h2", "h1", "r1", "r2", "m1", "m2"]
var solo_tower_positions := [Vector2(19, -32.8), Vector2(37.7, 0), Vector2(19, 32.8),
	Vector2(-19, -32.8), Vector2(-37.7, 0), Vector2(-19, 32.8)]
var puddles := []
var solo_towers := []
var middle_tower: LRTower
var n_orb_pattern: bool
var halo_spread_pattern: bool
var strat: Strat


func start_sequence(new_party: Dictionary) -> void:
	assert(new_party != null, "Error. Where the party at?")
	ground_aoe_controller.preload_aoe(["lr_tower", "circle", "cone"])
	lockon_controller.pre_load([10, 11])
	lr_chains_controller.preload_resources()
	strat = SavedVariables.save_data["settings"]["p2_lr_strat"]
	if strat is not int or strat >= Strat.size() or strat < 0:
		push_warning("Invalid strat selected. Defaulting to NA.")
		GameEvents.emit_variable_saved("settings", "p2_lr_strat", 0)
		strat = Strat.NA
	instantiate_party(new_party)
	light_ramp_anim.play("light_ramp")


### START OF TIMELINE ###

## 03.00
# Start LR Cast (5s).
# Move to pre positions (4/4 or clocks).
func cast_lr() -> void:
	cast_bar.cast("Light Rampant", 5.0)
	# Start Shiva cast animation
	shiva.play_hand_down_cast()


func move_pre_pos() -> void:
	if strat in [Strat.ELE, Strat.MANA]:
		move_party(party, LRPosNA.pre_pos_44_ele)
	else:
		move_party(party, LRPosNA.pre_pos_44)

## 08.00
# Finish cast animation.
func finish_shiva_cast() -> void:
	shiva.finish_cast_animation()


## 08.75
# Assign debuffs.
# Put up spread markers, orbs, and chains.
func assing_debuffs() -> void:
	# Orb debuffs and lockon
	party[lr_party[orb_keys[0]]].add_debuff(WEIGHT_OF_LIGHT, 16)
	party[lr_party[orb_keys[1]]].add_debuff(WEIGHT_OF_LIGHT, 16)
	lockon_controller.add_marker(10, party[lr_party[orb_keys[0]]])
	lockon_controller.add_marker(10, party[lr_party[orb_keys[1]]])
	# Chains (inactive)
	for key in lr_north_lineup:
		party[key].add_debuff(CHAINS, 10)
	for key in lr_south_lineup:
		party[key].add_debuff(CHAINS, 10)
	# Spread Markers + Lightsteeped
	lockon_controller.add_marker(11, party[spread_keys[0]])
	lockon_controller.add_marker(11, party[spread_keys[1]])
	party[spread_keys[0]].add_debuff(LIGHTSTEEPED, 36, true, "lightsteeped")
	party[spread_keys[1]].add_debuff(LIGHTSTEEPED, 36, true, "lightsteeped")
	# Add a stack to first 4 in lightsteeped keys Array.
	for key in 4:
		party[lightsteeped_keys[key]].add_debuff(LIGHTSTEEPED, 36, true, "lightsteeped")
	# Spawn LC Chains
	spawn_chains()

## 09.75
# Spread markers move.
func move_puddles_tower_lineup() -> void:
	if strat in [Strat.NA,Strat.ELE]:
		party[lr_party["n_puddle"]].move_to(LRPosNA.tower_lineup["n_puddle"])
		party[lr_party["s_puddle"]].move_to(LRPosNA.tower_lineup["s_puddle"])
	elif strat == Strat.ELE: 
		party[lr_party["n_puddle"]].move_to(LRPosEU.tower_lineup["n_puddle"])
		party[lr_party["s_puddle"]].move_to(LRPosEU.tower_lineup["s_puddle"])
	elif strat == Strat.MANA:
		party[lr_party["n_puddle"]].move_to(LRPosJP.tower_lineup["n_puddle"])
		party[lr_party["s_puddle"]].move_to(LRPosJP.tower_lineup["s_puddle"])

## 10.75
# Chains first move.
func move_tower_lineup() -> void:
	if strat in [Strat.NA, Strat.ELE]:
		move_lr_party(LRPosNA.tower_lineup)
	elif strat == Strat.EU:
		move_lr_party(LRPosEU.tower_lineup)
	elif strat == Strat.MANA:
		move_lr_party(LRPosJP.tower_lineup)

## 11.00
# Solo towers spawn
# Hide Shiva
func spawn_solo_towers() -> void:
	for tower_pos in solo_tower_positions:
		solo_towers.append(ground_aoe_controller.spawn_lr_tower(tower_pos, LR_SOLO_TOWER_DURATION))
	# Hide Shiva
	shiva.visible = false


## 12.75
# Chains move to towers.
func move_tower_soak():
	if strat in [Strat.NA, Strat.ELE]:
		move_lr_party(LRPosNA.tower_soak)
	elif strat == Strat.EU:
		move_lr_party(LRPosEU.tower_soak)
	elif strat == Strat.MANA:
		move_lr_party(LRPosJP.tower_soak)

## 15.60
# First puddle snapshot (fades after 11s)
func first_puddle_snapshot() -> void:
	# Remove spread markers
	lockon_controller.remove_marker(11, party[spread_keys[0]])
	lockon_controller.remove_marker(11, party[spread_keys[1]])
	# Instantiate puddles
	puddles.append(puddle_controller.spawn_puddle(party[spread_keys[0]], PUDDLE_COUNT,
		PUDDLE_DROP_DELAY, PUDDLE_DURATION, PUDDLE_RADIUS, PUDDLE_COLOR, PUDDLE_TARGET_FAIL_COUNT))
	puddles.append(puddle_controller.spawn_puddle(party[spread_keys[1]], PUDDLE_COUNT,
		PUDDLE_DROP_DELAY, PUDDLE_DURATION, PUDDLE_RADIUS, PUDDLE_COLOR, PUDDLE_TARGET_FAIL_COUNT))
	# Spawn first AoE
	drop_puddles()
	# Move spread players
	if strat in [Strat.NA, Strat.ELE]:
		move_lr_party(LRPosNA.puddle_dodge_1)
	elif strat == Strat.EU:
		move_lr_party(LRPosEU.puddle_dodge_1)
	elif strat == Strat.MANA:
		move_lr_party(LRPosJP.puddle_dodge_1)


## 17.20
# Second puddle snapshot
func second_puddle_snapshot() -> void:
	drop_puddles()
	if strat in [Strat.NA, Strat.ELE]:
		move_lr_party(LRPosNA.puddle_dodge_2)
	elif strat == Strat.EU:
		move_lr_party(LRPosEU.puddle_dodge_2)
	elif strat == Strat.MANA:
		move_lr_party(LRPosJP.puddle_dodge_2)


## 18.80
# Third puddle snapshot
func third_puddle_snapshot() -> void:
	drop_puddles()
	if strat in [Strat.NA, Strat.ELE]:
		move_lr_party(LRPosNA.puddle_dodge_3)
	elif strat == Strat.EU:
		move_lr_party(LRPosEU.puddle_dodge_3)
	elif strat == Strat.MANA:
		move_lr_party(LRPosJP.puddle_dodge_3)


## 19.00
# Towers snapshot
func towers_snapshot() -> void:
	# Check towers
	for tower: LRTower in solo_towers:
		if tower.soaked != LRTower.SoakState.SOAKED:
			if tower.soaked == LRTower.SoakState.OVER:
				fail_list.add_fail("Too many players soaked tower.")
			elif tower.soaked == LRTower.SoakState.UNDER:
				fail_list.add_fail("Not enough players soaked tower.")
		# Add lightsteeped debuffs
		for pc: PlayableCharacter in tower.get_bodies():
			pc.add_debuff(LIGHTSTEEPED, LIGHTSTEEPED_DURATION, true, "lightsteeped")
		tower.queue_free()
	lr_chains_controller.activate_chains()


## 20.00
# Move soakers to N/S
# Spawn first orb trio
func move_post_tower() -> void:
	# Movement excludes puddles and should be universal.
	move_lr_party(LRPosNA.post_tower) 
	#if strat in [Strat.NA, Strat.ELE]:
		#move_lr_party(LRPosNA.post_tower)
	#else:
		#move_lr_party(LRPosEU.post_tower)
	first_orbs_spawn()


func first_orbs_spawn () -> void:
	# Randomize orb patter
	n_orb_pattern = randi() % 2 == 0
	if n_orb_pattern:
		for orb: P2LargeOrb in n_orb_list:
			orb.play_orb_spawn()
	else:
		for orb: P2LargeOrb in s_orb_list:
			orb.play_orb_spawn()


## 20.40
# Forth puddle snapshot
func forth_puddle_snapshot() -> void:
	drop_puddles()
	if strat in [Strat.NA, Strat.ELE]:
		move_lr_party(LRPosNA.puddle_dodge_4)
	elif strat == Strat.EU:
		move_lr_party(LRPosEU.puddle_dodge_4)
	elif strat == Strat.MANA:
		move_lr_party(LRPosJP.puddle_dodge_4)


## 22.00 
# Fifth puddle snapshot
# First orb telegraph (grow in)
func fifth_puddle_snapshot() -> void:
	drop_puddles()
	if strat in [Strat.NA, Strat.ELE]:
		move_lr_party(LRPosNA.puddle_dodge_5)
	elif strat == Strat.EU:
		move_lr_party(LRPosEU.puddle_dodge_5)
	elif strat == Strat.MANA:
		move_lr_party(LRPosJP.puddle_dodge_5)
	first_orbs_telegraph()


func first_orbs_telegraph () -> void:
	if n_orb_pattern:
		for orb: P2LargeOrb in n_orb_list:
			orb.play_tele_spawn()
	else:
		for orb: P2LargeOrb in s_orb_list:
			orb.play_tele_spawn()


## 23.00
# Second orb spawn
func second_orbs_spawn () -> void:
	if n_orb_pattern:
		for orb: P2LargeOrb in s_orb_list:
			orb.play_orb_spawn()
	else:
		for orb: P2LargeOrb in n_orb_list:
			orb.play_orb_spawn()


# Intermediate dodge to simulate slower movement leading up to shared hit
func move_to_intermediate_spot() -> void:
	if strat in [Strat.NA, Strat.ELE, Strat.MANA]:
		move_lr_party(LRPosNA.inter_dodge)
	elif strat == Strat.EU:
		move_lr_party(LRPosEU.inter_dodge)


## 24.50
# Move groups to first safe spot
func move_safe_spot_1() -> void:
	if strat in [Strat.NA, Strat.ELE, Strat.MANA]:
		if n_orb_pattern:
			move_lr_party(LRPosNA.north_orb_first_dodge)
		else:
			move_lr_party(LRPosNA.south_orb_first_dodge)
	else:
		if n_orb_pattern:
			move_lr_party(LRPosEU.north_orb_first_dodge)
		else:
			move_lr_party(LRPosEU.south_orb_first_dodge)


## 25.00
# Group soak snapshots
# Second orb telegraph
# Middle tower spawns
func group_soak_hit() -> void:
	# Group soak hit
	for key in orb_keys:
		ground_aoe_controller.spawn_circle(v2(party[lr_party[key]].global_position),
			ORB_AOE_RADIUS, ORB_AOE_LIFETIME, ORB_AOE_COLOR, [4, 4, "Powerful Light (LP Soaks)"])
		#for pc: PlayableCharacter in circle_aoe.get_bodies():
			#pc.add_debuff(LIGHTSTEEPED, 35.0, true, "lightsteeped")
		# Remove light orb
		lockon_controller.remove_marker(10, party[lr_party[key]])
	for pc_key in party:
			party[pc_key].add_debuff(LIGHTSTEEPED, 35.0, true, "lightsteeped")
	second_orbs_telegraph()
	spawn_middle_tower()


func second_orbs_telegraph() -> void:
	if n_orb_pattern:
		for orb: P2LargeOrb in s_orb_list:
			orb.play_tele_spawn()
	else:
		for orb: P2LargeOrb in n_orb_list:
			orb.play_tele_spawn()
			


func spawn_middle_tower() -> void:
	middle_tower = ground_aoe_controller.spawn_lr_tower(Vector2(0, 0), 8)
	middle_tower.set_bodies_required(4)


## 26.70
# First orb snapshot/fade
func first_orbs_hit() -> void:
	var this_orb_list = n_orb_list if n_orb_pattern else s_orb_list
	for orb: P2LargeOrb in this_orb_list:
		ground_aoe_controller.spawn_circle(v2(orb.global_position),
			LARGE_ORB_RADIUS, LARGE_ORB_DURATION, LARGE_ORB_COLOR, [0, 0, "Light Orb AoE"])
		orb.visible = false

## 27.00
# Move group to second safe spot
# Remove chains
func move_safe_spot_2() -> void:
	if strat in [Strat.NA, Strat.ELE, Strat.MANA]:
		if n_orb_pattern:
			move_lr_party(LRPosNA.north_orb_second_dodge)
		else:
			move_lr_party(LRPosNA.south_orb_second_dodge)
	elif strat == Strat.EU:
		if n_orb_pattern:
			move_lr_party(LRPosEU.north_orb_second_dodge)
		else:
			move_lr_party(LRPosEU.south_orb_second_dodge)
	# Remove all chains
	lr_chains_controller.remove_all_chains()

## 29.60
# Second orb snapshot/fade
# Move to middle soak spots
# Show shiva
func second_orbs_hit() -> void:
	var this_orb_list = s_orb_list if n_orb_pattern else n_orb_list
	for orb: P2LargeOrb in this_orb_list:
		ground_aoe_controller.spawn_circle(v2(orb.global_position),
			LARGE_ORB_RADIUS, LARGE_ORB_DURATION, LARGE_ORB_COLOR, [0, 0, "Light Orb AoE"])
		orb.visible = false
	move_middle_safe_spot()
	# Show Shiva
	shiva.visible = true


func move_middle_safe_spot() -> void:
	if strat in [Strat.NA, Strat.ELE, Strat.MANA]:
		if n_orb_pattern:
			move_lr_party(LRPosNA.n_pattern_middle_dodge)
		else:
			move_lr_party(LRPosNA.s_pattern_middle_dodge)
	elif strat == Strat.EU:
		if n_orb_pattern:
			move_lr_party(LRPosEU.n_pattern_middle_dodge)
		else:
			move_lr_party(LRPosEU.s_pattern_middle_dodge)
	# Move tower soakers in
	for index in range(4,8):
		party[lightsteeped_keys[index]].move_to(Vector2(0, 0))


## 32.00
# Show halo orbs
func show_halo_orbs() -> void:
	# Randomize pattern (4=spread, 1=pairs)
	halo_spread_pattern = randi() % 2 == 0
	if halo_spread_pattern:
		shiva.play_orb_anim(4)
	else:
		shiva.play_orb_anim(1)

## 33.7
# Snapshot middle tower
func middle_tower_snapshot() -> void:
	# Check tower
	if middle_tower.soaked != LRTower.SoakState.SOAKED:
		if middle_tower.soaked == LRTower.SoakState.OVER:
			fail_list.add_fail("Too many players soaked tower.")
		elif middle_tower.soaked == LRTower.SoakState.UNDER:
			fail_list.add_fail("Not enough players soaked tower.")
	# Add lightsteeped debuffs
	for pc: PlayableCharacter in middle_tower.get_bodies():
		pc.add_debuff(LIGHTSTEEPED, LIGHTSTEEPED_DURATION, true, "lightsteeped")
	# Free tower
	middle_tower.queue_free()


## 34.4
# Move to spread/pair spots
func move_spread_pairs() -> void:
	if halo_spread_pattern:
		if strat == Strat.MANA:
			move_party(party, LRPosJP.spread_clocks)
		else:
			move_party(party, LRPosNA.spread_clocks)
	else:
		if strat == Strat.MANA:
			move_party(party, LRPosJP.pairs)
		else:
			move_party(party, LRPosNA.pairs)


## 37.1
# Spread/pair hits
func spread_pairs_hit() -> void:
	if halo_spread_pattern:
		for pc_key in party:
			ground_aoe_controller.spawn_circle(v2(party[pc_key].global_position), SPREAD_AOE_RADIUS,
				SPREAD_AOE_LIFETIME, SPREAD_AOE_COLOR, [1, 1, "Banish III Divided (Spread AoE)"])
	else:
		# Coin flip for supports or dps being pair targets.
		var keys = support_keys if randi() % 2 == 0 else dps_keys
		for key in keys:
			ground_aoe_controller.spawn_circle(v2(party[key].global_position), PAIRS_AOE_RADIUS,
				PAIRS_AOE_LIFETIME, PAIRS_AOE_COLOR, [2, 2, "Banish III Shared (Pairs AoE)"])
	shiva.hide_halo()


## 38.0
# Move to clock pos
func move_to_clock_pos() -> void:
	if strat == Strat.MANA:
		move_party(party, LRPosJP.spread_clocks)
	else:
		move_party(party, LRPosNA.spread_clocks)


## 40.0
# Start House of Light Cast
func start_house_cast() -> void:
	cast_bar.cast("The House of Light", 4.5)

## 45.0
# Protean waves
# Check stacks
func protean_wave_hits() -> void:
	for pc_key in party:
		ground_aoe_controller.spawn_cone(Vector2(0, 0), PROTEAN_ANGLE, PROTEAN_LENGTH,
			v2(party[pc_key].global_position), PROTEAN_LIFETIME, PROTEAN_COLOR, [1, 1, "House of Light (Protean)"])
		party[pc_key].add_debuff(LIGHTSTEEPED, 0.0, true, "lightsteeped")
		if party[pc_key].get_debuff_stacks("lightsteeped") > 4:
			fail_list.add_fail(str(party[pc_key].to_string(), " got too many stacks."))


### END OF TIMELINE ###



func instantiate_party(new_party: Dictionary) -> void:
	# Standard role keys
	party = new_party
	# 4/4 Strat, will populate lr_party Dictionary
	four_four_party_setup()
	# Randomize lightsteeped array
	lightsteeped_keys.shuffle()


func four_four_party_setup() -> void:
	var spread_prio
	if strat == Strat.NA:
		spread_prio = na_we_spread_prio
	elif strat == Strat.EU:
		spread_prio = eu_ns_spread_prio
	elif strat in [Strat.ELE, Strat.MANA]:
		spread_prio = na_we_spread_prio
		lr_south_lineup = lr_south_lineup_ele
	# LR assigments: 2 puddles, 6 chains, 2 chained orbs
	# Get 2 unique random keys
	var spread_keys_index := []
	# Manual puddle force by user.
	if Global.p2_force_puddles:
		var player: PlayableCharacter = get_tree().get_first_node_in_group("player")
		spread_keys_index.append(lightsteeped_keys.find(player.get_role()))
	while spread_keys_index.size() < 2:
		var rand = randi_range(0, 7)
		if spread_keys_index.has(rand):
			continue
		spread_keys_index.append(rand)
	
	# Order spread (puddle) based on north/south prio
	if spread_prio.find(spread_keys_index[0]) > spread_prio.find(spread_keys_index[1]):
		spread_keys_index.append(spread_keys_index.pop_at(0))
	
	# Remove spread from lineups (0-3 is north, 4-7 is south)
	for index in spread_keys_index:
		if index < 4:
			if lr_north_lineup.size() <= index:
				spread_keys.append(lr_north_lineup.pop_back())
			else:
				spread_keys.append(lr_north_lineup.pop_at(index))
		else:
			if lr_south_lineup.size() <= index - 4:
				spread_keys.append(lr_south_lineup.pop_back())
			else:
				spread_keys.append(lr_south_lineup.pop_at(index - 4))
	# Check if we're 4/2, if so we move cw most person to the other group
	if lr_north_lineup.size() > 3:
		lr_south_lineup.append(lr_north_lineup.pop_front())
	elif lr_south_lineup.size() > 3:
		lr_north_lineup.append(lr_south_lineup.pop_front())
	# Populate Dictionary
	lr_party = { 
		"n0" : lr_north_lineup[0], "n1" : lr_north_lineup[1], "n2" : lr_north_lineup[2],
		"s0" : lr_south_lineup[0], "s1" : lr_south_lineup[1], "s2" : lr_south_lineup[2],
		"n_puddle" : spread_keys[0], "s_puddle" : spread_keys[1],
	}
	# Pick orb targets (adjacent chain targets)
	var valid_orb_keys = ["n0", "n1", "n2", "s0", "s1", "s2"]
	var orb_index_1 = randi_range(0, 5)
	var orb_index_2 = orb_index_1 + ((randi_range(0, 1) * 2) - 1)  # Either +1 or -1
	# Loop around 0 and 5
	if orb_index_2 > 5:
		orb_index_2 = 0
	elif orb_index_2 < 0:
		orb_index_2 = 5
	orb_keys = [valid_orb_keys[orb_index_1], valid_orb_keys[orb_index_2]]


func spawn_chains() -> void:
	spawn_chain_from_index("n0", "n1")
	spawn_chain_from_index("n1", "n2")
	spawn_chain_from_index("n2", "s0")
	spawn_chain_from_index("s0", "s1")
	spawn_chain_from_index("s1", "s2")
	spawn_chain_from_index("s2", "n0")


func spawn_chain_from_index(source_index: String, target_index: String) -> void:
	lr_chains_controller.spawn_chain(party[lr_party[source_index]],
		party[lr_party[target_index]],CHAINS_MAX_DIST, CHAINS_MIN_DIST, CHAINS_WIDTH)


func drop_puddles() -> void:
	for puddle: Puddle in puddles:
		puddle.drop()


# Moves given party of CharacterBodies to given positions, make sure keys match.
func move_party(party_dict: Dictionary, pos: Dictionary) -> void:
	for key: String in pos:
		var pc: PlayableCharacter = party_dict[key]
		pc.move_to(pos[key])

func move_lr_party(pos: Dictionary) -> void:
	for key: String in pos:
		var pc: PlayableCharacter = party[lr_party[key]]
		pc.move_to(pos[key])

func v2(v3: Vector3) -> Vector2:
	return Vector2(v3.x, v3.z)
