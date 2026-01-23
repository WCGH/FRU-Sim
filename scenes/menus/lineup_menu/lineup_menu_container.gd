# Copyright 2025
# All rights reserved.
# This file is released under "GNU General Public License 3.0".
# Please see the LICENSE file that should have been included as part of this package.

extends MarginContainer

class_name PartyOrderMenu

signal refresh_party_list(new_order)

const DEFAULT_ORDER = ["t1", "t2", "h1", "h2", "m1", "m2", "r1", "r2"]
const DEFAULT_PLAYER_TOP = true
const HEADER_NODE_COUNT = 2  # Number of nodes in the container before the first role node

@onready var control_margin_container: MarginContainer = %ControlMarginContainer
@onready var player_top_button: CheckButton = %PlayerOnTopCheckBox
@onready var buttons_vbox: VBoxContainer = %LeftButtonsVBox
@onready var containers := {
	"t1": %T1Container, "t2": %T2Container, "h1": %H1Container, "h2": %H2Container,
	"m1": %M1Container, "m2": %M2Container, "r1": %R1Container, "r2": %R2Container
}
var party_keys: Array
var player_top: bool
var adjusted_order: Array  # This is the "correct" order depending on player's placement.


func _ready() -> void:
	party_keys = SavedVariables.save_data["settings"]["pt_list_order"].duplicate()
	player_top = SavedVariables.save_data["settings"]["pt_list_player_top"]
	player_top_button.button_pressed = player_top
	#GameEvents.party_ready.connect(on_party_ready)


#func on_party_ready():
	#order_containers()


# Returns the adjusted order with player on top of list if user opted.
func get_party_order() -> Array:
	if !adjusted_order:
		order_containers()
	return adjusted_order


func order_containers() -> void:
	# Set adjusted order and send refresh signal.
	adjusted_order = party_keys.duplicate()
	if player_top:
		var player_role: String = get_tree().get_first_node_in_group("player").get_role()
		adjusted_order.erase(player_role)
		adjusted_order.push_front(player_role)
	refresh_party_list.emit(adjusted_order)
	# Order menu items
	for i in party_keys.size():
		buttons_vbox.move_child(containers[party_keys[i]], i + HEADER_NODE_COUNT)


func save_lineup() -> void:
	GameEvents.emit_variable_saved("settings", "pt_list_order", party_keys)


func _on_default_button_pressed() -> void:
	party_keys = DEFAULT_ORDER.duplicate()
	player_top = DEFAULT_PLAYER_TOP
	player_top_button.button_pressed = player_top
	order_containers()
	save_lineup()


func _on_back_button_pressed() -> void:
	self.hide()
	control_margin_container.show()


func _on_player_on_top_check_box_pressed() -> void:
	player_top = player_top_button.button_pressed
	GameEvents.emit_variable_saved("settings", "pt_list_order", party_keys)
	order_containers()
