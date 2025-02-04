# Copyright 2025
# All rights reserved.
# This file is released under "GNU General Public License 3.0".
# Please see the LICENSE file that should have been included as part of this package.

extends MovableCanvasLayer

@onready var sprint_action_button: ActionButton = $MarginContainer/ButtonsContainer/SprintActionButton
@onready var arms_action_button: ActionButton = $MarginContainer/ButtonsContainer/ArmsActionButton
@onready var dash_action_button: ActionButton = $MarginContainer/ButtonsContainer/DashActionButton
@onready var parent_node: Sequence = $".."
@onready var control_menu: CanvasLayer = %ControlMenu


var player: Player
var keybinds: Dictionary


func _ready() -> void:
	section_key = "action_bar"
	init_position()

	GameEvents.party_ready.connect(on_party_ready)
	sprint_action_button.action_pressed.connect(on_sprint_pressed)
	arms_action_button.action_pressed.connect(on_arms_pressed)
	dash_action_button.action_pressed.connect(on_dash_pressed)
	SavedVariables.keybind_changed.connect(on_keybind_changed)
	keybinds = SavedVariables.get_keybinds()
	update_keybinds()


func _unhandled_input(event : InputEvent) -> void:
	if control_menu.visible:
		return
	if event is InputEventKey:
		var keycode : int = event.get_keycode_with_modifiers()
		if keycode == keybinds["ab1_sprint"]:
			sprint_action_button._on_pressed()
		elif keycode == keybinds["ab2_arms"]:
			arms_action_button._on_pressed()
		elif keycode == keybinds["ab3_dash"]:
			dash_action_button._on_pressed()
		elif keycode == keybinds["reset"]:
			if not Global.is_moving_ui and Input.is_action_just_pressed("reset"):  # Needed to stop ghost input from hanging after reset.
				parent_node._on_reset_button_pressed()
	# Controller button binds (non-configurable)
	elif event is InputEventJoypadButton:
		var button_index: int = event.get_button_index()
		match button_index:
			JOY_BUTTON_X:
				sprint_action_button._on_pressed()
			JOY_BUTTON_A:
				arms_action_button._on_pressed()
			JOY_BUTTON_B:
				dash_action_button._on_pressed()
			JOY_BUTTON_Y:  # BUG: InputEvent hangs on this input after reset.
				if not Global.is_moving_ui:
					parent_node._on_reset_button_pressed()


func on_party_ready() -> void:
	player = get_tree().get_first_node_in_group("player")


func on_keybind_changed(new_keybinds: Dictionary) -> void:
	keybinds = new_keybinds
	update_keybinds()


func update_keybinds() -> void:
	sprint_action_button.set_keybind_label(OS.get_keycode_string(keybinds["ab1_sprint"]))
	arms_action_button.set_keybind_label(OS.get_keycode_string(keybinds["ab2_arms"]))
	dash_action_button.set_keybind_label(OS.get_keycode_string(keybinds["ab3_dash"]))


func on_sprint_pressed() -> void:
	if !player:
		return
	player.sprint()


func on_arms_pressed() -> void:
	if !player:
		return
	player.arms_length()


func on_dash_pressed() -> void:
	if !player:
		return
	player.dash()
