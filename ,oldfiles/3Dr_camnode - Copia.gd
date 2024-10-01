extends Node2D
var receive = []
func _process(_delta):
	queue_redraw()

func _draw():
	if receive.size() > 0:
		if typeof(receive[0]) == TYPE_OBJECT:#Received texture, is sprite!
			draw_set_transform(Vector2i(),false, Vector2(receive[3],abs(receive[3])))
			draw_texture(receive[0], receive[1], receive[2]) 
		
		elif typeof(receive[1]) == TYPE_COLOR:#Received color, is textureless polygon!
			draw_set_transform(Vector2i(),false, Vector2(1,1))
			draw_colored_polygon(receive[0], receive[1])
		
		elif typeof(receive[1]) == TYPE_PACKED_VECTOR2_ARRAY:#textured polygon, colorful/less!
			draw_set_transform(Vector2i(),false, Vector2(1,1))
			draw_colored_polygon(receive[0], receive[1], receive[2], receive[3])
		
		################################### NEW STUFF!!! ###########################################
		else:#if get_parent().get_parent().position3.z < 3000:#Received float, is sky!
			draw_set_transform(Vector2i(),false,Vector2(1, 1))
			
			var Ymax = (3000-get_parent().get_parent().get_parent().position_z)/29.4/ 0.0001 *DisplayServer.window_get_size().x/1225.0
			var Ymin = (3000-get_parent().get_parent().get_parent().position_z)/29.4/ 4.0960 *DisplayServer.window_get_size().x/1225.0
			
			var rot = receive[0]/360.0 * DisplayServer.window_get_size().x
			
			draw_colored_polygon(PackedVector2Array(
				[Vector2(-rot+DisplayServer.window_get_size().x*1.5,Ymax),#low right #destroys angle: DisplayServer.window_get_size().x/2
				Vector2( -rot-DisplayServer.window_get_size().x/2,Ymax),#low left
				Vector2( -rot-DisplayServer.window_get_size().x/2,Ymin),#high left
				Vector2( -rot+DisplayServer.window_get_size().x*1.5,Ymin)]),#high right
				Color(1,1,1,1), PackedVector2Array([Vector2(), Vector2(1,0), Vector2(1,1600), Vector2(0,1600)]), load("res://resources/floor.png"))
			############################ FLOOR !!!!! ###############################################
			########################################################################################
			
			
			
			for objects in receive: if typeof(objects) == TYPE_ARRAY: 
				if sign(get_parent().get_parent().get_parent().position_z-3000) == sign(objects[1]): continue
				
				var Y = 0
				if objects[1] != 0:#stretch sky
					var thing = DisplayServer.window_get_size().x/float(objects[0].get_width())/objects[1]
					draw_set_transform(Vector2i(),false,Vector2(abs(thing),thing))
					Y = objects[2]/thing -objects[0].get_height()
					for t in abs(objects[1])+1:#loop to complete horizon horizontally
						draw_texture(objects[0],
						Vector2(-receive[0] * objects[0].get_width()/360.0 -objects[0].get_width()*t +objects[0].get_width()*abs(objects[1])/2, Y))
					
				
				else:#non-stretched sky
					draw_set_transform(Vector2i(),false,Vector2(1,1))
					Y = objects[2] -objects[0].get_height()
					for t in (DisplayServer.window_get_size().x/objects[0].get_width())*2:#loop to complete horizon horizontally
						draw_texture(objects[0],
						Vector2(-receive[0] * objects[0].get_width()/360.0 -objects[0].get_width()*t +DisplayServer.window_get_size().x/2, Y))
					
		
		#else: drawfloor()
	
	receive = []

#func drawfloor():
	#draw_set_transform(Vector2i(),false,Vector2(1, 1))
	#
	#var Ymax = (3000-get_parent().get_parent().position3.z)/29.4/ 0.0001 *DisplayServer.window_get_size().x/1225.0
	#var Ymin = (3000-get_parent().get_parent().position3.z)/29.4/ 4.0960 *DisplayServer.window_get_size().x/1225.0
	#
	#var rot = get_parent().get_parent().rot()/360.0 * DisplayServer.window_get_size().x
	#
	#draw_colored_polygon(PackedVector2Array(
		#[Vector2(-rot+DisplayServer.window_get_size().x*1.5,Ymax),#low right #destroys angle: DisplayServer.window_get_size().x/2
		#Vector2( -rot-DisplayServer.window_get_size().x/2,Ymax),#low left
		#Vector2( -rot-DisplayServer.window_get_size().x/2,Ymin),#high left
		#Vector2( -rot+DisplayServer.window_get_size().x*1.5,Ymin)]),#high right
		#Color(1,1,1,1), PackedVector2Array([Vector2(), Vector2(1,0), Vector2(1,1600), Vector2(0,1600)]), load("res://resources/floor.png"))


	#var rot = get_parent().get_parent().rot()/360.0 * DisplayServer.window_get_size().x
	
	#draw_colored_polygon(PackedVector2Array(
		#[Vector2((-rot+DisplayServer.window_get_size().x)*2 + DisplayServer.window_get_size().x/2,Ymax),#low right #destroys angle: DisplayServer.window_get_size().x/2
		#Vector2( (-rot)                                  *2 - DisplayServer.window_get_size().x/2,Ymax),#low left
		#Vector2(  -rot-DisplayServer.window_get_size().x /2,                                      Ymin),#high left
		#Vector2(  -rot+DisplayServer.window_get_size().x *1.5,                                    Ymin)]),#high right
		#Color(1,1,1,1), PackedVector2Array([Vector2(), Vector2(1,0), Vector2(1,6400), Vector2(0,6400)]), load("res://resources/floorrgb.png"))


	#var rot = -(get_parent().get_parent().rot()+180)/360.0 * DisplayServer.window_get_size().x
	
	#draw_colored_polygon(PackedVector2Array(
		#[Vector2((rot+DisplayServer.window_get_size().x*2)*2,    Ymax),#low right #destroys angle: DisplayServer.window_get_size().x/2
		#Vector2(  rot                                   *2,    Ymax),#low left
		#Vector2(  rot,   Ymin),#high left
		#Vector2(  rot+(DisplayServer.window_get_size().x*2),Ymin)]),#high right
		#Color(1,1,1,1), PackedVector2Array([Vector2(), Vector2(1,0), Vector2(1,6400), Vector2(0,6400)]), load("res://resources/floorrgb.png"))

	#var rot = -get_parent().get_parent().rot()/360.0 * DisplayServer.window_get_size().x
	#var rot180 = -DisplayServer.window_get_size().x/2
	#var rot2 = -(get_parent().get_parent().rot()/2)/360.0 * DisplayServer.window_get_size().x
	
	#draw_colored_polygon(PackedVector2Array(
		#[Vector2((rot2+DisplayServer.window_get_size().x/2 )*2,Ymax),#low right #destroys angle: DisplayServer.window_get_size().x/2
		#Vector2((rot2-DisplayServer.window_get_size().x/2 )*2,Ymax),#low left
		#Vector2( rot180-rot-DisplayServer.window_get_size().x/2,Ymin),#high left
		#Vector2( rot180-rot+DisplayServer.window_get_size().x/2,Ymin)]),#high right
		#Color(1,1,1,1), PackedVector2Array([Vector2(), Vector2(1,0), Vector2(1,6400), Vector2(0,6400)]), load("res://resources/floorrgb.png"))

	#draw_colored_polygon(PackedVector2Array(
		#[Vector2((-rot+DisplayServer.window_get_size().x)*2 + DisplayServer.window_get_size().x/2,Ymax),#low right #destroys angle: DisplayServer.window_get_size().x/2
		#Vector2( (-rot)                                  *2 - DisplayServer.window_get_size().x/2,Ymax),#low left
		#Vector2(  -rot-DisplayServer.window_get_size().x /2,                                      Ymin),#high left
		#Vector2(  -rot+DisplayServer.window_get_size().x *1.5,                                    Ymin)]),#high right
		#Color(1,1,1,1), PackedVector2Array([Vector2(), Vector2(1,0), Vector2(1,1), Vector2(0,1)]), load("res://resources/floorwolf.png"))

	#draw_colored_polygon(PackedVector2Array(
		#[Vector2((-rot+DisplayServer.window_get_size().x)*2,Ymax),#low right
		#Vector2((-rot)*2,Ymax),#low left
		#Vector2(-rot-DisplayServer.window_get_size().x/2,Ymin),#high left
		#Vector2(-rot+DisplayServer.window_get_size().x*1.5,Ymin)]),#high right
		##Color(1,1,1,1), PackedVector2Array([Vector2(), Vector2(), Vector2(1,2560), Vector2(0,2560)]), load("res://resources/floorrgb.png"))
		#Color(1,1,1,1), PackedVector2Array([Vector2(), Vector2(1,0), Vector2(1,1), Vector2(0,1)]), load("res://resources/floorrgb.png"))
