# Copyright 2025
# All rights reserved.
# This file is released under "GNU General Public License 3.0".
# Please see the LICENSE file that should have been included as part of this package.

extends Node3D

@onready var box_highlight_anim: AnimationPlayer = %BoxHighlightAnim


# Also will spawn in arrows.
func play_fade_in_out():
	box_highlight_anim.play("fade_in_out")
