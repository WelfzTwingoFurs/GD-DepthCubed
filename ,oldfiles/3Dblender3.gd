@tool
extends Node2D
@export var import : String
@export var DO_IT = false
@export var poly_array = []
var as_text
var subL = 0

func _process(_delta):
	if DO_IT:
		as_text = (FileAccess.open(import, FileAccess.READ)).get_as_text()
		var wasL = 0
		
		for L in as_text.length():
			if as_text.substr(L-2, 2) == "v ":#polygon time!
				
				wasL += subL
				subL = 1 ### L == start of number, L+subL == end of number...........
				while as_text[L+wasL+subL] != " ":
					subL += 1
				$vertexes/dummy.position.x = float(as_text.substr(L+wasL, subL))
				#things(L+wasL+subL)
				
				wasL += subL#...Then wasL += subL, and L+wasL == start of new number!
				subL = 1
				while as_text[L+wasL+subL] != " ":
					subL += 1
				$vertexes/dummy.position.y = float(as_text.substr(L+wasL, subL))
				
				
				wasL += subL
				subL = 1
				while as_text[L+wasL+subL] != " ":
					subL += 1
				$vertexes/dummy.position_z = float(as_text.substr(L+wasL, subL))
				
				print($vertexes/dummy.position,$vertexes/dummy.position_z)#I hate this repeating crap
				
			
			elif (as_text.substr(L-5, 5) == "s off"):
				pass
				
			
			
		
		
		DO_IT = false #TURN IT OFF!!!!
