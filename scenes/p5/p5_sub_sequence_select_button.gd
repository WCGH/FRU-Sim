# Copyright 2025
# All rights reserved.
# This file is released under "GNU General Public License 3.0".
# Please see the LICENSE file that should have been included as part of this package.

extends OptionButton


func _ready() -> void:
	selected = Global.p5_selected_seq


func _on_item_selected(index : int) -> void:
	Global.p5_selected_seq = index
