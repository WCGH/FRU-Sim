# Copyright 2025
# All rights reserved.
# This file is released under "GNU General Public License 3.0".
# Please see the LICENSE file that should have been included as part of this package.

# For now this keep the default scale that the cone is set in editor. If variable
# lengths are needed, just set the scale to the desired cone length.


extends GroundMarker
class_name WideConeAoe


func set_parameters(new_position: Vector3, target: Vector2, lifetime: float, color: Color, fail_conditions: Array = []) -> void:
	set_center_position(new_position)
	set_cone(target)
	set_color(color)
	set_lifetime(lifetime)
	if fail_conditions.size() > 0:
		set_fail_conditions(fail_conditions)


func set_cone(target: Vector2) -> void:
	# Rotate to face target
	look_at(Vector3(target.x, GroundAoeController.CONE_Y, target.y))


func set_color(color : Color) -> void:
	if color != Color.TRANSPARENT and color.a > 0.99:
		color.a = COLOR_ALPHA
	mesh_instance_3d.mesh.surface_get_material(0).albedo_color = color


func play_start_animation() -> void:
	var cur_scale = mesh_instance_3d.scale
	mesh_instance_3d.scale = Vector3(0.1, 0.1, 1)
	var tween: Tween = create_tween()
	tween.tween_property(mesh_instance_3d, "scale", cur_scale, 0.15)
