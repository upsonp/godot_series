extends TileMap

class_name IsoMap

@export var map_seed: int = 255

@export var chunk_size: int = 9
@export var num_of_visible_chunks: int = 3
@export var num_of_cache_chunks: int = 20
@export var chunk_height: int = 6

@export var active_color: Color = Color(1.0, 1.0, 1.0)
@export var in_active_color: Color = Color(0.85, 0.85, 0.85)
@export var invisible_color: Color = Color(0.1, 0.1, 0.1, 0.3)

var noise_generator: FastNoiseLite

var tile_offset: Vector2 = Vector2(0, -float(tile_set.tile_size.y) * 0.5)
var layer_offset: Vector2i = Vector2i(-1, -1)

var chunk_manager: ChunkManager

func _init():
	randomize()
	
	y_sort_enabled = true
	chunk_manager = ChunkManager.new()
	noise_generator = FastNoiseLite.new()
	noise_generator.seed = map_seed
	
# Called when the node enters the scene tree for the first time.
func _ready():
		
	for i in range(1, chunk_height):
		add_layer(i)
		set_layer_z_index(i, i)
		set_layer_y_sort_enabled(i, true)

	chunk_manager.init(self)
	chunk_manager.update_chunks()
	
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
	
func get_valid_cell(cell_index: Vector2i, max_layer: int = get_layers_count()-1) -> Vector3i:
	for layer in range(max_layer, -1, -1):
		var cell_test: Vector2i = cell_index + (layer_offset * layer)
		if get_cell_source_id(layer, cell_test) != -1:
			return Vector3i(cell_index.x, cell_index.y, layer)
		
	return Vector3i(cell_index.x, cell_index.y, -1)

func draw_chunk(chunk: Array[TileMapPattern], chunk_index: Vector2i):
	var chunk_offset: Vector2i = (chunk_index * chunk_size)
	for z in range(len(chunk)):
		set_pattern(z, chunk_offset + (layer_offset * z), chunk[z])
	
func request_chunk_update(current_position: Vector2, active_layer: int):
	var cell_index: Vector2 = local_to_map(current_position - tile_offset)
	var chunk: Vector2i = floor(cell_index / chunk_size)
	chunk_manager.update_chunks(chunk)
	set_active_layer(active_layer)
