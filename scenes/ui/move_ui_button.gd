class_name MoveUiButton
extends Button

signal save_position()
signal reset_position()

@onready var parent_node : Node = get_parent()

var keybinds: Dictionary
var is_button_pressed : bool = false
var previous_position : Vector2

func _ready():
	SavedVariables.keybind_changed.connect(on_keybind_changed)
	keybinds = SavedVariables.get_keybinds()

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
	if event is InputEventKey and event.get_keycode_with_modifiers() == keybinds["reset"]:
		reset_key_pressed()
	elif event is InputEventJoypadButton and event.get_button_index() == JOY_BUTTON_Y:
		reset_key_pressed()
	elif event is not InputEventMouse:
		accept_event()

func reset_key_pressed() -> void:
	move_button_up()
	reset_position.emit()

func move_button_down() -> void:
	previous_position = get_viewport().get_mouse_position()
	is_button_pressed = true
	Global.is_moving_ui = true

func move_button_up() -> void:
	is_button_pressed = false
	release_focus()

	await get_tree().process_frame # await to not win the condition race against action_bar
	Global.is_moving_ui = false

func on_keybind_changed(new_keybinds: Dictionary) -> void:
	keybinds = new_keybinds
