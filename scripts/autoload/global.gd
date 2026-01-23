# Copyright 2025
# All rights reserved.
# This file is released under "GNU General Public License 3.0".
# Please see the LICENSE file that should have been included as part of this package.

extends Node

const TANKS = ["Tank 1", "Tank 2"]
const HEALERS = ["Healer 1", "Healer 2"]
const MELEE = ["Melee 1", "Melee 2"]
const RANGED = ["Ranged 1", "Ranged 2"]
const SUPPORT = TANKS + HEALERS
const DPS = MELEE + RANGED
const ALL_ROLES = SUPPORT + DPS
const ROLE_GROUP_NAMES = {"Tank": TANKS, "Healer": HEALERS, "DPS": DPS}
const ROLE_KEYS = ["t1", "t2", "h1", "h2", "m1", "m2", "r1", "r2"]
const DPS_ROLE_KEYS = ["m1", "m2", "r1", "r2"]
const TANK_ROLE_KEYS = ["t1", "t2"]
const HEALER_ROLE_KEYS = ["h1", "h2"]
const ROLE_NAMES = {"t1": TANKS[0], "t2": TANKS[1],
	"h1": HEALERS[0], "h2": HEALERS[1],
	"m1": MELEE[0], "m2": MELEE[1],
	"r1": RANGED[0], "r2": RANGED[1]}

# General
var debug := false
var deathwall_active := true
var player_role_key : String
var selected_role_index := 4
var selected_sequence_index := 0
var spectate_mode := false
var is_moving_ui := false

# P2 Light Rampant
var p2_force_puddles := false

# P3 Ultimate Relativity
var p3_selected_debuff := 0  # [random, short, med, long]
var p3_ur_hide_bots := false

# P3 Apoc
var p3_t1_bait := false
var p3_apoc_force_swap := false

# P4 Darklit Dragonsong
var p4_dd_force_tether := false
var p4_dd_force_spirit := false

# P4 Crystallize Time
var p4_ct_selected_debuff := 0  # [random, red/aero, red/ice, blue/eruption, blue/ice, blue,unholy, blue/water]
var p4_ct_force_spirit := false
var p4_ct_hide_bots := false

# P5 Pandora
var p5_selected_seq := 0 # [Fulgent Blade, Paradise Regained, Polarizing Strikes]
var p5_ew_hide_bots := false

# Waymarks
var waymarks := {
	"preset_1": {
		"wm_a": Vector2(26, 0), "wm_b": Vector2(0, 26), "wm_c": Vector2(-26, 0), "wm_d": Vector2(0, -26),
		"wm_1": Vector2(18.38, -18.38), "wm_2": Vector2(18.38, 18.38), "wm_3": Vector2(-18.38, 18.38), "wm_4": Vector2(-18.38, -18.38),
	},
	"preset_2": {
		"wm_a": Vector2(23, 0), "wm_b": Vector2(0, 23), "wm_c": Vector2(-23, 0), "wm_d": Vector2(0, -23),
		"wm_1": Vector2(16.26, -16.26), "wm_2": Vector2(16.26, 16.26), "wm_3": Vector2(-16.26, 16.26), "wm_4": Vector2(-16.26, -16.26),
	},
	"preset_3": {
		"wm_a": Vector2(40, 0), "wm_b": Vector2(0, 40), "wm_c": Vector2(-40, 0), "wm_d": Vector2(0, -40),
		"wm_1": Vector2(28.28, -28.28), "wm_2": Vector2(28.28, 28.28), "wm_3": Vector2(-28.28, 28.28), "wm_4": Vector2(-28.28, -28.28),
	},
	"current": {}
}


# Global Utility Functions

func v2(vec3: Vector3) -> Vector2:
	return Vector2(vec3.x, vec3.z)


# Launcher
#var checked_update := false
#var launcher_pck_path := ""
#var main_menu_path := "res://scenes/encounters/dsr/main_menu.tscn"
# P5
#var player_puddles := false
#var rare_death_pattern := false
#var default_lineup := ["r1", "t1", "r2", "m1", "h2", "t2", "m2", "h1"]
# P6
#var hide_bots := false
#var vow_target_key := ""

#enum Role {Tank1 = 0, Tank2, Healer1, Healer2, Melee1, Melee2, Ranged, Caster}
#enum Role_Category {Tank, Healer, DPS}
