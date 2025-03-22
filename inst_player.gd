extends CharacterBody2D
@export var MOVEspeed = 1000.0
@export var FLYspeed = 1.0
@export var TURNspeed = 0.25
@export var GRAVITY = 0.025
@export var JUMPspeed = 2.5
@export var position_z = 0.0
@export var height = 50.0
var velocity_z = 0.0

#var framehack = 1
func _physics_process(_delta):#Game process exclusively
	move_and_slide()
	position_z += velocity_z
	
	#framehack = 0.001/delta #print(delta*framehack)
	
	$Camera/Area.rotation_degrees += int(!Input.is_action_pressed("ply1_strafe")) * Input.get_axis("ply1_move_left", "ply1_move_right")*TURNspeed# *framehack
	$Camera.offset.y += 1* Input.get_axis("ply1_butt_up", "ply1_butt_down")# *framehack
	if Input.is_action_pressed("ply1_butt_up") && Input.is_action_pressed("ply1_butt_down"):
		$Camera.offset.y = lerp($Camera.offset.y, 0.0, 0.1)
	
	
	velocity = MOVEspeed*Vector2(
		int(Input.is_action_pressed("ply1_strafe")) * Input.get_axis("ply1_move_right", "ply1_move_left"), 
		Input.get_axis("ply1_move_back", "ply1_move_forward")).rotated($Camera/Area.rotation)
	
	if gravmode:
		velocity_z = FLYspeed*Input.get_axis("ply1_move_up", "ply1_move_down")
		if Input.is_action_pressed("ply1_move_up") && Input.is_action_pressed("ply1_move_down"):
			position_z = lerp(position_z, 0.0, 0.1)
	else:
		#print(onfloor)
		if position_z > 0:
			position_z = 0
			velocity_z = 0
			onfloor = true
		
		if !onfloor:
			velocity_z += GRAVITY
		else:
			if Input.is_action_pressed("ply1_move_up"):
				velocity_z -= JUMPspeed
				onfloor = false
	
	if Input.is_action_just_pressed("bug_set_mode"): gravmode = !gravmode
	
	
	
	$aim.position.y = $Camera.offset.y
	$aim.modulate.r = -$aim.modulate.r 
	$aim.modulate.b = -$aim.modulate.r
	
	if cols.size(): col_process()





var gravmode = false
var cols = []
var onfloor = false
var onbody = null

func col_process():
	for C in cols:
		var our_feet = position_z
		var our_head = our_feet - height
		var their_feet
		var their_head
		
		if C.height < 0:#SLOPES
			#var nega_fix = Vector3(INF,INF,0)
			#for i in 3:
				#if C.poly_verts[C.poly_faces[0][i]].x < nega_fix.x:
					#nega_fix.x = C.poly_verts[C.poly_faces[0][i]].x
				#if C.poly_verts[C.poly_faces[0][i]].y < nega_fix.y:
					#nega_fix.y = C.poly_verts[C.poly_faces[0][i]].y
			#
			#if nega_fix.x >= 0:
				#nega_fix.x = 0
			#if nega_fix.y >= 0:
				#nega_fix.y = 0
			#
			#print(nega_fix)
			
			their_feet = (old_slope_code(
				Vector3(position.x, position.y, position_z),
				#Vector3(0,0,C.position_z*10) + C.poly_verts[C.poly_faces[0][0]],
				#Vector3(0,0,C.position_z*10) + C.poly_verts[C.poly_faces[0][1]],
				#Vector3(0,0,C.position_z*10) + C.poly_verts[C.poly_faces[0][2]]) /10)
				#Vector3(0,0,C.position_z*10) + C.poly_verts[C.poly_faces[0][0]].rotated(Vector3(0,0,1), C.rotation),
				#Vector3(0,0,C.position_z*10) + C.poly_verts[C.poly_faces[0][1]].rotated(Vector3(0,0,1), C.rotation),
				#Vector3(0,0,C.position_z*10) + C.poly_verts[C.poly_faces[0][2]].rotated(Vector3(0,0,1), C.rotation)) /10) #+ 180 = -500, 270 = -850, 0 = +200, 90 = 0
				#-nega_fix + Vector3(C.position.x,C.position.y,C.position_z*10) + C.poly_verts[C.poly_faces[0][0]],
				#-nega_fix + Vector3(C.position.x,C.position.y,C.position_z*10) + C.poly_verts[C.poly_faces[0][1]],
				#-nega_fix + Vector3(C.position.x,C.position.y,C.position_z*10) + C.poly_verts[C.poly_faces[0][2]]) /10)
				Vector3(C.position.x,C.position.y,C.position_z*10) + C.poly_verts[C.poly_faces[0][0]],
				Vector3(C.position.x,C.position.y,C.position_z*10) + C.poly_verts[C.poly_faces[0][1]],
				Vector3(C.position.x,C.position.y,C.position_z*10) + C.poly_verts[C.poly_faces[0][2]]) /10)
			
			their_head = their_feet - ((-C.height*2) * C.scale_z)
			#position_z = their_feet
			#print(C.rotation * 180/PI)
		
		else:#FLATS
			their_feet = C.position_z
			their_head = their_feet - (C.height * C.scale_z)
		
		
		
		#vertical collision
		if velocity_z:
			if (our_feet < their_head) && (our_feet + velocity_z) > their_head:
				position_z -= C.velocity_z*10#print("at head")
				velocity_z = 0 
				onfloor = true
				onbody = C
			
			elif (our_head > their_feet) && (our_head + velocity_z) < their_feet:
				position_z -= C.velocity_z#print("at feet")
				velocity_z = 0
		
		
		if (C.height < 0) && (our_head < their_head) && (onbody == C) && (velocity_z == 0):#get_collision_exceptions().has(C) && 
			position_z = their_head
			onfloor = true
			onbody = C
		
		
		#horizontal collision
		if ((our_feet > their_head) && (our_head < their_feet))  && !(onbody == C):
			remove_collision_exception_with(C)
		else:#if !C.get_collision_exceptions().has(self):
			add_collision_exception_with(C) 
		
		#print("\nour_feet:",our_feet,"\nour_head:",our_head,"\ntheir_feet:",their_feet,"\ntheir_head:",their_head,"\nonbody:",onbody)
		print("\nour_feet:",our_feet,"  their_head:",their_head,"   onbody:",onbody)




func old_slope_code(v0,v1,v2,v3):#v0 = where colliding  #v1-3 slope points position
	var normal = (v2 - v1).cross(v3 - v1).normalized()
	var dir = Vector3(0.0, 0.0, 1.0)
	var r = v0 + dir * ((v1.dot(normal)) - v0.dot(normal)) / dir.dot(normal)
	
	return r.z












func _on_area_body_entered(body):
	if (body != self):
		if body.is_in_group("collision"): cols.push_back(body)
		else: add_collision_exception_with(body) 

func _on_area_body_exited(body):
	if cols.has(body):
		cols.erase(body)
		onfloor = false
		onbody = null
