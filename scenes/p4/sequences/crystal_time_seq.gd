# Copyright 2025
# All rights reserved.
# This file is released under "GNU General Public License 3.0".
# Please see the LICENSE file that should have been included as part of this package.

extends Node

enum Intercards {NW, NE, SE, SW}
enum Strat {NA, MUR}

# Debuff Icon Scenes
const AERO_ICON = preload("res://scenes/ui/auras/debuff_icons/p4/aero.tscn")
const WYRMCLAW_ICON = preload("res://scenes/ui/auras/debuff_icons/p4/wyrmclaw.tscn")  # Red
const DARK_BLIZZARD_ICON = preload("res://scenes/ui/auras/debuff_icons/p3/dark_blizzard_icon.tscn")
const WYRMFANG_ICON = preload("res://scenes/ui/auras/debuff_icons/p4/wyrmfang.tscn")  # Blue
const DARK_ERUPTION_ICON = preload("res://scenes/ui/auras/debuff_icons/p3/dark_eruption.tscn")
const UNHOLY_DARKNESS_ICON = preload("res://scenes/ui/auras/debuff_icons/p3/unholy_darkness_icon.tscn")
const DARK_WATER_ICON = preload("res://scenes/ui/auras/debuff_icons/p3/dark_water_icon.tscn")
const QUIETUS_ICON = preload("res://scenes/ui/auras/debuff_icons/p4/quietus_icon.tscn")
const RETURN_ICON = preload("res://scenes/ui/auras/debuff_icons/p3/return_icon.tscn")
const RETURN_ICON_2 = preload("res://scenes/ui/auras/debuff_icons/p3/return_icon_2.tscn")
const STUN_ICON = preload("res://scenes/ui/auras/debuff_icons/common/stun_icon.tscn")
const MAGIC_VULN_ICON = preload("res://scenes/ui/auras/debuff_icons/common/magic_vuln_icon.tscn")
const REWIND_MARKER = preload("res://scenes/p3/arena/rewind_marker.tscn")
const CLEANSE_PUDDLE = preload("res://scenes/p4/ground/cleanse_puddle.tscn")

# AoE Dimensions
const AERO_RADIUS := 27.2
const AERO_LIFETIME := 0.2
const AERO_COLOR := Color(0.612, 0.882, 0.776, 0.903)
const AERO_KNOCKBACK_DISTANCE := 69.0
const AERO_KNOCKBACK_TIME := 1.0
const FIRE_COLOR := Color(0.564706, 0.933333, 0.564706, 0.3)
const UD_RADIUS := 9.0
const UD_LIFETIME := 0.3
const UD_COLOR := Color.REBECCA_PURPLE
const HG_RADIUS := 28.93
const HG_TELE_LIFETIME := 1.3
const HG_TELE_COLOR := Color(0.768, 0.579, 0.165, 0.4)
const HG_HIT_LIFETIME := 0.2 
const HG_HIT_COLOR := Color(0.522, 0.217, 0.627, 0.297)
const ICE_RADIUS_INNER := 7.0
const ICE_RADIUS_OUTTER := 27.2
const ICE_LIFETIME := 0.3
const ICE_COLOR := Color.SKY_BLUE
const WATER_RADIUS := 9.0
const WATER_LIFETIME := 0.3
const WATER_COLOR := Color(0.376, 0.667, 0.918, 0.86)
const ERUPTION_RADIUS := 15.0
const ERUPTION_LIFETIME := 0.3
const ERUPTION_COLOR := Color(0.545098, 0, 0, 0.3)
const DRAGON_RADIUS := 27.2
const DRAGON_LIFETIME := 0.3
const DRAGON_COLOR := Color(0.886, 0.871, 0.287, 0.5)
const WINGS_KNOCKBACK_TIME := 1.0
const WINGS_KNOCKBACK_DISTANCE := 47.0
const JUMP_DURATION := 0.5
const JUMP_RADIUS := 16.0
const JUMP_LIFETIME := 0.3
const JUMP_COLOR := Color.REBECCA_PURPLE
const STUN_DURATION := 9.0
const REWIND_SLIDE_TIME := 0.5
const WINGS_SLIDE_TIME := 0.7
const MAGIC_VULN_DURATION := 6.0
const REWIND_2_DURATION := 7.0
const AKH_MORN_RADIUS := 12.0
const AKH_MORN_LIFETIME := 0.3
const AKH_MORN_LIGHT_COLOR := Color.GOLD
const AKH_MORN_DARK_COLOR := Color.DARK_VIOLET

const NA_WE_PRIO := ["h2", "h1", "t2", "t1", "m1", "m2", "r1", "r2"]
const MUR_WE_PRIO := ["h1", "r1", "m1", "t1", "t2", "m2", "r2", "h2"]
const DEBUFF_ASSIGNMENTS := {
	"r_aero_sw": {AERO_ICON: 14, WYRMCLAW_ICON: 40, RETURN_ICON: 33},
	"r_aero_se": {AERO_ICON: 14, WYRMCLAW_ICON: 40, RETURN_ICON: 33},
	"r_ice_w": {DARK_BLIZZARD_ICON: 14, WYRMCLAW_ICON: 17, RETURN_ICON: 33},
	"r_ice_e": {DARK_BLIZZARD_ICON: 14, WYRMCLAW_ICON: 17, RETURN_ICON: 33},
	"b_erupt": {DARK_ERUPTION_ICON: 14, WYRMFANG_ICON: 40, RETURN_ICON: 33},
	"b_ice": {DARK_BLIZZARD_ICON: 14, WYRMFANG_ICON: 40, RETURN_ICON: 33},
	"b_ud": {UNHOLY_DARKNESS_ICON: 17, WYRMFANG_ICON: 40, RETURN_ICON: 33},
	"b_water": {DARK_WATER_ICON: 12, WYRMFANG_ICON: 40, RETURN_ICON: 33}
}
const QUIETUS_DURATION := 31
# Shift the duplicates to the end so we can line up index with dropdown selection.
const ASSIGNMENT_INDEX := ["r_aero_sw", "r_ice_w", "b_erupt",
	"b_ice", "b_ud", "b_water", "r_aero_se", "r_ice_e"]
const USURPER_POS := {
	"e": Vector3(0, 0, 48.0), "e_rota": 180.0,
	"w": Vector3(0, 0, -48.0), "w_rota": 0.0,
	"n": Vector3(48.0, 0, 0), "n_rota": -90.0,
	"s": Vector3(-48.0, 0, 0), "s_rota": 90.0,
	"mid": Vector3(0, 0, 0), "mid_rota": -90.0,
	"final": Vector3(0, 0, -6), "final_rota": -135.0
}
const ORACLE_POS := {
	"s": Vector3(-9.86, 0, 0), "s_rota": -90.0,
	"final": Vector3(0, 0, 6), "final_rota": -45.0
}

@onready var crystal_time_anim: AnimationPlayer = %CrystalTimeAnim
@onready var cast_bar: CastBar = %CastBar
@onready var clone_cast_bar: CloneCastBar = %CloneCastBar
@onready var ground_aoe_controller: GroundAoeController = %GroundAoEController
@onready var lockon_controller: LockonController = %LockonController
@onready var oracle: Oracle = %Oracle
@onready var usurper: Usurper = %Usurper
@onready var hitbox_ring: Node3D = %HitboxRing
@onready var ground_markers: Node3D = %GroundMarkers
@onready var fail_list: FailList = %FailList
@onready var dragon_e: CrystalizedDragon = %DragonE
@onready var dragon_w: CrystalizedDragon = %DragonW
@onready var exaline_ew: Exaline = %ExalineEW
@onready var exaline_ns: Exaline = %ExalineNS
@onready var line_scanner: LineScanner = %LineScanner
@onready var hide_bots_button: CheckButton = %HideBotsCheckButton
@onready var hourglasses := {
	"n": %HourglassN, "nw": %HourglassNW, "ne": %HourglassNE,
	"s": %HourglassS, "sw": %HourglassSW, "se": %HourglassSE, 
}

var party: Dictionary
var party_ct := {
	"r_aero_sw": "", "r_aero_se": "",
	"r_ice_w": "", "r_ice_e": "",
	"b_erupt": "", "b_ice": "", "b_ud": "", "b_water": ""
	}
var soak_pos_dictionaries = [
	CTPos.POST_SOAK_TARGET_NW, CTPos.POST_SOAK_TARGET_NE,
	CTPos.POST_SOAK_TARGET_SW, CTPos.POST_SOAK_TARGET_SE]
var arena_rotation := [deg_to_rad(270.0), deg_to_rad(0.0), deg_to_rad(90.0), deg_to_rad(180.0)]
var quietus_keys := []
var nw_tether: bool
var rewind_positions: Dictionary
var rewind_ground_markers := []
var kb_targets: Dictionary
var jump_target: String
var exaline_spawns: Intercards
var east_exa: bool
var north_exa: bool
var active_tethers := []
var scan_count := 0
var ew_kb_targets := []
var ns_kb_targets := []
var puddles_positions: Dictionary
var strat: Strat
var aero_plant: bool

func start_sequence(new_party: Dictionary) -> void:
	assert(new_party != null, "Error. Where the party at?")
	ground_aoe_controller.preload_aoe(["line", "circle", "donut"])
	#lockon_controller.pre_load([13])
	# Get Strat.
	strat = SavedVariables.save_data["settings"]["p4_ct_strat"]
	if strat is not int or strat >= Strat.size() or strat < 0:
		# Fix invalid SavedVariables, defaults to NA.
		GameEvents.emit_variable_saved("settings", "p4_ct_strat", 0)
		strat = Strat.NA
	# Apply user settings
	aero_plant = SavedVariables.save_data["settings"]["p4_ct_aero_plant"]
	
	instantiate_party(new_party)
	on_toggle_bots_visible()
	# Connect signals
	dragon_e.collided_with_body.connect(on_dragon_collision)
	dragon_w.collided_with_body.connect(on_dragon_collision)
	line_scanner.scan_finished.connect(on_scan_finished)
	hide_bots_button.toggle_bots_visible.connect(on_toggle_bots_visible)
	# Start animation sequence
	crystal_time_anim.play("crystal_time")


### START OF TIMELINE ###

## 0.00
# Usurper Hand in animtion.
func hands_in_cast() -> void:
	usurper.play_hands_in_cast()


## 1.00
# Start Crystallize Time Cast (4.5s, accelerated)
func start_ct_cast() -> void:
	cast_bar.cast("Crystallize Time", 4.5)


## 5.4
# Play cast finish animation
func ct_cast_animation() -> void:
	usurper.play_hands_in_finish()
	oracle.play_ct_cast()


## 6.5
# Assign debuffs
# Fade in Hourglass
func assign_debuffs() -> void:
	# Static debuffs
	for key in DEBUFF_ASSIGNMENTS:
		for debuff_icon in DEBUFF_ASSIGNMENTS[key]:
			if debuff_icon == WYRMCLAW_ICON or debuff_icon == WYRMFANG_ICON:
				get_char(key).add_debuff(debuff_icon, DEBUFF_ASSIGNMENTS[key][debuff_icon]).connect(on_wyrm_debuff_timeout)
			else:
				get_char(key).add_debuff(debuff_icon, DEBUFF_ASSIGNMENTS[key][debuff_icon])
	# Quietus
	for i: int in quietus_keys.size():
		get_char(quietus_keys[i]).add_debuff(QUIETUS_ICON, QUIETUS_DURATION)
	# Spawn Hourglasses
	for key in hourglasses:
		hourglasses[key].show_hourglass()


## 10.0
# Show tethers and dragons
# Hide Usurper and Hibox
func show_tethers() -> void:
	clone_cast_bar.cast_clone("Speed", 5.3, 1)
	hourglasses["n"].show_yellow_tether()
	hourglasses["s"].show_yellow_tether()
	if nw_tether:
		hourglasses["nw"].show_purple_tether()
		hourglasses["se"].show_purple_tether()
	else:
		hourglasses["ne"].show_purple_tether()
		hourglasses["sw"].show_purple_tether()
	# Show dragons
	dragon_e.play_fade_in()
	dragon_w.play_fade_in()
	# Hide boss
	usurper.play_fade_out()
	hitbox_ring.visible = false

## 14.0
# Move to pre-hg positions
func move_pre_hg():
	if nw_tether:
		if aero_plant:
			move_party_ct(CTPos.PRE_HG_1_NW_AEROS_PLANT)
		else:
			move_party_ct(CTPos.PRE_HG_1_NW)
	else:
		if aero_plant:
			move_party_ct(CTPos.PRE_HG_1_NE_AEROS_PLANT)
		else:
			move_party_ct(CTPos.PRE_HG_1_NE)

## 15.3
# Start moving dragons
func move_dragons():
	dragon_e.start_circle("e")
	dragon_w.start_circle("w")

## 16.3
# Show hourglass 1 telegraph
# Remove tethers
# Start moving dragon
func hg_1_telegraph():
	active_tethers = ["n", "s"]
	for tether_key in active_tethers:
		ground_aoe_controller.spawn_circle(v2(hourglasses[tether_key].global_position),
		HG_RADIUS, HG_TELE_LIFETIME, HG_TELE_COLOR)
	# Remove tethers
	for key in hourglasses:
		hourglasses[key].hide_tether()


## 17.7
# Hourglass 1 hit
func hg_1_hit():
	for tether_key in active_tethers:
		ground_aoe_controller.spawn_circle(v2(hourglasses[tether_key].global_position),
			HG_RADIUS, HG_HIT_LIFETIME, HG_HIT_COLOR, [0, 0, "Maelstrom (Hourglass AoE)"])

## 18.0
# Move to post HG 1 positions
func move_pre_aero():
	if aero_plant:
		# Calculate positions of the players getting knocked back relative to the current position of the aero player. 
		var aero_target: Vector2
		var positions := {}
		
		if nw_tether:
			positions["r_aero_sw"] = CTPos.AERO_SOURCE * CTPos.SW # Aero not knocking back the party can move
			aero_target = v2(get_char("r_aero_se").global_position) + CTPos.AERO_TARGET_OFFSET * CTPos.SE
		else:
			positions["r_aero_se"] = CTPos.AERO_SOURCE * CTPos.SE # Aero not knocking back the party can move
			aero_target = v2(get_char("r_aero_sw").global_position) + CTPos.AERO_TARGET_OFFSET * CTPos.SW
		positions["b_ice"] = aero_target + CTPos.RS1
		positions["b_ud"] = aero_target + CTPos.RS2
		positions["b_water"] = aero_target + CTPos.RS3
		move_party_ct(positions)
	else:
		if nw_tether:
			move_party_ct(CTPos.POST_HG_1_NW)
		else:
			move_party_ct(CTPos.POST_HG_1_NE)

## 18.7
# Water hits.
func water_hit():
	var water_target: PlayableCharacter = get_char("b_water")
	ground_aoe_controller.spawn_circle(v2(water_target.global_position), WATER_RADIUS,
		WATER_LIFETIME, WATER_COLOR, [4, 4, "Dark Water III"])

## 20.6
# Fireworks go off.
# Aero's hit + snapshot knockback.
# Blizzards hit.
# Eruption his.
func fireworks():
	# Spawn Aero AoE's and snapshot targets with source of kb.
	var aero_1_circle: CircleAoe = ground_aoe_controller.spawn_circle(v2(get_char("r_aero_sw").global_position),
		AERO_RADIUS, AERO_LIFETIME, AERO_COLOR)
	var aero_2_circle: CircleAoe = ground_aoe_controller.spawn_circle(v2(get_char("r_aero_se").global_position),
		AERO_RADIUS, AERO_LIFETIME, AERO_COLOR)
	aero_1_circle.collisions_checked.connect(on_aero_1_collisions)
	aero_2_circle.collisions_checked.connect(on_aero_2_collisions)
	# Blizzards hit
	ground_aoe_controller.spawn_donut(v2(get_char("r_ice_w").global_position),
		ICE_RADIUS_INNER, ICE_RADIUS_OUTTER, ICE_LIFETIME, ICE_COLOR, [0, 0, "Dark Blizzard III"])
	ground_aoe_controller.spawn_donut(v2(get_char("r_ice_e").global_position),
		ICE_RADIUS_INNER, ICE_RADIUS_OUTTER, ICE_LIFETIME, ICE_COLOR, [0, 0, "Dark Blizzard III"])
	ground_aoe_controller.spawn_donut(v2(get_char("b_ice").global_position),
		ICE_RADIUS_INNER, ICE_RADIUS_OUTTER, ICE_LIFETIME, ICE_COLOR, [0, 0, "Dark Blizzard III"])
	# Eruption hits
	ground_aoe_controller.spawn_circle(v2(get_char("b_erupt").global_position), ERUPTION_RADIUS,
		ERUPTION_LIFETIME, ERUPTION_COLOR, [1, 1, "Dark Eruption", [get_char("b_erupt")]])

func on_aero_1_collisions(bodies: Array):
	for body in bodies:
		if body == get_char("r_aero_sw"):
			continue
		kb_targets[body] = (v2(get_char("r_aero_sw").global_position))

func on_aero_2_collisions(bodies: Array):
	for body in bodies:
		if body == get_char("r_aero_se"):
			continue
		kb_targets[body] = (v2(get_char("r_aero_se").global_position))


## 20.7
func move_puddle_dodge():
	move_party_ct(CTPos.PUDDLE_DODGE)


## 21.1
# Knockback movement starts (1s duration).
# HG 2 Tele
func aero_knockback():
	for pc: PlayableCharacter in kb_targets:
		pc.knockback(AERO_KNOCKBACK_DISTANCE, kb_targets[pc], AERO_KNOCKBACK_TIME)


## 21.6
func hg_2_tele():
	# Hourglass 2 Telegraph
	active_tethers = ["ne", "sw"] if nw_tether else ["nw", "se"]
	for tether_key in active_tethers:
		ground_aoe_controller.spawn_circle(v2(hourglasses[tether_key].global_position),
		HG_RADIUS, HG_TELE_LIFETIME, HG_TELE_COLOR)

## 21.4
# Move post kb positions
func move_post_aero():
	if nw_tether:
		move_party_ct(CTPos.POST_KB_NW)
	else:
		move_party_ct(CTPos.POST_KB_NE)



## 22.4
# Knockback ends.
# Move to post_kb positions (may need to move red/ice earlier).
#func move_post_kb():
	#pass

## 23.0
# Hourglass 2 Hit.
func hg_2_hit():
	for tether_key in active_tethers:
		ground_aoe_controller.spawn_circle(v2(hourglasses[tether_key].global_position),
			HG_RADIUS, HG_HIT_LIFETIME, HG_HIT_COLOR, [0, 0, "Maelstrom (Hourglass AoE)"])

## 23.2
# Move post HG 2 positions.
func move_post_hg_2():
	if nw_tether:
		move_party_ct(CTPos.POST_HG_2_NW)
	else:
		move_party_ct(CTPos.POST_HG_2_NE)

## 23.6
# Unholy Darkness hits.
# Usurper spawns on E/W.
func ud_hit():
	ground_aoe_controller.spawn_circle(v2(get_char("b_ud").global_position),
		UD_RADIUS, UD_LIFETIME, UD_COLOR, [5, 8, "Unholy Darkness (Group Stack)"])
	# Move Usurper
	move_usurper_ew()


func move_usurper_ew():
	if east_exa:
		usurper.global_position = USURPER_POS["e"]
		usurper.rotation.y = deg_to_rad(USURPER_POS["e_rota"])
	else:
		usurper.global_position = USURPER_POS["w"]
		usurper.rotation.y = deg_to_rad(USURPER_POS["w_rota"])
	usurper.play_fade_in()


## 24.3
# E/W Exa spawn.
func ew_exa_spawn():
	if east_exa:
		exaline_ew.play_exaline("e")
	else:
		exaline_ew.play_exaline("w")

## 24.5
# Move post UD
# Move aeros to dodge hg3
func move_post_ud():
	if east_exa:
		move_party_ct(CTPos.POST_UD_E)
	else:
		move_party_ct(CTPos.POST_UD_W)


## 26.2
func move_post_aero_soak():
	if east_exa:
		move_party_ct(CTPos.POST_EARLY_SOAK_E)
	else:
		move_party_ct(CTPos.POST_EARLY_SOAK_W)


## 26.8
# Hourglass 3 telegraph (1.1s??).
func hg_3_telegraph():
	active_tethers = ["nw", "se"] if nw_tether else ["ne", "sw"]
	for tether_key in active_tethers:
		ground_aoe_controller.spawn_circle(v2(hourglasses[tether_key].global_position),
		HG_RADIUS, HG_TELE_LIFETIME, HG_TELE_COLOR)


## 28.2
# Hourglass 3 Hit.
func hg_3_hit():
	for tether_key in active_tethers:
		ground_aoe_controller.spawn_circle(v2(hourglasses[tether_key].global_position),
			HG_RADIUS, HG_HIT_LIFETIME, HG_HIT_COLOR, [0, 0, "Maelstrom (Hourglass AoE)"])


## 28.3
# Move far soakers out.
func move_post_hg_3():
	if east_exa:
		move_party_ct_and_soak(CTPos.POST_HG_3_E)
	else:
		move_party_ct_and_soak(CTPos.POST_HG_3_W)


## 29.3
# Move to post Exa2 positions.
func move_post_exa_2():
	if east_exa:
		move_party_ct_and_soak(CTPos.POST_EXA_2_E)
	else:
		move_party_ct_and_soak(CTPos.POST_EXA_2_W)

## 29.6
# Hide Usurper
func hide_usurper():
	usurper.play_fade_out()


## 29.8
# Usurper jumps N/S.
func move_usurper_ns():
	if north_exa:
		usurper.global_position = USURPER_POS["n"]
		usurper.rotation.y = deg_to_rad(USURPER_POS["n_rota"])
	else:
		usurper.global_position = USURPER_POS["s"]
		usurper.rotation.y = deg_to_rad(USURPER_POS["s_rota"])
	usurper.play_fade_in()


## 30.6
# N/S Exa spawn.
func ns_exa_spawn():
	if north_exa:
		exaline_ns.play_exaline("n")
	else:
		exaline_ns.play_exaline("s")


## 31.2
# Move to post Exa3 positions.
func move_post_exa_3():
	move_party_ct_and_soak(CTPos.POST_EXA_3_REF[exaline_spawns])


## 33.6
# Move to post Exa4 positions.
func move_post_exa_4():
	move_party_ct(CTPos.POST_EXA_4_REF[exaline_spawns])


## 35.8
# Move to Rewind posistions.
func move_rewind():
	move_party(party, CTPos.REWIND_REF[exaline_spawns])


## 39.6
# Snapshot rewinds, spawn circles.
# Tele Oracle middle.
func snapshot_rewinds():
	for key in party_ct:
		var pos: Vector3 = get_char(key).global_position
		rewind_positions[key] = v2(pos)
		# Drop ground aoe
		var new_marker = REWIND_MARKER.instantiate()
		ground_markers.add_child(new_marker)
		new_marker.set_key(key)
		new_marker.global_position = pos
		rewind_ground_markers.append(new_marker)
		# Add rewind debuff
		get_char(key).add_debuff(RETURN_ICON_2, REWIND_2_DURATION)
	# Tele Oracle middle.
	oracle.global_position = ORACLE_POS["s"]
	oracle.rotation.y = deg_to_rad(ORACLE_POS["s_rota"])
	oracle.play_show()

## 39.9
# Start Clone Cast Spirit Taker (2.7s).
# Run first scan (E/W).
# Scan rewind markers ahead of time to determine pass/fail for wings knockbacks.
# We do this now to give the scanner enough frames to cross the entire arena.
func clone_cast_spirit():
	clone_cast_bar.cast_clone("Spirit Taker", 2.7, 1)
	
	# E/W Scan
	if east_exa:
		line_scanner.scan_line(v2(USURPER_POS["e"]), v2(USURPER_POS["w"]), 1.5)
	else:
		line_scanner.scan_line(v2(USURPER_POS["w"]), v2(USURPER_POS["e"]), 1.5)


## 40.6
# Move to post-rewind spread.
func move_jump_spread():
	if exaline_spawns == Intercards.NW:
		for key: String in CTPos.JUMP_SPREAD_NW:
			party[key].move_to(CTPos.JUMP_SPREAD_NW[key])
	else:
		for key: String in CTPos.JUMP_SPREAD_NE:
			party[key].move_to(CTPos.JUMP_SPREAD_NE[key].rotated(arena_rotation[exaline_spawns]))


## 41.0
# Hide Usurper


## 41.4
# Tele Usurper middle.
func tele_usurper_mid():
	usurper.global_position = USURPER_POS["mid"]
	usurper.rotation.y = deg_to_rad(USURPER_POS["mid_rota"])
	usurper.play_fade_in()

## 42
# Run N/S scan
func scan_rewind_ns():
	# First kb will come East to West
	if north_exa:
		line_scanner.scan_line(v2(USURPER_POS["n"]), v2(USURPER_POS["s"]), 1.5)
	else:
		line_scanner.scan_line(v2(USURPER_POS["s"]), v2(USURPER_POS["n"]), 1.5)

func on_scan_finished(areas: Array):
	if areas.size() < 4:
		print("Error: Not enough targets found in kb scan (Probably got knocked out of arena).")
		return
	# First scan is E/W
	if scan_count == 0:
		# Grab 4 nearest targets
		for i in 4:
			ew_kb_targets.append(areas[i].get_parent().get_key())
		scan_count = 1
	# N/S Scan
	else:
		# Grab 4 nearest targets
		for i in 4:
			ns_kb_targets.append(areas[i].get_parent().get_key())


## 41.6
# Start wings out cast anim.
func wings_out_anim():
	usurper.play_wings_out_cast()


## 42.7
# Start Clone Cast Hallowed Wings (5s).
func clone_cast_wings():
	clone_cast_bar.cast_clone("Hallowed Wings", 5.0, 1)
	# Hide rewind markers
	for marker in rewind_ground_markers:
		marker.visible = false


## 43.4
# Usurper jump towards rand target.
func usurper_jump():
	var target_pos: Vector3 = party[jump_target].global_position
	oracle.look_at(target_pos)
	oracle.rotation.y += deg_to_rad(180.0)
	var tween : Tween = get_tree().create_tween()
	tween.tween_property(oracle, "global_position",
		Vector3(target_pos.x, 0, target_pos.z), JUMP_DURATION)\
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	oracle.play_flip_special()


## 44.0
# Usurper aoe hit.
func jump_hit():
	var pc: PlayableCharacter = party[jump_target]
	ground_aoe_controller.spawn_circle(v2(pc.global_position), JUMP_RADIUS,
		JUMP_LIFETIME, JUMP_COLOR, [1, 1, "Spirit Taker (Oracle Jump)", [pc]])


## 46.6
# Freeze players.
# Assign stun debuffs (9s)
func stun_players():
	for key in party_ct:
		var pc: PlayableCharacter = get_char(key) 
		if pc.is_player():
			pc.freeze_player()
		pc.add_debuff(STUN_ICON, STUN_DURATION)

## 47.5
# Hide Usurper

## 48.0
# Slide players to rewind.
# Move Usurper to E/W kb spot.
func slide_to_rewind():
	for key in party_ct:
		get_char(key).slide(rewind_positions[key], REWIND_SLIDE_TIME)
	# Move Usurper
	move_usurper_ew()


## 49.3
# Play short wings animation
func play_usurper_short():
	usurper.play_short_cast()


## 49.9
# Knockback 1
func knockback_1_hit():
	var kb_vector = Vector2(0.0, -WINGS_KNOCKBACK_DISTANCE) if east_exa else Vector2(0.0, WINGS_KNOCKBACK_DISTANCE)
	ct_knockback(kb_vector)
	# Check for tank closest
	if ew_kb_targets.size() < 4:
		print("Error: Not enough targets found in kb scan (Probably got knocked out of arena).")
		return
	var nearest = ew_kb_targets[0]
	if party_ct[nearest] != "t1" and party_ct[nearest] != "t2":
		fail_list.add_fail(str(get_char(nearest).get_name(), " was closest to Hallowed Wings (non-tank)"))
	# Assign Magic Vulns
	for key in ew_kb_targets:
		get_char(key).add_debuff(MAGIC_VULN_ICON, MAGIC_VULN_DURATION)

## 52.5
# Hide Usurper

## 53.1
# Move Usurper to N/S kn spot.
#func move_usurper_ns():


## 53.9
# Play short wings animation

## 54.5
# Knockback 2
func knockback_2_hit():
	var kb_vector = Vector2(-WINGS_KNOCKBACK_DISTANCE, 0.0) if north_exa else Vector2(WINGS_KNOCKBACK_DISTANCE, 0.0)
	ct_knockback(kb_vector)
	# Check for tank closest
	if ns_kb_targets.size() < 4:
		print("Error: Not enough targets found in kb scan (Probably got knocked out of arena).")
		return
	var nearest = ns_kb_targets[0]
	if party_ct[nearest] != "t1" and party_ct[nearest] != "t2":
		fail_list.add_fail(str(get_char(nearest).get_name(), " was closest to Hallowed Wings (non-tank)"))
	# Assign Magic Vulns and check for double hits
	for key in ns_kb_targets:
		var pc: PlayableCharacter = get_char(key)
		if pc.has_debuff("magic_vuln"):
			fail_list.add_fail(str(pc.get_name(), " failed Hallowed Wings (2 stacks of Magic Vuln)"))
		else:
			pc.add_debuff(MAGIC_VULN_ICON, MAGIC_VULN_DURATION)


func ct_knockback(kb_vector: Vector2):
	for key in party_ct:
		var pc: PlayableCharacter = get_char(key)
		pc.kb_slide(v2(pc.global_position) + kb_vector, WINGS_SLIDE_TIME)

## 55.5
# Unfreeze player
func unfreeze_player():
	get_tree().get_first_node_in_group("player").unfreeze_player()


## 56.4
# Move to Akh Morn positions
func move_akh_morn():
	var am_strat = SavedVariables.save_data["settings"]["p4_ct_am_strat"]
	if am_strat == 0:
		move_party(party, CTPos.AKH_MORN)
	elif am_strat == 1:
		move_party(party, CTPos.AKH_MORN_7_1_T1)
	elif am_strat == 2:
		move_party(party, CTPos.AKH_MORN_7_1_T2)


## 56.8
# Hide bosses and hgs
func hide_bosses():
	hide_usurper()
	oracle.play_hide()
	for key in hourglasses:
		hourglasses[key].hide_hourglass()

## 57.6
# Move bosses mid
func move_bosses_final():
	usurper.global_position = USURPER_POS["final"]
	usurper.rotation.y = deg_to_rad(USURPER_POS["final_rota"])
	usurper.play_fade_in()
	oracle.global_position = ORACLE_POS["final"]
	oracle.rotation.y = deg_to_rad(ORACLE_POS["final_rota"])
	oracle.play_show()

## 58.4
# Start Akh Morn cast (2.5)
func cast_akh_morn():
	cast_bar.cast("Akh Morn", 3.5)


## 61.9
# Akh Morn hit
func akh_morn_hit():
	ground_aoe_controller.spawn_circle(v2(party["t1"].global_position),
		AKH_MORN_RADIUS, AKH_MORN_LIFETIME, AKH_MORN_LIGHT_COLOR, [1, 7, "Akh Morn"])
	ground_aoe_controller.spawn_circle(v2(party["t2"].global_position),
		AKH_MORN_RADIUS, AKH_MORN_LIFETIME, AKH_MORN_DARK_COLOR, [1, 7, "Akh Morn"])


### END OF TIMELINE ###



## Collision Signals
func on_dragon_collision(pos: Vector3, body: PlayableCharacter) -> void:
	# Spawn AoE
	ground_aoe_controller.spawn_circle(v2(pos), DRAGON_RADIUS, DRAGON_LIFETIME, DRAGON_COLOR, [1, 1, "Dragon Soak", [body]])
	# Cleanse red debuff
	body.remove_debuff("wyrmclaw")
	# Spawn cleanse puddle
	var new_puddle: CleansePuddle = CLEANSE_PUDDLE.instantiate()
	ground_markers.add_child(new_puddle)
	new_puddle.global_position = pos
	new_puddle.on_puddle_collision.connect(on_puddle_collision)
	# Store puddle postion for bot movement later
	puddles_positions[get_ct_key(body)] = v2(pos)


# Returns the ct_key for a give CharacterBody
func get_ct_key(body: PlayableCharacter) -> String:
	return party_ct.find_key(body.get_role())


func on_puddle_collision(body: PlayableCharacter) -> void:
	body.remove_debuff("wyrmfang")
	# Check if we need to move after soaking (SE/SW far soaks)
	# TODO: May need to add extra movement for safe side SE/SW soaks as well, if puddle drop is off.
	var ct_key = get_ct_key(body)
	if CTPos.POST_SOAK_TARGET_REF[exaline_spawns].has(ct_key):
		get_char(ct_key).move_to(CTPos.POST_SOAK_TARGET_REF[exaline_spawns][ct_key])


func on_wyrm_debuff_timeout(player_key: String) -> void:
	fail_list.add_fail(str(party[player_key].get_name(), " failed to cleanse their debuff."))


### END OF TIMELINE ###


func instantiate_party(new_party: Dictionary) -> void:
	# Standard role keys
	party = new_party
	# NA/MUR Party setup
	na_mur_party_setup()
	# Randomize Tether spawn
	nw_tether = randi() % 2 == 0
	# Pick 3 Quietus targets
	var pool_party := party_ct.keys()
	for i in 3:
		quietus_keys.append(pool_party.pop_at(randi_range(0, pool_party.size() - 1)))
	# Pick Usurper Jump target
	if Global.p4_ct_force_spirit:
		jump_target = get_tree().get_first_node_in_group("player").get_role()
	else:
		jump_target = NA_WE_PRIO.pick_random()
	# Randomize Exaline spawns
	exaline_spawns = randi_range(0, 3) as Intercards
	east_exa = (exaline_spawns == Intercards.NE or exaline_spawns == Intercards.SE)
	north_exa = (exaline_spawns == Intercards.NE or exaline_spawns == Intercards.NW)


func na_mur_party_setup() -> void:
	var we_prio
	if strat == Strat.NA:
		we_prio = NA_WE_PRIO
	elif strat == Strat.MUR:
		we_prio = MUR_WE_PRIO
	
	# Shuffle dps/sup roles
	var shuffle_list := party.keys()
	shuffle_list.shuffle()
	
	# Handle manual debuff selection from user.
	if Global.p4_ct_selected_debuff != 0:
		var player_role_key = get_tree().get_first_node_in_group("player").get_role()
		# Remove player index and insert at selected key
		shuffle_list.erase(player_role_key)
		# For DPS need to convert 1,2,3 index to 3,2,1
		shuffle_list.insert(Global.p4_ct_selected_debuff - 1, player_role_key)
	
	# Check if red/aero (0, 6) are in prio order, otherwise swap them.
	if we_prio.find(shuffle_list[0]) > we_prio.find(shuffle_list[6]):
		var temp = shuffle_list[0]
		shuffle_list[0] = shuffle_list[6]
		shuffle_list[6] = temp
	# Check if red/ice (1, 7) are in prio order, otherwise swap them.
	if we_prio.find(shuffle_list[1]) > we_prio.find(shuffle_list[7]):
		var temp = shuffle_list[1]
		shuffle_list[1] = shuffle_list[7]
		shuffle_list[7] = temp
	# Add keys to CT dictionary
	for i in ASSIGNMENT_INDEX.size():
		party_ct[ASSIGNMENT_INDEX[i]] = shuffle_list[i]


# Returns the PlayableCharacter for the assigned key.
func get_char(ct_key) -> PlayableCharacter:
	return party[party_ct[ct_key]]


# Moves given party of CharacterBodies to given positions, make sure keys match.
func move_party(party_dict: Dictionary, pos: Dictionary) -> void:
	for key: String in pos:
		var pc: PlayableCharacter = party_dict[key]
		if pc.is_player() and !Global.spectate_mode:
			continue
		pc.move_to(pos[key])


# Moves UR Party to gives pos dictionary (must match UR keys)
func move_party_ct(pos: Dictionary) -> void:
	for key: String in pos:
		var pc: PlayableCharacter = get_char(key)
		#if pc.is_player() and !Global.spectate_mode:
			#continue
		pc.move_to(pos[key])


# If position dictioary has a key instead of Vector2, move that player to the corresponding soak puddle.
func move_party_ct_and_soak(pos: Dictionary) -> void:
	for key: String in pos:
		var pc: PlayableCharacter = get_char(key)
		if pc.is_player() and !Global.spectate_mode:
			continue
		# If we get a string, it should be the key for puddle positions
		if pos[key] is String:
			if puddles_positions.has(pos[key]):
				pc.move_to(puddles_positions[pos[key]])
			else:
				push_warning("Cannot find %s puddle to soak." % pos[key])
		else:
			pc.move_to(pos[key])


# Triggered when a spell hits Roomates. Check if avoidable AoE
func _on_area_3d_area_entered(area: Area3D) -> void:
	if area is CircleAoe or area is DonutAoe:
		if area.spell_name == "" or area.spell_name == "Maelstrom (Hourglass AoE)":
			return
		fail_list.add_fail("Fragment of Fate was hit by %s." % area.spell_name)


func on_toggle_bots_visible() -> void:
	var bots_visible = !Global.p4_ct_hide_bots
	for key in party:
		var pc: PlayableCharacter = party[key]
		if pc.is_player():
			continue
		pc.visible = bots_visible


func v2(vec3: Vector3) -> Vector2:
	return Vector2(vec3.x, vec3.z)


func v3(vec2: Vector2) -> Vector3:
	return Vector3(vec2.x, 0, vec2.y)
