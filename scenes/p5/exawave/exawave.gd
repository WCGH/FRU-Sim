# Copyright 2025
# All rights reserved.
# This file is released under "GNU General Public License 3.0".
# Please see the LICENSE file that should have been included as part of this package.

extends Node3D

class_name Exawave

@onready var exawave_anim: AnimationPlayer = %ExawaveAnim

@onready var baselight_ab: Node3D = %BaselightAB
@onready var baselight_cd: Node3D = %BaselightCD
@onready var lowlight_ab: Node3D = %LowlightAB
@onready var lowlight_cd: Node3D = %LowlightCD
@onready var medlight_ab: Node3D = %MedlightAB
@onready var medlight_cd: Node3D = %MedlightCD
@onready var highlight_ab: Node3D = %HighlightAB
@onready var highlight_cd: Node3D = %HighlightCD
@onready var box_highlight_ab: Node3D = %BoxHighlightAB
@onready var box_highlight_cd: Node3D = %BoxHighlightCD
@onready var waves_ab: Node3D = %WavesAB
@onready var waves_cd: Node3D = %WavesCD

@onready var wave_dark_a: WaveController = %WaveDarkA
@onready var wave_light_b: WaveController = %WaveLightB
@onready var wave_dark_c: WaveController = %WaveDarkC
@onready var wave_light_d: WaveController = %WaveLightD

@onready var ab_wave := [baselight_ab, lowlight_ab, medlight_ab, highlight_ab, box_highlight_ab, waves_ab]
@onready var cd_wave := [baselight_cd, lowlight_cd, medlight_cd, highlight_cd, box_highlight_cd, waves_cd]


# TODO: Randomize the light/dark orientation for each line.
func _ready() -> void:
	pass


func show_base():
	baselight_ab.play_fade_in()
	baselight_cd.play_fade_in()


## 0.0 Seq start (6.2s)
func play_exaline():
	exawave_anim.play("exaline")

## 0.0
# Small Highlight
func small_highlight():
	lowlight_ab.play_fade_in()
	lowlight_cd.play_fade_in()
	baselight_ab.play_fade_out()
	baselight_cd.play_fade_out()

## 2.0
# Med Highlight
func med_highlight():
	medlight_ab.play_fade_in()
	medlight_cd.play_fade_in()
	lowlight_ab.play_fade_out()
	lowlight_cd.play_fade_out()


## 4,0
# Large Highlight
func large_highlight():
	highlight_ab.play_fade_in()
	highlight_cd.play_fade_in()
	medlight_ab.play_fade_out()
	medlight_cd.play_fade_out()

## 5.0
# Box Highlight
func box_highlight():
	box_highlight_ab.play_fade_in_out()
	box_highlight_cd.play_fade_in_out()
	highlight_ab.play_fade_out()
	highlight_cd.play_fade_out()

## 6.8, 8.8, etc. (7 hits)
# Hits 1 -7
func wave_hit():
	wave_dark_a.wave_hit()
	wave_light_b.wave_hit()
	wave_dark_c.wave_hit()
	wave_light_d.wave_hit()
