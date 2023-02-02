class_name IsoPlayer

extends CharacterBody2D

@onready var body: AnimatedBody2d = $Body

@export var jumpstrenght: int = 1
var target_position: Vector2 = Vector2.ZERO
var target_height: int = -1

const MAX_SPEED: int = 1000

var acceleration: float = 0.25
var deceleration: float = 1.0

var current_direction: Vector2i = Vector2i.ZERO

var jumping: bool = false

var look_at_function: Callable = func(current_position: Vector2, height: int, direction: Vector2i): return Vector3i(current_position.x, current_position.y, height)
signal move_complete

func _init():
	y_sort_enabled = true

func _ready():
	pass

func set_location(location: Vector2, zindex: int) -> void:
	position = location
	z_index = zindex

func set_look_at_function(new_look_at_function: Callable) -> void:
	look_at_function = new_look_at_function
	
func _physics_process(delta):
	var direction: Vector2i = Vector2i.ZERO
	
	if Input.is_action_pressed("ui_up"):
		direction.y = -1
	elif Input.is_action_pressed("ui_down"):
		direction.y = 1
	elif Input.is_action_pressed("ui_left"):
		direction.x = -1
	elif Input.is_action_pressed("ui_right"):
		direction.x = 1

	if Input.is_action_just_pressed("ui_jump"):
		jumping = true

	if direction != Vector2i.ZERO and target_position == Vector2.ZERO:
		var valid_position: Vector3 = look_at_function.call(position, z_index, direction)
		if valid_position.z != -1:
			if valid_position.z == z_index - 1:
				target_position = Vector2(valid_position.x, valid_position.y)
			elif jumping and (valid_position.z <= (z_index + jumpstrenght - 1) and valid_position.z >= (z_index - jumpstrenght - 1)):
				target_position = Vector2(valid_position.x, valid_position.y)
				target_height = valid_position.z + 1
				
				if(valid_position.z >= z_index):
					z_index = target_height

			jumping = false
			current_direction = direction

	if target_position:
		body.walk(delta, direction)
		var target_direction: Vector2 = position.direction_to(target_position).normalized()
		var distance: float = position.distance_to(target_position)
		
		var accelerate = (MAX_SPEED/acceleration) * delta
		var decelerate = (velocity.length()/deceleration) * delta
		
		if velocity.length() > distance and direction != current_direction:
			velocity -= target_direction * decelerate
		elif velocity.length() < MAX_SPEED and velocity.length() < distance:
			velocity += target_direction * accelerate
			
		if distance < deceleration:
			velocity = Vector2.ZERO
			position = target_position
			if target_height != -1:
				z_index = target_height
				target_height = -1
			target_position = Vector2.ZERO
			current_direction = Vector2.ZERO
			emit_signal("move_complete", position, z_index-1)
	elif body.current_state != AnimatedBody2d.ab_state.idling:
		body.rest(delta)
	
	move_and_slide()
