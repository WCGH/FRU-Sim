# Copyright 2025
# All rights reserved.
# This file is released under "GNU General Public License 3.0".
# Please see the LICENSE file that should have been included as part of this package.

extends Node

class_name ApocPos

const N := Vector2(1, 0)
const S := Vector2(-1, 0)
const E := Vector2(0, 1)
const W := Vector2(0, -1)
const NE := Vector2(1,  1)
const NW := Vector2(1, -1)
const SE := Vector2(-1, 1)
const SW := Vector2(-1, -1)

const RS1 := Vector2(0.2, -0.4)
const RS2 := Vector2(-0.1, 0.3)

# Setup
# NA (E/W square)
const SETUP_NA_CLOSE := Vector2(4, 8)
const SETUP_NA_FAR := Vector2(4, 16)
const SPREAD_NA_CLOSE := Vector2(8, 9)
const SPREAD_NA_FAR := Vector2(8, 27)
# EU (NW/SE square)
const SETUP_EU_CLOSE_LEFT := Vector2(15.8, 7.1)
const SETUP_EU_CLOSE_RIGHT := Vector2(7.1, 15.8)
const SETUP_EU_FAR_LEFT := Vector2(25, 16.2)
const SETUP_EU_FAR_RIGHT := Vector2(16.2, 25)
const SETUP_EU_T1 = SETUP_EU_CLOSE_LEFT * NW
const SETUP_EU_T2 = SETUP_EU_CLOSE_RIGHT * NW
const SETUP_EU_H1 = SETUP_EU_FAR_LEFT * NW
const SETUP_EU_H2 = SETUP_EU_FAR_RIGHT * NW
const SETUP_EU_M1 = SETUP_EU_CLOSE_LEFT * SE
const SETUP_EU_M2 = SETUP_EU_CLOSE_RIGHT * SE
const SETUP_EU_R1 = SETUP_EU_FAR_LEFT * SE
const SETUP_EU_R2 = SETUP_EU_FAR_RIGHT * SE

# Stacks
const STACK_NA := Vector2(0, 12)
const STACK_EU := Vector2(15.3, 15.5)

# Apoc Spread (N/S default, will be rotated)
const APOC_NEAR_CARD := Vector2(23, 0)
const APOC_NEAR_INTER := Vector2(16.23, 16.23)
const APOC_FAR := Vector2(44, 8)

# Post Eruption
const POST_ERUPT_NEAR := Vector2(10, 0)
const POST_ERUPT_FAR := Vector2(33, 0)


# Initial role positions
# Apoc keys, static rotation
const ROLE_SETUP_NA := {
	"nl_sup": SETUP_NA_CLOSE * NW, "nr_sup": SETUP_NA_CLOSE * SW, "fl_sup": SETUP_NA_FAR * NW, "fr_sup": SETUP_NA_FAR * SW,
	"nl_dps": SETUP_NA_CLOSE * SE, "nr_dps": SETUP_NA_CLOSE * NE, "fl_dps": SETUP_NA_FAR * SE, "fr_dps": SETUP_NA_FAR * NE
}
const ROLE_SETUP_EU := {
	"nl_sup": SETUP_EU_T1, "nr_sup": SETUP_EU_T2, "fl_sup": SETUP_EU_H1, "fr_sup": SETUP_EU_H2,
	"nl_dps": SETUP_EU_M1, "nr_dps": SETUP_EU_M2, "fl_dps": SETUP_EU_R1, "fr_dps": SETUP_EU_R2
}

# Swap Positions
# Apoc keys, static rotation
const SWAP_SETUP_NA := {
	"nl_sup": SETUP_NA_CLOSE * NW, "nr_sup": SETUP_NA_CLOSE * SW, "fl_sup": SETUP_NA_FAR * NW, "fr_sup": SETUP_NA_FAR * SW,
	"nl_dps": SETUP_NA_CLOSE * SE, "nr_dps": SETUP_NA_CLOSE * NE, "fl_dps": SETUP_NA_FAR * SE, "fr_dps": SETUP_NA_FAR * NE
}
const SWAP_SETUP_EU := {
	"nl_sup": SETUP_EU_T1, "nr_sup": SETUP_EU_T2, "fl_sup": SETUP_EU_H1, "fr_sup": SETUP_EU_H2,
	"nl_dps": SETUP_EU_M1, "nr_dps": SETUP_EU_M2, "fl_dps": SETUP_EU_R1, "fr_dps": SETUP_EU_R2
}

# First Water stack after swaps are done.
# Apoc keys, static rotation
const STACK_1_NA := {
	"nl_sup": STACK_NA * W, "nr_sup": STACK_NA * W, "fl_sup": STACK_NA * W, "fr_sup": STACK_NA * W,
	"nl_dps": STACK_NA, "nr_dps": STACK_NA, "fl_dps": STACK_NA, "fr_dps": STACK_NA
}
const STACK_1_EU := {
	"nl_sup": STACK_EU * NW, "nr_sup": STACK_EU * NW, "fl_sup": STACK_EU * NW, "fr_sup": STACK_EU * NW,
	"nl_dps": STACK_EU * SE, "nr_dps": STACK_EU * SE, "fl_dps": STACK_EU * SE, "fr_dps": STACK_EU * SE
}

# Static Spread positions (right after water hit)
# Apoc keys, static rotation
const SPREAD_NA := {
	"nl_sup": SPREAD_NA_CLOSE * NW, "nr_sup": SPREAD_NA_CLOSE * SW, "fl_sup": SPREAD_NA_FAR * NW, "fr_sup": SPREAD_NA_FAR * SW,
	"nl_dps": SPREAD_NA_CLOSE * SE, "nr_dps": SPREAD_NA_CLOSE * NE, "fl_dps": SPREAD_NA_FAR * SE, "fr_dps": SPREAD_NA_FAR * NE
}
const SPREAD_EU := {
	"nl_sup": SETUP_EU_T1, "nr_sup": SETUP_EU_T2, "fl_sup": SETUP_EU_H1, "fr_sup": SETUP_EU_H2,
	"nl_dps": SETUP_EU_M1, "nr_dps": SETUP_EU_M2, "fl_dps": SETUP_EU_R1, "fr_dps": SETUP_EU_R2
}

# Apoc Spread
# Positions are rotated up to 135 deg CW, NE/SW relative.
const APOC_SPREAD_CW := {
	"nl_sup": APOC_NEAR_CARD * N, "nr_sup": APOC_NEAR_INTER * NW, "fl_sup": APOC_FAR * NE, "fr_sup": APOC_FAR * NW,
	"nl_dps": APOC_NEAR_CARD * S, "nr_dps": APOC_NEAR_INTER * SE, "fl_dps": APOC_FAR * SW, "fr_dps": APOC_FAR * SE
}
const APOC_SPREAD_CW_HR := {
	"nr_sup": APOC_NEAR_CARD * N, "nl_sup": APOC_NEAR_INTER * NW, "fl_sup": APOC_FAR * NE, "fr_sup": APOC_FAR * NW,
	"nr_dps": APOC_NEAR_CARD * S, "nl_dps": APOC_NEAR_INTER * SE, "fl_dps": APOC_FAR * SW, "fr_dps": APOC_FAR * SE
}
# Positions are rotated up to 135 deg CCW, NW/SE relative.
const APOC_SPREAD_CCW := {
	"nl_sup": APOC_NEAR_INTER * NE, "nr_sup": APOC_NEAR_CARD * N, "fl_sup": APOC_FAR * NE, "fr_sup": APOC_FAR * NW,
	"nl_dps": APOC_NEAR_INTER * SW, "nr_dps": APOC_NEAR_CARD * S, "fl_dps": APOC_FAR * SW, "fr_dps": APOC_FAR * SE
}

# First move after eruptions.
# Relative to NE/SW CW or NW/SE CCW
const POST_ERUPTION := {
	"nl_sup": POST_ERUPT_NEAR * N, "nr_sup": POST_ERUPT_NEAR * N + RS1, "fl_sup": POST_ERUPT_FAR * N, "fr_sup": POST_ERUPT_FAR * N + RS1,
	"nl_dps": POST_ERUPT_NEAR * S, "nr_dps": POST_ERUPT_NEAR * S + RS1, "fl_dps": POST_ERUPT_FAR * S, "fr_dps": POST_ERUPT_FAR * S + RS1
}

# Once fars reach center line, move everyone to stack positions.
# Relative to both NE/SW CW or NW/SE CCW
const STACK_2 := {
	"nl_sup": POST_ERUPT_NEAR * N, "nr_sup": POST_ERUPT_NEAR * N + RS1, "fl_sup": POST_ERUPT_NEAR * N + RS2, "fr_sup": POST_ERUPT_NEAR * N - RS1,
	"nl_dps": POST_ERUPT_NEAR * S, "nr_dps": POST_ERUPT_NEAR * S + RS1, "fl_dps": POST_ERUPT_NEAR * S + RS2, "fr_dps": POST_ERUPT_NEAR * S - RS1
}
