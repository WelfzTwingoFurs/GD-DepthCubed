extends Node
func _process(_delta):
	#F1 F2 F3 F4...
	#F5
	if Input.is_action_just_pressed("bug_reset"): get_tree().reload_current_scene()
	#...F6 F7 F8...
	#F9
	if Input.is_action_pressed("bug_time_down"):
		if (Engine.time_scale > 1): Engine.time_scale -= 1
		elif (Engine.time_scale > 0.1): Engine.time_scale -= 0.1
	#F10
	elif Input.is_action_pressed("bug_time_up"):
		if (Engine.time_scale > 1): Engine.time_scale += 1
		else: Engine.time_scale += 0.1
	#F11
	if Input.is_action_just_pressed("bug_time_reset"): Engine.time_scale = 1
	#F12
	elif Input.is_action_just_pressed("bug_time_stop"): Engine.time_scale = 0
	
	
	
	#TAB
	if Input.is_action_just_pressed("bug_see_colls"): 
		get_window().size.x -= 1
		see_collisions = !see_collisions
		get_tree().set_debug_collisions_hint(see_collisions)
		var root_node : Node = get_tree().get_root()
		var queue_stack : Array = []
		queue_stack.push_back(root_node)
		# Traverse tree to call update methods where available.
		while not queue_stack.size() == 0:
			var node : Node = queue_stack.pop_back()
			if is_instance_valid(node):
				if node.has_method("update"):
					#warning-ignore:unsafe_method_access
					node.update()
				var children_count : int = node.get_child_count()
				for child_index in range(0, children_count):
					queue_stack.push_back(node.get_child(child_index))
		get_window().size.x += 1
var see_collisions = false
