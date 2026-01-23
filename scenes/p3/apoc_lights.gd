# Copyright 2025
# All rights reserved.
# This file is released under "GNU General Public License 3.0".
# Please see the LICENSE file that should have been included as part of this package.

extends Node3D

class_name ApocLights

const APOC_RADIUS := 21.8
const APOC_LIFETIME := 0.3
const APOC_COLOR := Color(1, 0.870588, 1, 0.6)
const APOC_SPELL_NAME := "Apocalypse"
const ROTATION_TIME := 2.0   # Time it takes for light to travel 45 deg.
const MAX_ROTATION_DEG := 225.0  # Angle travelled by Light 1

@onready var ground_aoe_controller: GroundAoeController = %GroundAoEController
@onready var apoc_lights_anim: AnimationPlayer = %ApocLightsAnim
@onready var ground_rings := {
	"n": %NRing, "ne": %NERing, "nw": %NWRing, "w": %WRing, 
	"s": %SRing, "se": %SERing, "sw": %SWRing, "e": %ERing, "center": %CenterRing
}
@onready var lights := {
	1: {"n": %NLight1, "s": %SLight1},
	2: {"n": %NLight2, "s": %SLight2},
	3: {"n": %NLight3, "s": %SLight3}
}

var hit_map_cw := {
	1: ["n", "center", "s"],
	2: ["n", "center", "s", "ne", "sw"],
	3: ["n", "s", "ne", "sw", "e", "w"],
	4: ["ne", "sw", "e", "w", "nw", "se"],
	5: ["e", "w", "nw", "se", "n", "s"],
	6: ["nw", "se", "n", "s", "ne", "sw"]
}
var hit_map_ccw := {
	1: ["n", "center", "s"],
	2: ["n", "center", "s", "nw", "se"],
	3: ["n", "s", "nw", "se", "e", "w"],
	4: ["nw", "se", "e", "w", "ne", "sw"],
	5: ["e", "w", "ne", "sw", "n", "s"],
	6: ["ne", "sw", "n", "s", "nw", "se"]
}
var hit_map: Dictionary
var rotate_cw: bool
var hit_counter := 1
var pulse_counter := 1


func start_lights(cw: bool):
	rotate_cw = cw
	hit_map = hit_map_cw if cw else hit_map_ccw
	apoc_lights_anim.play("light_sequence")


# AnimationPlayer calls

# Sends the givent set of lights into its full movement pattern.
func spawn_lights_pair(light_number: int):
	spawn_light(light_number, "n")
	spawn_light(light_number, "s")


# Pulses all rings for next pattern. Automatically increments count and accounts for direction.
func pulse_rings():
	for key in hit_map[pulse_counter]:
		ground_rings[key].pulse()
	pulse_counter += 1


# Hit all ring AoE's for next pattern. Automatically increments count and accounts for direction.
func hit_rings():
	assert(hit_counter < 7, "Hit counter incremented passed max hit count (6).")
	for key in hit_map[hit_counter]:
		ground_aoe_controller.spawn_circle(Global.v2(ground_rings[key].global_position),
			APOC_RADIUS, APOC_LIFETIME, APOC_COLOR, [0, 0, APOC_SPELL_NAME])
	hit_counter += 1


# Clears all lights (call on last ring pulse).
func clear_lights():
	for key in lights:
		for l in lights[key]:
			lights[key][l].queue_free()


# Other functions

func pulse_ring(ring_key: String):
	ground_rings[ring_key].pulse()


func spawn_light(light_number: int, dir_key: String):
	var ring_pos = ground_rings[dir_key].position
	lights[light_number][dir_key].start(ring_pos, rotate_cw,
		MAX_ROTATION_DEG - (45.0 * (light_number - 1)), ROTATION_TIME,
		light_number == 1, dir_key == "n")
