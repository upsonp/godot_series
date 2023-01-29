extends CharacterBody2D

var map: IsoMap
var body: AnimatedBody2d

@export var jumpstrenght: int = 1
var target_position: Vector2 = Vector2.ZERO
var target_height: int = -1

const MAX_SPEED: int = 1000

var acceleration: float = 0.25
var deceleration: float = 1.0

var current_direction: Vector2i = Vector2i.ZERO

var jumping: bool = false

signal move_complete

func _init():
	y_sort_enabled = true

func _ready():
	map = get_parent()
	body = $body

func set_location(location: Vector2, zindex: int) -> void:
	position = location
	z_index = zindex
	
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
		var cur_cell = map.layer_local_to_map(z_index-1, position)
		var new_cell = cur_cell + direction
		var valid_cell: Vector3i = map.get_valid_cell(new_cell, z_index)
		if valid_cell.z != -1:
			if valid_cell.z == z_index - 1:
				target_position = map.vector_height_map_to_local(valid_cell) + map.tile_offset
			elif jumping and (valid_cell.z <= (z_index + jumpstrenght - 1) and valid_cell.z >= (z_index - jumpstrenght - 1)):
				target_position = map.vector_height_map_to_local(valid_cell) + map.tile_offset
				target_height = valid_cell.z + 1
				
				if(valid_cell.z >= z_index):
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
				map.set_active_layer(z_index - 1)
				target_height = -1
			target_position = Vector2.ZERO
			current_direction = Vector2.ZERO
			emit_signal("move_complete")
	elif body.current_state != AnimatedBody2d.ab_state.idling:
		body.rest(delta)
			
	move_and_slide()
