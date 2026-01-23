# Copyright 2025
# All rights reserved.
# This file is released under "GNU General Public License 3.0".
# Please see the LICENSE file that should have been included as part of this package.

extends CheckButton

signal toggle_bots_visible


func _ready() -> void:
	button_pressed = Global.p5_ew_hide_bots


func _on_pressed() -> void:
	Global.p5_ew_hide_bots = button_pressed
	toggle_bots_visible.emit()


func set_bots_visible() -> void:
	Global.p5_ew_hide_bots = false
	button_pressed = false
	toggle_bots_visible.emit()
