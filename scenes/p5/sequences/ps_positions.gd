# Copyright 2025
# All rights reserved.
# This file is released under "GNU General Public License 3.0".
# Please see the LICENSE file that should have been included as part of this package.

# Used for storing bot positions for Fulgent Blade sequence.

extends Node
class_name PSPos

# Directional Multipliers
const SE := Vector2(-1, 1)
const SW := Vector2(-1, -1)
const NORTH := Vector2(8, 0)

const NEAR_IN = Vector2(9, 9)
const FAR_IN = Vector2(13.5, 13.5)
const NEAR_OUT = Vector2(14.2, 2.0)
const FAR_OUT = Vector2(18.5, 4.8)

const SE_NEAR_IN = NEAR_IN * SE
const SE_FAR_IN = FAR_IN * SE
const SW_NEAR_IN = NEAR_IN * SW
const SW_FAR_IN = FAR_IN * SW

const SE_NEAR_OUT = NEAR_OUT * SE
const SE_FAR_OUT = FAR_OUT * SE
const SW_NEAR_OUT = NEAR_OUT * SW
const SW_FAR_OUT = FAR_OUT * SW

# 'Random' spread values for pre positions
const RS1 := Vector2(0.3, 0.2)
const RS2 := Vector2(0.25, -0.58)
const RS3 := Vector2(-0.4, 0.1)


# Tanks North
const PRE_POS := {
	"t1": NORTH, "t2": NORTH,
	"m1": SW_FAR_IN + RS1, "m2": SE_FAR_IN - RS1, 
	"r1": SW_FAR_IN + RS2, "r2": SE_FAR_IN - RS2, 
	"h1": SW_FAR_IN + RS3, "h2": SE_FAR_IN - RS3
}

# Tanks move in
const HIT_1_IN := {
	"t1": SW_NEAR_IN, "t2": SE_NEAR_IN,
	"m1": SW_FAR_IN + RS1, "m2": SE_FAR_IN - RS1, 
	"r1": SW_FAR_IN + RS2, "r2": SE_FAR_IN - RS2, 
	"h1": SW_FAR_IN + RS3, "h2": SE_FAR_IN - RS3
}

const HIT_1_OUT := {
	"t1": SE_FAR_OUT, "t2": SW_FAR_OUT,
	"m1": SW_NEAR_OUT + RS1, "m2": SE_NEAR_OUT - RS1, 
	"r1": SW_FAR_OUT + RS2, "r2": SE_FAR_OUT - RS2, 
	"h1": SW_FAR_OUT + RS3, "h2": SE_FAR_OUT - RS3
}

const HIT_2_IN := {
	"t1": SE_FAR_IN, "t2": SW_FAR_IN,
	"m1": SW_NEAR_IN + RS1, "m2": SE_NEAR_IN - RS1, 
	"r1": SW_FAR_IN + RS2, "r2": SE_FAR_IN - RS2, 
	"h1": SW_FAR_IN + RS3, "h2": SE_FAR_IN - RS3
}

const HIT_2_OUT := {
	"t1": SE_FAR_OUT, "t2": SW_FAR_OUT,
	"m1": SE_FAR_OUT + RS1, "m2": SW_FAR_OUT - RS1, 
	"r1": SW_NEAR_OUT + RS2, "r2": SE_NEAR_OUT - RS2, 
	"h1": SW_FAR_OUT + RS3, "h2": SE_FAR_OUT - RS3
}

const HIT_3_IN := {
	"t1": SE_FAR_IN, "t2": SW_FAR_IN,
	"m1": SE_FAR_IN + RS1, "m2": SW_FAR_IN - RS1, 
	"r1": SW_NEAR_IN + RS2, "r2": SE_NEAR_IN - RS2, 
	"h1": SW_FAR_IN + RS3, "h2": SE_FAR_IN - RS3
}

const HIT_3_OUT := {
	"t1": SE_FAR_OUT, "t2": SW_FAR_OUT,
	"m1": SE_FAR_OUT + RS1, "m2": SW_FAR_OUT - RS1, 
	"r1": SE_FAR_OUT + RS2, "r2": SW_FAR_OUT - RS2, 
	"h1": SW_NEAR_OUT + RS3, "h2": SE_NEAR_OUT - RS3
}

const HIT_4_IN := {
	"t1": SE_FAR_IN, "t2": SW_FAR_IN,
	"m1": SE_FAR_IN + RS1, "m2": SW_FAR_IN - RS1, 
	"r1": SE_FAR_IN + RS2, "r2": SW_FAR_IN - RS2, 
	"h1": SW_NEAR_IN + RS3, "h2": SE_NEAR_IN - RS3
}

const HIT_4_OUT := {
	"t1": SE_FAR_OUT, "t2": SW_FAR_OUT,
	"m1": SE_FAR_OUT + RS1, "m2": SW_FAR_OUT - RS1, 
	"r1": SE_FAR_OUT + RS2, "r2": SW_FAR_OUT - RS2, 
	"h1": SW_NEAR_OUT + RS3, "h2": SE_NEAR_OUT - RS3
} 
