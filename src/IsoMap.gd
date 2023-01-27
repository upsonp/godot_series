extends TileMap

class_name IsoMap

@export var chunk_size: int = 9
@export var chunks: int = 3
@export var cache_chunks: int = 20
@export var layers: int = 4

@export var active_color: Color = Color(1.0, 1.0, 1.0)
@export var in_active_color: Color = Color(0.85, 0.85, 0.85)
@export var invisible_color: Color = Color(0.1, 0.1, 0.1, 0.3)

var player: CharacterBody2D

var tile_offset: Vector2 = Vector2(0, -tile_set.tile_size.y/2)
var layer_offset: Vector2i = Vector2i(-1, -1)

var chunk_map: Dictionary = Dictionary()
var cached_chunks: Dictionary = Dictionary()

func _init():
	y_sort_enabled = true
	
# Called when the node enters the scene tree for the first time.
func _ready():
		
	for i in range(1, layers):
		add_layer(i)
		set_layer_z_index(i, i)
		set_layer_y_sort_enabled(i, true)

	update_chunks()

	player = get_child(0)
	
	var chunk_index = Vector2(chunk_size * 0.5, chunk_size * 0.5)
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

func update_chunks(chunk_index: Vector2i = Vector2i.ZERO):
	# get new chunks
	var visible_chunks: Dictionary = get_new_chunks(chunk_index)

	# cache old chunks
	cache_unused_chunks(visible_chunks.keys())
	
	# draw chunks
	for key in visible_chunks.keys():
		if key not in chunk_map.keys():
			draw_chunk(visible_chunks[key], key)
	
func get_new_chunks(chunk_index: Vector2i) -> Dictionary:
	var visible_chunks = Dictionary()
	for x in range(-chunks * 0.5, ceil(chunks * 0.5)):
		for y in range(-chunks * 0.5, ceil(chunks * 0.5)):
			var chunk_key: Vector2i = chunk_index + Vector2i(x, y)
			var chunk_func: Callable = flat_chunk
			if cached_chunks.has(chunk_key):
				chunk_func = cached_chunks[chunk_key]
				cached_chunks.erase(chunk_key)
			elif (chunk_key.x % 3 == 0 and chunk_key.y % 3 == 0):
				chunk_func = make_chunk
				
			visible_chunks[chunk_key] = chunk_func
	
	return visible_chunks
	
func cache_unused_chunks(used_keys: Array):
	for key in chunk_map.keys():
		if key not in used_keys:
			cached_chunks[key] = chunk_map[key]
			chunk_map.erase(key)
	
	# clear chunks
	if cached_chunks.size() > cache_chunks:
		clear()
		cached_chunks.clear()
		chunk_map.clear()
		
func draw_chunk(chunk_func: Callable, chunk_index: Vector2i):
	var chunk = chunk_func.call()
	var chunk_offset = chunk_index * chunk_size
	var cell_offset: Vector2i = Vector2i.ZERO
	for x in range(len(chunk)):
		for y in range(len(chunk[x])):
			if typeof(chunk[x][y]) == TYPE_ARRAY:
				for z in range(len(chunk[x][y])):
					cell_offset = Vector2i(x, y) + (layer_offset * chunk[x][y][z]) + chunk_offset
					set_cell(chunk[x][y][z], cell_offset, 0, Vector2(0, 0), 0)
			else:
				cell_offset = Vector2i(x, y) + (layer_offset * chunk[x][y]) + chunk_offset
				set_cell(chunk[x][y], cell_offset, 0, Vector2(0, 0), 0)

	chunk_map[chunk_index] = chunk_func
	
func flat_chunk() -> Array[Array]:
	var chunk: Array = Array()
	chunk.resize(chunk_size)
	
	for x in range(chunk_size):
		chunk[x] = Array()
		chunk[x].resize(chunk_size)
		chunk[x].fill(0)
	
	return chunk
	
func make_chunk() -> Array[Array]:
	print("making chunk")
	var chunk: Array[Array] = flat_chunk()
	
	var middle_x = chunk_size * 0.5
	var middle_y = chunk_size * 0.5
	
	chunk[middle_x+1][middle_y-1] = 1
	chunk[middle_x][middle_y-2] = 1
	chunk[middle_x-1][middle_y-1] = 1
	chunk[middle_x][middle_y-1] = Array()
	chunk[middle_x][middle_y-1].push_back(1)
	chunk[middle_x][middle_y-1].push_back(2)

	chunk[middle_x][middle_y] = Array()
	chunk[middle_x][middle_y].push_back(0)
	chunk[middle_x][middle_y].push_back(2)
	chunk[middle_x][middle_y].push_back(3)

	chunk[middle_x-1][middle_y+1] = 1
	chunk[middle_x][middle_y+2] = 1
	chunk[middle_x+1][middle_y+1] = 1
	chunk[middle_x][middle_y+1] = Array()
	chunk[middle_x][middle_y+1].push_back(1)
	chunk[middle_x][middle_y+1].push_back(2)
	
	return chunk

func _process(delta):
	var cell_index = local_to_map(player.position - tile_offset)
	var chunk = cell_index / chunk_size
	update_chunks(chunk)
