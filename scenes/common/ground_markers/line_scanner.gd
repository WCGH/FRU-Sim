# Copyright 2025
# All rights reserved.
# This file is released under "GNU General Public License 3.0".
# Please see the LICENSE file that should have been included as part of this package.

# This node will scan for other Area3D's on mask layer 11, and return an array with the first area hit at the front.
# This is used mainly for Wild Charge style mechanics where you need to determine the nearest target in a line.

extends Node3D

class_name LineScanner

signal scan_finished(areas: Array)

var areas_scanned := []
var scan_started := false

func scan_line(starting_pos: Vector2, target_pos: Vector2, duration: float):
	self.global_position = Vector3(starting_pos.x, 0, starting_pos.y)
	self.look_at(Vector3(target_pos.x, 0, target_pos.y))
	
	scan_started = true
	var tween : Tween = get_tree().create_tween()
	tween.tween_property(self, "global_position",
		Vector3(target_pos.x, 0, target_pos.y), duration)\
		.set_trans(Tween.TRANS_LINEAR).connect("finished", on_scan_complete)

func on_scan_complete():
	scan_finished.emit(areas_scanned)
	areas_scanned = []
	scan_started = false

func _on_area_3d_area_entered(area: Area3D) -> void:
	if scan_started:
		if areas_scanned.has(area):
			print("Warning: Scanner scanned an area twice.")
			#return
		areas_scanned.append(area)
