# Copyright 2025
# All rights reserved.
# This file is released under "GNU General Public License 3.0".
# Please see the LICENSE file that should have been included as part of this package.

extends CanvasLayer

class_name MovableCanvasLayer

var debug = true

const DEFAULT_UI_POSITIONS = {
	#"action_bar": Vector2(426, 494),
	#"cast_bar": Vector2(157, 430),
	#"fail_list": Vector2(12, 238),
	#"party_list": Vector2(950, 159),
	#"player_debuffs": Vector2(637, 351),
	#"enmity_cast_bar": Vector2(195, 483)
	"action_bar": [0.463, 0.716],
	"cast_bar": [0.226, 0.654],
	"fail_list": [0.028, 0.201],
	"party_list": [0.706, 0.279],
	"player_debuffs": [0.576, 0.667],
	"enmity_cast_bar": [0.174, 0.711]
}
const DEFAULT_UI_SCALES = {
	"action_bar": Vector2(1, 1),
	"cast_bar": Vector2(1, 1),
	"fail_list": Vector2(1, 1),
	"party_list": Vector2(1, 1),
	"player_debuffs": Vector2(2, 2),
	"enmity_cast_bar": Vector2(0.85, 0.85)
}
const UI_SCALE_INCREMENT = Vector2(0.05, 0.05)

var margin_container : MarginContainer
var move_ui_reset_button : MoveUiResetButton
#var margin_container_start_position : Vector2
var section_key = ""

var is_button_pressed := false
var previous_position : Vector2


func _process(_delta):
	#if not Global.is_moving_ui:
		#return
	if is_button_pressed:
		var current_position = get_viewport().get_mouse_position()
		var move_position = current_position - previous_position
		var window_size = get_window().get_size()
		var x_margin: float = abs(margin_container.anchor_left + (float(move_position.x) / float(window_size.x)))
		var y_margin: float = abs(margin_container.anchor_top + (float(move_position.y) / float(window_size.y)))
		margin_container.set_anchor(SIDE_LEFT, x_margin, true, true)
		margin_container.set_anchor(SIDE_RIGHT, x_margin, true, true)
		margin_container.set_anchor(SIDE_TOP, y_margin, true, true)
		margin_container.set_anchor(SIDE_BOTTOM, y_margin, true, true)
		
		#margin_container.position += move_position
		previous_position = current_position

		if abs(move_position.x) + abs(move_position.y) > 0:
			save_position()


func init_position():
	GameEvents.toggle_move_ui.connect(on_toggle_move_ui)
	
	margin_container = $MarginContainer
	move_ui_reset_button  = %MoveUIResetButton

	#margin_container_start_position = margin_container.position
	#move_ui_reset_button.save_position.connect(save_position)
	move_ui_reset_button.reset_position.connect(reset_position)
	load_position_and_scale()
	set_process(false)


func load_position_and_scale():
	if SavedVariables.has_data("ui_positions", section_key):
		set_anchor_position(SavedVariables.get_data("ui_positions", section_key))
	if SavedVariables.has_data("ui_scales", section_key):
		margin_container.scale = SavedVariables.config_file.get_value("ui_scales", section_key)


func save_position():
	GameEvents.emit_variable_saved("ui_positions", section_key, get_anchor_position())


func set_anchor_position(anchors: Array):
	if debug:
		check_anchors()
	margin_container.set_anchor(SIDE_LEFT, anchors[0], true, true)
	margin_container.set_anchor(SIDE_RIGHT, anchors[0], true, true)
	margin_container.set_anchor(SIDE_TOP, anchors[1], true, true)
	margin_container.set_anchor(SIDE_BOTTOM, anchors[1], true, true)


func get_anchor_position() -> Array:
	if debug:
		check_anchors()
	return [margin_container.anchor_left, margin_container.anchor_top]


func save_scale():
	GameEvents.emit_variable_saved("ui_scales", section_key, margin_container.scale)


func reset_position():
	#GameEvents.emit_variable_removed("ui_positions", section_key)
	set_anchor_position(DEFAULT_UI_POSITIONS[section_key])
	margin_container.scale = DEFAULT_UI_SCALES[section_key]
	save_position()
	save_scale()
	on_mouse_click_up()


func on_mouse_click_down():
	previous_position = get_viewport().get_mouse_position()
	is_button_pressed = true
	Global.is_moving_ui = true
	#Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func on_mouse_click_up():
	is_button_pressed = false
	margin_container.release_focus()
	#Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	await get_tree().process_frame # await to not win the condition race against action_bar
	Global.is_moving_ui = false


func on_mouse_wheel_down():
	margin_container.scale = margin_container.scale - UI_SCALE_INCREMENT
	save_scale()


func on_mouse_wheel_up():
	margin_container.scale = margin_container.scale + UI_SCALE_INCREMENT
	save_scale()


func on_toggle_move_ui(is_moving: bool):
	if is_moving:
		set_process(true)
		on_move_ui_on()
	else:
		set_process(false)
		on_mouse_click_up()
		on_move_ui_off()


func on_container_mouse_button_event(event: InputEventMouseButton):
	if event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			on_mouse_click_down()
		else:
			on_mouse_click_up()
	elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
		on_mouse_wheel_down()
	elif event.button_index == MOUSE_BUTTON_WHEEL_UP:
		on_mouse_wheel_up()
	get_viewport().set_input_as_handled()


func on_ui_ready():
	init_position()


func check_anchors() -> void:
		assert(margin_container.anchor_top == margin_container.anchor_bottom, "Top/Bottom Anchor mismacth.")
		assert(margin_container.anchor_left == margin_container.anchor_right, "Left/Right Anchor mismacth.")


# Handled in CavasItem children to toggle ui elements.
func on_move_ui_on():
	pass
func on_move_ui_off():
	pass
