# Copyright 2025
# All rights reserved.
# This file is released under "GNU General Public License 3.0".
# Please see the LICENSE file that should have been included as part of this package.

extends Node

class_name ExawaveController

const RAND_POS := [Vector3(0, 0, 17), Vector3(0, 0, -17), Vector3(17, 0, 0), Vector3(-17, 0, 0)]
const RAND_ROTA_DEG := [0.0, 90.0, 180.0, 270.0]

@onready var exawave_anim: AnimationPlayer = $ExawaveAnim
@onready var exawave_e: Exawave = %ExawaveE
@onready var exawave_w: Exawave = %ExawaveW
@onready var exawave_n: Exawave = %ExawaveN

var east_first: bool

func _ready() -> void:
	# Randomize position, rotation and order of exawaves.
	var index = randi_range(0, 3)
	self.position = RAND_POS[index]
	index = randi_range(0, 3)
	self.rotation.y = deg_to_rad(RAND_ROTA_DEG[index])
	east_first = randi_range(0, 1) == 0


## Called at 4.0s
func start_exawaves():
	exawave_anim.play("exawaves")


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
