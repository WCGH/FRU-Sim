# Copyright 2025
# All rights reserved.
# This file is released under "GNU General Public License 3.0".
# Please see the LICENSE file that should have been included as part of this package.


extends Sequence


func start_new_sequence() -> void:
	var player_role_index : int = SavedVariables.save_data["settings"]["player_role"]
	var selected_role : String = Global.ROLE_KEYS[player_role_index]
	var party : Dictionary = party_controller.instantiate_party(selected_role)
	encounter_controller.start_p5_encounter(party)
