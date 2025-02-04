extends MovableCanvasLayer


func _ready():
	await get_tree().process_frame
	section_key = "coords"
	init_position()
