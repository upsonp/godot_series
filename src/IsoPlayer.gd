extends CharacterBody2D

var map: IsoMap

var target_position: Vector2 = Vector2.ZERO

const MAX_SPEED: int = 1000

var acceleration: float = 0.25
var deceleration: float = 1.0

var current_direction: Vector2i = Vector2i.ZERO

func _init():
	y_sort_enabled = true

func _ready():
	map = get_parent()
	
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

	if direction != Vector2i.ZERO and target_position == Vector2.ZERO:
		var cur_cell = map.local_to_map(position - map.tile_offset)
		var new_cell = cur_cell + direction
		var valid_cell: Vector3i = map.get_valid_cell(new_cell)
		if valid_cell.z != -1 and valid_cell.z <= z_index - 1:
			target_position = map.map_to_local(Vector2i(valid_cell.x, valid_cell.y)) + map.tile_offset
			current_direction = direction
	
	if target_position:
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
			target_position = Vector2.ZERO
			current_direction = Vector2.ZERO
			
	move_and_slide()
