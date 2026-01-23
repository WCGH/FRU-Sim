# Also handles the toggling of movable UI elements via move_ui keybind.

extends Button

class_name MoveUiResetButton

signal reset_position()

@onready var control_menu: CanvasLayer = %ControlMenu

var keybinds: Dictionary

func _ready():
	SavedVariables.keybind_changed.connect(on_keybind_changed)
	keybinds = SavedVariables.get_keybinds()
	get_viewport().focus_exited.connect(on_focus_exit)


# Handle move_ui toggle.
func _unhandled_input(event : InputEvent) -> void:
	if control_menu.visible:
		return
	if event is InputEventKey and event.get_keycode() == keybinds["move_ui"]:
		GameEvents.emit_toggle_move_ui(event.is_pressed())
		self.visible = event.is_pressed()


func reset_key_pressed() -> void:
	reset_position.emit()


func on_keybind_changed(new_keybinds: Dictionary) -> void:
	keybinds = new_keybinds


func _on_pressed() -> void:
	reset_key_pressed()


func _on_gui_input(event: InputEvent) -> void:
	if not Global.is_moving_ui:
		return
	
	if event is InputEventKey and event.get_keycode() == keybinds["reset"]:
		reset_key_pressed()
	elif event is InputEventJoypadButton and event.get_button_index() == JOY_BUTTON_Y:
		reset_key_pressed()
	elif event is not InputEventMouse:
		accept_event()


func on_focus_exit():
	GameEvents.emit_toggle_move_ui(false)
	self.visible = false
