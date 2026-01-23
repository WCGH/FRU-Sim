# Copyright 2025
# All rights reserved.
# This file is released under "GNU General Public License 3.0".
# Please see the LICENSE file that should have been included as part of this package.

extends MovableCanvasLayer

class_name PartyList

@onready var move_ui_bg: Panel = %MoveUIBG
@onready var player_debuff_container : BoxContainer = get_tree().get_first_node_in_group("player_debuff_container")
@onready var member_containers := {
	"t1": %T1MemberContainer, "t2": %T2MemberContainer, "h1": %H1MemberContainer, "h2": %H2MemberContainer,
	"m1": %M1MemberContainer, "m2": %M2MemberContainer, "r1": %R1MemberContainer, "r2": %R2MemberContainer
}
@onready var member_vbox_container: VBoxContainer = %MemberVBoxContainer

var party_order_menu: PartyOrderMenu
var party_order: Array


func _ready():
	section_key = "party_list"
	GameEvents.ui_ready.connect(on_ui_ready)


func create_party_list(player_role_key : String) -> void:
	# Get ordered list and attach refresh signal
	party_order_menu = get_tree().get_first_node_in_group("party_list_menu")
	party_order = party_order_menu.get_party_order()
	party_order_menu.refresh_party_list.connect(on_refresh_party)
	# Set player text label
	member_containers[player_role_key].set_as_player()
	# Order list
	order_list()


func order_list():
	for i in party_order.size():
		member_vbox_container.move_child(member_containers[party_order[i]], i)
		member_containers[party_order[i]].set_index_icon(i)


# Returns timeout signal
# If sending a stackable debuff, we also need the debuff name. It's messy, sorry.
func add_debuff(role_key : String, debuff_icon_scene : PackedScene, duration := 0.0, stackable := false, debuff_name := "") -> Signal:
	return member_containers[role_key].add_debuff(role_key, debuff_icon_scene, duration, stackable, debuff_name)


func remove_debuff(role_key : String, debuff_name : String) -> void:
	member_containers[role_key].remove_debuff(debuff_name)


func has_debuff(role_key : String, debuff_name : String) -> bool:
	return member_containers[role_key].has_debuff(debuff_name)


func get_debuff_stacks(role_key : String, debuff_name : String) -> int:
	return member_containers[role_key].get_debuff_stacks(debuff_name)


func on_refresh_party(new_order: Array):
	party_order = new_order
	order_list()



func _on_margin_container_gui_input(event: InputEvent) -> void:
	if not Global.is_moving_ui:
		return
	if event is InputEventMouseButton:
		on_container_mouse_button_event(event)


func on_move_ui_on():
	move_ui_bg.show()


func on_move_ui_off():
	move_ui_bg.hide()
