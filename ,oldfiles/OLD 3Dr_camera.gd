extends Camera2D
var fov = 120#@export
@export var drawdist = 8192
@export var position_z = 0
@export var rotation_z = Vector2()

var nodes_z = []
var debugcount = Vector3()
func _draw():
	draw_set_transform(Vector2i(),false, Vector2(1,1))
	var drawstring = str(
		"(x",int(global_position.x)," y",int(global_position.y)," z",int(get_parent().position_z)," r",int($Area.rotation_degrees),") *",Engine.time_scale,"\n",
		inview.size()," objects, ",debugcount.x+debugcount.z," points (", debugcount.z," vertexes, ",debugcount.x," sprites, ",debugcount.y," polygons)",
		#"\nFPS: ",Engine.get_frames_per_second()," ...",get_parent().framehack
		"\nFPS: ",Engine.get_frames_per_second()
		)
	debugcount = Vector3()
	
	var count = 1
	for L in drawstring.split("\n"):
		draw_string(ThemeDB.fallback_font, Vector2(-DisplayServer.window_get_size().x/2, offset.y+(15*count)-DisplayServer.window_get_size().y/2), L)
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
		
		if object.get_type(): for poly in object.poly_faces:#get_type() == true == polygon array. How many polys in array?
			var current = []
			var z_calc = 0
			
			#n(vertex/info), of poly(polygon), of poly_faces(list), of object(model in world) <-- old text
			for n in poly:#n(vertex/info), of poly(current polygon), of object.poly_faces(list in poly), of object(model in world)
				if typeof(n) == TYPE_INT:#INT? Means it's vertex! Calculating...
					draw_set_transform(Vector2i(),false, Vector2(1,1))
					var vertex2 = (Vector2(object.poly_verts[n].x, object.poly_verts[n].y) *object.scale) +object.position
					var angle = (vertex2-global_position).angle() - midscreen
					
					var final = Vector2(
						tan(angle),
						((object.position_z+object.poly_verts[n].z*object.scale_z)-get_parent().position_z)/29.4  /  (global_position.distance_to(vertex2)/10000 * cos(angle))
						) * Vector2(# 90/2 =45 || 100/2.38 =42.01 || 120/3.5 =34.28 || 130/4.28 =30.37 || 170/22.85 = 7.43
						DisplayServer.window_get_size().x/3.6,#3.5 for 120 fov...
						DisplayServer.window_get_size().x/1225.0)#1225 = 35*35
					
					
					if global_position.distance_to(vertex2) * cos(angle) < 0:#Behind fix 
						final = Vector2(100000000,0).rotated((-final-Vector2(midscreen,0)).angle())
						z_calc += drawdist
					else: z_calc += Vector3(global_position.x, global_position.y, get_parent().position_z).distance_to(object.poly_verts[n] + Vector3(object.position.x, object.position.y, object.position_z))
					
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
					#elif typeof(poly[poly.size()-1]) == TYPE_OBJECT:#polygon texture, no color
					#	nodes_z[counter-1].receive = [current, Color(1,1,1), select_uv(current.size()), n]
					else:#polygon colored texture
						nodes_z[counter-1].receive = [current, poly[poly.size()-1], select_uv(current.size()), n]
					
					debugcount.y += 1#
					break
				
				else:
					print("something went wrong!!")
					break
				#debugcount.y += 1
		
		
		
		else:#object.get_type() == Sprite:
			var sprite
			var rotangle = 1
			if object.rotations == 1: sprite = load(str("res://resources/",object.texture,".png"))
			
			elif object.rotations > 1:
				rotangle = -int(( ($Area.rotation_degrees-(object.rotation_degrees+180))/360 )*(abs(object.rotations)+1)) % 360
				
				if rotangle < 0: rotangle = object.rotations+rotangle#all rotations
				sprite = load(str("res://resources/",object.texture, rotangle,".png"))
				rotangle = -1
			
			
			elif object.rotations < -1:
				rotangle = int(( ($Area.rotation_degrees-(object.rotation_degrees+180))/360 )*(abs(object.rotations)+1)) % 360
				
				if (rotangle < 0) or (!object.rot_flip && (rotangle == -object.rotations/2)): 
					rotangle = abs(rotangle)#for flipped graphics
					sprite = load(str("res://resources/",object.texture, rotangle,".png"))
					rotangle = -1
				
				else: sprite = load(str("res://resources/",object.texture, abs(rotangle),".png"))
				
				if rotangle == 0:
					if object.rot_flip && ($Area.rotation_degrees-object.rotation_degrees > 180): rotangle = -1
					else: rotangle = 1
			
			
			var angle = (object.global_position-global_position).angle() - midscreen
			var size = digit_to_decimal(8192-sprite.get_size().x)*object.scaleR / ((global_position.distance_to(object.global_position)/(DisplayServer.window_get_size().x)) * cos(angle))
			
			if size > 0:
				nodes_z[counter-1].z_index = zindex_max(-((Vector3(global_position.x, global_position.y, get_parent().position_z).distance_to(Vector3i(object.global_position.x, object.global_position.y, object.position_z))) * (8192/drawdist)-4096))
				nodes_z[counter-1].receive = [sprite, (Vector2(
					tan(angle),
					(object.position_z-get_parent().position_z)/29.4  /  (global_position.distance_to(object.global_position)/8192 * cos(angle))
					) * Vector2(
						(DisplayServer.window_get_size().x/3.6)*sign(rotangle),
						DisplayServer.window_get_size().x/1225.0)/size)
						- Vector2(
							sprite.get_size().x/2,
							sprite.get_size().y/(2*int(!object.offset_z) + 1*int(object.offset_z))),# Offset correction
					object.modulate, size*sign(rotangle)]
				
				debugcount.x += 1
# Render








####################################################################################################
####################################################################################################
func zindex_max(n):#replace this with % 8192 later
	if n < -4096: return -4096
	elif n > 4096: return 4096
	return n

func digit_to_decimal(n):
	while n > 1: n /= 10
	return n

func select_uv(n):
	if n == 3: return PackedVector2Array([Vector2(0,0), Vector2(1,0), Vector2(1,1)])
	elif n == 4: return PackedVector2Array([Vector2(0,0), Vector2(1,0), Vector2(1,1), Vector2(0,1)])
	return PackedVector2Array()

####################################################################################################
####################################################################################################
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
	if $Area.rotation_degrees < 0: $Area.rotation_degrees += 360 #if (rotation3.z < 0) or (rotation3.z > 360): rotation3.z = int(rotation3.z) % 360
	elif $Area.rotation_degrees > 360: $Area.rotation_degrees -= 360
	
	if drawdist-fov != valuecompare:#Reconfiguration, y'know so we don't run this every frame
		if drawdist < 1: drawdist = 1
		elif drawdist > 8192: drawdist = 8192
		if fov < 2: fov = 2
		elif fov > 178: fov = 178
		valuecompare = drawdist-fov
		
		var B2 = Vector2(0,1).rotated(deg_to_rad(fov/2.0))
		$Area/Col.polygon[1] = Vector2(drawdist*B2.x/B2.y, drawdist*B2.y/B2.y)
		$Area/Col.polygon[2] = Vector2(-1,1) * $Area/Col.polygon[1]
	################################################################################################
	queue_redraw()
	
	$DrawContainer/Node0.receive = [$Area.rotation_degrees, #SKY & FLOOR
		[load("res://resources/sky3.png"),  3.0,( 2000-get_parent().position_z)/29.4/ 4.9152 *DisplayServer.window_get_size().x/1225.0],
		[load("res://resources/sky2.png"),  2.5,( 1000-get_parent().position_z)/29.4/ 4.0960 *DisplayServer.window_get_size().x/1225.0],
		[load("res://resources/sky1.png"),  2.0,( 2000-get_parent().position_z)/29.4/ 3.2768 *DisplayServer.window_get_size().x/1225.0],
		[load("res://resources/sky0.png"),  1.5,( 3000-get_parent().position_z)/29.4/ 1.6384 *DisplayServer.window_get_size().x/1225.0],
		[load("res://resources/cave0.png"),-1.5,( 6000-get_parent().position_z)/29.4/ 4.0960 *DisplayServer.window_get_size().x/1225.0],
		[load("res://resources/cave0.png"),-1.0,( 3000-get_parent().position_z)/29.4/ 3.2768 *DisplayServer.window_get_size().x/1225.0]]
