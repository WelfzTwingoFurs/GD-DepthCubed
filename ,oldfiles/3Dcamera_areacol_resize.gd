@tool
extends Node2D
var drawfov_check
func process():
	if get_parent().draw_dist-get_parent().fov != drawfov_check:
		var B2 = Vector2(0,1).rotated(deg_to_rad(get_parent().fov/2))
		$col.polygon[1] = Vector2(get_parent().draw_dist*B2.x/B2.y, get_parent().draw_dist*B2.y/B2.y)
		$col.polygon[2] = $area/col.polygon[1]
		$col.polygon[2].x *= -1
		drawfov_check = get_parent().draw_dist-get_parent().fov
