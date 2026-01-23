# Copyright 2025
# All rights reserved.
# This file is released under "GNU General Public License 3.0".
# Please see the LICENSE file that should have been included as part of this package.

## The clone cast bar should be used used to mimic the enmity cast bar in game.
## Currently it copies the same cast 3 times. It needs to be updated to handle multiple casts.


extends MovableCanvasLayer

class_name CloneCastBar

@onready var timer: Timer = $Timer
@onready var label1: Label = $MarginContainer/CastBarContainer/CastBar1/Label
@onready var label2: Label = $MarginContainer/CastBarContainer/CastBar2/Label
@onready var label3: Label = $MarginContainer/CastBarContainer/CastBar3/Label
@onready var progress_bar1: ProgressBar = $MarginContainer/CastBarContainer/CastBar1/ProgressBar
@onready var progress_bar2: ProgressBar = $MarginContainer/CastBarContainer/CastBar2/ProgressBar
@onready var progress_bar3: ProgressBar = $MarginContainer/CastBarContainer/CastBar3/ProgressBar
@onready var cast_bar_2: VBoxContainer = %CastBar2
@onready var cast_bar_3: VBoxContainer = %CastBar3
@onready var move_ui_bg: Panel = %MoveUIBG

var casting := false


func _ready():
	section_key = "enmity_cast_bar"
	GameEvents.ui_ready.connect(on_ui_ready)


func _process(_delta: float) -> void:
	if casting:
		progress_bar1.value = 1 - (timer.time_left / timer.wait_time)
		progress_bar2.value = 1 - (timer.time_left / timer.wait_time)
		progress_bar3.value = 1 - (timer.time_left / timer.wait_time)
	
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


func cast_clone(cast_name : String, cast_time : float, bars: int = 3) -> void:
	if casting:
		print("CastBar Error: Simultaneous casts.")
		return
	label1.text = cast_name
	label2.text = cast_name
	label3.text = cast_name
	progress_bar1.value = 0
	progress_bar2.value = 0
	progress_bar3.value = 0
	timer.start(cast_time)
	casting = true
	self.show()
	cast_bar_2.visible = bars > 1
	cast_bar_3.visible = bars > 2


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
