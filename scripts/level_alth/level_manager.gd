extends Node2D

@export var level_base: PackedScene
@export var other_levels: Array[PackedScene]
@export var room_size := Vector2i(576, 336)

var room_grid := {}
var used_positions := []
var directions := [Vector2i(0, -1), Vector2i(1, 0), Vector2i(0, 1), Vector2i(-1, 0)]

func _ready():
	generate_floor()
	find_farthest_room_from_base()
	
func generate_floor():
	var start_pos = Vector2i(0, 0)
	var start_room = spawn_room(level_base, start_pos)
	used_positions.append(start_pos)

	var shuffled = other_levels.duplicate()
	shuffled.shuffle()

	# Ngẫu nhiên số lượng phòng cần spawn (trừ base)
	var total_rooms = randi_range(6, 10)
	var placed_count = 0

	# Gán duy nhất 1 phòng kề base
	var dir_from_base = directions.pick_random()
	var next_pos = start_pos + dir_from_base
	var first_room = spawn_room(shuffled.pop_front(), next_pos)
	used_positions.append(next_pos)
	open_doors_between(next_pos, start_pos)
	placed_count += 1

	var queue := [next_pos]

	while placed_count < total_rooms:
		var from = queue.pick_random()
		var dir = directions.pick_random()
		var new_pos = from + dir

		if room_grid.has(new_pos):
			continue

		# Không đặt 2 phòng giống nhau cạnh nhau
		var neighbor_scenes := []
		for d in directions:
			var neighbor = new_pos + d
			if room_grid.has(neighbor):
				neighbor_scenes.append(room_grid[neighbor]["scene_path"])

		var next_scene = shuffled.pick_random()
		if next_scene.resource_path in neighbor_scenes:
			continue

		var new_room = spawn_room(next_scene, new_pos)
		used_positions.append(new_pos)
		queue.append(new_pos)
		open_doors_between(new_pos, from)
		placed_count += 1


func find_farthest_room_from_base():
	var base_pos = Vector2i(0, 0)
	var max_dist = -1
	var boss_pos = base_pos

	for pos in room_grid.keys():
		var dist = pos.distance_squared_to(base_pos)
		if dist > max_dist:
			max_dist = dist
			boss_pos = pos

	
func spawn_room(scene: PackedScene, grid_pos: Vector2i) -> Node2D:
	var room = scene.instantiate()
	room.position = grid_pos * room_size
	add_child(room)
	room_grid[grid_pos] = {
		"node": room,
		"scene_path": scene.resource_path
	}
	print("Spawning room: ", scene.resource_path, " at grid: ", grid_pos, " -> position: ", room.position)
	return room
	
func open_doors_between(pos_a: Vector2i, pos_b: Vector2i):
	var dir = pos_b - pos_a
	
	var room_a_data = room_grid.get(pos_a)
	var room_b_data = room_grid.get(pos_b)
	
	var room_a = null
	if room_a_data and room_a_data.has("node"):
		room_a = room_a_data["node"]
	var room_b = null
	if room_b_data and room_b_data.has("node"):
		room_b = room_b_data["node"]

	var name_a = get_dir_name(dir)
	var name_b = get_dir_name(-dir)

	if room_a and room_a.has_method("open_door"):
		room_a.open_door(name_a)
	if room_b and room_b.has_method("open_door"):
		room_b.open_door(name_b)


func get_dir_name(dir: Vector2i) -> String:
	match dir:
		Vector2i(0, -1): return "top"
		Vector2i(0, 1): return "bottom"
		Vector2i(-1, 0): return "left"
		Vector2i(1, 0): return "right"
		_: return ""
		
