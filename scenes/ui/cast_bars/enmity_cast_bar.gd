# Copyright 2025
# All rights reserved.
# This file is released under "GNU General Public License 3.0".
# Please see the LICENSE file that should have been included as part of this package.

## The clone cast bar should be used used to mimic the enmity cast bar in game.
## Currently it copies the same cast 3 times. It needs to be updated to handle multiple casts.


extends MovableCanvasLayer

class_name EnmityCastBar


const ENMITY_CB = preload("res://scenes/ui/cast_bars/enmity_cb_singleton.tscn")

@onready var cast_bar_container: VBoxContainer = %CastBarContainer
@onready var move_ui_bg: Panel = %MoveUIBG


func _ready():
	section_key = "enmity_cast_bar"
	GameEvents.ui_ready.connect(on_ui_ready)


func cast(cast_name : String, cast_time : float, bars: int = 1) -> void:
	for i in bars:
		var new_cast_bar = ENMITY_CB.instantiate()
		cast_bar_container.add_child(new_cast_bar)
		new_cast_bar.cast(cast_name, cast_time)


func _on_margin_container_gui_input(event: InputEvent) -> void:
	if not Global.is_moving_ui:
		return
	if event is InputEventMouseButton:
		on_container_mouse_button_event(event)


func on_move_ui_on():
	move_ui_bg.show()


func on_move_ui_off():
	move_ui_bg.hide()
