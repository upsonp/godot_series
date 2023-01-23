extends TileMap

class_name IsoMap

@export var chunk_size: int = 9
@export var chunks: int = 3
@export var layers: int = 4

@export var active_color: Color = Color(1.0, 1.0, 1.0)
@export var in_active_color: Color = Color(0.85, 0.85, 0.85)
@export var invisible_color: Color = Color(0.1, 0.1, 0.1, 0.3)

var player: CharacterBody2D

var tile_offset: Vector2 = Vector2(0, -tile_set.tile_size.y/2)
var layer_offset: Vector2i = Vector2i(-1, -1)

func _init():
	y_sort_enabled = true
	for i in range(1, layers):
		add_layer(i)
		set_layer_z_index(i, i)
		set_layer_y_sort_enabled(i, true)

	for x in range(chunks):
		for y in range(chunks):
			if x == 0 and y == 0:
				draw_chunk(make_chunk, Vector2i(x, y))
			else:
				draw_chunk(flat_chunk, Vector2i(x, y))
	
# Called when the node enters the scene tree for the first time.
func _ready():
		
	player = get_child(0)
	
	var chunk_index = Vector2(chunk_size/2, chunk_size/2)
#	var chunk_index = Vector2(3, 3)
	var valid: Vector3i = get_valid_cell(chunk_index)
	
	player.position = vector_height_map_to_local(valid)  + tile_offset
	player.z_index = valid.z + 1
	set_active_layer(player.z_index - 1)

func set_active_layer(layer: int):
	for ilayer in range(get_layers_count()-1, -1, -1):
		if ilayer > layer + 1:
			set_layer_modulate(ilayer, invisible_color)
		elif ilayer == layer:
			set_layer_modulate(ilayer, active_color)
		else:
			set_layer_modulate(ilayer, in_active_color)

	
func layer_local_to_map(layer: int, local_position: Vector2) -> Vector2i:
	return local_to_map(local_position - tile_offset) - (layer_offset * layer)
	
func vector_height_map_to_local(cell_index: Vector3i) -> Vector2:
	return map_to_local(Vector2i(cell_index.x, cell_index.y) + (layer_offset * cell_index.z))
	
func get_valid_cell(cell_index: Vector2i, max_layer: int = get_layers_count()) -> Vector3i:
	for layer in range(max_layer-1, -1, -1):
		var cell_test: Vector2i = cell_index + (layer_offset * layer)
		if get_cell_source_id(layer, cell_test) != -1:
			return Vector3i(cell_index.x, cell_index.y, layer)
		
	return Vector3i(cell_index.x, cell_index.y, -1)
	
func draw_chunk(chunk_func: Callable, chunk_index: Vector2i):
	var chunk = chunk_func.call()
	var chunk_offset = chunk_index * chunk_size
	for x in range(len(chunk)):
		for y in range(len(chunk[x])):
			if typeof(chunk[x][y]) == TYPE_ARRAY:
				for z in range(len(chunk[x][y])):
					set_cell(chunk[x][y][z], Vector2i(x, y) + (layer_offset * chunk[x][y][z]) + chunk_offset, 0, Vector2(0, 0), 0)
			else:
				set_cell(chunk[x][y], Vector2i(x, y) + (layer_offset * chunk[x][y]) + chunk_offset, 0, Vector2(0, 0), 0)

func flat_chunk() -> Array[Array]:
	var chunk: Array = Array()
	for x in range(chunk_size):
		chunk.push_back(Array())
		for y in range(chunk_size):
			chunk[x].push_back(0)
	
	return chunk
	
func make_chunk() -> Array[Array]:
	var chunk = flat_chunk()
	
	chunk[3][2] = 1
	chunk[4][3] = 1
	chunk[2][3] = 1
	chunk[3][3] = Array()
	chunk[3][3].push_back(1)
	chunk[3][3].push_back(2)

	chunk[3][4] = Array()
	chunk[3][4].push_back(0)
	chunk[3][4].push_back(2)
	chunk[3][4].push_back(3)

	chunk[2][5] = 1
	chunk[4][5] = 1
	chunk[3][6] = 1
	chunk[3][5] = Array()
	chunk[3][5].push_back(1)
	chunk[3][5].push_back(2)
	
	return chunk
