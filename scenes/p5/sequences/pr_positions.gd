# Copyright 2025
# All rights reserved.
# This file is released under "GNU General Public License 3.0".
# Please see the LICENSE file that should have been included as part of this package.

# Used for storing bot positions for Fulgent Blade sequence.

extends Node
class_name PRPos

# Directional Multipliers
const NW := Vector2(1, -1)

const MID = Vector2(0, 0)
const SOUTH_TOWER = Vector2(-16.7, 0)
const NE_TOWER = Vector2(8.4, 14.5)
const NW_TOWER = NE_TOWER * NW
const LIGHT_TANK_OUT = Vector2(-16.5, 28.58) # Light T2 out position - cos/sin(120 deg) * 33
const DARK_TANK_IN = Vector2(-8.25, -14.29) # Dark T2 in position - cos/sin(240 deg) * 16.5
const LIGHT_TANK_IN = Vector2(-8.25, 14.29) # Light T2 in position - cos/sin(120 deg) * 16.5
const NORTH_MID = Vector2(16.7, 0) # Healer position between NE/NW tower
const NORTH_FAR = Vector2(33, 0) # Dark T1 out position

# 'Random' spread values for pre positions
const RS1 := Vector2(2.3, 3.2)
const RS2 := Vector2(5.25, -2.18)
const RS3 := Vector2(-1.4, 6.1)


const PRE_POS := {
	"t1": SOUTH_TOWER, "t2": SOUTH_TOWER,
	"m1": SOUTH_TOWER + RS1, "m2": SOUTH_TOWER - RS1, 
	"r1": SOUTH_TOWER + RS2, "r2": SOUTH_TOWER - RS2, 
	"h1": SOUTH_TOWER + RS3, "h2": SOUTH_TOWER - RS3
}

const DARK_POS_1 := {
	"t1": NW_TOWER, "t2": MID - Vector2(2, 0),
	"m1": SOUTH_TOWER - Vector2(0, 9.5), "m2": SOUTH_TOWER + Vector2(0, 9.5), 
	"r1": SOUTH_TOWER - Vector2(1, 10), "r2": SOUTH_TOWER + Vector2(1, 10), 
	"h1": SOUTH_TOWER - Vector2(0, 2), "h2": SOUTH_TOWER + Vector2(0, 2)
}

const LIGHT_POS_1 := {
	"t1": NE_TOWER, "t2": LIGHT_TANK_OUT,
	"m1": SOUTH_TOWER + Vector2(-7, -7), "m2": SOUTH_TOWER + Vector2(-7, 7), 
	"r1": SOUTH_TOWER + Vector2(-7.2, -6.8), "r2": SOUTH_TOWER + Vector2(-7.2, 6.8), 
	"h1": SOUTH_TOWER - Vector2(0, 2), "h2": SOUTH_TOWER + Vector2(0, 2)
}

const DARK_POS_2 := {
	"t1": NORTH_FAR, "t2": DARK_TANK_IN,
	"m1": NW_TOWER + Vector2(4.1, 3.9), "m2": NE_TOWER + Vector2(4.1, -3.9), 
	"r1": NW_TOWER + Vector2(3.8, 4.2), "r2": NE_TOWER + Vector2(3.8, -4.2), 
	"h1": NORTH_MID - Vector2(0, 2), "h2": NORTH_MID + Vector2(0, 2)
}

const LIGHT_POS_2 := {
	"t1": MID + Vector2(2, 0), "t2": LIGHT_TANK_IN,
	"m1": NW_TOWER + Vector2(4.1, 3.9), "m2": NE_TOWER + Vector2(4.1, -3.9), 
	"r1": NW_TOWER + Vector2(3.8, 4.2), "r2": NE_TOWER + Vector2(3.8, -4.2), 
	"h1": NORTH_MID + Vector2(0, -2), "h2": NORTH_MID + Vector2(0, 2)
}
