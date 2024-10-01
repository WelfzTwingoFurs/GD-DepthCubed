extends CharacterBody2D
@export var draw_dist = 100
@export var fov = 100
var drawfov_check = -1

func _ready():
	var B2 = Vector2(0,1).rotated(deg_to_rad(fov/2))
	$area/col.polygon[1] = Vector2(draw_dist*B2.x/B2.y, draw_dist*B2.y/B2.y)
	$area/col.polygon[2] = $area/col.polygon[1]
	$area/col.polygon[2].x *= -1
	drawfov_check = draw_dist+fov

func _physics_process(_delta):
	move_and_slide()
	$area.rotation += Input.get_axis("ply1_move_left", "ply1_move_right")/500
	position += (Vector2(Input.get_axis("ply1_butt_right", "ply1_butt_left"), Input.get_axis("ply1_move_down", "ply1_move_up")).rotated($area.rotation))/10
	
	if Input.is_action_just_pressed("bug_pos_reset"):
		$area.rotation += PI/2


var spr_scale = 5
func _process(_delta):
	if draw_dist+fov != drawfov_check: _ready()
	if render.size():
		if $box/sprite.scale.x < 0: $box/sprite.scale.y = 9999
		else: $box/sprite.scale.y = $box/sprite.scale.x
		
		$box/sprite.scale.x = 1-(position.distance_to(render[0].position)/draw_dist)
		
		#$box/sprite.position.x = ((position.angle_to(render[0].position)) / 2.35) * DisplayServer.window_get_size().x
		#print( ((position.angle_to(render[0].position)) / 2.35) * DisplayServer.window_get_size().x )

var render = []
func _on_area_body_entered(body): if body.is_in_group("render") && !render.has(body): render.push_back(body)
func _on_area_body_exited(body): if render.has(body): render.erase(body)




















#cum
