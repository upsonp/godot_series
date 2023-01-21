extends CharacterBody2D

var map: IsoMap

var target_position: Vector2 = Vector2.ZERO

const MAX_SPEED: int = 1000

var acceleration: float = 0.25
var deceleration: float = 1.0

var current_direction: Vector2i = Vector2i.ZERO

func _ready():
	map = get_parent()
	
func _physics_process(delta):
	var direction: Vector2i = Vector2i.ZERO
	
	if Input.is_action_pressed("ui_up"):
		direction.y = -1
	elif Input.is_action_pressed("ui_down"):
		direction.y = 1

	if Input.is_action_pressed("ui_left"):
		direction.x = -1
	elif Input.is_action_pressed("ui_right"):
		direction.x = 1

	if direction != Vector2i.ZERO or direction == current_direction:
		var cur_cell = map.local_to_map(position - map.tile_offset)
		var new_cell = cur_cell + direction
		target_position = map.map_to_local(new_cell) + map.tile_offset
		current_direction = direction
	
	if target_position:
		var target_direction: Vector2 = position.direction_to(target_position).normalized()
		var distance: float = position.distance_to(target_position)
		
		var accelerate = (MAX_SPEED/acceleration) * delta
		var decelerate = (velocity.length()/deceleration) * delta
		
		if velocity.length() < MAX_SPEED and velocity.length() < distance:
			velocity += target_direction * accelerate
		elif velocity.length() > distance and direction != current_direction:
			velocity -= target_direction * decelerate
			
		if distance < deceleration:
			velocity = Vector2.ZERO
			position = target_position
			target_position = Vector2.ZERO
			current_direction = Vector2.ZERO
			
	move_and_slide()
