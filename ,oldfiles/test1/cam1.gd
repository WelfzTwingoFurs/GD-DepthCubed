extends CharacterBody2D

@export var draw_dist = 100
@export var fov = 100

func _physics_process(_delta):
	big_tri()
	move_and_slide()
	queue_redraw()
	$area.rotation += Input.get_axis("ply1_move_left", "ply1_move_right")/1000
	position += Vector2(Input.get_axis("ply1_butt_right", "ply1_butt_left"), Input.get_axis("ply1_move_down", "ply1_move_up")).rotated($area.rotation)

func big_tri():
	var A1 = Vector2(-1,draw_dist)
	var A2 = Vector2(1,draw_dist)
	var B1 = Vector2(0,0)
	var B2 = Vector2(0,1).rotated(deg_to_rad(fov/2))
	$area/col.polygon[1] = intersection(A1, A2, B1, B2)
	$area/col.polygon[2] = $area/col.polygon[1]
	$area/col.polygon[2].x *= -1

func _draw():
	var A1 = Vector2(-999,draw_dist).rotated($area.rotation)
	var A2 = Vector2(999,draw_dist).rotated($area.rotation)
	var B1 = Vector2(0,0)
	var B2 = Vector2(0,999).rotated($area.rotation).rotated(deg_to_rad(fov/2))
	draw_line(A1,A2,Color(1,1,1))
	draw_line(B1,B2,Color(1,1,1))

func intersection(A1, A2, B1, B2):#1start, 1end, 2start, 2end
#	var A1 = Vector2(-1,draw_dist)
#	var A2 = Vector2(1,draw_dist)
#	var B1 = Vector2(0,0)
#	var B2 = Vector2(0,1).rotated(fov/2)
	var det = (A1.x - A2.x)*(B1.y - B2.y) - (A1.y - A2.y)*(B1.x - B2.x)#)  +  Vector2(0,1).rotated(rotation_angle)
	return Vector2(
	((A1.x*A2.y - A1.y*A2.x) * (B1.x-B2.x)  -  (A1.x-A2.x) * (B1.x*B2.y - B1.y*B2.x)   /   (A1.x-A2.x) * (B1.y-B2.y)  -  (A1.y-A2.y) * (B1.x-B2.x))/det,
	((A1.x*A2.y - A1.y*A2.x) * (B1.y-B2.y)  -  (A1.y-A2.y) * (B1.x*B2.y - B1.y*B2.x)   /   (A1.x-A2.x) * (B1.y-B2.y)  -  (A1.y-A2.y) * (B1.x-B2.x))/det)

#func big_tri1():#1start, 1end, 2start, 2end
#	var B2 = Vector2(0,draw_dist).rotated(deg_to_rad(fov/2))
#	$area/col.polygon[1] = Vector2(
#	2*draw_dist*B2.x / B2.y*2,
#	2*draw_dist*B2.y / B2.y*2)
#	$area/col.polygon[2] = $area/col.polygon[1]
#	$area/col.polygon[2].x *= -1


func _on_area_body_entered(body):
	pass # Replace with function body.


func _on_area_body_exited(body):
	pass # Replace with function body.
