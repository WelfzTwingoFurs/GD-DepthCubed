extends Node2D
@export var poly_faces = [] #Array of arrays[point, point, point etc, color(s)/texture+UV]
@export var position_z = 0.0
@export var scale_z = 1.0
var poly_verts = []
func get_type(): return(true)
func _ready():
	if has_node("vertexes"):
		for markers in $vertexes.get_children():
			poly_verts.append(Vector3(markers.global_position.x, markers.global_position.y, (position_z+markers.position_z)*scale_z))
	
	elif has_node("CollisionPolygon2D"):
		if ($CollisionPolygon2D.position_z.size() != 1) && ($CollisionPolygon2D.polygon.size() != $CollisionPolygon2D.position_z.size()):
			print("polygon made with collision, amount of position-Z's doesn't match amount of vertexes")
			queue_free()
		
		for m in $CollisionPolygon2D.polygon.size():
			if $CollisionPolygon2D.position_z.size() == 1:#one Z, = all
				poly_verts.append(Vector3(position.x+$CollisionPolygon2D.polygon[m].x, position.y+$CollisionPolygon2D.polygon[m].y, (position_z+$CollisionPolygon2D.position_z[0])*scale_z))
			
			else:#Z individual
				poly_verts.append(Vector3(position.x+$CollisionPolygon2D.polygon[m].x, position.y+$CollisionPolygon2D.polygon[m].y, (position_z+$CollisionPolygon2D.position_z[m])*scale_z))
	
	else:
		print("no polygon detected")
		queue_free()
