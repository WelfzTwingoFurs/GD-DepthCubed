@tool
extends Node2D
@export var import : String
@export var DO_IT = false
@export var poly_array = []

func _process(_delta):
	if DO_IT:
		var as_text = (FileAccess.open(import, FileAccess.READ)).get_as_text()
		
		
		for L in as_text.length():
			if (as_text.substr(L-2, 2) == "v "):#polygon time!
				var wasL = 0#L == start of number, L+subL == end of number. Then wasL += subL,
				var subL = 1#and L+wasL == start of new number
				while as_text[L+wasL+subL] != " ":
					subL += 1
				$vertexes/dummy.position.x = float(as_text.substr(L+wasL, subL))
				
				wasL += subL#L+wasL == end number. L+wasL+subL
				subL = 1
				while as_text[L+wasL+subL] != " ":
					subL += 1
				$vertexes/dummy.position.y = float(as_text.substr(L+wasL, subL))
				
				wasL += subL
				subL = 1
				while as_text[L+wasL+subL] != " ":
					subL += 1
				$vertexes/dummy.position_z = float(as_text.substr(L+wasL, subL))
				print($vertexes/dummy.position,$vertexes/dummy.position_z)
			
			elif (as_text.substr(L, 2) == "v "):
				pass
				
		
		DO_IT = false






	#if DO_IT:
		#var as_text = (FileAccess.open(import, FileAccess.READ)).get_as_text()
		#var polyswitch = false
		#
		#for L in as_text.length():
			#if polyswitch or (as_text.substr(L, 2) == "v "):#polygon time!
				#polyswitch = 1
				#
				#if as_text[L] == " ":
					#var subL = 1
					#while as_text[L+subL] != " ":
						#subL += 1
					#
					#subL = float(as_text.substr(L, subL))#re using SUBL
					#if polyswitch == 1: $vertexes/dummy.position.x = subL
					#elif polyswitch == 2: $vertexes/dummy.position.y = subL
					#else:
						#$vertexes/dummy.position.z = subL
						#polyswitch = false
					#L += 1
					#polyswitch += 1
			#
			#
		#
		#DO_IT = false
