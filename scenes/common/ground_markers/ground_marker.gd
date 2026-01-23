# Copyright 2025
# All rights reserved.
# This file is released under "GNU General Public License 3.0".
# Please see the LICENSE file that should have been included as part of this package.

extends Area3D
class_name GroundMarker

signal collision_ready
signal collisions_checked(bodies: Array)

const COLOR_ALPHA = 0.75

var debug := false

@onready var mesh_instance_3d : MeshInstance3D = $MeshInstance3D
@onready var collision_shape_3d : CollisionShape3D = $CollisionShape3D
#@onready var animation_player : AnimationPlayer = $AnimationPlayer
@onready var fail_list : FailList = get_tree().get_first_node_in_group("fail_list")

var min_hit := 0
var max_hit := 99
var spell_name := ""
var whitelist := []
var blacklist := []

var waiting_for_collision := false
var check_collision_at_end := false
var next_frame: int
var is_donut := false
var donut_inner_radius := 0.0   # minor hack for filtering donut collision
var bodies: Array

func _ready() -> void:
	collision_ready.connect(on_collision_ready)


func _process(_delta: float) -> void:
	if !waiting_for_collision:
		return
	if get_tree().get_frame() > next_frame:
		collision_ready.emit()
		waiting_for_collision = false


func await_collision() -> void:
	next_frame = get_tree().get_frame() + 1
	waiting_for_collision = true


func on_collision_ready() -> void:
	if is_donut:
		donut_collision_check()
		return
	bodies = get_overlapping_bodies()
	if debug:
		print("Bodies hit: ", bodies)
	check_fail()
	collisions_checked.emit(bodies)


func donut_collision_check() -> void:
	var all_bodies: Array = get_overlapping_bodies()
	bodies = []
	# Filter out bodies within inner radius
	for body: CharacterBody3D in all_bodies:
		var pos: Vector3 = body.global_position
		if pos.distance_squared_to(global_position) > donut_inner_radius ** 2:
			bodies.append(body)
	check_fail()


func set_center_position(new_position : Vector3) -> void:
	global_position = new_position


func set_color(color : Color) -> void:
	if color != Color.TRANSPARENT and color.a > 0.99:
		color.a = COLOR_ALPHA
	mesh_instance_3d.mesh.material.albedo_color = color


func set_lifetime(lifetime : float) -> void:
	await get_tree().create_timer(lifetime).timeout
	if check_collision_at_end:
		on_collision_ready()
	queue_free()


func check_at_end() -> void:
	check_collision_at_end = true


#func play_start_animation():
	#animation_player.play("grow_in")


func set_fail_conditions(fail_conditions : Array) -> void:
	var size := fail_conditions.size()
	if size < 3:
		print("Error. Fail conditions array missing arguments.")
		return
	min_hit = fail_conditions[0]
	max_hit = fail_conditions[1]
	spell_name = fail_conditions[2]
	if size > 3:
		whitelist = fail_conditions[3]
	if size == 5:
		blacklist = fail_conditions[4]


# Use this when you need collision on AoE spawn. Needs a frame buffer for collisions to update.
func get_collisions() -> Array:
	await wait_two_frames()
	return get_overlapping_bodies()


# Debug: Method gets stuck when called from outside of ground_aoe_controller.
func wait_two_frames() -> void:
	await get_tree().process_frame
	await get_tree().physics_frame
	await get_tree().process_frame
	await get_tree().physics_frame
	await get_tree().process_frame
	#await get_tree().create_timer(0.1).timeout


func get_bodies() -> Array:
	return bodies


func check_fail() -> void:
	# Too few hit fail condition
	if min_hit > 0 and bodies.size() < min_hit:
		fail_list.add_fail("Not enough targets hit by %s." % spell_name)
		return
	var fail_bodies_list := []
	# Too many hit fail condition
	if max_hit < 99 and bodies.size() > max_hit:
		for body: CharacterBody3D in bodies:
			if whitelist.has(body):
				continue
			fail_bodies_list.append(body)
	# Blacklist fail condition
	if blacklist.size() > 0:
		for body: CharacterBody3D in bodies:
			if blacklist.has(body):
				fail_bodies_list.append(body)
	# Output fails
	if fail_bodies_list.size() == 1:
		fail_list.add_fail("%s was hit by %s." % [fail_bodies_list[0].name, spell_name])
		return
	if fail_bodies_list.size() > 1:
		fail_list.add_fail("Multiple targets were hit by %s." % spell_name)
		return
