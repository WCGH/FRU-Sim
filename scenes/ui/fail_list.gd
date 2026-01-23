# Copyright 2025
# All rights reserved.
# This file is released under "GNU General Public License 3.0".
# Please see the LICENSE file that should have been included as part of this package.

extends MovableCanvasLayer
class_name FailList

const MOVE_UI_BG_SIZE = Vector2(226, 234)

@export var label_scene : PackedScene

@onready var move_ui_bg: Panel = %MoveUIBG
@onready var v_box_container : VBoxContainer = $MarginContainer/VBoxContainer


func _ready():
	section_key = "fail_list"
	GameEvents.ui_ready.connect(on_ui_ready)


func add_fail(text: String) -> void:
	# Add player first
	var fail_label : Label = label_scene.instantiate()
	fail_label.text = text
	v_box_container.add_child(fail_label)


func clear_list() -> void:
	for label : Label in v_box_container.get_children():
		label.queue_free()


func _on_margin_container_gui_input(event: InputEvent) -> void:
	if not Global.is_moving_ui:
		return
	if event is InputEventMouseButton:
		on_container_mouse_button_event(event)


func on_move_ui_on():
	margin_container.size = MOVE_UI_BG_SIZE
	move_ui_bg.show()


func on_move_ui_off():
	move_ui_bg.hide()
	margin_container.size = Vector2.ZERO
