extends TileMap

class_name IsoMap

@export var chunk_size: int = 9

var player: CharacterBody2D

var tile_offset: Vector2 = Vector2(0, -tile_set.tile_size.y/2)

# Called when the node enters the scene tree for the first time.
func _ready():
	player = get_child(0)
	draw_chunk(make_chunk)
	
	var chunk_index = Vector2(chunk_size/2, chunk_size/2)
	player.position = map_to_local(chunk_index) + tile_offset

func draw_chunk(chunk_func: Callable):
	var chunk = chunk_func.call()
	
	for x in range(len(chunk)):
		for y in range(len(chunk[x])):
			set_cell(0, Vector2i(x, y), 0, Vector2(0, 0), 0)

func make_chunk() -> Array[Array]:
	var chunk: Array = Array()
	for x in range(chunk_size):
		chunk.push_back(Array())
		for y in range(chunk_size):
			chunk[x].push_back(0)
			
	return chunk
