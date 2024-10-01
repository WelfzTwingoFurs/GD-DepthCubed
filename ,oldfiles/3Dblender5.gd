@tool
extends Node2D
@export var import : String
@export var DO_IT = false

@export var poly_array = []
var vertex = []
func _ready():
#	poly_array = []
#	DO_IT = true
	if has_node("vertexes"):
		for markers in $vertexes.get_children():
			vertex.append(Vector3(markers.global_position.x, markers.global_position.y, markers.position_z*((scale.x+scale.y)/2)))

func get_type(): return(true)

####################################################################################################

func things(LwasL):
	var subL = 1
	while as_text[LwasL+subL] != " ": subL += 1
	wasL += subL
	return float(as_text.substr(LwasL, subL))


var as_text
var wasL = 0
func _process(_delta):
	as_text = (FileAccess.open(import, FileAccess.READ)).get_as_text()
	
	if DO_IT:
		for L in as_text.length():
			if as_text.substr(L-2, 2) == "v ":#polygon time!
				var new_marker = $dummy.duplicate()
				wasL = 0
				new_marker.position.x = things(L+wasL)#I hate repeating this crap!
				new_marker.position_z = -things(L+wasL)#But so far it works and looks the best
				new_marker.position.y = things(L+wasL)# >:(!!!!
				print(new_marker.position,new_marker.position_z)#I hate this repeating crap
				$vertexes.add_child(new_marker)
				new_marker.set_owner(self)
			
			elif (as_text.substr(L-2, 2) == "f "):#something wrong here
				wasL = 0
				var subL = 0
				while as_text[L+subL] != "\n": subL += 1
				
				var new_array = string_to_array(as_text.substr(L,subL))
				
				new_array.append(Color8(randi()%255,randi()%255,randi()%255,255))
				poly_array.append(new_array)
				print(new_array)
		
		#$vertexes/dummy.queue_free()
		
		var node_to_save = self
		var scene = PackedScene.new()
		scene.pack(node_to_save.duplicate())
		ResourceSaver.save(scene, "res://MyScene.tscn")
		
		DO_IT = false #TURN IT OFF!!!!


func string_to_array(str):
	var arr = []
	for L in str.length():
		var subL = 0
		while (str[L+subL] != " ") && (str[L+subL] != "f"): subL +=1
		arr.append(int(str.substr(L,subL)))
	return arr
