class_name ChunkManager

extends Node

var chunk_size: int
var num_of_visible_chunks: int
var num_of_cache_chunks: int
var chunk_height: int

var map: IsoMap

var chunk_map: Dictionary = Dictionary()
var cached_patterens: Dictionary = Dictionary()

var null_chunk: Array[TileMapPattern]

var visible_chunk_vectors: Array[Vector2i]

func init(init_map: IsoMap) -> void:
	self.map = init_map
	self.chunk_size = init_map.chunk_size
	self.num_of_visible_chunks = init_map.num_of_visible_chunks
	self.num_of_cache_chunks = init_map.num_of_cache_chunks
	self.chunk_height = init_map.get_layers_count()
	
	var visible_chunk_offset = floor(num_of_visible_chunks * 0.5)
	for x in range(num_of_visible_chunks):
		for y in range(num_of_visible_chunks):
			visible_chunk_vectors.push_back(Vector2i(x-visible_chunk_offset, y-visible_chunk_offset))
			
	null_chunk = get_null_chunk()
	
func update_chunks(chunk_index: Vector2i = Vector2i.ZERO):
	# get new chunks
	var visible_chunk_keys: Array[Vector2i] = visible_chunk_vectors.map(func(x): return x+chunk_index)

	for chunk_key in chunk_map.keys():
		if chunk_key not in visible_chunk_keys:
			map.draw_chunk(get_null_chunk(), chunk_key)
	
	# clear chunks
	# create an algorithm to determine how likely a user is to revisit a chunk
	# in the cached chunks, if it's unlikely, drop the chunk from the cache
	# maybe write it to long-term storage to maintain changes the user may
	# have maded to the chunk
	if cached_patterens.size() - visible_chunk_keys.size() > num_of_cache_chunks:
		for chunk_key in cached_patterens.keys():
			if chunk_key not in visible_chunk_keys:
				cached_patterens.erase(chunk_key)
				chunk_map.erase(chunk_key)

	# draw chunks
	for chunk_key in visible_chunk_keys:
		if chunk_key not in chunk_map.keys():
			chunk_map[chunk_key] = noise_chunk(flat_chunk(), chunk_key)
		
		if chunk_key not in cached_patterens.keys():
			cached_patterens[chunk_key] = construct_tile_map_pattern(chunk_map[chunk_key])
			
		map.draw_chunk(cached_patterens[chunk_key], chunk_key)
			
func construct_tile_map_pattern(chunk_data: Array[Array]) -> Array[TileMapPattern]:
	var tile_map_patterens: Array[TileMapPattern] = Array()
	var layer_size: Vector2i = Vector2i(chunk_size, chunk_size)
	
	for layer in range(chunk_height):
		tile_map_patterens.push_back(TileMapPattern.new())
		tile_map_patterens[layer].set_size(layer_size)
	
	for x in range(len(chunk_data)):
		for y in range(len(chunk_data[x])):
			if typeof(chunk_data[x][y]) == TYPE_ARRAY:
				for z in range(len(chunk_data[x][y])):
					var layer = chunk_data[x][y][z]
					tile_map_patterens[layer].set_cell(Vector2i(x, y), 0, Vector2i(0, 0), 0)
			else:
				var layer = chunk_data[x][y]
				tile_map_patterens[layer].set_cell(Vector2i(x, y), 0, Vector2i(0, 0), 0)
				
	return tile_map_patterens

func get_chunk_func(chunk_key: Vector2i) -> Callable:
	if (chunk_key.x % 3 == 0 and chunk_key.y % 3 == 0):
		return special_chunk

	return flat_chunk

func get_null_chunk() -> Array[TileMapPattern]:
	if null_chunk:
		return null_chunk
	
	var layer_size: Vector2i = Vector2i(chunk_size, chunk_size)
	var tile_map_pattern: TileMapPattern = TileMapPattern.new()
	
	tile_map_pattern.set_size(layer_size)
	for x in range(layer_size.x):
		for y in range(layer_size.y):
			tile_map_pattern.set_cell(Vector2i(x, y))
			
	var chunk: Array[TileMapPattern] = Array()
	chunk.resize(chunk_height)
	chunk.fill(tile_map_pattern)
	
	return chunk

func flat_chunk(_chunk_data: Array = Array(), _chunk_index: Vector2i = Vector2i.ZERO) -> Array[Array]:
	var chunk: Array = _chunk_data
	chunk.resize(chunk_size)
	
	for x in range(chunk_size):
		chunk[x] = Array()
		chunk[x].resize(chunk_size)
		chunk[x].fill(0)
	
	return chunk
	
func noise_chunk(_chunk_data: Array, _chunk_index: Vector2i) -> Array[Array]:
	var chunk_offset = _chunk_index * chunk_size
	for x in range(len(_chunk_data)):
		for y in range(len(_chunk_data)):
			var noise = map.noise_generator.get_noise_2d(x+chunk_offset.x, y+chunk_offset.y)
			noise = (noise + 1) * 0.5 * chunk_height
			_chunk_data[x][y] = noise
			
	return _chunk_data
	
func special_chunk(_chunk_data: Array, _chunk_index: Vector2i) -> Array[Array]:
	print("making chunk")
	var chunk: Array[Array] = flat_chunk(_chunk_data, _chunk_index)
	
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
