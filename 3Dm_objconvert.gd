#@tool
extends Node
@export var import = ""
@export var savename = ""
@export var DO_IT = false
@export var scale = 100

@export var poly_faces = []
@export var poly_verts = []
func _process(_delta):
	if DO_IT:
		var limits = Vector4()
		poly_faces.resize(0)
		poly_verts.resize(0)
		var as_text = (FileAccess.open(import, FileAccess.READ)).get_as_text()
		
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
				poly_verts.append(Vector3(ugh[0],ugh[2],-ugh[1])*scale)
				
				
				if ugh[0] > limits.x: limits.x = ugh[0]
				elif ugh[0] < limits.z: limits.z = ugh[0]
				if ugh[2] > limits.y: limits.y = ugh[2]
				elif ugh[2] < limits.w: limits.w = ugh[2]
				
				
				print("v",poly_verts.size()," =",ugh)
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
				print("f",poly_faces.size()," =",arraygay)
				var cor = randi()%255
				#arraygay.append("res://resources/aim.png")
				arraygay.append(Color8(0,0,cor, 255))
				
				poly_faces.append(arraygay)
				
				L = isL + subL
		
		if savename != null:
			var file = FileAccess.open(str("res://resources/",savename,".3D"), FileAccess.WRITE)
			file.store_var(poly_faces)
			file.store_var(poly_verts)
		
		limits *= scale
		$CollisionPolygon2D.polygon = [Vector2(limits.z, limits.y), Vector2(limits.x, limits.y), Vector2(limits.x, limits.w), Vector2(limits.z, limits.w)]
		
		DO_IT = false #TURN IT OFF!!!!
