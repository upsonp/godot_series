class_name AnimatedBody2d
extends CollisionShape2D

enum ab_state {walking, idling}
enum ab_facing_lr {left, right}
enum ab_facing_fb {front, back}

var arm_front = preload("res://assets/alice_arm.png")
var arm_back = preload("res://assets/alice_arm_back.png")
var body_front = preload("res://assets/alice_body.png")
var body_back = preload("res://assets/alice_body_back.png")

@export var animation_speed = PI * 2
@export var current_state: ab_state = ab_state.idling
@export var current_lr_facing: ab_facing_lr = ab_facing_lr.right
@export var current_fb_facing: ab_facing_fb = ab_facing_fb.front
@export var max_rotation = 0.5

@onready var arm_left: Marker2D = $arm_left
@onready var leg_left: Marker2D = $leg_left
@onready var arm_right: Marker2D = $arm_right
@onready var leg_right: Marker2D = $leg_right
@onready var body: Sprite2D = $body

var current_rotation: float = 0.0

func _ready():
	pass

func is_state(state: ab_state) -> bool:
	return current_state == state

func is_facing_lr(facing: ab_facing_lr) -> bool:
	return current_lr_facing == facing

func is_facing_fb(facing: ab_facing_fb) -> bool:
	return current_fb_facing == facing

func flip_left_right(facing: ab_facing_lr):
	if is_facing_lr(facing):
		return
	
	if is_facing_lr(ab_facing_lr.left) and facing == ab_facing_lr.right:
		scale *= Vector2(1, -1)
	elif is_facing_lr(ab_facing_lr.right) and facing == ab_facing_lr.left:
		scale *= Vector2(1, -1)

	current_lr_facing = facing

func flip_front_back(facing: ab_facing_fb):
	if is_facing_fb(facing):
		return
	var pos_arm_left = arm_left.position
	var pos_arm_right = arm_right.position
	var pos_leg_left = leg_left.position
	var pos_leg_right = leg_right.position
	
	if facing == ab_facing_fb.front and not is_facing_fb(ab_facing_fb.front):
		body.set_texture(body_front)
		arm_right.get_child(0).set_texture(arm_front)
		arm_left.get_child(0).set_texture(arm_front)
	
		arm_right.position = pos_arm_left
		arm_left.position = pos_arm_right
		
	elif facing == ab_facing_fb.back and not is_facing_fb(ab_facing_fb.back):
		body.set_texture(body_back)
		arm_right.get_child(0).set_texture(arm_back)
		arm_left.get_child(0).set_texture(arm_back)

		arm_right.position = pos_arm_left
		arm_left.position = pos_arm_right

	current_fb_facing = facing
	
func walk(delta: float, direction: Vector2i):
	current_state = ab_state.walking

	if direction.y == 1:
		flip_left_right(ab_facing_lr.right)
		flip_front_back(ab_facing_fb.front)
	elif direction.x == 1:
		flip_left_right(ab_facing_lr.left)
		flip_front_back(ab_facing_fb.front)
	elif direction.y == -1:
		flip_left_right(ab_facing_lr.left)
		flip_front_back(ab_facing_fb.back)
	elif direction.x == -1:
		flip_left_right(ab_facing_lr.right)
		flip_front_back(ab_facing_fb.back)

	var a_rotation = arm_left.rotation + PI/2
	if current_rotation == 0:
		current_rotation = 1
	elif abs(a_rotation) > max_rotation:
		current_rotation *= -1

	arm_left.rotate(animation_speed * current_rotation * delta)	
	arm_right.rotate(animation_speed * -current_rotation * delta)	
	leg_left.rotate(animation_speed * -current_rotation * delta)	
	leg_right.rotate(animation_speed * current_rotation * delta)	

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
	stopped = stopped and rest_appendage(arm_left, delta)
	stopped = stopped and rest_appendage(arm_right, delta)
	stopped = stopped and rest_appendage(leg_left, delta)
	stopped = stopped and rest_appendage(leg_right, delta)
	
	if stopped:
		current_rotation = 0.0
		current_state = ab_state.idling

