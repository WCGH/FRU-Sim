# Copyright 2025
# All rights reserved.
# This file is released under "GNU General Public License 3.0".
# Please see the LICENSE file that should have been included as part of this package.

extends MovableCanvasLayer

class_name CastBar

@onready var label : Label = $MarginContainer/VBoxContainer/Label
@onready var progress_bar : ProgressBar = $MarginContainer/VBoxContainer/ProgressBar
@onready var timer : Timer = $Timer
@onready var move_ui_bg: Panel = %MoveUIBG

var casting := false


func _ready():
	#await get_tree().process_frame
	section_key = "cast_bar"
	GameEvents.ui_ready.connect(on_ui_ready)


func _process(_delta : float) -> void:
	if casting:
		progress_bar.value = 1 - (timer.time_left / timer.wait_time)
	
	if is_button_pressed:
		var current_position = get_viewport().get_mouse_position()
		var move_position = current_position - previous_position
		margin_container.position += move_position
		previous_position = current_position

		if abs(move_position.x) + abs(move_position.y) > 0:
			save_position()


func init_position():
	GameEvents.toggle_move_ui.connect(on_toggle_move_ui)
	margin_container = $MarginContainer
	move_ui_reset_button  = %MoveUIResetButton
	move_ui_reset_button.reset_position.connect(reset_position)
	load_position_and_scale()


func cast(cast_name : String, cast_time : float) -> void:
	if casting:
		print("CastBar Error: Simultaneous casts.")
		return
	label.text = cast_name
	progress_bar.value = 0
	timer.start(cast_time)
	casting = true
	self.show()


func clear_casts() -> void:
	if not Global.is_moving_ui:
		self.hide()
	casting = false


func _on_timer_timeout() -> void:
	if not Global.is_moving_ui:
		self.hide()
	casting = false


func _on_margin_container_gui_input(event: InputEvent) -> void:
	if not Global.is_moving_ui:
		return
	if event is InputEventMouseButton:
		on_container_mouse_button_event(event)


func on_move_ui_on():
	self.show()
	move_ui_bg.show()


func on_move_ui_off():
	move_ui_bg.hide()
	if not casting:
		self.hide()


func on_toggle_move_ui(is_moving: bool):
	if is_moving:
		on_move_ui_on()
	else:
		on_mouse_click_up()
		on_move_ui_off()
