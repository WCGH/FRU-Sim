# Copyright 2025
# All rights reserved.
# This file is released under "GNU General Public License 3.0".
# Please see the LICENSE file that should have been included as part of this package.

extends TextureButton
class_name ActionButton

signal action_pressed()

@export var cooldown := 10.0

@onready var cooldown_timer: Timer = %CooldownTimer
@onready var cooldown_sweep: TextureProgressBar = %CooldownSweep
@onready var cooldown_label: Label = %CooldownLabel
@onready var keybind_label: Label = %KeybindLabel


func _ready() -> void:
	cooldown_timer.wait_time = cooldown
	cooldown_label.hide()
	cooldown_sweep.texture_progress = texture_normal
	cooldown_sweep.value = 0
	set_process(false)


func _process(_delta: float) -> void:
	cooldown_label.text = "%3.f" %  (int(cooldown_timer.time_left) + 1)
	cooldown_sweep.value = int((cooldown_timer.time_left / cooldown) * 100)


func set_keybind_label(key: String) -> void:
	keybind_label.set_text(key)


func _on_pressed() -> void:
	# TODO: Need to distinguish stunned from frozen.
	if disabled or get_tree().get_first_node_in_group("player").is_player_frozen()\
		or Global.spectate_mode or Global.is_moving_ui:
		return
	disabled = true
	set_process(true)
	cooldown_timer.start()
	cooldown_label.show()
	action_pressed.emit()


func _on_cooldown_timer_timeout() -> void:
	cooldown_sweep.value = 0
	disabled = false
	cooldown_label.hide()
	set_process(false)
