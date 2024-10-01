extends Camera2D
@export var noclip = true
@export var fov_pixels = Vector2(1024, 512)
var box
var Queue = []

func _ready():
	if fov_pixels.x == 1:
		$Area/Col.shape.size = DisplayServer.window_get_size()
	else:
		$Area/Col.shape.size = fov_pixels

func _process(_delta):
	$Box.scale = Vector2(DisplayServer.window_get_size())/fov_pixels
	print($Box.scale)
	
	if noclip: position += Vector2(Input.get_axis("ply1_move_left", "ply1_move_right"), Input.get_axis("ply1_move_up", "ply1_move_down")) * 10
	################################################################################################
	if box != null: box.queue_free() #if not here, shit doesn't happen
	box = $Box.duplicate()
	add_child(box)
	
	for Targs in Queue:
		var polys = []
		var face_back = []
		var face_front = []
		
		for Verts in Targs.get_node("CollisionPolygon2D").polygon: #3D calculations, polygon creation
			face_back.append(
				(Verts / Targs.depth[0]) - (global_position-Targs.position) / Targs.depth[0])
			face_front.append(
				(Verts * Targs.depth[1]) - (global_position-Targs.position) * Targs.depth[1])
			polys.append($Box/Poly.duplicate())
		
		for C in polys.size(): #Insert 3Ds into the polygons
			polys[C-1].polygon[0] = face_back[C-1] #first
			polys[ C ].polygon[1] = face_back[C-1] #second
			polys[ C ].polygon[2] = face_front[C-1] #third
			polys[C-1].polygon[3] = face_front[C-1] #last
		
		for C in polys.size(): #Extra processes for polygons, and add them
			polys[C-1].z_index = calcu_z(polys[C-1].polygon[0], polys[C-1].polygon[1])
			polys[C-1].modulate = Color(1,C%2+C%3,C%4)
			if Geometry2D.is_polygon_clockwise(polys[C-1].polygon): box.add_child(polys[C-1])
		
		polys[0] = $Box/Poly.duplicate() #The top polygon, we can re-use first
		polys[0].polygon = face_front
		polys[0].z_index = 4096
		box.add_child(polys[0])

func calcu_z(point1,point2):
	$Dummy.rotation_degrees = int(position.x+position.y) % 360
	var result = ((point2.x-point1.x)*point1.y - point1.x*(point2.y-point1.y))/sqrt(pow(point2.x-point1.x, 2) + pow(point2.y-point1.y, 2))
	if result < -4096: return(-4096)
	elif result > 4095: return(4095)
	else: return(result)


func _on_area_body_entered(body):
	if !Queue.has(body): Queue.push_back(body)
func _on_area_body_exited(body):
	if Queue.has(body): Queue.erase(body)
