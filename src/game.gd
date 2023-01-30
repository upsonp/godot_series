extends Node2D

@onready var map: IsoMap = $IsoMap
@onready var player: IsoPlayer = $IsoMap/IsoPlayer

# Called when the node enters the scene tree for the first time.
func _ready():
	var chunk_index = Vector2(map.chunk_size * 0.5, map.chunk_size * 0.5)
	var valid: Vector3i = map.get_valid_cell(chunk_index)
	var player_position = map.vector_height_map_to_local(valid) + map.tile_offset

	map.set_active_layer(valid.z)

	player.set_location(player_position, valid.z + 1)
	player.set_look_at_function(look_at_function)
	player.connect("move_complete", map.request_chunk_update)

func look_at_function(current_position: Vector2, height: int, direction: Vector2i) -> Vector3:
	var cur_cell = map.layer_local_to_map(height-1, current_position)
	var new_cell = cur_cell + direction
	var valid_cell: Vector3i = map.get_valid_cell(new_cell, height)
	var valid_position: Vector2 = map.vector_height_map_to_local(valid_cell) + map.tile_offset

	return Vector3(valid_position.x, valid_position.y, valid_cell.z)
