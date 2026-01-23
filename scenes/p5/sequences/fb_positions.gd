# Copyright 2025
# All rights reserved.
# This file is released under "GNU General Public License 3.0".
# Please see the LICENSE file that should have been included as part of this package.

# Used for storing bot positions for Fulgent Blade sequence.

extends Node

class_name FBPos

# Directional Multipliers
const NE := Vector2(1, 1)
const NW := Vector2(1, -1)
const SE := Vector2(-1, 1)
const SW := Vector2(-1, -1)

# All Exawave dodges are done on secondary intercardinal directions.
# The dodge sequence is always WSW/ENE > ENE/WSW > SSE > NNW > ENE/WSW > WSW/ENE

const COS_NNE = 2.77  # ~cos(22.5deg) * 3
const SIN_NNE = 1.15  # ~sin(22.5deg) * 3

const EXA_DODGES = {
	"ene": Vector2(SIN_NNE, COS_NNE), "wsw": Vector2(SIN_NNE, COS_NNE) * SW,
	"sse": Vector2(COS_NNE, SIN_NNE) * SE, "nnw": Vector2(COS_NNE, SIN_NNE) * NW, 
}

# Dodge pattern sequence when first exawave is East.
const EAST_DODGE_PATTERN = ["wsw", "ene", "sse", "nnw", "ene", "wsw"]
const WEST_DODGE_PATTERN = ["ene", "wsw", "sse", "nnw", "wsw", "ene"]

# Akh Morn
# Base positions are based on South exawave, centered at -17,0.
const AM_STACK_LEFT := Vector2(-14.6, -9.6)
const AM_STACK_RIGHT := Vector2(-14.6, 9.6)

# 'Random' spread values so bots aren't stacked
const RS1 := Vector2(0.1, 0.2)
const RS2 := Vector2(0.15, -0.08)
const RS3 := Vector2(-0.2, 0.1)


const AKH_MORN_SOUTH := {
	"t1": AM_STACK_LEFT, "t2": AM_STACK_RIGHT,
	"m1": AM_STACK_LEFT + RS1, "m2": AM_STACK_RIGHT + RS1, 
	"r1": AM_STACK_LEFT + RS2, "r2": AM_STACK_RIGHT + RS2, 
	"h1": AM_STACK_LEFT + RS3, "h2": AM_STACK_RIGHT + RS3
}
