extends Button

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

func _gui_input(event: InputEvent) -> void:
	if event is not InputEventMouse:
		accept_event()

func move_button_down() -> void:
	previous_position = get_viewport().get_mouse_position()
	is_button_pressed = true

func move_button_up() -> void:
	is_button_pressed = false
	release_focus()
