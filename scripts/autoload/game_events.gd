# Copyright 2025
# All rights reserved.
# This file is released under "GNU General Public License 3.0".
# Please see the LICENSE file that should have been included as part of this package.

extends Node

signal variable_saved(section: String, key: String, value: Variant)
signal variable_removed(section: String, key: String)
signal party_ready()
signal spectate_mode_changed()


func emit_variable_saved(section: String, key: String, value: Variant) -> void:
	variable_saved.emit(section, key, value)

func emit_variable_removed(section: String, key: String) -> void:
	variable_removed.emit(section, key)

func emit_party_ready() -> void:
	party_ready.emit()


func emit_spectate_mode_changed() -> void:
	spectate_mode_changed.emit()
