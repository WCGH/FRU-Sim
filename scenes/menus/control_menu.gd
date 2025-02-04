# Copyright 2025
# All rights reserved.
# This file is released under "GNU General Public License 3.0".
# Please see the LICENSE file that should have been included as part of this package.

extends CanvasLayer

enum {SPRINT, ARMS, DASH, RESET}

@onready var sprint_key_button: Button = %SprintKeyButton
@onready var arms_key_button: Button = %ArmsKeyButton
@onready var dash_key_button: Button = %DashKeyButton
@onready var reset_key_button: Button = %ResetKeyButton
@onready var buttons := [%SprintKeyButton, %ArmsKeyButton, %DashKeyButton, %ResetKeyButton]
@onready var mouse_sens_h_slider: HSlider = %MouseSensHSlider
@onready var x_sens_h_slider: HSlider = %XSensHSlider
@onready var y_sens_h_slider: HSlider = %YSensHSlider
@onready var invert_y_check_button: CheckButton = %InvertYCheckButton

var awaited_key: Variant
var saved_var_keys := ["ab1_sprint", "ab2_arms", "ab3_dash", "reset"]


func _ready() -> void:
	awaited_key = null
	# Set keybind button text.
	sprint_key_button.set_text(OS.get_keycode_string(SavedVariables.save_data["keybinds"]["ab1_sprint"]))
	arms_key_button.set_text(OS.get_keycode_string(SavedVariables.save_data["keybinds"]["ab2_arms"]))
	dash_key_button.set_text(OS.get_keycode_string(SavedVariables.save_data["keybinds"]["ab3_dash"]))
	reset_key_button.set_text(OS.get_keycode_string(SavedVariables.save_data["keybinds"]["reset"]))
	# Set sliders
	mouse_sens_h_slider.set_value_no_signal(SavedVariables.save_data["settings"]["mouse_sens"])
	x_sens_h_slider.set_value_no_signal(SavedVariables.save_data["settings"]["x_sens"])
	y_sens_h_slider.set_value_no_signal(SavedVariables.save_data["settings"]["y_sens"])
	invert_y_check_button.set_pressed_no_signal(SavedVariables.save_data["settings"]["invert_y"])


func _unhandled_input(event : InputEvent) -> void:
	# Only take in keyboard inputs.
	if event is not InputEventKey:
		return
	var keycode : int = event.get_keycode_with_modifiers()
	# Handle open/closing control menu.
	if keycode == KEY_ESCAPE and event.is_pressed():
		awaited_key = null
		self.visible = !self.visible
		return
	# Handle keybind input.
	if awaited_key == null:
		return
	if keycode == KEY_SHIFT or keycode == KEY_CTRL or keycode == KEY_ALT:
		return
	GameEvents.emit_variable_saved("keybinds", saved_var_keys[awaited_key], keycode)
	buttons[awaited_key].set_text(OS.get_keycode_string(keycode))
	awaited_key = null


func _on_sprint_key_button_pressed() -> void:
	if awaited_key != null:
		return
	awaited_key = SPRINT
	sprint_key_button.set_text("Press Key")


func _on_arms_key_button_pressed() -> void:
	if awaited_key != null:
		return
	awaited_key = ARMS
	arms_key_button.set_text("Press Key")


func _on_dash_key_button_pressed() -> void:
	if awaited_key != null:
		return
	awaited_key = DASH
	dash_key_button.set_text("Press Key")


func _on_reset_key_button_pressed() -> void:
	if awaited_key != null:
		return
	awaited_key = RESET
	reset_key_button.set_text("Press Key")


func _on_mouse_sens_h_slider_drag_ended(value_changed: bool) -> void:
	if value_changed:
		GameEvents.emit_variable_saved("settings", "mouse_sens", mouse_sens_h_slider.get_value())


func _on_x_sens_h_slider_drag_ended(value_changed: bool) -> void:
	if value_changed:
		GameEvents.emit_variable_saved("settings", "x_sens", x_sens_h_slider.get_value())


func _on_y_sens_h_slider_drag_ended(value_changed: bool) -> void:
	if value_changed:
		GameEvents.emit_variable_saved("settings", "y_sens", y_sens_h_slider.get_value())


func _on_invert_y_check_button_toggled(toggled_on: bool) -> void:
	GameEvents.emit_variable_saved("settings", "invert_y", toggled_on)


func _on_back_button_pressed() -> void:
	self.hide()
