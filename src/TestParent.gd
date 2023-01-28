extends CharacterBody2D

var body: AnimatedBody2d

func _ready():
	set_physics_process(false)
	body = $body
	
func _process(delta):
	var direction = Vector2.ZERO
	
	if Input.is_action_pressed("ui_up"):
		direction.y = -1
	elif Input.is_action_pressed("ui_down"):
		direction.y = 1
	elif Input.is_action_pressed("ui_left"):
		direction.x = -1
	elif Input.is_action_pressed("ui_right"):
		direction.x = 1
		
	if direction != Vector2.ZERO:
		body.walk(delta, direction)
	elif not body.is_state(AnimatedBody2d.ab_state.idling):
		body.rest(delta)
