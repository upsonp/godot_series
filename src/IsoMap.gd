extends TileMap

class_name IsoMap

@export var chunk_size: int = 9
@export var layers: int = 4

var player: CharacterBody2D

var tile_offset: Vector2 = Vector2(0, -tile_set.tile_size.y/2)
var layer_offset: Vector2i = Vector2i(-1, -1)

# Called when the node enters the scene tree for the first time.
func _ready():
	for i in range(1, layers):
		add_layer(i)
		set_layer_z_index(i, i)
		
	player = get_child(0)
	draw_chunk(make_chunk)
	
	var chunk_index = Vector2(chunk_size/2, chunk_size/2)
	player.position = map_to_local(chunk_index) + tile_offset
	player.z_index = 1

func get_valid_cell(cell_index: Vector2i) -> Vector3i:
	for layer in range(get_layers_count()-1, -1, -1):
		var cell_test: Vector2i = cell_index + (layer_offset * layer)
		if get_cell_source_id(layer, cell_test) != -1:
			return Vector3i(cell_index.x, cell_index.y, layer)
		
	return Vector3i(cell_index.x, cell_index.y, -1)
	
func draw_chunk(chunk_func: Callable):
	var chunk = chunk_func.call()
	
	for x in range(len(chunk)):
		for y in range(len(chunk[x])):
			if typeof(chunk[x][y]) == TYPE_ARRAY:
				for z in range(len(chunk[x][y])):
					set_cell(chunk[x][y][z], Vector2i(x, y) + (layer_offset * chunk[x][y][z]), 0, Vector2(0, 0), 0)
			else:
				set_cell(chunk[x][y], Vector2i(x, y) + (layer_offset * chunk[x][y]), 0, Vector2(0, 0), 0)

func make_chunk() -> Array[Array]:
	var chunk: Array = Array()
	for x in range(chunk_size):
		chunk.push_back(Array())
		for y in range(chunk_size):
			chunk[x].push_back(0)
	
	chunk[4][3] = 1
	chunk[3][3] = Array()
	chunk[3][3].push_back(1)
	chunk[3][3].push_back(2)
	return chunk
