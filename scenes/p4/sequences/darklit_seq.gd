# Copyright 2025
# All rights reserved.
# This file is released under "GNU General Public License 3.0".
# Please see the LICENSE file that should have been included as part of this package.

extends Node

enum Strat {NA, EU, JP, MANA, MUR}
enum DanceStrat {SHARED, T1SOLO, T2SOLO}

# Debuff Icon Scenes
const DARK_WATER_ICON = preload("res://scenes/ui/auras/debuff_icons/p3/dark_water_icon.tscn")
const CHAINS_LOCKED_ICON = preload("res://scenes/ui/auras/debuff_icons/p2/chains_locked.tscn")
const CHAINS_ICON = preload("res://scenes/ui/auras/debuff_icons/p2/chains.tscn")
const LIGHTSTEEPED_ICON = preload("res://scenes/ui/auras/debuff_icons/p2/lightsteeped.tscn")

# AoE Dimensions
# Ahk Arai baits
const AHK_RADIUS := 14.0
const AHK_LIFETIME := 0.2
const AHK_COLOR := Color(0.416, 0.733, 0.949, 0.4)
# Light Rampant Chains
const CHAINS_MAX_DIST := 61.0
const CHAINS_MIN_DIST := 22.0
const CHAINS_WIDTH := 0.1
const CHAINS_LOCKED_DURATION := 14
# Path of Light Cones
const PROTEAN_ANGLE := 90
const PROTEAN_LENGTH := 150
const PROTEAN_LIFETIME := 0.5
const PROTEAN_COLOR := Color(0.8, 0.647059, 0, 0.6)
# Spirit Taker Jump
const JUMP_BUFFER := 15.0
const JUMP_DURATION := 0.5
const JUMP_RADIUS := 13.0
const JUMP_LIFETIME := 0.3
const JUMP_COLOR := Color.REBECCA_PURPLE
# Dark Water
const WATER_RADIUS := 16.0
const WATER_LIFETIME := 0.4
const WATER_COLOR := Color.DODGER_BLUE
# Hallowed Wings
const HALLOWED_SOURCE := Vector2(-50, -25)
const HALLOWED_TARGET := Vector2(50, -25)
const HALLOWED_WIDTH := 50
const HALLOWED_LENGTH := 100
const HALLOWED_LIFETIME := 0.3
const HALLOWED_COLOR := Color.SKY_BLUE
# Akh Morn
const AM_RADIUS := 12.0
const AM_LIFETIME := 0.3
const AM_LIGHT_COLOR := Color.GOLD
const AM_DARK_COLOR := Color.DARK_VIOLET
# Misc
const TOWER_LIFETIME := 8.0
const MID_BAIT_THRESHOLD := 4.0

# NA Prios. West to East prio for Path of Light baits
const NAUR_LINEUP := ["h1", "h2", "t1", "t2", "r1", "r2", "m1", "m2"]
const NAUR_WE_PRIO := ["h1", "h2", "t1", "t2", "r2", "r1", "m1", "m2"]
# MUR Prio, matches lineup.
const MUR_WE_PRIO := ["h1", "h2", "t1", "t2", "r1", "r2", "m1", "m2"]
# EU/JP Prios. West to East for Tower positions, South to North for baits.
# If you want to change the dps lineup, do it here.
const EU_JP_DPS_LINEUP := ["m1", "m2", "r1", "r2"]  # W>E or S>N
const EU_JP_WE_PRIO := ["t1", "t2", "h1", "h2", "m1", "m2", "r1", "r2"]
# Mana Prio, matches lineup.
const MANA_WE_PRIO := ["h1", "h2", "t1", "t2", "m1", "m2", "r1", "r2"]

# Entity Positions
const USURPER_POS := {"final": Vector3(0, 0, -6), "final_rota": 135.0}
const ORACLE_POS := {"final": Vector3(0, 0, 6), "final_rota": -135.0}
const TOWER_POS := {"north": Vector2(19, 0), "south": Vector2(-19, 0)}

const DEBUFF_ASSIGNMENTS := {
	"nw_tether": {LIGHTSTEEPED_ICON: 12, CHAINS_ICON: 7},
	"ne_tether": {LIGHTSTEEPED_ICON: 12, CHAINS_ICON: 7},
	"sw_tether": {LIGHTSTEEPED_ICON: 12, CHAINS_ICON: 7},
	"se_tether": {LIGHTSTEEPED_ICON: 12, CHAINS_ICON: 7},
	"nw_bait": {LIGHTSTEEPED_ICON: 12},
	"ne_bait": {LIGHTSTEEPED_ICON: 12},
	"sw_bait": {LIGHTSTEEPED_ICON: 12},
	"se_bait": {LIGHTSTEEPED_ICON: 12},
	"water": {DARK_WATER_ICON: 19}
}

@onready var lr_chains_controller: LRChainsController = %LRChainsController
@onready var darklit_anim: AnimationPlayer = %DarklitAnim
@onready var cast_bar: CastBar = %CastBar
@onready var enmity_cast_bar: EnmityCastBar = %EnmityCastBar
@onready var ground_aoe_controller: GroundAoeController = %GroundAoEController
@onready var lockon_controller: LockonController = %LockonController
@onready var usurper_boss: Node3D = %UsurperBoss
@onready var oracle_boss: Node3D = %OracleBoss
@onready var oracle: Oracle = %Oracle
@onready var usurper: Usurper = %Usurper
@onready var fail_list: FailList = %FailList
@onready var oracle_hitbox_ring: Node3D = %OracleHitboxRing
@onready var usurper_hitbox_ring: Node3D = %UsurperHitboxRing
@onready var wings_west: UsurperWings = %WingsWest
@onready var wings_east: UsurperWings = %WingsEast
@onready var watch_hp_label: Label = %WatchHPLabel

var party: Dictionary  # Standard role keys (m1, r1, etc.)
var party_dd := {
	"nw_tether": "", "ne_tether": "", "se_tether": "", "sw_tether": "",
	"nw_bait": "", "ne_bait": "", "se_bait": "", "sw_bait": ""
	}
var tether_keys := ["nw_tether", "ne_tether", "se_tether", "sw_tether"]
var ahk_snapshots: Dictionary
var water_keys: Array  # [tether, non-tether]
var spirit_jump_target: String
var spirit_jump_pos: Vector3
var jump_snap_pos: Vector3
var jump_snap_key: String
# List of party keys in order of chaining (0 > 1 > 2 > 3 > 0). 0 should be anchor (healer).
var tether_links := []
var water_lockons := []
var lr_towers := []
var east_wing: bool
var pre_swap_party_dd: Dictionary
var spirit_spread_dd: Dictionary
var tank_bait_east: bool
var strat: Strat
var dance_strat: DanceStrat  # [Share, T1 Solo, T2 Solo]
var bait_tank: PlayableCharacter


func start_sequence(new_party: Dictionary) -> void:
	assert(new_party != null, "Error. Where the party at?")
	ground_aoe_controller.preload_aoe(["line", "circle", "cone"])
	lockon_controller.pre_load([LockonController.STACK_MARKER, LockonController.CD_COG])
	lr_chains_controller.preload_resources()
	strat = SavedVariables.save_data["settings"]["p4_dd_strat"]
	# If strat is invalid, fix SavedVariable
	if strat is not int or strat >= Strat.size() or strat < 0:
		strat = Strat.NA
		printerr("Invalid Strat SavedVariable. Defaulting to NAUR.")
		GameEvents.emit_variable_saved("settings", "p4_dd_strat", 0)
	# Setup debuff and random assignments.
	instantiate_party(new_party)
	# Boss visibility and animation setup.
	usurper.remove_wings()
	oracle.play_hide()
	oracle.hide()
	# Start DD sequence.
	darklit_anim.play("darklit")


### START OF TIMELINE ###

## 2.0
# Move part mid
func move_mid():
	if strat == Strat.MANA:
		move_party(DDPos.MANA_STACK_PARTY)
	else:
		move_party(DDPos.MID_STACK_PARTY)


## 3.2
# Start dragon animation
func start_ahk_anim() -> void:
	usurper.play_spin_wings()

## 6.6
# Dragon wings out
# Snapshot all player positions
func snapshot_ahk_aoe() -> void:
	for key in party:
		ahk_snapshots[key] = v2(party[key].global_position)

## 7.2
# Move to first spread positions
func move_first_spread() -> void:
	if strat in [Strat.NA, Strat.MUR]:
		move_party(DDPos.POST_AA_PARTY_NA)
	elif strat == Strat.EU:
		move_party(DDPos.POST_AA_PARTY_EU)
	elif strat == Strat.JP:
		move_party(DDPos.POST_AA_PARTY_JP)
	elif strat == Strat.MANA:
		move_party(DDPos.POST_AA_PARTY_MANA)

## 9.3
# First AoE's hit on snapshot positions
func ahk_hit():
	for key in ahk_snapshots:
		ground_aoe_controller.spawn_circle(ahk_snapshots[key], AHK_RADIUS,
			AHK_LIFETIME, AHK_COLOR, [0, 0, "Ahk Rhai"])

## 13.3
# Last AoE hit (11 hits, every .4s)

## 14.2
# Spawn in Oracle
# Move to LR pre positions
func show_oracle():
	oracle.play_show()


func move_lr_pre_pos():
	if strat in [Strat.NA, Strat.MUR]:
		move_party(DDPos.LR_PARTY_NA)
	elif strat == Strat.EU:
		move_party(DDPos.LR_PARTY_EU)
	elif strat == Strat.JP:
		move_party(DDPos.LR_PARTY_JP)
	elif strat == Strat.MANA:
		move_party(DDPos.LR_PARTY_MANA)


## 14.7
# Manually swap targets (temporary)
func swap_target():
	usurper_hitbox_ring.play_hide()
	oracle_hitbox_ring.play_show()


## 16.4
# Show stack markers.
# Cast and Clone Cast Darklit Dragonsong (4.7s)
# Start hands out cast animation.
func cast_darklit():
	cast_bar.cast("Darklit Dragonsong", 4.7)
	enmity_cast_bar.cast("Darklit Dragonsong", 4.7)
	for water_key in water_keys:
		lockon_controller.add_marker(LockonController.STACK_MARKER, party[water_key])
	usurper.play_hands_out_cast()


## 21.2
# Finish cast animations (both)
func darklit_cast_finish():
	usurper.play_hands_in_finish()
	oracle.play_ct_cast()


## 21.6
# Remove stack markers
# Show cog lockons
func show_cog_lockon():
	for water_key in water_keys:
		var pc: PlayableCharacter = party[water_key]
		lockon_controller.remove_marker(LockonController.STACK_MARKER, pc)
		for key in DEBUFF_ASSIGNMENTS["water"]:
			pc.add_debuff(key, DEBUFF_ASSIGNMENTS["water"][key])
		# Lockon markers
		var lockon = lockon_controller.add_marker(LockonController.CD_COG, pc)
		water_lockons.append(lockon)

## 22.3
# Assign LC debuffs
# Show chains
func add_debuffs():
	for dd_key in party_dd:
		for debuff_key in DEBUFF_ASSIGNMENTS[dd_key]:
			# Need to apply 3 stacks of each Lightsteeped debuff.
			if debuff_key == LIGHTSTEEPED_ICON:
				for i in 3:
					get_char(dd_key).add_debuff(debuff_key, DEBUFF_ASSIGNMENTS[dd_key][debuff_key],
						true, "lightsteeped")
			else:
				get_char(dd_key).add_debuff(debuff_key, DEBUFF_ASSIGNMENTS[dd_key][debuff_key])
	# Spawn chains
	spawn_chain_from_key(tether_links[0], tether_links[1])
	spawn_chain_from_key(tether_links[1], tether_links[2])
	spawn_chain_from_key(tether_links[2], tether_links[3])
	spawn_chain_from_key(tether_links[3], tether_links[0])


func spawn_chain_from_key(source_key: String, target_key: String) -> void:
	lr_chains_controller.spawn_chain(party[source_key],
		party[target_key], CHAINS_MAX_DIST, CHAINS_MIN_DIST, CHAINS_WIDTH)


## 24.6
# Show towers
# Clone Cast Path of Light (7.7s)
func spawn_lr_towers():
	enmity_cast_bar.cast("The Path of Light", 7.7)
	lr_towers.append(ground_aoe_controller.spawn_lr_tower(TOWER_POS["north"], TOWER_LIFETIME))
	lr_towers.append(ground_aoe_controller.spawn_lr_tower(TOWER_POS["south"], TOWER_LIFETIME))
	lr_towers[0].set_bodies_required(2)
	lr_towers[1].set_bodies_required(2)

## 25.2
# Move to LR positions
func move_lr_pos():
	# Pre Water swap
	for key: String in pre_swap_party_dd:
		var pc: PlayableCharacter = party[pre_swap_party_dd[key]]
		pc.move_to(DDPos.BOWTIE_DD[key])


## 28.2
# Make Water debuff swap if needed
func move_water_swap():
	# Post Water swap
	move_party_dd(DDPos.BOWTIE_DD)


## 29.2
# Activate chains (14s)
func activate_chains():
	# Add debuff
	for dd_key in tether_keys:
		get_char(dd_key).add_debuff(CHAINS_LOCKED_ICON, CHAINS_LOCKED_DURATION)
	# Activate chains
	lr_chains_controller.activate_chains()


## 32.3
# Towers hit, Path of Light cones hit.
func towers_hit():
	# Towers hit
	for tower: LRTower in lr_towers:
		if tower.soaked != LRTower.SoakState.SOAKED:
			if tower.soaked == LRTower.SoakState.OVER:
				fail_list.add_fail("Too many players soaked tower.")
			elif tower.soaked == LRTower.SoakState.UNDER:
				fail_list.add_fail("Not enough players soaked tower.")
		# Add lightsteeped debuffs
		for pc: PlayableCharacter in tower.get_bodies():
			pc.add_debuff(LIGHTSTEEPED_ICON, 0.0, true, "lightsteeped")
		tower.queue_free()
	# Path of Light on 4 nearest to Shiva
	var nearest_keys = get_nearest_target_list(Vector2(0, 0), 4)
	for key in nearest_keys:
		ground_aoe_controller.spawn_cone(Vector2(0, 0), PROTEAN_ANGLE, PROTEAN_LENGTH,
			v2(party[key].global_position), PROTEAN_LIFETIME, PROTEAN_COLOR, [1, 1, "House of Light (Protean)"])
		party[key].add_debuff(LIGHTSTEEPED_ICON, 0.0, true, "lightsteeped")
		if party[key].get_debuff_stacks("lightsteeped") > 4:
			fail_list.add_fail(str(party[key].to_string(), " got too many stacks of Lightsteeped."))

## 32.6
# Cast + Enmity Cast Spirit Taker (2.7s)
func cast_spirit_taker():
	cast_bar.cast("Spirit Taker", 2.7)
	enmity_cast_bar.cast("Spirit Taker", 2.7)

## 33.5
# Move to Spirit spread pos
func move_spirit_spread():
	if strat in [Strat.NA, Strat.MUR]:
		for key: String in spirit_spread_dd:
			var pc: PlayableCharacter = party[spirit_spread_dd[key]]
			pc.move_to(DDPos.SPIRIT_DD_SP_NA[key])
	elif strat == Strat.EU:
		move_party_dd(DDPos.SPIRIT_DD_EU)
	elif strat in [Strat.JP, Strat.MANA]:
		move_party_dd(DDPos.SPIRIT_DD_JP)

## 35.5
# Start cog countdown
# Snapshot Spirit AoE position
func snapshot_spirit():
	water_lockons[0].start_countdown()
	water_lockons[1].start_countdown()
	# Snapshot Spirit Jump AoE position
	spirit_jump_pos = party[spirit_jump_target].global_position
	# Play wings out anim
	usurper.play_wings_out_cast()

## 35.7
# Enmity Cast Hallowed Wings (4.7s)
# Show Wing Glow
func cast_hallowed():
	enmity_cast_bar.cast("Hallowed Wings", 4.7)
	# Show wing glow
	if east_wing:
		wings_east.play_show()
	else:
		wings_west.play_show()

## 36.1
# Start of Oracle jump
func oracle_rand_jump():
	oracle_jump(spirit_jump_pos)


func oracle_jump(target_pos: Vector3):
	# We only want to jump to around the edge of the boss' hitbox.
	var dist = target_pos.distance_to(oracle.global_position)
	target_pos = (target_pos - oracle.global_position).normalized()
	# If target is not far enough away, don't move.
	target_pos *= max((dist - JUMP_BUFFER), 0.001) 
	target_pos += oracle.global_position
	oracle_boss.look_at(Vector3(target_pos.x, 0, target_pos.z))
	oracle_boss.rotation.y += deg_to_rad(90.0)
	var tween : Tween = get_tree().create_tween()
	tween.tween_property(oracle_boss, "global_position",
		Vector3(target_pos.x, 0, target_pos.z), JUMP_DURATION)\
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	oracle.play_flip_special()


## 36.7
# Oracle jump hit
func jump_hit():
	ground_aoe_controller.spawn_circle(v2(spirit_jump_pos), JUMP_RADIUS,
		JUMP_LIFETIME, JUMP_COLOR, [1, 1, "Darkest Dance (Oracle Jump)",
		[party[spirit_jump_target]]])

## 38.4
# Move to wing stacks
func move_hallowed_stacks():
	if east_wing:
		move_party_dd(DDPos.WATER_W_DD)
	else:
		move_party_dd(DDPos.WATER_E_DD)

## 38.8
# Cast + Enmity Cast Somber Dance (4.7s)
func cast_somber():
	cast_bar.cast("Somber Dance", 4.7)
	enmity_cast_bar.cast("Somber Dance", 4.7)

## 40.4
# Move tank out to bait pos
func move_tank_1_inter_bait():
	# Determine which tank is baiting.
	dance_strat = SavedVariables.save_data["settings"]["p4_dd_dance_strat"]
	if dance_strat in [DanceStrat.SHARED, DanceStrat.T1SOLO]:
		bait_tank = party["t1"]
	else:
		bait_tank = party["t2"]
	
	# If Mana strat, ignore Oracle's position and bait based off wings only.
	if strat == Strat.MANA:
		tank_bait_east = !east_wing
	# Otherwise, tank bait position is based off Oracle's position.
	else:
		var oracle_z := oracle_boss.global_position.z
		# If Oracle is close enough to mid, send tank to bait where wings hit.
		tank_bait_east = oracle_z < -MID_BAIT_THRESHOLD or\
		((oracle_z < MID_BAIT_THRESHOLD and oracle_z > -MID_BAIT_THRESHOLD) and east_wing)
	
	# Move tank
	if tank_bait_east:
		# Check if movement is needed (tank is already East of inter pos).
		if bait_tank.global_position.z > DDPos.DANCE_NW_INTER_TANK.y:
			return
		# Tank is North.
		if bait_tank.global_position.x > 0:
			bait_tank.move_to(DDPos.DANCE_NE_INTER_TANK)
		# Tank is South.
		else:
			bait_tank.move_to(DDPos.DANCE_SE_INTER_TANK)
	else:
		# Check if movement is needed (tank is already West of inter pos).
		if bait_tank.global_position.z < DDPos.DANCE_NW_INTER_TANK.y:
			return
		# Check where tank is for intermediate movement.
		# Tank is North.
		if bait_tank.global_position.x > 0:
			# If tank is already on correct side, skip this movement.
			bait_tank.move_to(DDPos.DANCE_NW_INTER_TANK)
		# Tank is South.
		else:
			bait_tank.move_to(DDPos.DANCE_SW_INTER_TANK)


## 40.5
# Water stacks hit
# Hallowed Wings hit
# Hide wings (need confirmation if these hit simultaneously).
func water_hallowed_hit():
	# Water
	for key in water_keys:
		ground_aoe_controller.spawn_circle(v2(party[key].global_position),
			WATER_RADIUS, WATER_LIFETIME, WATER_COLOR, [4, 4, "Dark Water III"])
	# Hallowed Wings Hit (half room cleave)
	var source := HALLOWED_SOURCE
	var target := HALLOWED_TARGET
	if east_wing:
		source = source * Vector2(1, -1)
		target = target * Vector2(1, -1)
	ground_aoe_controller.spawn_line(source, HALLOWED_WIDTH, HALLOWED_LENGTH,
		target, HALLOWED_LIFETIME, HALLOWED_COLOR, [0, 0, "Hallowed Wings"])
	usurper.play_wings_out_finish()
	# Hide Wings
	if east_wing:
		wings_east.play_hide()
	else:
		wings_west.play_hide()


## 41.8
# Move tank to final bait position:
func move_tank_bait():
	if tank_bait_east:
		bait_tank.move_to(DDPos.DANCE_E_TANK)
	else:
		bait_tank.move_to(DDPos.DANCE_W_TANK)


## 42.4
# Move party towards Oracle, move tank 1 to final bait position.
func move_party_bait():
	if tank_bait_east:
		#move_party_dd(DDPos.DANCE_W_DD)
		move_party_dd(DDPos.DANCE_MID_DD)
		bait_tank.move_to(DDPos.DANCE_E_TANK)
	else:
		#move_party_dd(DDPos.DANCE_E_DD)
		move_party_dd(DDPos.DANCE_MID_DD)
		bait_tank.move_to(DDPos.DANCE_W_TANK)


## 43.5
# Remove chains
func remove_chains():
	lr_chains_controller.remove_all_chains()
	

## 44.1
# Snapshot farthest target
func snapshot_farthest():
	var target_list = get_nearest_target_list(v2(oracle.global_position), 8)
	jump_snap_key = target_list[7]
	jump_snap_pos = party[jump_snap_key].global_position


## 44.0
# T2 Follows to bait near
func move_tank_2_bait():
	# Check if Tank is soloing Dance.
	if dance_strat == DanceStrat.SHARED:
		if tank_bait_east:
			party["t2"].move_to(DDPos.DANCE_E_TANK)
		else:
			party["t2"].move_to(DDPos.DANCE_W_TANK)

## 44.8
# Jump to farthest player (not to snapshot)
# Jump AoE hits (at snapshot)
# Swap target ring to frost (temporary until proper targetting is added)
func oracle_far_jump():
	oracle_jump(party[jump_snap_key].global_position)
	ground_aoe_controller.spawn_circle(v2(jump_snap_pos), JUMP_RADIUS,
		JUMP_LIFETIME, JUMP_COLOR, [1, 1, "Darkest Dance (Oracle Jump)"])

## 45.5
# Move Second Bait tank to Oracle
func move_tank_2_oracle():
	if dance_strat == DanceStrat.SHARED:
		party["t2"].move_to(v2(oracle_boss.global_position))
	else:
		bait_tank.move_to(v2(oracle_boss.global_position))


## 47.6
# Second jump to nearest
# Jump AoE hits (at nearest)
func oracle_near_jump():
	var near_jump_key = get_nearest_target_list(v2(oracle.global_position), 1)[0]
	var near_jump_pos = party[near_jump_key].global_position
	oracle_jump(near_jump_pos)
	ground_aoe_controller.spawn_circle(v2(near_jump_pos), JUMP_RADIUS,
		JUMP_LIFETIME, JUMP_COLOR, [1, 1, "Darkest Dance (Oracle Jump)"])


## 51.1
# Move party to AM positions
func move_party_am():
	var am_strat = SavedVariables.save_data["settings"]["p4_dd_am_strat"]
	if am_strat == 0:
		move_party(DDPos.AM_4_4_PARTY)
	elif am_strat == 1:
		move_party(DDPos.AM_7_1_PARTY_T1)
	elif am_strat == 2:
		move_party(DDPos.AM_7_1_PARTY_T2)

## 51.9
# Fade out bosses
func fade_out_bosses():
	oracle.play_hide()
	usurper.play_fade_out()
	oracle_hitbox_ring.play_hide()
	usurper_hitbox_ring.play_hide()

## 52.3*
# Move/show bosses at Light/Dark positions
func move_bosses_mid():
	oracle_boss.global_position = ORACLE_POS["final"]
	oracle_boss.rotation.y = deg_to_rad(ORACLE_POS["final_rota"])
	usurper_boss.global_position = USURPER_POS["final"]
	usurper_boss.rotation.y = deg_to_rad(USURPER_POS["final_rota"])
	oracle.play_show()
	#oracle_hitbox_ring.play_show()
	usurper.play_fade_in()
	usurper_hitbox_ring.play_show()

## 53.2
# Cast + Enmity Cast x2 Akh Morn (3.7s)
# Show watch HP warning
func cast_am():
	watch_hp_label.show()
	cast_bar.cast("Akh Morn", 3.7)
	enmity_cast_bar.cast("Akh Morn", 3.7, 2)

## 56.9
# Cast animations (both)
func am_boss_anim():
	watch_hp_label.hide()
	oracle.play_ct_cast()
	usurper.play_short_cast()

## 58.6, 59.2, 59.8, 60.4
# AM hits (4 over 1.8s)
func am_hit():
	ground_aoe_controller.spawn_circle(v2(party["t1"].global_position), AM_RADIUS,
		AM_LIFETIME, AM_LIGHT_COLOR, [1, 7, "Akh Morn (Light)"])
	ground_aoe_controller.spawn_circle(v2(party["t2"].global_position), AM_RADIUS,
		AM_LIFETIME, AM_DARK_COLOR, [1, 7, "Akh Morn (Dark)"])


### END OF TIMELINE ###


func instantiate_party(new_party: Dictionary) -> void:
	# Standard role keys
	party = new_party
	# NAUR/MANA/MUR setup
	if strat in [Strat.NA, Strat.MANA, Strat.MUR]:
		na_mana_mur_party_setup()
	# Vetical/EU setup
	elif strat in [Strat.EU, Strat.JP]:
		eu_jp_party_setup()
	else:
		assert(false, "Error. Invalid Strat selection in party setup.")
	# Pick Usurper Jump target
	if Global.p4_dd_force_spirit:
		spirit_jump_target = get_tree().get_first_node_in_group("player").get_role()
	else:
		spirit_jump_target = NAUR_WE_PRIO.pick_random()
		#spirit_jump_target = party_dd.keys().pick_random()
	east_wing = randi() % 2 == 0


func na_mana_mur_party_setup() -> void:
	# Shuffle tank, healers and dps (tank/healer/dps[0] + dps[1] will be LR tethers)
	var tanks = Global.TANK_ROLE_KEYS.duplicate()
	var healers = Global.HEALER_ROLE_KEYS.duplicate()
	var dps = Global.DPS_ROLE_KEYS.duplicate()
	tanks.shuffle()
	healers.shuffle()
	dps.shuffle()
	
	# If user is forcing tethers, swap player to tether index.
	if Global.p4_dd_force_tether:
		var player_key: String = get_tree().get_first_node_in_group("player").get_role()
		if Global.TANK_ROLE_KEYS.has(player_key) and tanks[0] != player_key:
			tanks[1] = tanks[0]
			tanks[0] = player_key
		elif Global.HEALER_ROLE_KEYS.has(player_key) and healers[0] != player_key:
			healers[1] = healers[0]
			healers[0] = player_key
		elif Global.DPS_ROLE_KEYS.has(player_key) and (dps[0] != player_key and dps[1] != player_key):
			var player_index = dps.find(player_key)
			var swap_index = randi_range(0, 1)
			dps[player_index] = dps[swap_index]
			dps[swap_index] = player_key
	
	# Build shuffled tether link list (0 linked to 1 and 3, etc.)
	tether_links.append(tanks[0])
	tether_links.append(dps[0])
	tether_links.append(dps[1])
	tether_links.shuffle()
	# Add healer at index 0 (Healer always NW anchor)
	tether_links.push_front(healers[0])
	
	# Handle tether swap to make bowtie shape
	# Use lineup to determine which dps is East/West
	var lineup
	var we_prio
	if strat == Strat.NA:
		we_prio = NAUR_WE_PRIO
		lineup = NAUR_LINEUP
	elif strat == Strat.MANA:
		we_prio = MANA_WE_PRIO
		lineup = MANA_WE_PRIO
	elif strat == Strat.MUR:
		we_prio = MUR_WE_PRIO
		lineup = MUR_WE_PRIO
	else:
		assert(false, "Invalid Strat selection in NA/Mana/MUR party setup.")
	
	var east_dps
	var west_dps
	if lineup.find(dps[0]) < lineup.find(dps[1]):
		west_dps = dps[0]
		east_dps = dps[1]
	else:
		east_dps = dps[0]
		west_dps = dps[1]
	# Default bowtie shape (no swaps needed)
	var bowtie_tethers := [healers[0], tanks[0], east_dps, west_dps]  # [nw, ne, se, sw]
	# Get the pair of keys linked to the healer
	var linked_to_nw := [tether_links[1], tether_links[3]]
	# If box shape, swap tank with east dps
	if linked_to_nw.has(tanks[0]) and linked_to_nw.has(west_dps):
		bowtie_tethers[1] = east_dps # ne
		bowtie_tethers[2] = tanks[0] # se
	# If hourglass shape, swap tank with west dps
	elif linked_to_nw.has(tanks[0]) and linked_to_nw.has(east_dps):
		bowtie_tethers[1] = west_dps # ne
		bowtie_tethers[3] = tanks[0] # sw
	# If bowtie shape, no swaps needed
	else:
		assert(!linked_to_nw.has(tanks[0]), "Bowtie shape with tank linked to healer should not be possible.")
	
	# Handle water debuffs and potential swap
	var non_tethers := [healers[1], tanks[1], dps[2], dps[3]]  # [nw, ne, se, sw]
	# Swap DPS based on W>E prio
	if we_prio.find(dps[2]) < we_prio.find(dps[3]):
		non_tethers[2] = dps[3]
		non_tethers[3] = dps[2]
	# Store pre-swap positions, to be used for bot movement.
	var pre_water_swap_non_tethers = non_tethers.duplicate()
	# Pick Waters, swap non-tethers if they are on same N/S side.
	var tether_water = bowtie_tethers.pick_random()
	var non_tether_water = non_tethers.pick_random()
	var west_swapped := false
	var east_swapped := false
	# Check if both waters are North
	if (tether_water == bowtie_tethers[0] or tether_water == bowtie_tethers[1]) and\
		(non_tether_water == non_tethers[0] or non_tether_water == non_tethers[1]):
		# 0 swaps with 3, 1 swaps with 2
		if non_tether_water == non_tethers[0]:
			var temp = non_tethers[0]
			non_tethers[0] = non_tethers[3]
			non_tethers[3] = temp
			west_swapped = true
		elif non_tether_water == non_tethers[1]:
			var temp = non_tethers[1]
			non_tethers[1] = non_tethers[2]
			non_tethers[2] = temp
			east_swapped = true
	# Check if both waters are South
	elif (tether_water == bowtie_tethers[2] or tether_water == bowtie_tethers[3]) and\
		(non_tether_water == non_tethers[2] or non_tether_water == non_tethers[3]):
		# 0 swaps with 3, 1 swaps with 2
		if non_tether_water == non_tethers[3]:
			var temp = non_tethers[0]
			non_tethers[0] = non_tethers[3]
			non_tethers[3] = temp
			west_swapped = true
		elif non_tether_water == non_tethers[2]:
			var temp = non_tethers[1]
			non_tethers[1] = non_tethers[2]
			non_tethers[2] = temp
			east_swapped = true
	assert(!(west_swapped and east_swapped), "Error in E/W swap logic.")
	# Build party_dd Dictionary
	party_dd = {
		"nw_tether": bowtie_tethers[0], "ne_tether": bowtie_tethers[1],
		"se_tether": bowtie_tethers[2], "sw_tether": bowtie_tethers[3],
		"nw_bait": non_tethers[0], "ne_bait": non_tethers[1],
		"se_bait": non_tethers[2], "sw_bait": non_tethers[3]
		}
	# Build pre-swap Dictionary (for positioning before waters swap)
	pre_swap_party_dd = party_dd.duplicate()
	pre_swap_party_dd["nw_bait"] = pre_water_swap_non_tethers[0]
	pre_swap_party_dd["ne_bait"] = pre_water_swap_non_tethers[1]
	pre_swap_party_dd["se_bait"] = pre_water_swap_non_tethers[2]
	pre_swap_party_dd["sw_bait"] = pre_water_swap_non_tethers[3]
	water_keys = [tether_water, non_tether_water]
	# Build Spirit Spread Dictionary (need to distinguish Supp from DPS for spread positions).
	spirit_spread_dd = {
		"nw_tether": party_dd["nw_tether"], "ne_tether": party_dd["ne_tether"],
		"se_tether": party_dd["se_tether"], "sw_tether": party_dd["sw_tether"],
		"w_sup": party_dd["nw_bait"], "w_dps": party_dd["sw_bait"],
		"e_sup": party_dd["ne_bait"], "e_dps": party_dd["se_bait"]
	}
	if west_swapped:
		spirit_spread_dd["w_sup"] = party_dd["sw_bait"]
		spirit_spread_dd["w_dps"] = party_dd["nw_bait"]
	elif east_swapped:
		spirit_spread_dd["e_sup"] = party_dd["se_bait"]
		spirit_spread_dd["e_dps"] = party_dd["ne_bait"]


func eu_jp_party_setup() -> void:
	# Shuffle tank, healers and dps (tank/healer/dps[0] + dps[1] will be LR tethers)
	var tanks = Global.TANK_ROLE_KEYS.duplicate()
	var healers = Global.HEALER_ROLE_KEYS.duplicate()
	var dps = Global.DPS_ROLE_KEYS.duplicate()
	tanks.shuffle()
	healers.shuffle()
	dps.shuffle()
	
	# If user is forcing tethers, swap player to tether index.
	if Global.p4_dd_force_tether:
		var player_key: String = get_tree().get_first_node_in_group("player").get_role()
		if Global.TANK_ROLE_KEYS.has(player_key) and tanks[0] != player_key:
			tanks[1] = tanks[0]
			tanks[0] = player_key
		elif Global.HEALER_ROLE_KEYS.has(player_key) and healers[0] != player_key:
			healers[1] = healers[0]
			healers[0] = player_key
		elif Global.DPS_ROLE_KEYS.has(player_key) and (dps[0] != player_key and dps[1] != player_key):
			var player_index = dps.find(player_key)
			var swap_index = randi_range(0, 1)
			dps[player_index] = dps[swap_index]
			dps[swap_index] = player_key
	
	# Build shuffled tether link list (0 linked to 1 and 3, etc.)
	tether_links.append(tanks[0])
	tether_links.append(dps[0])
	tether_links.append(dps[1])
	tether_links.shuffle()
	# Add healer at index 0 (Healer always North anchor)
	tether_links.push_front(healers[0])
	
	# Handle tether swap to make bowtie shape
	# Get the pair of keys linked to the healer. These will be south_tower
	var south_tethers := [tether_links[1], tether_links[3]]  # [SW, SE]
	var north_tethers := [tether_links[0], tether_links[2]]  # [NW, NE]
	# Order tethers based on W>E prio.
	if EU_JP_WE_PRIO.find(south_tethers[0]) > EU_JP_WE_PRIO.find(south_tethers[1]):
		south_tethers = [tether_links[3], tether_links[1]]
	if EU_JP_WE_PRIO.find(north_tethers[0]) > EU_JP_WE_PRIO.find(north_tethers[1]):
		north_tethers = [tether_links[2], tether_links[0]]
	var west_baits := [healers[1], tanks[1]]  # [NW, SW]
	var east_baits := [dps[2], dps[3]]  # [NE, SE]
	# Order dps baits based on S>N prio
	if EU_JP_WE_PRIO.find(east_baits[1]) > EU_JP_WE_PRIO.find(east_baits[0]):
		east_baits = [dps[3], dps[2]]
	# [NW, NE, SE, SW]
	var tethers := [north_tethers[0], north_tethers[1], south_tethers[1], south_tethers[0]]
	var baits := [west_baits[0], east_baits[0], east_baits[1], west_baits[1]]
	# Pick waters
	var tether_water = tethers.pick_random()
	var non_tether_water = baits.pick_random()
	
	# Store pre-swap positions, to be used for bot positions before waters swap.
	var pre_water_swap_non_tethers = baits.duplicate()
	
	# Check for water swaps
	var west_swapped := false
	var east_swapped := false
	# Check if both waters are North
	if (tether_water == tethers[0] or tether_water == tethers[1]) and\
		(non_tether_water == baits[0] or non_tether_water == baits[1]):
		# 0 swaps with 3, 1 swaps with 2
		if non_tether_water == baits[0]:
			var temp = baits[0]
			baits[0] = baits[3]
			baits[3] = temp
			west_swapped = true
		elif non_tether_water == baits[1]:
			var temp = baits[1]
			baits[1] = baits[2]
			baits[2] = temp
			east_swapped = true
	# Check if both waters are South
	elif (tether_water == tethers[2] or tether_water == tethers[3]) and\
		(non_tether_water == baits[2] or non_tether_water == baits[3]):
		# 0 swaps with 3, 1 swaps with 2
		if non_tether_water == baits[3]:
			var temp = baits[0]
			baits[0] = baits[3]
			baits[3] = temp
			west_swapped = true
		elif non_tether_water == baits[2]:
			var temp = baits[1]
			baits[1] = baits[2]
			baits[2] = temp
			east_swapped = true
	assert(!(west_swapped and east_swapped), "Error in E/W swap logic (multiple swaps).")
	# Build party_dd Dictionary
	party_dd = {
		"nw_tether": tethers[0], "ne_tether": tethers[1],
		"se_tether": tethers[2], "sw_tether": tethers[3],
		"nw_bait": baits[0], "ne_bait": baits[1],
		"se_bait": baits[2], "sw_bait": baits[3]
		}
	# Build pre-swap Dictionary (for positioning before waters swap)
	pre_swap_party_dd = party_dd.duplicate()
	pre_swap_party_dd["nw_bait"] = pre_water_swap_non_tethers[0]
	pre_swap_party_dd["ne_bait"] = pre_water_swap_non_tethers[1]
	pre_swap_party_dd["se_bait"] = pre_water_swap_non_tethers[2]
	pre_swap_party_dd["sw_bait"] = pre_water_swap_non_tethers[3]
	water_keys = [tether_water, non_tether_water]
	
	# Build Spirit Spread Dictionary (need to distinguish Supp from DPS for spread positions).
	# Shouldn't be needed for current EU/JP strats.
	spirit_spread_dd = {
		"nw_tether": party_dd["nw_tether"], "ne_tether": party_dd["ne_tether"],
		"se_tether": party_dd["se_tether"], "sw_tether": party_dd["sw_tether"],
		"w_sup": party_dd["nw_bait"], "w_dps": party_dd["sw_bait"],
		"e_sup": party_dd["ne_bait"], "e_dps": party_dd["se_bait"]
	}
	if west_swapped:
		spirit_spread_dd["w_sup"] = party_dd["sw_bait"]
		spirit_spread_dd["w_dps"] = party_dd["nw_bait"]
	elif east_swapped:
		spirit_spread_dd["e_sup"] = party_dd["se_bait"]
		spirit_spread_dd["e_dps"] = party_dd["ne_bait"]

# Returns the PlayableCharacter for the assigned key.
func get_char(dd_key) -> PlayableCharacter:
	return party[party_dd[dd_key]]


# Moves given party of CharacterBodies to given positions, make sure keys match.
func move_party(pos: Dictionary) -> void:
	for key: String in pos:
		var pc: PlayableCharacter = party[key]
		pc.move_to(pos[key])


# Moves UR Party to gives pos dictionary (must match UR keys)
func move_party_dd(pos: Dictionary) -> void:
	for key: String in pos:
		var pc: PlayableCharacter = get_char(key)
		pc.move_to(pos[key])


# Triggered when a spell hits Roomates. Check if avoidable AoE
func _on_area_3d_area_entered(area: Area3D) -> void:
	if area is CircleAoe or area is DonutAoe:
		if area.spell_name == "" or area.spell_name == "Hallowed Wings":
			return
		fail_list.add_fail("Fragment of Fate was hit by %s." % area.spell_name)


# Returns an Array of the given number of target party keys nearest to the given source position.
func get_nearest_target_list(source_pos: Vector2, number_of_targets) -> Array:
	#var dist_keys_dict: Dictionary
	var dist_list := []
	var keys_list := []
	for key in party:
		dist_list.append(v2(party[key].global_position).distance_squared_to(source_pos))
		keys_list.append(key)
	# Manually sort parallel arrays
	assert(dist_list.size() == keys_list.size())
	var n = dist_list.size()
	for i in range(n):
		for j in range(0, n - i - 1):
			if dist_list[j] > dist_list[j + 1]:
				# Swap distance
				var tmp = dist_list[j]
				dist_list[j] = dist_list[j + 1]
				dist_list[j + 1] = tmp
				# Swap key
				var tmp_key = keys_list[j]
				keys_list[j] = keys_list[j + 1]
				keys_list[j + 1] = tmp_key
	
	keys_list.resize(number_of_targets)
	return keys_list


func v2(vec3: Vector3) -> Vector2:
	return Vector2(vec3.x, vec3.z)


func v3(vec2: Vector2) -> Vector3:
	return Vector3(vec2.x, 0, vec2.y)
