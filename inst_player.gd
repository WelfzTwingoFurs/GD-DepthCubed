extends CharacterBody2D
@export var MOVEspeed = 100
@export var TURNspeed = 10
@export var position_z = 0

var framehack = 1
func _process(delta):#Game process exclusively
	#framehack = 60/Engine.get_frames_per_second() #Engine.get_frames_per_second()*framehack == 60, means it's working
	framehack = 0.001/delta #print(delta*framehack)
	
	$Camera/Area.rotation_degrees += int(!Input.is_action_pressed("ply1_strafe")) * Input.get_axis("ply1_move_left", "ply1_move_right")*TURNspeed *framehack
	$Camera.offset.y += Input.get_axis("ply1_butt_up", "ply1_butt_down") *framehack
	
	position += MOVEspeed*Vector2(
		int(Input.is_action_pressed("ply1_strafe")) * Input.get_axis("ply1_move_right", "ply1_move_left"), 
		Input.get_axis("ply1_move_back", "ply1_move_forward")).rotated($Camera/Area.rotation) *framehack
	position_z += MOVEspeed*Input.get_axis("ply1_move_up", "ply1_move_down") *framehack
	
	
	$aim.position.y = $Camera.offset.y
	$aim.modulate.r = -$aim.modulate.r 
	$aim.modulate.b = -$aim.modulate.r

#func _physics_process(delta):
#	print(delta)
