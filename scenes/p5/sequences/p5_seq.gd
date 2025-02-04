# Copyright 2025
# All rights reserved.
# This file is released under "GNU General Public License 3.0".
# Please see the LICENSE file that should have been included as part of this package.

extends Node


@onready var p5_anim: AnimationPlayer = %P5Anim
@onready var cast_bar: CastBar = %CastBar
@onready var ground_aoe_controller: GroundAoeController = %GroundAoEController
@onready var oracle_boss: Node3D = %OracleBoss
@onready var oracle: Oracle = %Oracle
@onready var fail_list: FailList = %FailList
@onready var exawave_controller: ExawaveController = %ExawaveController

var party: Dictionary  # Standard role keys (m1, r1, etc.)


func start_sequence(new_party: Dictionary) -> void:
	assert(new_party != null, "Error. Where the party at?")
	ground_aoe_controller.preload_aoe(["line", "circle", "cone"])
	#instantiate_party(new_party)
	party = new_party
	despawn_bots()
	p5_anim.play("p5_seq")


### START OF TIMELINE ###

## 2.1
# Start Oracle Swing animation
func oracle_swing():
	oracle.play_slash()

## 4.0
# Start Exaline seq
func start_exalines():
	exawave_controller.start_exawaves()


### END OF TIMELINE ###


func despawn_bots():
	var player_key: String = get_tree().get_first_node_in_group("player").get_role()
	for key in party:
		if key != player_key:
			party[key].queue_free()


# Returns an Array of the given number of target party keys nearest to the given source position.
#func get_nearest_target_list(source_pos: Vector2, number_of_targets) -> Array:
	##var dist_keys_dict: Dictionary
	#var dist_list := []
	#var keys_list := []
	#for key in party:
		#dist_list.append(v2(party[key].global_position).distance_squared_to(source_pos))
		#keys_list.append(key)
	## Manually sort parallel arrays
	#assert(dist_list.size() == keys_list.size())
	#var n = dist_list.size()
	#for i in range(n):
		#for j in range(0, n - i - 1):
			#if dist_list[j] > dist_list[j + 1]:
				## Swap distance
				#var tmp = dist_list[j]
				#dist_list[j] = dist_list[j + 1]
				#dist_list[j + 1] = tmp
				## Swap key
				#var tmp_key = keys_list[j]
				#keys_list[j] = keys_list[j + 1]
				#keys_list[j + 1] = tmp_key
	#
	#keys_list.resize(number_of_targets)
	#return keys_list


func v2(vec3: Vector3) -> Vector2:
	return Vector2(vec3.x, vec3.z)


func v3(vec2: Vector2) -> Vector3:
	return Vector3(vec2.x, 0, vec2.y)
