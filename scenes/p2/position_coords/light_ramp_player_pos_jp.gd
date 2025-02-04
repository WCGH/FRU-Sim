# Copyright 2025
# All rights reserved.
# This file is released under "GNU General Public License 3.0".
# Please see the LICENSE file that should have been included as part of this package.

extends Node

class_name LRPosJP

# Pre-pos for 4/4 setup
static  var pre_pos_44: = {
	"t1": Vector2(14.5, 4.5), "t2": Vector2(11, 11), "h1": Vector2(11, -11), "h2": Vector2(14.5, -4.5), 
	"m1": Vector2(-14.5, 4.5), "m2": Vector2(-11, 11), "r1": Vector2(-11, -11), "r2": Vector2(-14.5, -4.5)
}

# Pre-pos for 4/4 setup for Elemental
static  var pre_pos_44_ele: = {
	"t1": Vector2(14.5, 4.5), "t2": Vector2(11, 11), "h1": Vector2(11, -11), "h2": Vector2(14.5, -4.5), 
	"r1": Vector2(-14.5, 4.5), "r2": Vector2(-11, 11), "m1": Vector2(-11, -11), "m2": Vector2(-14.5, -4.5)
}

# Pre-pos for clock setup
static  var pre_pos_clock: = {
	"t1": Vector2(14.2, 0), "t2": Vector2(0, 14.2), "h1": Vector2(0, -14.2), "h2": Vector2(-14.2, 0), 
	"m1": Vector2(-10, -10), "m2": Vector2(-10, 10), "r1": Vector2(10, -10), "r2": Vector2(10, 10)
}

# Tower line up, with puddles 1/3
static  var tower_lineup: = {
	"n0": Vector2(7, 13.7), "n1": Vector2(16.1, 0), "n2": Vector2(7, -13.7), 
	"s0": Vector2(-7, -13.7), "s1": Vector2(-16.1, 0), "s2": Vector2(-7, 13.7), 
	"n_puddle": Vector2(-6, -6), "s_puddle": Vector2(6, 6)
}


# Tower soak pos, puddles stay 1/3
static  var tower_soak: = {
	"n0": Vector2(19, 32.8), "n1": Vector2(-37.7, 0), "n2": Vector2(19, -32.8), 
	"s0": Vector2(-19, 32.8), "s1": Vector2(37.7, 0), "s2": Vector2(-19, -32.8)
}

static  var puddle_dodge_1: = {
	"n_puddle": Vector2(-18, -18), "s_puddle": Vector2(18, 18)
}

static  var puddle_dodge_2: = {
	"n_puddle": Vector2(0, -25), "s_puddle": Vector2(0, 25)
}

static  var puddle_dodge_3: = {
	"n_puddle": Vector2(16, -20), "s_puddle": Vector2(-16, 20)
}

static  var puddle_dodge_4: = {
	"n_puddle": Vector2(30, -12), "s_puddle": Vector2(-30, 12)
}

static  var puddle_dodge_5: = {
	"n_puddle": Vector2(45, 0), "s_puddle": Vector2(-45, 0)
}

# N/S Post tower positions
static  var post_tower: = {
	"n0": Vector2(45, 0), "n1": Vector2(-45, 0), "n2": Vector2(45, 0), 
	"s0": Vector2(-45, 0), "s1": Vector2(45, 0), "s2": Vector2(-45, 0), 
}

static  var inter_dodge: = {
	"n0": Vector2(43, 10), "n1": Vector2(-42.0, -11.7), "n2": Vector2(44, 11), 
	"s0": Vector2(-42.7, -10.5), "s1": Vector2(44.5, 10.5), "s2": Vector2(-41.2, -11.7), 
	"n_puddle": Vector2(43.5, 10.8), "s_puddle": Vector2(-42.0, -10.7)
}


# Rotate CW to first safe spot
static  var north_orb_first_dodge: = {
	"n0": Vector2(37, 27), "n1": Vector2(-42.0, -16.7), "n2": Vector2(35.3, 27.6), 
	"s0": Vector2(-41.7, -16.5), "s1": Vector2(36.6, 27.5), "s2": Vector2(-42.2, -17.7), 
	"n_puddle": Vector2(36.2, 26.6), "s_puddle": Vector2(-42.0, -16.7)
}


static  var south_orb_first_dodge: = {
	"n0": Vector2(41.7, 16.5), "n1": Vector2(-36.6, -27.5), "n2": Vector2(42.2, 17.7), 
	"s0": Vector2(-37, -27), "s1": Vector2(42.0, 16.7), "s2": Vector2(-35.3, -27.6), 
	"n_puddle": Vector2(42.0, 16.7), "s_puddle": Vector2(-36.2, -26.6)
}


static  var north_orb_second_dodge: = {
	"n0": Vector2(41.7, 16.5), "n1": Vector2(-36.6, -27.5), "n2": Vector2(42.2, 17.7), 
	"s0": Vector2(-37, -27), "s1": Vector2(42.0, 16.7), "s2": Vector2(-35.3, -27.6), 
	"n_puddle": Vector2(42.0, 16.7), "s_puddle": Vector2(-36.2, -26.6)
}


static  var south_orb_second_dodge: = {
	"n0": Vector2(37, 27), "n1": Vector2(-42.0, -16.7), "n2": Vector2(35.3, 27.6), 
	"s0": Vector2(-41.7, -16.5), "s1": Vector2(36.6, 27.5), "s2": Vector2(-42.2, -17.7), 
	"n_puddle": Vector2(36.2, 26.6), "s_puddle": Vector2(-42.0, -16.7)
}


static  var n_pattern_middle_dodge: = {
	"n0": Vector2(16.6, 0.4), "n1": Vector2(-6.8, -11.8), "n2": Vector2(16.1, 0.4), 
	"s0": Vector2(-7, -12), "s1": Vector2(15.9, -0.2), "s2": Vector2(-7.3, -12.1), 
	"n_puddle": Vector2(16.1, -0.5), "s_puddle": Vector2(-6.8, -11.5)
}


static  var s_pattern_middle_dodge: = {
	"n0": Vector2(7, 11), "n1": Vector2(-16.7, 1.4), "n2": Vector2(7.3, 12.1), 
	"s0": Vector2(-17.8, -0.4), "s1": Vector2(7, 12), "s2": Vector2(-16, 0.4), 
	"n_puddle": Vector2(6.8, 11.5), "s_puddle": Vector2(-17.8, 0)
}



static  var spread_clocks: = {
	"t1": Vector2(18, 0), "t2": Vector2(-18, 0), "h1": Vector2(0, -18), "h2": Vector2(0, 18), 
	"m1": Vector2(-12, -12), "m2": Vector2(-12, 12), "r1": Vector2(12, -12), "r2": Vector2(12, 12)
}


static  var pairs: = {
	"t1": Vector2(12.2, -12.5), "t2": Vector2(-12.2, 12), "h1": Vector2(-12.5, -11.5), "h2": Vector2(11.4, 12.5), 
	"m1": Vector2(-12, -12), "m2": Vector2(-12, 12), "r1": Vector2(12, -12), "r2": Vector2(12, 12)
}
