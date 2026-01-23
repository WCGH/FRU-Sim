# Copyright 2024 by William Craycroft
# All rights reserved.
# This file is released under "GNU General Public License 3.0".
# Please see the LICENSE file that should have been included as part of this package.

extends HBoxContainer

@onready var buttons_vbox: VBoxContainer = $".."
@onready var party_order_menu: PartyOrderMenu = %PartyOrderMarginContainer


func _on_up_button_pressed() -> void:
	var index: int = get_index() - party_order_menu.HEADER_NODE_COUNT
	if index == 0:
		return
	buttons_vbox.move_child(self, index + party_order_menu.HEADER_NODE_COUNT - 1)
	party_order_menu.save_lineup()
	# Swap key in array with previous one
	var temp : String = party_order_menu.party_keys[index - 1]
	party_order_menu.party_keys[index - 1] = party_order_menu.party_keys[index]
	party_order_menu.party_keys[index] = temp
	party_order_menu.order_containers()
	party_order_menu.save_lineup()


func _on_down_button_pressed() -> void:
	var index := get_index() - party_order_menu.HEADER_NODE_COUNT
	if index == 7:
		return
	buttons_vbox.move_child(self, index + party_order_menu.HEADER_NODE_COUNT + 1)
	party_order_menu.save_lineup()
	# Swap key in array with next one
	var temp : String = party_order_menu.party_keys[index + 1]
	party_order_menu.party_keys[index + 1] = party_order_menu.party_keys[index]
	party_order_menu.party_keys[index] = temp
	party_order_menu.order_containers()
	party_order_menu.save_lineup()
