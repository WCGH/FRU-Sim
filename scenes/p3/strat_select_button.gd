# Copyright 2025 by Wojciech Gruszka
# All rights reserved.
# This file is released under "GNU General Public License 3.0".
# Please see the LICENSE file that should have been included as part of this package.

extends OptionButton


func _ready() -> void:
	self.selected = Global.p3_selected_strat


func _on_item_selected(index: int) -> void:
	Global.p3_selected_strat = index
