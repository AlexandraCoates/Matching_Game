extends TileMap


# Setting up the vars needed
@onready var reset_button: Button = $"../CanvasLayer/reset_button"
var board_size = 4
enum Layers{hidden, revealed}
var SOURCE_NUM = 0
const hidden_tile_coords = Vector2(6,2)
const hidden_tile_alt = 1
var revealed_spots = []
var tile_pos_to_atlas_pos = {}
var score = 0
var turns_taken = 0
var wins = 0


# Called when the node enters the scene tree for the first time.
# Sets up the very first board
func _ready() -> void:
	setup_board()
	update_text()
	pass # Replace with function body.


# Getting the tiles to use from the tile map, in this case it is the middle row of tiles
# Grabs these (2 of each chosen) and shuffles them
func get_tiles_to_use():
	var chosen_tile_coords = []
	var options = range(10)
	options.shuffle()
	for i in range(board_size * int(board_size / 2)):
		var current = Vector2(options.pop_back(), 1)
		for j in range(2):
			chosen_tile_coords.append(current)
	chosen_tile_coords.shuffle()
	return chosen_tile_coords


# Sets up the board using the tiles gotten from the above function
# Populates the board by moving through and "placing" the tiles
func setup_board():
	var cards_to_use = get_tiles_to_use()
	for y in range(board_size):
		for x in range(board_size):
			var current_spot = Vector2(x, y)
			place_single_face_down_card(current_spot)
			var card_atlas_coords = cards_to_use.pop_back()
			tile_pos_to_atlas_pos[current_spot] = card_atlas_coords
			self.set_cell(Layers.revealed, current_spot, SOURCE_NUM, card_atlas_coords)
	
	
# Flips a single tile to be face down (using the alt tile)
func place_single_face_down_card(coords: Vector2):
	self.set_cell(Layers.hidden, coords,
					SOURCE_NUM, hidden_tile_coords, hidden_tile_alt)
	
	
# Handles all the inputs (Mouse clicking) and flips the tiles accordingly 
func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
			var global_clicked = event.position
			var pos_clicked = Vector2(local_to_map(to_local(global_clicked)))
			print(pos_clicked) 
			var current_tile_alt = get_cell_alternative_tile(Layers.hidden, pos_clicked)
			if current_tile_alt == 1 and revealed_spots.size() < 2:
				self.set_cell(Layers.hidden, pos_clicked, -1)
				revealed_spots.append(pos_clicked)
				if revealed_spots.size() == 2:
					when_two_cards_revealed()
	
	
# Checks to see if the two cards are the same, and either puts them back if not, or adds one to the score
# If they are the same the two cards remain face up
func when_two_cards_revealed():
	if tile_pos_to_atlas_pos[revealed_spots[0]] == tile_pos_to_atlas_pos[revealed_spots[1]]:
		score += 1
		revealed_spots.clear()
	else:
		put_back_cards_with_delay()
	turns_taken += 1
	update_text()
	on_win()
	
	
#  Places the cards back face down with a delay (currently 1 sec)
func put_back_cards_with_delay():
	await self.get_tree().create_timer(1).timeout
	for spot in revealed_spots:
		place_single_face_down_card(spot)
	revealed_spots.clear()
	
	
# Updates the three labels: Score, Turns and Wins
func update_text():
	$"../CanvasLayer/score_label".text = "Score: %d" % score
	$"../CanvasLayer/turns_label".text = "Turns Taken: %d" % turns_taken
	$"../CanvasLayer/wins_label".text = "Wins: %d" % wins
	
	
# Moves through the grid and clears the board so it can be reset
func clear_board():
	for y in range(board_size):
		for x in range(board_size):
			clear()
		
	
	
# Detects when the score reaches 8 adds one to wins and clears and resets the board
func on_win():
	if score == 8:
		wins += 1
		update_text()
		score = 0
		turns_taken = 0
		update_text()
		clear_board()
		setup_board()
	
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


# Handles the reset button, does the same as on_win, without adding one to the wins
func _on_reset_button_pressed() -> void:
	score = 0
	turns_taken = 0
	update_text()
	clear_board()
	setup_board()
	pass # Replace with function body.
