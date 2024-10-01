@tool
extends Node2D
@export var drawdist = 10000
@export var fov = 120
@export var rotate = 0
@export var position_z = 0

func _draw():
	var midscreen = Vector2(0,1).rotated($area.rotation).angle()
	
	for object in inview:
		if object.get_type():# == Polygon:
			for poly in object.poly_array:
				var current = []
				for n in poly:#n(vertex/info), of poly(polygon), of poly_array(list), of object(model in world)
					if typeof(n) == TYPE_INT:#Calculating...
						draw_set_transform(Vector2i(),false, Vector2(1,1))
						var vertex2 = Vector2(object.vertex[n].x,object.vertex[n].y)
						var angle = (vertex2-position).angle() - midscreen
						
						var final = Vector2(
							tan(angle),# * DisplayServer.window_get_size().x/3.5,
							(object.vertex[n].z-position_z)  /  (position.distance_to(vertex2)/drawdist * cos(angle))
							) * Vector2(# 90/2 =45 || 100/2.38 =42.01 || 120/3.5 =34.28 || 130/4.28 =30.37 || 170/22.85 = 7.43
							DisplayServer.window_get_size().x/3.6,
							DisplayServer.window_get_size().x/1225.0)#1225 = 35*35
						
						if ((position.distance_to(object.global_position)/drawdist) * cos(angle)) < 0:#Behind fix 
							final = Vector2(100000000,0).rotated((-final-Vector2(midscreen,0)).angle())
						
						current.append(final)
					
					
					elif Geometry2D.triangulate_polygon(current):#Drawing...
						if typeof(n) == TYPE_COLOR: draw_colored_polygon(current, n)
						elif typeof(poly[poly.size()-1]) == TYPE_OBJECT: draw_colored_polygon(current, Color(1,1,1), select_uv(current.size()), n)
						else: draw_colored_polygon(current, poly[poly.size()-1], select_uv(current.size()), n)
						break
					#How about we get distance from the middle position of polygon, store in an array in that order, then draw array
		
		else:#object.get_type() == Sprite:
			var angle = (object.global_position-position).angle() - midscreen
			var size = digit_to_decimal(object.texture.get_size().x)*object.scaleR / ((position.distance_to(object.global_position)/drawdist) * cos(angle))
			if size > 0:
				draw_set_transform(Vector2i(),false, Vector2(size,size))
				draw_texture(object.texture, Vector2i(
					tan(angle),
					(object.position_z-position_z)  /  (position.distance_to(object.global_position)/drawdist)
					)/size - object.texture.get_size()/2, object.modulate)
				



func digit_to_decimal(n):
	if n <= 10: return 1-(n/10)
	elif n <= 100: return 1-(n/100)
	elif n <= 1000: return 1-(n/1000)#texture size kinda thing...
	while n > 1: n /= 10
	return n

func select_uv(n):
	if n == 3: return PackedVector2Array([Vector2(0,0), Vector2(1,0), Vector2(1,1)])
	elif n == 4: return PackedVector2Array([Vector2(0,0), Vector2(1,0), Vector2(1,1), Vector2(0,1)])
	return PackedVector2Array()


#draw_line(-final, Vector2(midscreen,0), Color(1,1,0))
							#final = Vector2(100000 + (100000/final.distance_to(Vector2(midscreen,0))), 0
							#final = Vector2(100000 * final.distance_to(Vector2(midscreen,0)), 0
####################################################################################################
####################################################################################################
var valuecompare = -1
func _process(_delta):#Graphics process exclusively
	if !Engine.is_editor_hint(): queue_free()
	
	queue_redraw()
	if drawdist-fov-rotate != valuecompare:
		if drawdist < 0: drawdist = abs(drawdist)
		if fov < 0: fov = abs(fov)
		if rotate < 0: rotate = 0
		elif rotate > 360: rotate = 360
		
		var B2 = Vector2(0,1).rotated(deg_to_rad(fov/2))
		$area/col.polygon[1] = Vector2(drawdist*B2.x/B2.y, drawdist*B2.y/B2.y)
		$area/col.polygon[2] = $area/col.polygon[1]
		$area/col.polygon[2].x *= -1
		$area.rotation = deg_to_rad(rotate)
		valuecompare = drawdist-fov-rotate

var inview = []
func _on_area_body_entered(body): inview.push_back(body)
func _on_area_body_exited(body): inview.erase(body)
