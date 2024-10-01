#@tool
extends Camera2D
@export var draw_dist = 100
@export var fov = 100
@export var max = 2

func _draw():
	var midscreen = (Vector2(0,draw_dist).rotated($area.rotation)).angle()
	for actual in inview:
		var xkusu = (actual.position - position).angle() - midscreen
		#################################################################################
		var siz = (1-((position.distance_to(actual.position)/draw_dist) * cos(xkusu)))*max
		#var siz = pow((1-((position.distance_to(actual.position)/draw_dist) * cos(xkusu)))*2, 2.5)
		#var siz = pow((1-((position.distance_to(actual.position)/draw_dist) * cos(xkusu)))*2, 2.5)#max size = x*y, except if x = 1
		#max1 = 1, x --- (1^x = 1)
		#max2 = 2, 1 --- (2^1 = 2)
		#max3 = 2, 1.5 - (2^1.5=2.8)
		#max4 = 2, 2 --- (2^2 = 4)
		#max5 =
		#max6 = 2, 2.5
		#max7 =
		#max8 = 2, 3 --- (2^3 = 8)
		#var siz = pow((1-((position.distance_to(actual.position)/draw_dist) * cos(xkusu)))*2, 2)
		#if (siz >= min_max.x) && (siz <= min_max.y): #small optmization
		
		# 100/2.38 =42.01 || 130/4.28 =30.37 || 170/22.85 = 7.43
		# 120/3.5 =34.28 || 90/2 =45 || 45*1.25 =56.25
		var pos = tan(xkusu) * (DisplayServer.window_get_size().x/3.5)
		
		draw_set_transform(Vector2(),0, Vector2(siz,siz))
		draw_texture(actual.texture, Vector2(pos/siz,0) - actual.texture.get_size()/2)

####################################################################################################
####################################################################################################
func _process(_delta):#Graphics process exclusively
	if draw_dist-fov != drawfov_check: areacol_resize()
	if !Engine.is_editor_hint() && inview.size(): queue_redraw()

var drawfov_check = -1
func areacol_resize():
	var B2 = Vector2(0,1).rotated(deg_to_rad(fov/2))
	$area/col.polygon[1] = Vector2(draw_dist*B2.x/B2.y, draw_dist*B2.y/B2.y)
	$area/col.polygon[2] = $area/col.polygon[1]
	$area/col.polygon[2].x *= -1
	drawfov_check = draw_dist-fov

var inview = []
func _on_area_body_entered(body): if !Engine.is_editor_hint(): inview.push_back(body)
func _on_area_body_exited(body): if !Engine.is_editor_hint(): inview.erase(body)

####################################################################################################
####################################################################################################
func _physics_process(_delta):#Game process exclusively
	if !Engine.is_editor_hint(): 
		$area.rotation += int(!Input.is_action_pressed("ply1_strafe")) * Input.get_axis("ply1_move_left", "ply1_move_right")/500
		position += (Vector2(
			int(Input.is_action_pressed("ply1_strafe")) * Input.get_axis("ply1_move_right", "ply1_move_left"), 
			Input.get_axis("ply1_move_back", "ply1_move_forward")).rotated($area.rotation))/10
