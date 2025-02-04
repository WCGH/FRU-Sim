# Copyright 2025
# All rights reserved.
# This file is released under "GNU General Public License 3.0".
# Please see the LICENSE file that should have been included as part of this package.

extends Node

var seq_scene_paths := {
	0: "res://scenes/p2/p2_lr_main.tscn",
	1: "res://scenes/p3/p3_ur_main.tscn",
	2: "res://scenes/p3/p3_apoc_main.tscn",
	3: "res://scenes/p4/p4_dd_main.tscn",
	4: "res://scenes/p4/p4_ct_main.tscn",
	5: "res://scenes/p5/p5_main.tscn"
}


func _ready() -> void:
	var selected_seq: int = SavedVariables.get_data("settings", "selected_seq")
	var loaded_scene = load(seq_scene_paths[selected_seq])
	await get_tree().process_frame
	get_tree().change_scene_to_packed(loaded_scene)
