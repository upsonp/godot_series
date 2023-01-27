extends CollisionShape2D

class_name AnimatedBody2d

enum STATE {WALKING, IDLING}

@export var animation_speed = PI * 2
@export var current_state = STATE.IDLING
@export var max_rotation = 0.5

var arm_f: Marker2D
var leg_f: Marker2D
var arm_b: Marker2D
var leg_b: Marker2D

var current_rotation: float = 0.0

func _ready():
	arm_f = $arm_front
	arm_b = $arm_back
	leg_f = $leg_front
	leg_b = $leg_back
	
func walk(delta):
	current_state = STATE.WALKING
	var a_rotation = arm_f.rotation + PI/2
	if current_rotation == 0:
		current_rotation = 1
	elif abs(a_rotation) > max_rotation:
		current_rotation *= -1

	arm_f.rotate(animation_speed * current_rotation * delta)	
	arm_b.rotate(animation_speed * -current_rotation * delta)	
	leg_f.rotate(animation_speed * -current_rotation * delta)	
	leg_b.rotate(animation_speed * current_rotation * delta)	

func rest_appendage(appendage: Marker2D, delta) -> bool:
	var a_rotation = appendage.rotation + PI/2
	
	var direction = 1 if a_rotation <= 1 else -1 if a_rotation >= 1 else 0
	var move = animation_speed * direction * delta
	if appendage.rotation + move > -PI/2 or appendage.rotation - move < -PI/2:
		appendage.rotation = -PI/2
		return true

	appendage.rotate(move)
	return false

func rest(delta):
	var stopped: bool = true
	stopped = stopped and rest_appendage(arm_f, delta)
	stopped = stopped and rest_appendage(arm_b, delta)
	stopped = stopped and rest_appendage(leg_f, delta)
	stopped = stopped and rest_appendage(leg_b, delta)
	
	if stopped:
		current_rotation = 0.0
		current_state = STATE.IDLING
		
#func _process(delta):
#	if Input.is_anything_pressed():
#		current_state = STATE.WALKING
#		walk(delta)
#	elif current_state != STATE.IDLING:
#		rest(delta)
