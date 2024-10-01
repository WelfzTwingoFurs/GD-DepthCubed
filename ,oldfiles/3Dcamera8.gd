#@tool
extends Node2D
var fov = 120#@export
@export var drawdist = 8192
@export var position_z = 0.0

var nodes_z = []
var debugcount = Vector3()
func _draw():
	$DrawContainer/Node0.receive = [$Area.rotation_degrees,
		[load("res://resources/sky3.png"), 3.0, (-2000-position_z)/29.4/ 4.0960 *DisplayServer.window_get_size().x/1225.0],
		[load("res://resources/sky2.png"), 2.5, (1000-position_z)/29.4/ 3.2768 *DisplayServer.window_get_size().x/1225.0],
		[load("res://resources/sky1.png"), 2.0, (2000-position_z)/29.4/ 2.457 *DisplayServer.window_get_size().x/1225.0],
		[load("res://resources/sky0.png"), 1.5, (3000-position_z)/29.4/ 1.6384 *DisplayServer.window_get_size().x/1225.0]]
	#SKY & FLOOR
	
	################################################################################################
	################################################################################################
	draw_set_transform(Vector2i(),false, Vector2(1,1))
	var drawstring = str(
		"(x",int(position.x)," y",int(position.y)," z",int(position_z)," r",int($Area.rotation_degrees),") *",Engine.time_scale,"\n",
		inview.size()," objects, ",debugcount.x+debugcount.z," points (", debugcount.z," vertexes, ",debugcount.x," sprites, ",debugcount.y," polygons)",
		"\nFPS: ",Engine.get_frames_per_second())
	debugcount = Vector3()
	
	var count = 1
	for L in drawstring.split("\n"):
		draw_string(ThemeDB.fallback_font, Vector2(-DisplayServer.window_get_size().x/2, (15*count)-DisplayServer.window_get_size().y/2), L)
		count += 1
	#DRAW TEXT
	
	################################################################################################
	################################################################################################
	var midscreen = Vector2(0,1).rotated($Area.rotation).angle()
	var counter = 0#Used to keep track of how many objects to draw, for Node2D cloning, for the Z-Indexing botch
	
	for object in inview:#what do we see?
		counter += 1
		if counter > nodes_z.size():#more objects than nodes? add a new one
			nodes_z.append($DrawContainer/Node0.duplicate())
			add_child(nodes_z[nodes_z.size()-1])
		
		if object.get_type(): for poly in object.poly_array:#get_type() == true == polygon array. How many polys in array?
			var current = []
			var z_calc = 0
			
			for n in poly:#n(vertex/info), of poly(polygon), of poly_array(list), of object(model in world)
				if typeof(n) == TYPE_INT:#INT? Means it's vertex! Calculating...
					draw_set_transform(Vector2i(),false, Vector2(1,1))
					var vertex2 = Vector2(object.vertex[n].x, object.vertex[n].y)
					var angle = (vertex2-position).angle() - midscreen
					
					var final = Vector2(
						tan(angle),
						(object.position_z+object.vertex[n].z-position_z)/29.4  /  (position.distance_to(vertex2)/10000 * cos(angle))
						) * Vector2(# 90/2 =45 || 100/2.38 =42.01 || 120/3.5 =34.28 || 130/4.28 =30.37 || 170/22.85 = 7.43
						DisplayServer.window_get_size().x/3.6,#3.5 for 120 fov...
						DisplayServer.window_get_size().x/1225.0)#1225 = 35*35
					
					if position.distance_to(object.global_position) * cos(angle) < 0:#Behind fix 
						final = Vector2(100000000,0).rotated((-final-Vector2(midscreen,0)).angle())
						z_calc += drawdist
					else: z_calc += position3.distance_to(object.vertex[n])
					
					current.append(final)
					debugcount.z += 1
				
				elif Geometry2D.triangulate_polygon(current):#Not INT? Means it's polygon info! Drawing...
					counter += 1
					if counter > nodes_z.size():
						nodes_z.append($DrawContainer/Node0.duplicate())
						add_child(nodes_z[nodes_z.size()-1])
					
					nodes_z[counter-1].z_index = zindex_max(-((z_calc/poly.size()) * (8192/drawdist)-4096))
					
					if typeof(n) == TYPE_COLOR:#draw_colored_polygon
						nodes_z[counter-1].receive = [current, n]#polygon color, no texture
					elif typeof(poly[poly.size()-1]) == TYPE_OBJECT:#polygon texture, no color
						nodes_z[counter-1].receive = [current, Color(1,1,1), select_uv(current.size()), n]
					else:#polygon colored texture
						nodes_z[counter-1].receive = [current, poly[poly.size()-1], select_uv(current.size()), n]
				
				else: print("something went wrong!!")
				
				debugcount.y += 1
		
		else:#object.get_type() == Sprite:
			var angle = (object.global_position-position).angle() - midscreen
			var size = digit_to_decimal(object.texture.get_size().x)*object.scaleR / ((position.distance_to(object.global_position)/(DisplayServer.window_get_size().x)) * cos(angle))
			if size > 0:
				nodes_z[counter-1].z_index = zindex_max(-((position3.distance_to(Vector3i(object.global_position.x, object.global_position.y, object.position_z))) * (8192/drawdist)-4096))
				nodes_z[counter-1].receive = [object.texture, (Vector2(
					tan(angle),
					(object.position_z-position_z)/29.4  /  (position.distance_to(object.global_position)/10000 * cos(angle))
					) * Vector2(
						DisplayServer.window_get_size().x/3.6,
						DisplayServer.window_get_size().x/1225.0)/size) - object.texture.get_size()/2,
					object.modulate, size]
				#last thing was this! you was working on the sprite positionZ, it has a weird fisheye effect
			debugcount.x += 1
# Render

####################################################################################################
####################################################################################################
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

func zindex_max(n):#replace this with % 8192 later im sad rn to do it
	if n < -4096: return -4096
	elif n > 4096: return 4096
	return n
# Functions

####################################################################################################
####################################################################################################
####################################################################################################
####################################################################################################
####################################################################################################
####################################################################################################
var inview = []
func _on_area_body_entered(body): inview.push_back(body)
func _on_area_body_exited(body): inview.erase(body)

var valuecompare = -1

func _process(_delta):#Graphics process exclusively
	queue_redraw()
	#scaleX = pow(0.005125*fov, 2) + (0.01025*fov)
	#scaleX = 259 + 0.541-259 / (1+pow(fov/178, 91.4))
	
	if drawdist-fov != valuecompare:#Reconfiguration, y'know so we don't run this every frame
		if drawdist < 0: drawdist = abs(drawdist)
		elif drawdist > 8192: drawdist = 8192
		if fov < 2: fov = 2
		elif fov > 178: fov = 178
		valuecompare = drawdist-fov
		
		var B2 = Vector2(0,1).rotated(deg_to_rad(fov/2.0))
		$Area/Col.polygon[1] = Vector2(drawdist*B2.x/B2.y, drawdist*B2.y/B2.y)
		$Area/Col.polygon[2] = Vector2(-1,1) * $Area/Col.polygon[1]
	
	position3 = Vector3(position.x, position.y, position_z)
var position3 = Vector3()

func _physics_process(_delta):#Game process exclusively
	$Area.rotation_degrees += int(!Input.is_action_pressed("ply1_strafe")) * Input.get_axis("ply1_move_left", "ply1_move_right")/10
	#if ($Area.rotation_degrees < 0) or ($Area.rotation_degrees > 360): $Area.rotation_degrees = int($Area.rotation_degrees) % 360
	if $Area.rotation_degrees < 0: $Area.rotation_degrees += 360
	elif $Area.rotation_degrees > 360: $Area.rotation_degrees -= 360
	
	position += Vector2(
		int(Input.is_action_pressed("ply1_strafe")) * Input.get_axis("ply1_move_right", "ply1_move_left"), 
		Input.get_axis("ply1_move_back", "ply1_move_forward")).rotated($Area.rotation)
	
	position_z += Input.get_axis("ply1_move_up", "ply1_move_down")

func rot(): return $Area.rotation_degrees
