# Copyright 2025
# All rights reserved.
# This file is released under "GNU General Public License 3.0".
# Please see the LICENSE file that should have been included as part of this package.

extends Node

class_name UltRelativityPcPos

const OUT_DISTANCE := 32.5  # Fire drop distance
const OUT_INTER := 23.27 
const MID_DISTANCE := 20.5  # Rewind drop
const MID_INTER := 14.5
const IN_DISTANCE := 3.0    # Middle baits/stacks
const IN_INTER := 2.1

const BAIT_X_CARD := 23
const BAIT_Y_CARD := 4.1
const BAIT_X_INTER := 13.3
const BAIT_Y_INTER := 19.1

const N := Vector2(1, 0)
const S := Vector2(-1, 0)
const E := Vector2(0, 1)
const W := Vector2(0, -1)
const NE := Vector2(1,  1)
const NW := Vector2(1, -1)
const SE := Vector2(-1, 1)
const SW := Vector2(-1, -1)

# Dropping Fires
const N_OUT := N * OUT_DISTANCE
const S_OUT := S * OUT_DISTANCE
const E_OUT := E * OUT_DISTANCE
const W_OUT := W * OUT_DISTANCE
const NW_OUT := NW * OUT_INTER
const NE_OUT := NE * OUT_INTER
const SW_OUT := SW * OUT_INTER
const SE_OUT := SE * OUT_INTER

# Inside Hourglass
const N_MID := N * MID_DISTANCE
const S_MID := S * MID_DISTANCE
const E_MID := E * MID_DISTANCE
const W_MID := W * MID_DISTANCE
const NW_MID := NW * MID_INTER
const NE_MID := NE * MID_INTER
const SW_MID := SW * MID_INTER
const SE_MID := SE * MID_INTER

# Center Stacks
const N_IN := N * IN_DISTANCE
const S_IN := S * IN_DISTANCE
const E_IN := E * IN_DISTANCE
const W_IN := W * IN_DISTANCE
const NW_IN := NW * IN_INTER
const NE_IN := NE * IN_INTER
const SW_IN := SW * IN_INTER
const SE_IN := SE * IN_INTER

# Laser Baits
const N_CW := Vector2(BAIT_X_CARD, -BAIT_Y_CARD)
const N_CCW := Vector2(BAIT_X_CARD, BAIT_Y_CARD)
const S_CW := Vector2(-BAIT_X_CARD, BAIT_Y_CARD)
const S_CCW := Vector2(-BAIT_X_CARD, -BAIT_Y_CARD)
const E_CW := Vector2(BAIT_Y_CARD, BAIT_X_CARD)
const E_CCW := Vector2(-BAIT_Y_CARD, BAIT_X_CARD)
const W_CW := Vector2(-BAIT_Y_CARD, -BAIT_X_CARD)
const W_CCW := Vector2(BAIT_Y_CARD, -BAIT_X_CARD)

const NW_CW := Vector2(BAIT_X_INTER, -BAIT_Y_INTER)
const NW_CCW := Vector2(BAIT_Y_INTER, -BAIT_X_INTER)
const NE_CW := Vector2(BAIT_Y_INTER, BAIT_X_INTER)
const NE_CCW := Vector2(BAIT_X_INTER, BAIT_Y_INTER)
const SW_CW := Vector2(-BAIT_Y_INTER, -BAIT_X_INTER)
const SW_CCW := Vector2(-BAIT_X_INTER, -BAIT_Y_INTER)
const SE_CW := Vector2(-BAIT_X_INTER, BAIT_Y_INTER)
const SE_CCW := Vector2(-BAIT_Y_INTER, BAIT_X_INTER)

# Intermediate spots for E/W during 2nd Baits/Rewinds (out of middle for visual clarity)
const W_BAIT_2 := W * (MID_DISTANCE / 2.0)
const E_BAIT_2 := E * (MID_DISTANCE / 2.0)

# Pre-pos for Fire 1, (short support has fire)
static var fire_1_dps_ice := {
	"f1_dps_sw": SW_OUT, "f1_dps_se": SE_OUT, "f1_sup": N_OUT,
	"f2_dps": E_IN, "f2_sup": W_IN,
	"f2_dps_g9": W_IN, "f2_sup_g9": E_IN,
	"f3_sup_nw": NW_IN, "f3_sup_ne": NE_IN,"f3_dps": S_IN
}

# Pre-pos for Fire 1, (short support has ice)
static var fire_1_sup_ice := {
	"f1_dps_sw": SW_OUT, "f1_dps_se": SE_OUT, "f1_sup": N_MID,
	"f2_dps": E_IN, "f2_sup": W_IN,
	"f2_dps_g9": W_IN, "f2_sup_g9": E_IN,
	"f3_sup_nw": NW_IN, "f3_sup_ne": NE_IN,"f3_dps": S_IN
}

# First Baits/Rewind for CW lasers.
static var bait_rewind_1_cw := {
	"f1_dps_sw": SW_MID, "f1_dps_se": SE_MID, "f1_sup": N_MID,
	"f2_dps": E_IN, "f2_sup": W_MID,
	"f2_dps_g9": W_IN, "f2_sup_g9": E_MID,
	"f3_sup_nw": NW_CW, "f3_sup_ne": NE_CW,"f3_dps": S_CW
}

# First Baits/Rewind for CCW lasers.
static var bait_rewind_1_ccw := {
	"f1_dps_sw": SW_MID, "f1_dps_se": SE_MID, "f1_sup": N_MID,
	"f2_dps": E_IN, "f2_sup": W_MID,
	"f2_dps_g9": W_IN, "f2_sup_g9": E_MID,
	"f3_sup_nw": NW_CCW, "f3_sup_ne": NE_CCW,"f3_dps": S_CCW
}

# Intermediate position with E/W fires mid.
static var fire_2_inter := {
	"f1_dps_sw": SW_IN, "f1_dps_se": SE_IN, "f1_sup": N_IN,
	"f2_dps": E_MID, "f2_sup": W_MID,
	"f2_dps_g9": W_MID, "f2_sup_g9": E_MID,
	"f3_sup_nw": NW_IN, "f3_sup_ne": NE_IN,"f3_dps": S_IN
}

# Move 2nd fires out.
static var fire_2 := {
	"f1_dps_sw": SW_IN, "f1_dps_se": SE_IN, "f1_sup": N_IN,
	"f2_dps": E_OUT, "f2_sup": W_OUT,
	"f2_dps_g9": W_OUT, "f2_sup_g9": E_OUT,
	"f3_sup_nw": NW_IN, "f3_sup_ne": NE_IN,"f3_dps": S_IN
}

# Second Baits/Rewind for CW lasers.
static var bait_rewind_2_cw := {
	"f1_dps_sw": SW_CW, "f1_dps_se": SE_CW, "f1_sup": N_CW,
	"f2_dps": E_BAIT_2, "f2_sup": W_BAIT_2,
	"f2_dps_g9": W_BAIT_2, "f2_sup_g9": E_BAIT_2,
	"f3_sup_nw": NW_IN, "f3_sup_ne": NE_IN,"f3_dps": S_IN
}

# Second Baits/Rewind for CCW lasers.
static var bait_rewind_2_ccw := {
	"f1_dps_sw": SW_CCW, "f1_dps_se": SE_CCW, "f1_sup": N_CCW,
	"f2_dps": E_BAIT_2, "f2_sup": W_BAIT_2,
	"f2_dps_g9": W_BAIT_2, "f2_sup_g9": E_BAIT_2,
	"f3_sup_nw": NW_IN, "f3_sup_ne": NE_IN,"f3_dps": S_IN
}

# Move 3rd fires out.
static var fire_3 := {
	"f1_dps_sw": SW_IN, "f1_dps_se": SE_IN, "f1_sup": N_IN,
	"f2_dps": E_IN, "f2_sup": W_IN,
	"f2_dps_g9": W_IN, "f2_sup_g9": E_IN,
	"f3_sup_nw": NW_OUT, "f3_sup_ne": NE_OUT,"f3_dps": S_OUT
}

# Third Baits for CW lasers.
static var bait_rewind_3_cw := {
	"f1_dps_sw": SW_IN, "f1_dps_se": SE_IN, "f1_sup": N_IN,
	"f2_dps": E_CW, "f2_sup": W_CW,
	"f2_dps_g9": W_CW, "f2_sup_g9": E_CW,
	"f3_sup_nw": NW_IN, "f3_sup_ne": NE_IN,"f3_dps": S_IN
}

# Third Baits for CCW lasers.
static var bait_rewind_3_ccw := {
	"f1_dps_sw": SW_IN, "f1_dps_se": SE_IN, "f1_sup": N_IN,
	"f2_dps": E_CCW, "f2_sup": W_CCW,
	"f2_dps_g9": W_CCW, "f2_sup_g9": E_CCW,
	"f3_sup_nw": NW_IN, "f3_sup_ne": NE_IN,"f3_dps": S_IN
}

# Pre-Slide movement
static var pre_slide := {
	"f1_dps_sw": SW_IN, "f1_dps_se": SE_IN, "f1_sup": N_IN,
	"f2_dps": E_IN, "f2_sup": W_IN,
	"f2_dps_g9": W_IN, "f2_sup_g9": E_IN,
	"f3_sup_nw": NW_IN, "f3_sup_ne": NE_IN,"f3_dps": S_IN
}

static var look_direction := {
	"f1_dps_sw": Vector2(-100, -100), "f1_dps_se": Vector2(-100, 100), "f1_sup": Vector2(100, 0),
	"f2_dps": Vector2(0, 100), "f2_sup": Vector2(0, -100),
	"f2_dps_g9": Vector2(0, -100), "f2_sup_g9": Vector2(0, 100),
	"f3_sup_nw": Vector2(100, -100), "f3_sup_ne": Vector2(100,  100),"f3_dps": Vector2(-100, 0)
}

static var final_stack := {
	"f1_dps_sw": SW, "f1_dps_se": SE, "f1_sup": NE,
	"f2_dps": E, "f2_sup": W,
	"f2_dps_g9": W, "f2_sup_g9": E,
	"f3_sup_nw": NW, "f3_sup_ne": NE,"f3_dps": S
}
