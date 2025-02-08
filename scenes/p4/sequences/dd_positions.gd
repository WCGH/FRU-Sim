# Copyright 2025
# All rights reserved.
# This file is released under "GNU General Public License 3.0".
# Please see the LICENSE file that should have been included as part of this package.

# Used for storing bot movement positions for Darklit Dragonsong sequence

extends Node

class_name DDPos

# Multipliers
const N := Vector2(1, 0)
const S := Vector2(-1, 0)
const E := Vector2(0, 1)
const W := Vector2(0, -1)
const NE := Vector2(1, 1)
const NW := Vector2(1, -1)
const SE := Vector2(-1, 1)
const SW := Vector2(-1, -1)
const MID := Vector2(0, 0)

# Mana Akh
const MARKER_OFFSET := 19.0
# Dodge towards LR Spots
const AA_NS := Vector2(16.4, 10.1)
const AA_EW := Vector2(10.1, 16.4)
const AA_N := Vector2(19.0, 3.0)
const AA_E := Vector2(3.0, 19.0)
# Adjust into LR spots (shift south so tanks have uptime on Gaia)
const S_OFFSET := Vector2(-10.5, 0)
const LR_NS := Vector2(15, 5)
const LR_EW := Vector2(10.7, 11.3)
const LR_EU_M1 := Vector2(19.2, 2.2)
const LR_EU_M2 := Vector2(18.7, 5.4)
const LR_EU_R1 := Vector2(13.7, 13.7)
const LR_EU_R2 := Vector2(5.4, 18.7)
const LR_JP := Vector2(10.5, 16.8)
# Bowtie
const TOWER := Vector2(19, 5.2)
const BAIT := Vector2(6.7, 14.6)
# Spirit spread
const SP_TETHER := Vector2(19, 17.2)
const SP_W_SUP := Vector2(0, -38)
const SP_W_DPS := Vector2(0, -19)
const SP_E_DPS := MID
const SP_E_SUP := Vector2(0, 19)
const SP_S_NT := Vector2(15, 19)
const SP_S_T := Vector2(31.4, 9)
# Water stacks
const WATER := Vector2(17.3, 15.5)
# Somber Dance stacks
const DANCE := Vector2(17.3, 8.9)
const DANCE_N := Vector2(15, 0)
const DANCE_S := Vector2(-15, 0)
const DANCE_INTER_TANK := Vector2(17.3, 7.2)
const DANCE_TANK := Vector2(0, 36)
# Akh Morn
const AM_TANK := Vector2(0, -22)
const AM_PARTY := Vector2(13, 0)

# 'Random' spread values so bots aren't stacked
const RS1 := Vector2(0.7, 0.3)
const RS2 := Vector2(0.55, -0.78)
const RS3 := Vector2(-0.2, 0.6)


# Stack mid for AA baits
const MID_STACK_PARTY := {
	"t1": MID, "t2": MID + RS1, "h1": MID + RS2, "h2": MID + RS3,
	"m1": MID - RS1, "m2": MID - RS2, "r1": MID - RS3, "r2": MID
	}

const MANA_STACK_PARTY := {
	"t1": NW * MARKER_OFFSET, "t2": NE * MARKER_OFFSET + RS1, "h1": NE * MARKER_OFFSET + RS2, "h2": NE * MARKER_OFFSET + RS3,
	"m1": NE * MARKER_OFFSET - RS1, "m2": NE * MARKER_OFFSET - RS2, "r1": NE * MARKER_OFFSET - RS3, "r2": NE * MARKER_OFFSET
	}

# Post AA spread, NA
const POST_AA_PARTY_NA := {
	"t1": AA_NS * NE, "t2": AA_EW * NE,
	"h1": AA_EW * NW, "h2": AA_NS * NW,
	"m1": AA_NS * SE, "m2": AA_EW * SE,
	"r1": AA_EW * SW, "r2": AA_NS * SW
	}
# EU
const POST_AA_PARTY_EU := {
	"t1": AA_E * NW, "t2": AA_E * SW,
	"h1": AA_N * NW, "h2": AA_N * NE,
	"m1": AA_N * SW, "m2": AA_N * SE,
	"r1": AA_NS * SE, "r2": AA_E * SE
	}
# JP
const POST_AA_PARTY_JP := {
	"t1": AA_E * SW, "t2": AA_EW * SW,
	"h1": AA_EW * NW, "h2": AA_E * NW,
	"m1": AA_EW * SE, "m2": AA_E * SE,
	"r1": AA_E * NE, "r2": AA_EW * NE
	}
# MANA
const POST_AA_PARTY_MANA := {
	"t1": MID, "t2": MID + RS1, "h1": MID + RS2, "h2": MID + RS3,
	"m1": MID - RS1, "m2": MID - RS2, "r1": MID - RS3, "r2": MID
	}
	
# Move to LR pre-pos, NA
const LR_PARTY_NA := {
	"t1": LR_NS * NE + S_OFFSET, "t2": LR_EW * NE + S_OFFSET,
	"h1": LR_EW * NW + S_OFFSET, "h2": LR_NS * NW + S_OFFSET,
	"m1": LR_NS * SE + S_OFFSET, "m2": LR_EW * SE + S_OFFSET,
	"r1": LR_EW * SW + S_OFFSET, "r2": LR_NS * SW + S_OFFSET
	}
# EU
const LR_PARTY_EU := {
	"t1": AA_E * SW + S_OFFSET, "t2": AA_E * NW + S_OFFSET,
	"h1": AA_N * NW + S_OFFSET, "h2": AA_N * NE + S_OFFSET,
	"m1": LR_EU_M1 * SW + S_OFFSET, "m2": LR_EU_M2 * SE + S_OFFSET,
	"r1": LR_EU_R1 * SE + S_OFFSET, "r2": LR_EU_R2 * SE + S_OFFSET
	}
# JP
const LR_PARTY_JP := {
	"t1": LR_JP * NW + (S_OFFSET * 2), "t2": LR_JP * NW + (S_OFFSET * 3),
	"h1": LR_JP * NW, "h2": LR_JP * NW + S_OFFSET,
	"m1": LR_JP * NE + (S_OFFSET * 3), "m2": LR_JP * NE + (S_OFFSET * 2),
	"r1": LR_JP * NE + S_OFFSET, "r2": LR_JP * NE
	}
# MANA
const LR_PARTY_MANA := {
	"t1": LR_NS * NE + S_OFFSET, "t2": LR_EW * NE + S_OFFSET,
	"h1": LR_EW * NW + S_OFFSET, "h2": LR_NS * NW + S_OFFSET,
	"m1": LR_EW * SW + S_OFFSET, "m2": LR_NS * SW + S_OFFSET,
	"r1": LR_NS * SE + S_OFFSET, "r2": LR_EW * SE + S_OFFSET
	}
	
# Bowtie positions
const BOWTIE_DD := {
	"nw_tether": TOWER * NW, "ne_tether": TOWER * NE,
	"se_tether": TOWER * SE, "sw_tether": TOWER * SW,
	"nw_bait": BAIT * NW, "ne_bait": BAIT * NE,
	"se_bait": BAIT * SE, "sw_bait": BAIT * SW
}

# Spirit Taker spread, NA (special keys for non-tethers)
const SPIRIT_DD_SP_NA := {
	"nw_tether": SP_TETHER * NW, "ne_tether": SP_TETHER * NE,
	"se_tether": SP_TETHER * SE, "sw_tether": SP_TETHER * SW,
	"w_sup": SP_W_SUP, "w_dps": SP_W_DPS,
	"e_sup": SP_E_SUP, "e_dps": SP_E_DPS
}
# Spirit Taker spread, MANA (special keys for non-tethers)
const SPIRIT_DD_SP_MANA := {
	"nw_tether": AA_NS * NW, "ne_tether": AA_NS * NE,
	"se_tether": SP_S_T * SE, "sw_tether": SP_S_T * SW,
	"w_sup": SP_W_DPS, "w_dps": SP_S_NT * SW,
	"e_sup": SP_E_SUP, "e_dps": SP_S_NT * SE
}
# EU (static spreads)
const SPIRIT_DD_EU := {
	"nw_tether": SP_TETHER * NW, "ne_tether": SP_TETHER * NE,
	"se_tether": SP_TETHER * SE, "sw_tether": SP_TETHER * SW,
	"nw_bait": SP_W_SUP, "sw_bait": SP_W_DPS,
	"se_bait": SP_E_SUP, "ne_bait": SP_E_DPS
}
# JP (static spreads, near)
const SPIRIT_DD_JP := {
	"nw_tether": AA_NS * NW, "ne_tether": AA_NS * NE,
	"se_tether": SP_S_T * SE, "sw_tether": SP_S_T * SW,
	"nw_bait": SP_W_DPS, "sw_bait": SP_S_NT * SW,
	"se_bait": SP_S_NT * SE, "ne_bait": SP_E_SUP
}

# Water Stacks (E/W safe)
const WATER_E_DD := {
	"nw_tether": WATER * NE, "ne_tether": WATER * NE + RS1,
	"se_tether": WATER * SE, "sw_tether": WATER * SE + RS1,
	"nw_bait": WATER * NE + RS2, "ne_bait": WATER * NE + RS3,
	"se_bait": WATER * SE + RS2, "sw_bait": WATER * SE + RS3
}
const WATER_W_DD := {
	"nw_tether": WATER * NW, "ne_tether": WATER * NW + RS1,
	"se_tether": WATER * SW, "sw_tether": WATER * SW + RS1,
	"nw_bait": WATER * NW + RS2, "ne_bait": WATER * NW + RS3,
	"se_bait": WATER * SW + RS2, "sw_bait": WATER * SW + RS3
}

# Somber Dance (away from Gaia). T1 needs to be moved separately.
const DANCE_E_DD := {
	"nw_tether": DANCE * NE, "ne_tether": DANCE * NE + RS1,
	"se_tether": DANCE * SE, "sw_tether": DANCE * SE + RS1,
	"nw_bait": DANCE * NE + RS2, "ne_bait": DANCE * NE + RS3,
	"se_bait": DANCE * SE + RS2, "sw_bait": DANCE * SE + RS3
}
const DANCE_W_DD := {
	"nw_tether": DANCE * NW, "ne_tether": DANCE * NW + RS1,
	"se_tether": DANCE * SW, "sw_tether": DANCE * SW + RS1,
	"nw_bait": DANCE * NW + RS2, "ne_bait": DANCE * NW + RS3,
	"se_bait": DANCE * SW + RS2, "sw_bait": DANCE * SW + RS3
}
# Moving party dance positions to mid for all strats and orientations.
const DANCE_MID_DD := {
	"nw_tether": DANCE_N, "ne_tether": DANCE_N + RS1,
	"se_tether": DANCE_S, "sw_tether": DANCE_S + RS1,
	"nw_bait": DANCE_N + RS2, "ne_bait": DANCE_N + RS3,
	"se_bait": DANCE_S + RS2, "sw_bait": DANCE_S + RS3
}

# Intemediate movement for tanks so we don't break tethers
const DANCE_NE_INTER_TANK := DANCE_INTER_TANK * NE
const DANCE_NW_INTER_TANK := DANCE_INTER_TANK * NW
const DANCE_SE_INTER_TANK := DANCE_INTER_TANK * SE
const DANCE_SW_INTER_TANK := DANCE_INTER_TANK * SW
# Jump bait position for tanks
const DANCE_E_TANK := DANCE_TANK * E
const DANCE_W_TANK := DANCE_TANK * W

# Akh Morn 7-1
const AM_7_1_PARTY := {
	"t1": MID, "t2": AM_TANK, "h1": MID + RS1, "h2": MID + RS2,
	"m1": MID + RS3, "m2": MID - RS1, "r1": MID - RS2, "r2": MID - RS3
}
# Akh Morn 4-4
const AM_4_4_PARTY := {
	"t1": AM_PARTY, "h1": AM_PARTY + RS1,
	"m1": AM_PARTY + RS2, "r1": AM_PARTY + RS3,
	"t2": AM_PARTY * S, "h2": AM_PARTY * S + RS1,
	"m2": AM_PARTY * S + RS2, "r2": AM_PARTY * S + RS3
}
