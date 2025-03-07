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
			if Input.is_action_just_pressed("ply1_move_up"):
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
func col_process():
	for C in cols:
	#horizontal collision
		var our_feet = position_z
		var our_head = position_z - height
		var their_feet = C.position_z
		var their_head = C.position_z - (C.height * C.scale_z)
		
		if (our_feet > their_head) && (our_head < their_feet):
			remove_collision_exception_with(C)
		else:#if !C.get_collision_exceptions().has(self):
			add_collision_exception_with(C) 
	
	#vertical collision
		if velocity_z:
			if (our_feet < their_head) && (our_feet + velocity_z) > their_head:
				position_z -= C.velocity_z*10#print("at head")
				velocity_z = 0 
				onfloor = true
			
			elif (our_head > their_feet) && (our_head + velocity_z) < their_feet:
				position_z -= C.velocity_z#print("at feet")
				velocity_z = 0



func _on_area_body_entered(body):
	if (body != self):
		if body.is_in_group("collision"): cols.push_back(body)
		else: add_collision_exception_with(body) 

func _on_area_body_exited(body):
	if cols.has(body):
		cols.erase(body)
		onfloor = false
