extends HBoxContainer

class_name MemberContainer

const PLAYER_LABEL = "You"

# Preload icon textures
const _1_ICON = preload("res://assets/common/icons/ui_icons/1_icon.png")
const _2_ICON = preload("res://assets/common/icons/ui_icons/2_icon.png")
const _3_ICON = preload("res://assets/common/icons/ui_icons/3_icon.png")
const _4_ICON = preload("res://assets/common/icons/ui_icons/4_icon.png")
const _5_ICON = preload("res://assets/common/icons/ui_icons/5_icon.png")
const _6_ICON = preload("res://assets/common/icons/ui_icons/6_icon.png")
const _7_ICON = preload("res://assets/common/icons/ui_icons/7_icon.png")
const _8_ICON = preload("res://assets/common/icons/ui_icons/8_icon.png")
const DEBUFF_SCENE = preload("res://scenes/ui/auras/debuff_icons/debuff.tscn")

@onready var index_icons := [_1_ICON, _2_ICON, _3_ICON, _4_ICON, _5_ICON, _6_ICON, _7_ICON, _8_ICON]
@onready var index_icon_texture: TextureRect = $HBoxContainer/VBoxContainer/InfoLabels/IndexIconTexture
@onready var role_label: Label = $HBoxContainer/VBoxContainer/InfoLabels/RoleLabelScale/RoleLabel
@onready var aura_container: HBoxContainer = $AuraContainer
@onready var player_debuff_container : BoxContainer = get_tree().get_first_node_in_group("player_debuff_container")

var is_player := false


func set_as_player():
	is_player = true
	role_label.text = PLAYER_LABEL


func set_index_icon(index: int):
	assert(index >= 0 and index < index_icons.size())
	index_icon_texture.texture = index_icons[index]


func add_debuff(role_key : String, debuff_icon_scene : PackedScene, duration : float,
	stackable : bool, debuff_name : String) -> Signal:
	# Check if stackable debuff exists, if so, add a stack
	if stackable:
		var auras : Array = aura_container.get_children()
		for aura : Node in auras:
			if aura is Debuff and aura.debuff_name == debuff_name:
				aura.add_stack()
				if is_player:
					var player_auras = player_debuff_container.get_children()
					for player_aura : Node in player_auras:
						if player_aura is Debuff and player_aura.debuff_name == debuff_name:
							player_aura.add_stack()
				return aura.debuff_timeout
	# Else, instantiate new debuff
	var new_debuff : Debuff = DEBUFF_SCENE.instantiate()
	aura_container.add_child(new_debuff)
	new_debuff.set_debuff(debuff_icon_scene, role_key, duration, stackable)
	if is_player:
		var player_debuff : Debuff = DEBUFF_SCENE.instantiate()
		player_debuff_container.add_child(player_debuff)
		player_debuff.set_debuff(debuff_icon_scene, role_key, duration, stackable)
	return new_debuff.debuff_timeout


func remove_debuff(debuff_name: String):
	# Remove from party list debuffs
	var auras : Array = aura_container.get_children()
	for aura : Node in auras:
		if aura is Debuff and aura.debuff_name == debuff_name:
			aura.queue_free()
	# Remove aura from player debuffs
	if is_player:
		var player_debuffs : Array = player_debuff_container.get_children()
		for player_debuff : Node in player_debuffs:
			if player_debuff.debuff_name == debuff_name:
				player_debuff.queue_free()


func has_debuff(debuff_name : String) -> bool:
	var auras : Array = aura_container.get_children()
	for aura : Node in auras:
		if aura is Debuff and aura.debuff_name == debuff_name:
			return true
	return false


func get_debuff_stacks(debuff_name : String) -> int:
	var auras : Array = aura_container.get_children()
	for aura : Node in auras:
		if aura is Debuff and aura.debuff_name == debuff_name:
			return aura.get_stacks()
	return 0
