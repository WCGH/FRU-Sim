# Copyright 2025
# All rights reserved.
# This file is released under "GNU General Public License 3.0".
# Please see the LICENSE file that should have been included as part of this package.

extends MovableCanvasLayer
class_name CastBar

@onready var label : Label = $MarginContainer/VBoxContainer/Label
@onready var progress_bar : ProgressBar = $MarginContainer/VBoxContainer/ProgressBar
@onready var timer : Timer = $Timer

var casting := false


func _ready():
	await get_tree().process_frame
	section_key = "cast_bar"
	init_position()


func _process(_delta : float) -> void:
	if casting:
		progress_bar.value = 1 - (timer.time_left / timer.wait_time)


func cast(cast_name : String, cast_time : float) -> void:
	if casting:
		print("CastBar Error: Simultaneous casts.")
		return
	label.text = cast_name
	progress_bar.value = 0
	timer.start(cast_time)
	casting = true
	visible = true


func clear_casts() -> void:
	visible = false
	casting = false


func _on_timer_timeout() -> void:
	visible = false
	casting = false
