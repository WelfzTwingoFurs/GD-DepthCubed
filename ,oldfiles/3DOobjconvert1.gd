@tool
extends Node2D
@export var import : String
@export var DO_IT = false
@export var CLEAR = false
@export var imp_scale = 300.0

@export var poly_array = [] # PolygonZ basis
@export var position_z = 0.0
@export var scale_z = 1.0
var vertex = []
func _ready():
#	poly_array = []
#	DO_IT = true
	if has_node("vertexes"):
		for markers in $vertexes.get_children():
			vertex.append(Vector3(markers.global_position.x, markers.global_position.y, markers.position_z*scale_z))

func get_type(): return(true)

func clear():
	poly_array.resize(0)
	for C in $vertexes.get_children(): C.queue_free()
	CLEAR = false

####################################################################################################
####################################################################################################

func rotate_yaw(add_angle):#same as 2D
	for posit in $vertexes.get_children():
		var cummy = Vector3(posit.position.x, posit.position.y, posit.position_z)
		posit.position.x = cummy.x * cos(add_angle) - cummy.y * sin(add_angle)
		posit.position.y = cummy.y * cos(add_angle) + cummy.x * sin(add_angle)

func rotate_roll(add_angle):#like a bullet, or a bike swinging left and right as it turns
	for posit in $vertexes.get_children():
		var cummy = Vector3(posit.position.x, posit.position.y, posit.position_z)
		posit.position_z = cummy.z * cos(add_angle) - cummy.y * sin(add_angle)
		posit.position.y = cummy.y * cos(add_angle) + cummy.z * sin(add_angle)

func rotate_pitch(add_angle):#like going on a ramp, we start facing the floor/ceiling
	for posit in $vertexes.get_children():
		var cummy = Vector3(posit.position.x, posit.position.y, posit.position_z)
		posit.position_z = cummy.z * cos(add_angle) - cummy.x * sin(add_angle)
		posit.position.x = cummy.x * cos(add_angle) + cummy.z * sin(add_angle)

var as_text
var wasL = 0
func _process(_delta):
	as_text = (FileAccess.open(import, FileAccess.READ)).get_as_text()
	
	if CLEAR: clear()
	
	if DO_IT:
		var limits = Vector4()
		clear()
		
		for L in as_text.length():
			if (as_text.substr(L-2, 2) == "v "):#polygon time!
				var subL = 1
				var isL = L
				var ugh = []
				while (as_text[isL+subL] != "\n"):
					if (as_text[isL+subL] == " "):
						ugh.append(float(as_text.substr(isL,subL)))
						isL += subL+1
						subL = 1
					else:
						subL += 1
				ugh.append(float(as_text.substr(isL,subL)))
				var new_marker = $dummy.duplicate()
				new_marker.position = Vector2(ugh[0],ugh[2])*imp_scale
				new_marker.position_z = -ugh[1]*imp_scale
				$vertexes.add_child(new_marker)
				new_marker.set_owner(self)
				
				if new_marker.position.x > limits.x: limits.x = new_marker.position.x
				elif new_marker.position.x < limits.z: limits.z = new_marker.position.x
				if new_marker.position.y > limits.y: limits.y = new_marker.position.y
				elif new_marker.position.y < limits.w: limits.w = new_marker.position.y
				
				print("v ",ugh)
				L = isL + subL
			
			
			elif (as_text.substr(L-2, 2) == "f "):#polyarray time!
				var subL = 1
				var isL = L
				var arraygay = []
				while (as_text[isL+subL] != "\n"):
					if (as_text[isL+subL] == " "):
						arraygay.append(int(as_text.substr(isL,subL))-1)
						isL += subL+1
						subL = 1
					else:
						subL += 1
				arraygay.append((int(as_text.substr(isL,subL)))-1)
				print("f ",arraygay)
				var cor = randi()%255
				arraygay.append(Color8(cor,0,0, 255))
				poly_array.append(arraygay)
				
				L = isL + subL
			
		
		$CollisionPolygon2D.polygon = [Vector2(limits.z, limits.y), Vector2(limits.x, limits.y), Vector2(limits.x, limits.w), Vector2(limits.z, limits.w)]
		
		DO_IT = false #TURN IT OFF!!!!
