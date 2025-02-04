# Copyright 2025
# All rights reserved.
# This file is released under "GNU General Public License 3.0".
# Please see the LICENSE file that should have been included as part of this package.

## DEBUG: If debuff is showing 99s duration, make sure you called set_debuff() after instantiating.


extends VBoxContainer
class_name Debuff

signal debuff_timeout(owner_key : String)

@export var icon_size := 25.0
@onready var stacks_label: Label = %Stacks
@onready var duration_label : Label = %Duration
@onready var timer : Timer = %Timer

var debuff_name : String
var remaining_duration := 99.0
var owner_key : String
var stackable : bool
var stacks := 0
var expand_mode := TextureRect.EXPAND_FIT_HEIGHT
var stretch_mode := TextureRect.STRETCH_KEEP_ASPECT_CENTERED
var horizontal_sizing := TextureRect.SIZE_SHRINK_BEGIN
var vertical_sizing := TextureRect.SIZE_SHRINK_BEGIN


func _ready() -> void:
	if remaining_duration > 0.0:
		timer.start()


func set_debuff(debuff_icon_scene: PackedScene, new_owner_key: String, debuff_duration := 0.0, new_stackable: bool = false) -> void:
	owner_key = new_owner_key
	remaining_duration = debuff_duration
	stackable = new_stackable
	%Duration.visible = remaining_duration > 0.0
	var new_debuff_icon : TextureRect = debuff_icon_scene.instantiate()
	new_debuff_icon.set_expand_mode(expand_mode)
	new_debuff_icon.set_stretch_mode(stretch_mode)
	new_debuff_icon.set_custom_minimum_size(Vector2(icon_size, 0))
	new_debuff_icon.set("size_flags_horizontal", horizontal_sizing)
	new_debuff_icon.set("size_flags_vertical", vertical_sizing)
	debuff_name = new_debuff_icon.get_meta("debuff_name")
	self.add_child(new_debuff_icon)
	self.move_child(new_debuff_icon, 1)
	if stackable:
		stacks = 1
		stacks_label.text = str(stacks)
	if remaining_duration < 60.0:
		duration_label.text = str("%.0f" % remaining_duration)
	else:
		duration_label.text = str("%dm" % (int(remaining_duration) / int(60)))


func add_stack() -> void:
	stacks += 1
	stacks_label.text = str(stacks)


func get_stacks() -> int:
	return stacks


# This debuff handles whole number durations only. For float durations, use debuff_float.
func _on_timer_timeout() -> void:
	if remaining_duration > 1.0:
		remaining_duration -= 1.0
	else:
		debuff_timeout.emit(owner_key)
		queue_free()
	if remaining_duration < 60.0:
		duration_label.text = str("%.0f" % remaining_duration)
	else:
		duration_label.text = str("%dm" % (int(remaining_duration) / int(60)))
