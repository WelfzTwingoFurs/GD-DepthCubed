@tool
extends CharacterBody2D
@export var polys = [] #Array of arrays[point, point, point etc, color(s)/texture+UV, z_index]
var points = []
var labels_array = []

func _ready():
	markers_to_points()
	FileAccess.open("res://testfiles/dumpy.dat", FileAccess.WRITE).store_var(points)

func _process(_delta):
	queue_redraw()
	if Engine.is_editor_hint():
		markers_to_points()

func markers_to_points():
	points = []
	for markers in $points.get_children():
		points.append(markers)
		
		if Engine.is_editor_hint():
			var label
			if labels_array.size() >= $points.get_child_count():
				label = labels_array[points.size()-1]
				label.text = str(points.size()-1)
				label.position = markers.position
				label.modulate = Color(randi() % 2, randi() % 2, randi() % 2, 0.5)
			else:
				label = $temp_labels/Label.duplicate()
				label.text = str(points.size()-1)
				label.position = markers.position
				labels_array.append(label)
				label.modulate = Color(randi() % 2, randi() % 2, randi() % 2, 0.5)
				$temp_labels.add_child(label)

func _draw():
	var current = []
	for now in polys:
		for n in now.size():
			if typeof(now[n]) == TYPE_INT:
				current.append(points[now[n]].position)
			elif typeof(now[n]) == TYPE_COLOR:
				draw_colored_polygon(current, now[n])
				current = []
