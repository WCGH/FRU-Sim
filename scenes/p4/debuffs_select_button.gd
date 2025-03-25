extends Button


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var idx := 1
	for i in $PanelContainer/VBoxContainer.get_children():
		i.button_pressed = idx in Global.p4_ct_selected_debuffs
		i.toggled.connect(_on_box_toggled.bind(idx))
		idx += 1
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_toggled(toggled_on: bool) -> void:
	$PanelContainer.visible = toggled_on
	text = "▲" if toggled_on else "▼"
	pass # Replace with function body.


func _on_box_toggled(toggled_on: bool, index:= 0) -> void:
	if toggled_on:
		Global.p4_ct_selected_debuffs.append(index)
	else:
		var i = Global.p4_ct_selected_debuffs.find(index)
		Global.p4_ct_selected_debuffs.remove_at(i)
