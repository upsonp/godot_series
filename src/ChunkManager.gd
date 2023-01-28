class_name ChunkManager

extends Node

var chunk_size: int
var num_of_visible_chunks: int
var numb_of_cache_chunks: int
var chunk_height: int

var map: IsoMap

var chunk_map: Dictionary = Dictionary()
var cached_patterns: Dictionary = Dictionary()

var null_chunk: Array[TileMapPattern]

func init(map: IsoMap) -> void:
	self.map = map
	self.chunk_size = map.chunk_size
	self.num_of_visible_chunks = map.num_of_visible_chunks
	self.numb_of_cache_chunks = map.numb_of_cache_chunks
	self.chunk_height = map.get_layers_count()
	
	null_chunk = get_null_chunk()
	
func update_chunks(chunk_index: Vector2i = Vector2i.ZERO):
	# get new chunks
	var visible_chunks: Dictionary = get_visible_chunks(chunk_index)

	# cache old chunks
	for chunk_key in chunk_map.keys():
		if chunk_key not in visible_chunks.keys():
			map.draw_chunk(get_null_chunk(), chunk_key)
	
	# clear chunks
	# create an algorithm to determine how likely a user is to revisit a chunk
	# in the cached chunks, if it's unlikely, drop the chunk from the cache
	# maybe write it to long-term storage to maintain changes the user may
	# have maded to the chunk
	print("Cached: ", cached_patterns.size() - visible_chunks.size())
	if cached_patterns.size() - visible_chunks.size() > numb_of_cache_chunks:
		for chunk_key in cached_patterns.keys():
			if chunk_key not in visible_chunks.keys():
				cached_patterns.erase(chunk_key)
				chunk_map.erase(chunk_key)
	
	# draw chunks that are left in the visisble chunks array
	for chunk_key in visible_chunks.keys():
		if chunk_key not in chunk_map.keys(): 
			chunk_map[chunk_key] = visible_chunks[chunk_key].call()
			
		if chunk_key not in cached_patterns.keys():
			print("making cached pattern: ", chunk_key)
			cached_patterns[chunk_key] = construct_tile_map_pattern(chunk_map[chunk_key])
			
		map.draw_chunk(cached_patterns[chunk_key], chunk_key)

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
	
func get_patteren_layers(chunk_data: Array[Array]) -> Array[TileMapPattern]:
	var chunk_layers: Array[TileMapPattern]
	
	return chunk_layers
	
func get_visible_chunks(chunk_index: Vector2i) -> Dictionary:
	var visible_chunks = Dictionary()
	for x in range(floor(-num_of_visible_chunks * 0.5), ceil(num_of_visible_chunks * 0.5)):
		for y in range(floor(-num_of_visible_chunks * 0.5), ceil(num_of_visible_chunks * 0.5)):
			var chunk_key: Vector2i = chunk_index + Vector2i(x, y)

			visible_chunks[chunk_key] = flat_chunk
			
			if (chunk_key.x % 3 == 0 and chunk_key.y % 3 == 0):
				visible_chunks[chunk_key] = special_chunk
					
	return visible_chunks
	
func get_null_chunk() -> Array[TileMapPattern]:
	if null_chunk:
		return null_chunk
	
	var layer_size: Vector2i = Vector2i(chunk_size, chunk_size)
	var cell_offset: Vector2i = Vector2i.ZERO
	var tile_map_pattern: TileMapPattern = TileMapPattern.new()
	
	tile_map_pattern.set_size(layer_size)
	for x in range(layer_size.x):
		for y in range(layer_size.y):
			tile_map_pattern.set_cell(Vector2i(x, y))
			
	var chunk: Array[TileMapPattern] = Array()
	chunk.resize(chunk_height)
	chunk.fill(tile_map_pattern)
	
	return chunk
	
func flat_chunk() -> Array[Array]:
	var chunk: Array = Array()
	chunk.resize(chunk_size)
	
	for x in range(chunk_size):
		chunk[x] = Array()
		chunk[x].resize(chunk_size)
		chunk[x].fill(0)
	
	return chunk
	
func special_chunk() -> Array[Array]:
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
