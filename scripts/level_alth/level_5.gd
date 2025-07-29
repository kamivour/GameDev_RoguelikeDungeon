extends Node2D

@onready var tilemap: TileMap = $TileMap

func open_door(direction: String):
	var wall_layer = 1 

	match direction:
		"top":
			for x in range(-2, 2):           
				for y in range(-14, -7):    
					tilemap.erase_cell(wall_layer, Vector2i(x, y))

		"bottom":
			for x in range(-2, 2):
				for y in range(7, 13):       
					tilemap.erase_cell(wall_layer, Vector2i(x, y))

		"left":
			for x in range(-21, -14):       
				for y in range(-2, 2):      
					tilemap.erase_cell(wall_layer, Vector2i(x, y))

		"right":
			for x in range(14, 23):         
				for y in range(-2, 2):      
					tilemap.erase_cell(wall_layer, Vector2i(x, y))
