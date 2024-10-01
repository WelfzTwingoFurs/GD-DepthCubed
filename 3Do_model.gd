#@tool
extends Node2D
@export var modelfile = ""  #import .3D file with model info

@export var poly_faces = [] #mess with these when you want to make models in the editor
@export var poly_verts = [] #mess with these when you want to make models in the editor

@export var position_z = 0.0
@export var rotation_z = Vector2()#roll, pitch, yaw
@export var scale_z = 1

func get_type(): return(true)

func _ready():
	if modelfile != "":
		var file = FileAccess.open(modelfile, FileAccess.READ)
		poly_faces = file.get_var()
		poly_verts = file.get_var()


func add_rotate_roll(add_angle):#like a bullet, or a bike swinging left and right as it turns
	rotation_z += add_angle
	for posit in $vertexes.get_children():
		var cummy = Vector3(posit.position.x, posit.position.y, posit.position_z)
		posit.position_z = cummy.z * cos(add_angle) - cummy.y * sin(add_angle)
		posit.position.y = cummy.y * cos(add_angle) + cummy.z * sin(add_angle)

func add_rotate_pitch(add_angle):#like going on a ramp, we start facing the floor/ceiling
	rotation_z += add_angle
	for posit in $vertexes.get_children():
		var cummy = Vector3(posit.position.x, posit.position.y, posit.position_z)
		posit.position_z = cummy.z * cos(add_angle) - cummy.x * sin(add_angle)
		posit.position.x = cummy.x * cos(add_angle) + cummy.z * sin(add_angle)
