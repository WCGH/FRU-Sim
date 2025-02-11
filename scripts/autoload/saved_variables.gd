# Copyright 2025
# All rights reserved.
# This file is released under "GNU General Public License 3.0".
# Please see the LICENSE file that should have been included as part of this package.

extends Node

signal keybind_changed(keybinds: Dictionary)

const CONFIG_FILE_PATH = "user://config.cfg"

var config_file: ConfigFile
var save_data: Dictionary = {
	"settings": {
		"player_role": 0,
		"screen_res": Vector2i(1600, 900),
		"maximized": false,
		"camera_distance": 22,
		"mouse_sens": 1.0,
		"x_sens": 1.0,
		"y_sens": 1.0,
		"invert_y": false,
		"selected_seq": 0,
		"p2_lr_strat": 0,  # [NAUR, LPDU]
		"p3_sa_strat": 0,  # [NAUR, LPDU]
		"p3_sa_swap": 0,   # [Freepoc, Permaswap]
		"p3_ur_strat": 0,   # [NAUR, LPDU]
		"p4_dd_strat": 0,  # [NA, EU, JP]
		"p4_dd_am_strat": 0,  # [4-4, 7-1]
		"p4_ct_strat": 0  # [NAUR, MUR]
	},
	"keybinds": {
		"ab1_sprint": KEY_1,
		"ab2_arms": KEY_2,
		"ab3_dash": KEY_3,
		"reset": KEY_R
	},
	"waymarks": {
		"active": "preset_1",
		"custom_1": {
			"wm_a": Waymarks.HIDE_VECTOR, "wm_b": Waymarks.HIDE_VECTOR, "wm_c": Waymarks.HIDE_VECTOR, "wm_d": Waymarks.HIDE_VECTOR,
			"wm_1": Waymarks.HIDE_VECTOR, "wm_2": Waymarks.HIDE_VECTOR, "wm_3": Waymarks.HIDE_VECTOR, "wm_4": Waymarks.HIDE_VECTOR,
		},
		"custom_2": {
			"wm_a": Waymarks.HIDE_VECTOR, "wm_b": Waymarks.HIDE_VECTOR, "wm_c": Waymarks.HIDE_VECTOR, "wm_d": Waymarks.HIDE_VECTOR,
			"wm_1": Waymarks.HIDE_VECTOR, "wm_2": Waymarks.HIDE_VECTOR, "wm_3": Waymarks.HIDE_VECTOR, "wm_4": Waymarks.HIDE_VECTOR,
		}
	}
}


func _ready() -> void:
	GameEvents.variable_saved.connect(on_variable_saved)
	config_file = ConfigFile.new()
	load_save_file()
	set_defaults()
	set_keybinds()
	save()


func get_data(category: String, key: String) -> Variant:
	return save_data[category][key]


# TODO: Replace old validation with version check.
func load_save_file() -> void:
	var _err := config_file.load(CONFIG_FILE_PATH)
	# Load data.
	for section in config_file.get_sections():
		for key in config_file.get_section_keys(section):
			save_data[section][key] = config_file.get_value(section, key)


func save() -> void:
	var err := config_file.save(CONFIG_FILE_PATH)
	if err != OK:
		print("Error saving config file: ", err)


func set_defaults() -> void:
	for section: String in save_data:
		for key: String in save_data[section]:
			config_file.set_value(section, key, save_data[section][key])


func on_variable_saved(section: String, key: String, value: Variant) -> void:
	save_data[section][key] = value
	config_file.set_value(section, key, value)
	save()
	if section == "keybinds":
		set_keybinds()


func set_keybinds() -> void:
	for key: String in save_data["keybinds"]:
		var new_key_event := InputEventKey.new()
		new_key_event.set_keycode(save_data["keybinds"][key])
		if !InputMap.action_has_event(key, new_key_event):
			InputMap.action_erase_events(key)
			InputMap.action_add_event(key, new_key_event)
	keybind_changed.emit(save_data["keybinds"])


func get_keybinds() -> Dictionary:
	return save_data["keybinds"]


func get_screen_res() -> Vector2i:
	return save_data["settings"]["screen_res"]
