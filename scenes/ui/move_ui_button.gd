class_name MoveUiButton
extends Button

signal save_position()
signal reset_position()

@onready var parent_node : Node = get_parent()

var is_button_pressed : bool = false
var previous_position : Vector2

func _ready():
	button_down.connect(move_button_down)
	button_up.connect(move_button_up)

func _process(delta):
	if is_button_pressed:
		var current_position = get_viewport().get_mouse_position()
		var move_position = current_position - previous_position
		parent_node.position += move_position
		previous_position = current_position

		if abs(move_position.x) + abs(move_position.y) > 0:
			save_position.emit()

func _gui_input(event: InputEvent) -> void:
	if is_button_pressed and event is InputEventKey and event.keycode == KEY_R:
		move_button_up()
		reset_position.emit()
	elif event is not InputEventMouse:
		accept_event()

func move_button_down() -> void:
	previous_position = get_viewport().get_mouse_position()
	is_button_pressed = true

func move_button_up() -> void:
	is_button_pressed = false
	release_focus()
