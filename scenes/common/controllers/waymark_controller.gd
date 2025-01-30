# Copyright 2025
# All rights reserved.
# This file is released under "GNU General Public License 3.0".
# Please see the LICENSE file that should have been included as part of this package.

extends Node

class_name WaymarkController

# Point to default waymark scene.
@export var waymark_scene: PackedScene
# Point to Arena/Waymark node in each new sequence.
@export var arena_waymark_node: Node3D

var wm_scene: Waymarks
var menu_slot_keys := ["preset_1", "preset_2", "preset_3", "mana_preset", "custom_1", "custom_2"]


func _ready() -> void:
	var wm_positions
	# Check if we have current waymarks saved in Global (we want to keep waymarks on reloaded scene)
	if Global.waymarks["current"].is_empty():
		var active_key = SavedVariables.save_data["waymarks"]["active"]
		if active_key.contains("custom"):
			wm_positions = SavedVariables.save_data["waymarks"][active_key]
		else:
			wm_positions = Global.waymarks[active_key]
		Global.waymarks["current"] = wm_positions
	else:
		wm_positions = Global.waymarks["current"]
	# Instantiate waymark scene
	wm_scene = waymark_scene.instantiate()
	arena_waymark_node.add_child(wm_scene)
	wm_scene.set_waymarks(wm_positions)


func move_waymark(wm_key: String, new_pos: Vector2):
	wm_scene.move_waymark(wm_key, new_pos)


func clear_wm(wm_key: String):
	wm_scene.hide_wm(wm_key)


func clear_all_wm():
	wm_scene.hide_all()


func set_preset_markers(preset_slot: int):
	# Preset markers from Global
	if preset_slot < 4:
		wm_scene.set_waymarks(Global.waymarks[menu_slot_keys[preset_slot]])
	# Custom markers from SavedVariables
	else:
		wm_scene.set_waymarks(SavedVariables.save_data["waymarks"][menu_slot_keys[preset_slot]])
	# Save newest selection as "active" waymarks, which will be loaded on launch.
	GameEvents.emit_variable_saved("waymarks", "active", menu_slot_keys[preset_slot])


func save_custom_preset(preset_slot: int):
	assert(preset_slot > 2, "Error. Tried to save Waymark preset to invalid index.")
	GameEvents.emit_variable_saved("waymarks", "active", menu_slot_keys[preset_slot])
	GameEvents.emit_variable_saved("waymarks", menu_slot_keys[preset_slot], wm_scene.get_active_wm_positions())
	
