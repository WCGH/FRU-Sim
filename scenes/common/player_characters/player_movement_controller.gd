# Copyright 2024 by William Craycroft
# All rights reserved.
# This file is released under "GNU General Public License 3.0".
# Please see the LICENSE file that should have been included as part of this package.

## Player Movement Controller

extends Node

class_name PlayerMovementController

const MAX_MOUSE_CLICK_MOVEMENT := 3000.0

const BASE_MOUSE_SENS := 0.002
const BASE_X_SENS := 0.027
const BASE_Y_SENS := 0.027

var debug := false
@export var move_speed : float = 14.3
@export var acceleration : float = 20.0
@export var jump_force : float = 13.0
@export var gravity : float = 37.0
@export var camera_distance : float = 22.0
@export var camera_max_dist : float = 30.0
@export_range(0, 1) var camera_zoom_speed : float = 0.5
@export var dash_distance := 15.0
@export var dash_duration := 0.5
@export var sprint_duration := 10.0
@export var arms_length_duration := 6.0

var facing_angle : float  # do we use this anywhere?
var rotation_speed := 0.15
var click_rotation_speed := 0.3
var mouse_sensitivity := BASE_MOUSE_SENS
var twist_input := 0.0
var pitch_input := 0.0
var mouse_position := Vector2(950.0, 480.0)
var mouse_travel := Vector2.ZERO
# Controller
var invert_y := false
var invert_x := false
var x_sensitivity := BASE_X_SENS
var y_sensitivity := BASE_Y_SENS
# Movement
var rotation_offset := 0.0
var target_rotation := 0.0
var xiv_model: bool
var sprinting := false
var jumping := false
var idle := true
var strafe_left := false
var strafe_right := false
var running := false
var last_input_back := false
var is_frozen := false
var spectate_mode: bool

@onready var player: Player = $".."
@onready var twist_pivot : Node3D = %TwistPivot
@onready var pitch_pivot : Node3D = %PitchPivot
@onready var camera : Camera3D = %Camera3D
@onready var camera_spring_arm : SpringArm3D = %SpringArm3D


func _ready() -> void:
	# Apply saved options
	camera_distance = SavedVariables.save_data["settings"]["camera_distance"]
	camera_spring_arm.spring_length = camera_distance
	mouse_sensitivity *= SavedVariables.save_data["settings"]["mouse_sens"]
	x_sensitivity *= SavedVariables.save_data["settings"]["x_sens"]
	y_sensitivity *= SavedVariables.save_data["settings"]["y_sens"]
	invert_y = SavedVariables.save_data["settings"]["invert_y"]
	invert_x = SavedVariables.save_data["settings"]["invert_x"]
	spectate_mode = Global.spectate_mode
	GameEvents.spectate_mode_changed.connect(on_spectate_mode_changed)
	GameEvents.variable_saved.connect(on_variable_saved)


func _physics_process(delta : float) -> void:
	if player.model == null:
		return
	
	# Reset scene if player is out of bounds.
	if player.global_position.y < -7 : 
		print("Player out of bounds.")
		get_tree().reload_current_scene()
	
	# Rotate pivot to match camera.
	twist_pivot.rotate_y(twist_input)
	pitch_pivot.rotate_x(pitch_input)
	pitch_pivot.rotation.x = clamp(pitch_pivot.rotation.x, deg_to_rad(-90), deg_to_rad(90))
	twist_input = 0.0
	pitch_input = 0.0
	
	# Apply gravity if not on floor.
	if not player.is_on_floor():
		player.velocity.y -= gravity * delta
	
	if is_frozen or spectate_mode or player.sliding:
		return
	
	# 3D Movement (camera relative).
	# Handle left+right click movement
	if Input.is_action_pressed("right_click") and Input.is_action_pressed("left_click"):
		Input.action_press("move_forward")
	
	var input := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	
	var dir := (twist_pivot.transform.basis * Vector3(input.x, 0, input.y)).normalized()
	if player.is_on_floor() and !player.sliding:
		var xz_acel := acceleration if input.x != 0 else 20.0
		player.velocity.x = lerp(player.velocity.x, dir.x * move_speed, xz_acel * delta)
		xz_acel = acceleration if input.y != 0 else 20.0
		player.velocity.z = lerp(player.velocity.z, dir.z * move_speed, xz_acel * delta)
	var vl := player.velocity * twist_pivot.transform.basis
	
	if xiv_model:
		idle = input == Vector2(0, 0)
		player.anim_tree.set("parameters/conditions/idle", idle)
		strafe_left = input == Vector2(-1, 0)
		player.anim_tree.set("parameters/conditions/strafe_left", strafe_left)
		strafe_right = input == Vector2(1, 0)
		player.anim_tree.set("parameters/conditions/strafe_right", strafe_right)
		running = input.y != 0
		player.anim_tree.set("parameters/conditions/running", running)
		last_input_back = input == Vector2(0, 1) or input == Vector2(0, 0)
		# Run backward
		if input == Vector2(0, 1):
			rotation_offset = 180
		# Forward strafe
		elif input.y < 0 and input.y > -1.0:
			rotation_offset = -63.65 * input.x
		# Back strafe
		elif input.y > 0 and input.y < 1.0:
			rotation_offset = -190.95 * input.x
		# Keep character looking back if we last pressed s.
		elif !last_input_back:
			rotation_offset = 0.0
	
	else:  # Old model animation.
		player.anim_tree.set("parameters/IWR/blend_position", Vector2(vl.x, -vl.z) / move_speed)
	
	if is_inside_tree():
		player.move_and_slide()
	
	# Handle Controller right stick (camera)
	var cam_input := Input.get_vector("look_left", "look_right", "look_up", "look_down")
	if cam_input.length_squared() > 0.0:
		if invert_x:
			twist_input = cam_input.x * x_sensitivity
		else:
			twist_input = - cam_input.x * x_sensitivity
		if invert_y:
			pitch_input = cam_input.y * y_sensitivity
		else:
			pitch_input = - cam_input.y * y_sensitivity
	
	# Rotate model to match pivot.
	if (Input.is_action_pressed("right_click") and Input.is_action_pressed("left_click")) or\
		(Input.is_action_pressed("move_left") and Input.is_action_pressed("move_right")):
		player.model.rotation.y = twist_pivot.rotation.y
	if !idle:
		target_rotation = twist_pivot.rotation.y + deg_to_rad(rotation_offset)
	player.model.rotation.y = lerp_angle(player.model.rotation.y, target_rotation, rotation_speed)
	
	# Jumping.
	if player.is_on_floor():
		if Input.is_action_pressed("jump") and player.last_frame_floor:
			player.velocity.y = jump_force
			jumping = true
			player.anim_tree.set("parameters/conditions/jumping", true)
			set_grounded(false)
		elif not player.last_frame_floor:
			jumping = false
			player.anim_tree.set("parameters/conditions/jumping", false)
			set_grounded(true)
		player.last_frame_floor = true
	# Not on floor and not jumping (e.g. walk off ledge, knock up)
	else: 
		if not jumping:
			player.anim_state.travel("Jump_Idle")
			set_grounded(false)
		player.last_frame_floor = false
	
	# Release forward if not pressing W.
	if Input.is_action_pressed("right_click") and Input.is_action_pressed("left_click")\
		and !Input.is_key_pressed(KEY_W):
		Input.action_release("move_forward")


func set_grounded(grounded: bool) -> void:
	if grounded:
		if xiv_model and running:
			player.anim_tree.set("parameters/conditions/grounded_run", true)
		elif xiv_model and strafe_left:
			player.anim_tree.set("parameters/conditions/grounded_strafe_left", true)
		elif xiv_model and strafe_right:
			player.anim_tree.set("parameters/conditions/grounded_strafe_right", true)
		else: # Idle or old model.
			player.anim_tree.set("parameters/conditions/grounded", true)
	else:
		if xiv_model:
				player.anim_tree.set("parameters/conditions/grounded_run", false)
				player.anim_tree.set("parameters/conditions/grounded_strafe_left", false)
				player.anim_tree.set("parameters/conditions/grounded_strafe_right", false)
		player.anim_tree.set("parameters/conditions/grounded", false)


# Mouse event handling
func _unhandled_input(event : InputEvent) -> void:
	# Mouse motion.
	if event is InputEventMouseMotion:
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			if invert_x:
				twist_input = event.relative.x * mouse_sensitivity
			else:
				twist_input = - event.relative.x * mouse_sensitivity
			if invert_y:
				pitch_input = event.relative.y * mouse_sensitivity
			else:
				pitch_input = - event.relative.y * mouse_sensitivity
			# Get left click movement to exclude click/drags
			mouse_travel += event.relative
	# Mouse button pressed.
	if event is InputEventMouseButton:
		# Left/Right click.
		if event.button_index == MOUSE_BUTTON_LEFT or event.button_index == MOUSE_BUTTON_RIGHT:
			if event.pressed:
				mouse_position = event.global_position
				if Input.get_mouse_mode() != Input.MOUSE_MODE_CAPTURED:
					Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			else:
				if !(Input.is_action_pressed("left_click") or Input.is_action_pressed("right_click")):
					Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
					Input.warp_mouse(mouse_position)
					if event.button_index == MOUSE_BUTTON_LEFT and\
						mouse_travel.length_squared() < MAX_MOUSE_CLICK_MOVEMENT:
						player.handle_left_click(mouse_position)
					Input.warp_mouse(mouse_position) # Duplicate call to counter mouse warp bug (shruge).
					mouse_travel = Vector2.ZERO
					twist_input = 0.0
					pitch_input = 0.0
		# Scroll wheel up/down (camera zoom).
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			camera_spring_arm.spring_length = max(0.1, camera.position.z - camera_zoom_speed)
			camera_distance = camera_spring_arm.spring_length
			SavedVariables.save_data["settings"]["camera_distance"] = camera_distance
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			camera_spring_arm.spring_length = min(camera_max_dist, camera.position.z + camera_zoom_speed)
			camera_distance = camera_spring_arm.spring_length
			SavedVariables.save_data["settings"]["camera_distance"] = camera_distance


func reset_player_movement():
	player.anim_tree.set("parameters/conditions/grounded", true)
	player.anim_tree.set("parameters/conditions/idle", true)


func dash() -> void:
	reset_player_movement()
	var tar : Vector3 = (twist_pivot.global_transform.basis.z.normalized() * -dash_distance) 
	tar += player.global_position
	var tween : Tween = get_tree().create_tween()
	tween.tween_property(player, "global_position",
		tar, dash_duration)\
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)


func arms_length() -> void:
	player.kb_resist = true
	var timer: Timer = Timer.new()
	timer.wait_time = arms_length_duration
	add_child(timer)
	timer.timeout.connect(func() -> void: player.kb_resist = false)
	timer.start()


func sprint() -> void:
	sprinting = true
	player.anim_tree.set("parameters/Run_Sprint/blend_position", 1.0)
	move_speed = move_speed * 1.25
	var timer: Timer = Timer.new()
	timer.wait_time = sprint_duration
	add_child(timer)
	timer.timeout.connect(func() -> void:
		sprinting = false
		move_speed = move_speed * 0.8
		player.anim_tree.set("parameters/Run_Sprint/blend_position", 0.0)
		timer.queue_free()
	)
	timer.start()


func on_spectate_mode_changed() -> void:
	spectate_mode = Global.spectate_mode
	#reset_camera()


# Used to update sensitivity when changed in controls menu.
func on_variable_saved(_section: String, key: String, _value: Variant) -> void:
	if key.contains("sens") or key.contains("invert_"):
		mouse_sensitivity = BASE_MOUSE_SENS * SavedVariables.save_data["settings"]["mouse_sens"]
		x_sensitivity = BASE_Y_SENS * SavedVariables.save_data["settings"]["x_sens"]
		y_sensitivity = BASE_Y_SENS * SavedVariables.save_data["settings"]["y_sens"]
		invert_y = SavedVariables.save_data["settings"]["invert_y"]
		invert_x = SavedVariables.save_data["settings"]["invert_x"]


# Resets camera position to fix it getting desync'd when leaving spectate mode.
func reset_camera():
	twist_pivot.rotation_degrees = Vector3(0, 0 ,0)
	pitch_pivot.rotation_degrees = Vector3(-30, 0 ,0)
