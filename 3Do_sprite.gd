@tool
extends PhysicsBody2D
@export var texture : String
@export var rotations = 1
@export var rot_flip = true
@export var offset_z = false
@export var scale_z = 1.0#ACTUALLY SCALE OF RENDERING; SAME VARIABLE NAME FOR EASIER COLLISION CODE
@export var position_z = 0.0

func get_type(): return(false)




func _physics_process(_delta):
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

####################################################################################################
####################################################################################################
####################################################################################################
####################################################################################################
####################################################################################################
####################################################################################################
####################################################################################################
####################################################################################################
####################################################################################################
####################################################################################################

var was_position
func _process(_delta):
	if Engine.is_editor_hint():
		if was_position != position:
			queue_redraw()
			was_position = position

func _draw():
	if Engine.is_editor_hint():
		draw_set_transform(Vector2i(),false, Vector2(scale_z,scale_z))
		
		if rotations == 1:
			var textload = load(str("res://resources/",texture,".png"))
			draw_texture(textload, -textload.get_size()/2)
		else:
			#draw_texture(load(str("res://resources/",texture,randi()%rotations/(2 if (rotations < 0) else 1),".png")), Vector2())
			var textload = load(str("res://resources/",texture,"0.png"))
			draw_texture(textload, -textload.get_size()/2)
