@tool
extends Camera2D
@export var draw_dist = 100
@export var fov = 100
var drawfov_check = -1

func _physics_process(_delta):
	$area.rotation += int(!Input.is_action_pressed("ply1_strafe")) * Input.get_axis("ply1_move_left", "ply1_move_right")/500
	position += (Vector2(
		int(Input.is_action_pressed("ply1_strafe")) * Input.get_axis("ply1_move_right", "ply1_move_left"), 
		Input.get_axis("ply1_move_back", "ply1_move_forward")).rotated($area.rotation))/10

func _process(_delta):
	if draw_dist+fov != drawfov_check: areacol_resize()
	if inview.size(): queue_redraw()

func _draw():
	var midscreen = (Vector2(0,draw_dist).rotated($area.rotation)).angle()
	for actual in inview:
		var pos = tan((actual.position - position).angle() - midscreen) * DisplayServer.window_get_size().x/2
		var siz = 1-((position.distance_to(actual.position)/draw_dist) * cos((actual.position - position).angle() - midscreen))
		#var siz = (1-((position.distance_to(actual.position)/draw_dist) * cos(xkusu)))
		#var siz = ((1-((position.distance_to(actual.position)/draw_dist*(1/min_max.x)) * cos(xkusu))) *min_max.y)/2
		#var siz = (2-((position.distance_to(actual.position)/draw_dist) * cos(xkusu))) *(min_max-1)
		#var siz = ((1+min_max.x)-((position.distance_to(actual.position)/draw_dist) * cos(xkusu))) *(min_max.y-min_max.x)
		#var siz = ((1+min_max.x)-((position.distance_to(actual.position)/draw_dist) * cos(xkusu))) *(min_max.y-min_max.x)
		#		var siz = min_max.y-(((position.distance_to(actual.position)/draw_dist) * cos(xkusu))*min_max.x)
		
		draw_set_transform(Vector2(),0, Vector2(siz,siz))
		draw_texture(actual.texture, Vector2(pos,0) - actual.texture.get_size()/2)

var inview = []
func _on_area_body_entered(body): inview.push_back(body)
func _on_area_body_exited(body): inview.erase(body)

func areacol_resize():
	var B2 = Vector2(0,1).rotated(deg_to_rad(fov/2))
	$area/col.polygon[1] = Vector2(draw_dist*B2.x/B2.y, draw_dist*B2.y/B2.y)
	$area/col.polygon[2] = $area/col.polygon[1]
	$area/col.polygon[2].x *= -1
	drawfov_check = draw_dist+fov
