# Copyright 2024 by William Craycroft
# All rights reserved.
# This file is released under "GNU General Public License 3.0".
# Please see the LICENSE file that should have been included as part of this package.

extends CanvasLayer

const LAUNCHER_VERSION = 1.06
const WINDOW_SIZE = Vector2(1600, 900)
const DISCORD_INVITE_URL := "https://discord.gg/7GEqpRc55c"

enum {DOWNLOAD, UPDATE, READY}

var debug := false
var seq_scene_paths := {
	"p2_main": "res://scenes/p2/p2_main.tscn",
	"p3_main": "res://scenes/p3/p3_main.tscn"
}
var button_text := {
	"update" : "Update Available!",
	"download_ready" : "Download Update",
	"downloading" : "Downloading...",
	"download_err" : "Download Error",
	"installing" : "Installing...",
	"restart" : "Restart",
	"restart_label" : "Restart To Finish Update"
}
var download_folder := "user://pcks/"
var launch_status := DOWNLOAD
var update_in_progress := false
var load_screen_active := false
var load_progress := []
var loading_seq := ""
var click_pos := Vector2.ZERO

@onready var buttons := {"p3_lc" : %P3LaunchButton, "p5_wrath" : %P5WLaunchButton,
	"p5_death" : %P5DLaunchButton, "p6_wyrm" : %P6LaunchButton, "p7": %P7LaunchButton,
	"launcher" : %UpdateLauncherButton}
@onready var download_progress_bar : ProgressBar = %LauncherDownloadProgress
@onready var load_screen_container: MarginContainer = %LoadScreenContainer
@onready var loading_progress_bar: ProgressBar = %LoadingProgressBar
@onready var transition_animation_player: AnimationPlayer = %TransitionAnimationPlayer
@onready var update_h_box_container: HBoxContainer = %UpdateHBoxContainer
@onready var update_label: Label = %UpdateLabel
@onready var main_menu_container: MarginContainer = %MainMenuContainer
@onready var options_menu_container: MarginContainer = %OptionsMenuContainer


func _ready() -> void:
	# Set window to borderless then adjust size.
	#get_tree().get_root().transparent = true
	#get_tree().get_root().set_transparent_background(true)
	get_tree().get_root().borderless = true
	get_tree().get_root().set_size(Vector2(WINDOW_SIZE))
	get_tree().get_root().move_to_center()

	if OS.get_name() != "Windows":
		buttons["launcher"].hide()


func _process(_delta: float) -> void:
	if load_screen_active:
		var load_status := ResourceLoader.load_threaded_get_status(seq_scene_paths[loading_seq], load_progress)
		if load_status == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			loading_progress_bar.value = load_progress[0]
		elif load_status == ResourceLoader.THREAD_LOAD_LOADED:
			game_scene_loaded()


func file_exists(path: String) -> bool:
	return FileAccess.file_exists(path)


# Returns the file path for the give module and type.
func file_path(file_type: String) -> String:
	if file_type == "version":
		return download_folder + "launcher_version.txt"
	else:
		return download_folder + "dsr_sim" + "." + file_type


# Creates directory if one doesn't exist.
func directory_exists(path: String) -> bool:
	if !DirAccess.dir_exists_absolute(path):
		var err := DirAccess.make_dir_absolute(path)
		if err != OK:
			print("Could not crate directory path. Error: ", err)
		return false
	return true


func hide_play_buttons() -> void:
	for key: String in buttons:
		if key == "launcher":
			continue
		buttons[key].visible = false


func enable_buttons() -> void:
	 # Check that no downloads are running
	if update_in_progress:
		return
	# Enable buttons
	for key: String in buttons:
		buttons[key].disabled = false


func disable_buttons() -> void:
	for key: String in buttons:
		buttons[key].disabled = true


func start_game_scene(seq: String) -> void:
	# Start threaded load
	loading_seq = seq
	ResourceLoader.load_threaded_request(seq_scene_paths[loading_seq], "PackedScene", true)
	# Start load screen
	loading_progress_bar.value = 0
	load_screen_active = true
	transition_animation_player.play("fade_in")


func game_scene_loaded() -> void:
	load_screen_active = false
	load_screen_container.visible = false
	#get_tree().get_root().borderless = false
	#ProjectSettings.set_setting("display/window/size/transparent", false)
	#get_tree().get_root().set_transparent_background(false)
	#get_tree().get_root().transparent = false
	#get_tree().get_root().transparent_bg = false
	
	var new_scene: PackedScene = ResourceLoader.load_threaded_get(seq_scene_paths[loading_seq])
	get_tree().change_scene_to_packed(new_scene)
	#var new_window = new_scene.instantiate()
	#add_child(new_window)


func _on_p3_launch_button_pressed() -> void:
	start_game_scene("p3_lc")


func _on_p5w_launch_button_pressed() -> void:
	start_game_scene("p5_wrath")


func _on_p5d_launch_button_pressed() -> void:
	start_game_scene("p5_death")


func _on_p6_launch_button_pressed() -> void:
	start_game_scene("p6_wyrm")


func _on_p7_launch_button_pressed() -> void:
	start_game_scene("p7")


func _on_update_launcher_button_pressed() -> void:
	if OS.get_name() != "Windows":
		return

	if launch_status == DOWNLOAD:
		pass
	elif launch_status == UPDATE:
		var path := OS.get_executable_path().get_base_dir() + "/data/upd.bat"
		var err := OS.create_process(path, [])
		if err == -1:
			print("Error launching updater (incorrect path?).")
			buttons["launcher"] = "Update Error."
		else:
			# Close launcher.
			get_tree().quit()


func _on_options_button_pressed() -> void:
	main_menu_container.hide()
	options_menu_container.show()


func _on_discord_button_pressed() -> void:
	if DISCORD_INVITE_URL != "":
		OS.shell_open(DISCORD_INVITE_URL)
	


func _on_exit_button_pressed() -> void:
	get_tree().quit()


# Handle window movement with left click.
func _unhandled_input(event: InputEvent) -> void:
	if !Input.is_action_pressed("left_click"):
		return
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			click_pos = get_viewport().get_mouse_position()
	if event is InputEventMouseMotion:
		DisplayServer.window_set_position(
			get_tree().get_root().position +
			Vector2i(get_viewport().get_mouse_position()) -
			Vector2i(click_pos))
