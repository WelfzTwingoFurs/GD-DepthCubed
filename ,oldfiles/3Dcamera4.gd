extends Node2D
@export var draw_dist = 5000
var fov = 120 #@export

func _draw():
	var midscreen = Vector2(0,draw_dist).rotated($area.rotation).angle()
	for object in inview:
		if object.get_type():# == Polygon 
			var current = []
			for now in object.polys:#now=pointer, in object.polys(array of arrays, list of polygons)
				for n in now:#n=current vertex, AKA pointer in now(array, 'currently selected' polygon data)
					if typeof(n) == TYPE_INT:
						var obj_point_pos = Vector2(object.points[n].x, object.points[n].y)
						var xkusu = (obj_point_pos - position).angle() - midscreen
						var size = (position.distance_to(obj_point_pos)/draw_dist) * cos(xkusu)
						var positionX = tan(xkusu) * (DisplayServer.window_get_size().x/3.5)#fov code should come here
						current.append(Vector2(positionX,(object.points[n].z - positionZ)/size))
					
					elif Geometry2D.triangulate_polygon(current):#Time to draw
							draw_set_transform(Vector2(),false,Vector2(1,1))
							if (typeof(n) == TYPE_COLOR): draw_colored_polygon(current, n)
							elif (typeof(n) == TYPE_STRING): draw_colored_polygon(current, Color(1,1,1), PackedVector2Array([Vector2(1,0), Vector2(1,1), Vector2(0,1)]), load(n))
							current = []


####################################################################################################
####################################################################################################
var drawfov_check = -1
func _process(_delta):#Graphics process exclusively
	if inview.size(): queue_redraw()
	if draw_dist-fov != drawfov_check:
		var B2 = Vector2(0,1).rotated(deg_to_rad(fov/2))
		$area/col.polygon[1] = Vector2(draw_dist*B2.x/B2.y, draw_dist*B2.y/B2.y)
		$area/col.polygon[2] = $area/col.polygon[1]
		$area/col.polygon[2].x *= -1
		drawfov_check = draw_dist-fov

var inview = []
func _on_area_body_entered(body): inview.push_back(body)
func _on_area_body_exited(body): inview.erase(body)

@export var positionZ = 0
func _physics_process(_delta):#Game process exclusively
	$area.rotation += int(!Input.is_action_pressed("ply1_strafe")) * Input.get_axis("ply1_move_left", "ply1_move_right")/500
	position += (Vector2(
		int(Input.is_action_pressed("ply1_strafe")) * Input.get_axis("ply1_move_right", "ply1_move_left"), 
		Input.get_axis("ply1_move_back", "ply1_move_forward")).rotated($area.rotation))
	positionZ += Input.get_axis("ply1_move_up", "ply1_move_down")/10


####################################################################################################
####################################################################################################
#func rad_overflow(N):
	#if N > PI*2: return N - PI*2
	#elif N < 0: return N + PI*2
	#else: return N

#func deg_overflow(N):
	#if N > 360: return N - 360
	#elif N < 360: return N + 360
	#else: return N

#func rad_deg(N): return N * (180/PI)

#func deg_rad(N): return N * (PI/180)

func vect_int(N): return Vector2(int(N.x),int(N.y))
