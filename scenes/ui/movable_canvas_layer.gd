class_name MovableCanvasLayer
extends CanvasLayer

var margin_container : MarginContainer
var move_button : MoveUiButton
var margin_container_start_position : Vector2
var section_key = ""

func init_position():
	margin_container = $MarginContainer
	move_button  = $MarginContainer/MoveButton

	margin_container_start_position = margin_container.position
	move_button.save_position.connect(save_position)
	move_button.reset_position.connect(reset_position)
	load_position()


func load_position():
	if SavedVariables.config_file.has_section_key("ui_positions", section_key):
		margin_container.position = SavedVariables.config_file.get_value("ui_positions", section_key)


func save_position():
	GameEvents.emit_variable_saved("ui_positions", section_key, margin_container.position)


func reset_position():
	GameEvents.emit_variable_removed("ui_positions", section_key)
	margin_container.position = margin_container_start_position
