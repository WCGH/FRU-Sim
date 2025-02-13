# Copyright 2025
# All rights reserved.
# This file is released under "GNU General Public License 3.0".
# Please see the LICENSE file that should have been included as part of this package.

extends MovableCanvasLayer
class_name FailList

@export var label_scene : PackedScene

@onready var v_box_container : VBoxContainer = $MarginContainer/VBoxContainer


func _ready():
	section_key = "fail_list"
	init_position()


func add_fail(text: String) -> void:
	# Add player first
	var fail_label : Label = label_scene.instantiate()
	fail_label.text = text
	v_box_container.add_child(fail_label)


func clear_list() -> void:
	for label : Label in v_box_container.get_children():
		label.queue_free()
