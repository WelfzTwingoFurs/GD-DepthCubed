@tool
extends PhysicsBody2D#Node2D
@export var modelfile = ""  #import .3D file with model info

@export var poly_faces = [] #mess with these when you want to make models in the editor
@export var poly_verts = [] #mess with these when you want to make models in the editor

@export var position_z = 0.0
@export var rotation3 = Vector3(0,0,0)#pitch, roll, yaw
@export var scale_z = 1.0

func get_type(): return(true)

func _ready():
	if modelfile != "":
		var file = FileAccess.open(modelfile, FileAccess.READ)
		poly_faces = file.get_var()
		poly_verts = file.get_var()


func add_rotate_yaw(add_angle):#2D rotation
	rotation3.z += add_angle
	$CollisionPolygon2D.rotation += add_angle
	for v in poly_verts.size():
		var cunty = Vector2(poly_verts[v].x,poly_verts[v].y).rotated(add_angle)
		poly_verts[v] = Vector3(cunty.x,cunty.y,poly_verts[v].z)

func add_rotate_roll(add_angle):#like a bullet, or a bike swinging left and right as it turns
	rotation3.y += add_angle
	for v in poly_verts.size():
		var cummy = Vector3(poly_verts[v].x, poly_verts[v].y, poly_verts[v].z)
		poly_verts[v].z = cummy.z * cos(add_angle) - cummy.y * sin(add_angle)
		poly_verts[v].y = cummy.y * cos(add_angle) + cummy.z * sin(add_angle)

func add_rotate_pitch(add_angle):#like going on a ramp, we start facing the floor/ceiling
	rotation3.x += add_angle
	for v in poly_verts.size():
		var cummy = Vector3(poly_verts[v].x, poly_verts[v].y, poly_verts[v].z)
		poly_verts[v].z = cummy.z * cos(add_angle) - cummy.x * sin(add_angle)
		poly_verts[v].x = cummy.x * cos(add_angle) + cummy.z * sin(add_angle)
################################################################################################
################################################################################################
################################################################################################
################################################################################################
################################################################################################
################################################################################################

func _physics_process(_delta):
	if !Engine.is_editor_hint():
		if self.get_class() == "CharacterBody2D": col_process()

@export var height = 0
var velocity = Vector2()
var velocity_z = 0
var cols = []
var onfloor = false
func col_process():
	for C in cols:
	#horizontal collision
		var our_feet = position_z
		var our_head = position_z - height
		var their_feet = C.position_z
		var their_head = C.position_z - C.height
		
		if (our_feet > their_head) && (our_head < their_feet):
			remove_collision_exception_with(C)
		else:#if !C.get_collision_exceptions().has(self):
			add_collision_exception_with(C) 
	
	#vertical collision
		if velocity_z:
			if (our_feet < their_head) && (our_feet + velocity_z) > their_head:
				position_z -= C.velocity_z*10#at head
				velocity_z = 0 
				onfloor = true
			
			elif (our_head > their_feet) && (our_head + velocity_z) < their_feet:
				position_z -= C.velocity_z#at feet
				velocity_z = 0



func _on_area_body_entered(body):
	if (body != self):
		if body.is_in_group("collision"): cols.push_back(body)
		else: add_collision_exception_with(body) 

func _on_area_body_exited(body):
	if cols.has(body):
		cols.erase(body)
		onfloor = false

################################################################################################
################################################################################################
################################################################################################
################################################################################################
################################################################################################
################################################################################################

var was_position
func _process(_delta):
	if Engine.is_editor_hint():
		if was_position != position:
			queue_redraw()
			was_position = position

func _draw():
	if Engine.is_editor_hint():
		var drawlist = []
		for poly in poly_faces:
			var current = []
			var order = position_z
			for v in poly:
				if typeof(v) == TYPE_INT:
					current.append(Vector2(poly_verts[v].x, poly_verts[v].y))
					
					draw_set_transform(Vector2i(),false, Vector2(1/(scale.x+scale.y/2),1/(scale.x+scale.y/2)))
					draw_string(ThemeDB.fallback_font, Vector2(poly_verts[v].x, poly_verts[v].y)*(scale.x+scale.y/2), str(v))
					
					order+=poly_verts[v].z
				
				
				else:
					order /= current.size()
					#draw_set_transform(Vector2i(),false, Vector2(1,1))
					#for l in current.size():
					#	draw_line(current[l],current[l+1 if (l < current.size()-1) else 0], Color(0,1,0), 10.0/(scale.x+scale.y/2))
					
					if typeof(poly[poly.size()-2]) == TYPE_STRING:
						#draw_colored_polygon(current,poly[poly.size()-1],select_uv(current.size()),load(poly[poly.size()-2]))
						drawlist.append([order, current, (poly[poly.size()-2]), poly[poly.size()-1]])
					
					else:
						#draw_colored_polygon(current,poly[poly.size()-1])#
						drawlist.append([order, current, poly[poly.size()-1]])
		############################################################################################
		
		
		drawlist.sort_custom(sort_ascending)
		
		for X in drawlist:
			draw_set_transform(Vector2i(),false, Vector2(1,1))
			
			for l in X[1].size():
				draw_line(X[1][l],X[1][l+1 if (l < X[1].size()-1) else 0], Color(0,1,0), 10.0/(scale.x+scale.y/2))
			
			if typeof(X[X.size()-2]) == TYPE_STRING:
				draw_colored_polygon(X[1],X[X.size()-1],select_uv(X[1].size()),load(X[X.size()-2]))
			else:
				draw_colored_polygon(X[1],X[X.size()-1])
	
	
	
	
	
	
	
	

func select_uv(n):
	if n == 3: return PackedVector2Array([Vector2(0,0), Vector2(1,0), Vector2(1,1)])
	elif n == 4: return PackedVector2Array([Vector2(0,0), Vector2(1,0), Vector2(1,1), Vector2(0,1)])
	return PackedVector2Array()

func sort_ascending(a, b):
	if a[0] > b[0]:
		return true
	return false

