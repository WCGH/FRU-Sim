# Copyright 2025
# All rights reserved.
# This file is released under "GNU General Public License 3.0".
# Please see the LICENSE file that should have been included as part of this package.

extends Node

class_name ExawaveController

var test_mode = false
const TEST_POS = Vector3(0, 0, 0)
const TEST_ROTA = 0.0

const RAND_POS := [Vector3(0, 0, 17), Vector3(0, 0, -17), Vector3(17, 0, 0), Vector3(-17, 0, 0)]
const RAND_ROTA_DEG := [0.0, 90.0, 180.0, 270.0]

@onready var exawave_anim: AnimationPlayer = $ExawaveAnim
@onready var exawave_e: Exawave = %ExawaveE
@onready var exawave_w: Exawave = %ExawaveW
@onready var exawave_n: Exawave = %ExawaveN

var east_first: bool
var exawave_varaibles: Dictionary  # Used for bot movement in main sequence.

func _ready() -> void:
	# Randomize position, rotation and order of exawaves.
	var pos_index = randi_range(0, 3)
	self.position = RAND_POS[pos_index]
	if test_mode:
		self.position = TEST_POS
	self.rotation.y = deg_to_rad(RAND_ROTA_DEG[randi_range(0, 3)])
	if test_mode:
		self.rotation.y = TEST_ROTA
	east_first = randi_range(0, 1) == 0
	exawave_varaibles = {"pos": self.position, "pos_index": pos_index, "rota_y_rad": self.rotation.y, "east_first": east_first}


## Called at 4.0s
func start_exawaves() -> Dictionary:
	exawave_anim.play("exawaves")
	return exawave_varaibles


## 0.0 Seq start (4.0s)
# Show base telegraphs
func show_base():
	exawave_e.show_base()
	exawave_w.show_base()
	exawave_n.show_base()

## 2.2
# 1 - Small Highlight
func start_exa_1():
	if east_first:
		exawave_e.play_exaline()
	else:
		exawave_w.play_exaline()

## 6.2
# 2- Small Highlight
func start_exa_2():
	exawave_n.play_exaline()

## 10.2
# 3- Small Highlight
func start_exa_3():
	if east_first:
		exawave_w.play_exaline()
	else:
		exawave_e.play_exaline()


func get_exawave_varaibles() -> Dictionary:
	return exawave_varaibles
