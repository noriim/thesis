extends Sprite2D

const CELL_WIDTH : int = 18

const TEXTURE_HOLDER = preload("res://Scenes/texture_holder.tscn")

const BLACK_PIECE = preload("res://Assets/black_ball.png")
const WHITE_PIECE = preload("res://Assets/white_ball.png")

const TURN_BLACK = preload("res://Assets/turn-black.png")
const TURN_WHITE = preload("res://Assets/turn-white.png")

const PIECE_MOVE = preload("res://Assets/Piece_move.png")

#Assets
@onready var pieces = $Pieces
@onready var dots = $Dots
@onready var turn = $Turn
@onready var cam = $"../Camera2D"
@onready var text = $EndText

#Variables
var board_size : int
var max_width : int
var win_con : int
var singleplayer : bool
var board : Array
var black : bool = true
var state : bool = false
var moves = []
var selected_piece : Vector2
var has_moved : bool = false
var is_timeout : bool = false
var placed_pieces : int = 0
var is_game_over = false

#Multiplayer
var side #white is true, black is false

func set_turn(sideturn):
	if !singleplayer:
		side = sideturn
		
		if side:
			turn.global_rotation_degrees = 180

func _ready():
	max_width = board_size - 1
	text.visible = false
	
	match board_size:
		4:
			texture = load("res://Assets/Board4.png")
			position = Vector2(36, -36)
			cam.zoom = Vector2(7, 7)
			cam.offset = Vector2(-36, 36)
			turn.scale = Vector2(0.54, 0.54)
			text.position = Vector2(-24, -16)
			text.scale = Vector2(0.54, 0.54)
			
		5:
			texture = load("res://Assets/Board5.png")
			position = Vector2(45, -45)
			cam.zoom = Vector2(5.8, 5.8)
			cam.offset = Vector2(-27, 27)
			turn.scale = Vector2(0.655, 0.655)
			text.position = Vector2(-32, -16)
			text.scale = Vector2(0.655, 0.655)
		6:
			texture = load("res://Assets/Board6.png")
			position = Vector2(54, -54)
			cam.zoom = Vector2(5, 5)
			cam.offset = Vector2(-18, 18)
			turn.scale = Vector2(0.77, 0.77)
			text.position = Vector2(-36, -16)
			text.scale = Vector2(0.77, 0.77)
		7:
			texture = load("res://Assets/Board7.png")
			position = Vector2(63, -63)
			cam.zoom = Vector2(4.3, 4.3)
			cam.offset = Vector2(-9, 9)
			turn.scale = Vector2(0.885, 0.885)
			text.position = Vector2(-42, -18)
			text.scale = Vector2(0.885, 0.885)
		8:
			texture = load("res://Assets/Board8.png")
			text.position = Vector2(-46, -22)
		_:
			push_warning("Unsupported board size: %s" % board_size)

	for i in range(board_size):
		board.append([])
		board[i].resize(board_size)
		board[i].fill(0)
	is_game_over = false
	display_board()

func _input(event):
	if singleplayer or side != null && side == black:
		if event is InputEventMouseButton && event.pressed && !is_timeout && !is_game_over:
			if event.button_index == MOUSE_BUTTON_LEFT:
				if is_mouse_out(): return
				if !has_moved:
					var var1 = snapped(get_global_mouse_position().x, 0) / CELL_WIDTH
					var var2 = abs(snapped(get_global_mouse_position().y, 0)) / CELL_WIDTH
					if !state && (black && board[var2][var1] == 1 || !black && board[var2][var1] == -1):
						selected_piece = Vector2(var2, var1)
						show_options()
						state = true
					elif state:
						if moves.has(Vector2(var2, var1)):
							if !singleplayer: get_parent().send_move(selected_piece, Vector2(var2, var1), false)
							set_move(selected_piece, Vector2(var2, var1), false)

						delete_dots()
						state = false
			elif event.button_index == MOUSE_BUTTON_RIGHT:
				if is_mouse_out(): return
				var var1 = snapped(get_global_mouse_position().x, 0) / CELL_WIDTH
				var var2 = abs(snapped(get_global_mouse_position().y, 0)) / CELL_WIDTH
				if !state && board[var2][var1] == 0:
					if !singleplayer: get_parent().send_move(Vector2(), Vector2(var2, var1), true)
					set_move(Vector2(), Vector2(var2, var1), true)

func is_board_full():
	return placed_pieces == board_size * board_size

func is_mouse_out():
	return get_global_mouse_position().x < 0 || get_global_mouse_position().x > (board_size * CELL_WIDTH) || get_global_mouse_position().y > 0 || get_global_mouse_position().y < (-1 * board_size * CELL_WIDTH)
	
func display_board():
	for child in pieces.get_children():
		child.queue_free()
		
	for i in board_size:
		for j in board_size:
			var holder = TEXTURE_HOLDER.instantiate()
			if !side:
				holder.global_rotation_degrees = 180
			pieces.add_child(holder)
			holder.global_position = Vector2(j * CELL_WIDTH + (CELL_WIDTH / 2.0), -i * CELL_WIDTH - (CELL_WIDTH / 2.0))
			
			match board[i][j]:
				-1: holder.texture = BLACK_PIECE
				0: holder.texture = null
				1: holder.texture = WHITE_PIECE
				
	if black: turn.texture = TURN_BLACK
	else: turn.texture = TURN_WHITE
				
func show_options():
	moves = get_moves()
	if moves == []:
		state = false
		return
	show_dots()
	
func show_dots():
	for i in moves:
		var holder = TEXTURE_HOLDER.instantiate()
		dots.add_child(holder)
		holder.texture = PIECE_MOVE
		holder.global_position = Vector2(i.y * CELL_WIDTH + (CELL_WIDTH / 2.0), -i.x * CELL_WIDTH - (CELL_WIDTH / 2.0))
		
func delete_dots():
	for child in dots.get_children():
		child.queue_free()
		
func set_move(start_pos : Vector2, end_pos : Vector2, create : bool):
	if create:
		board[end_pos.x][end_pos.y] = -1 if black else 1
		placed_pieces += 1
		display_board()
		black = !black
		has_moved = false
		is_timeout = true
		await get_tree().create_timer(1.0).timeout
		is_timeout = false
		spin_board()
		if is_board_full():
			for i in 5:
				await get_tree().create_timer(1.0).timeout
				if is_game_over:
					return
				spin_board()
			if !is_game_over:
				text.text = "GAME OVER\n It's a tie!"
				text.visible = true
				print("no winner :(")
				is_game_over = true
	else:
		board[end_pos.x][end_pos.y] = board[start_pos.x][start_pos.y]
		board[start_pos.x][start_pos.y] = 0
		has_moved = true
	display_board()

func get_moves():
	var _moves = []
	var directions = [Vector2(0, 1), Vector2(0, -1), Vector2(1, 0), Vector2(-1, 0)]
	
	for i in directions:
		var pos = selected_piece + i
		if is_valid_position(pos):
			if is_empty(pos): _moves.append(pos)

	return _moves

func is_valid_position(pos : Vector2):
	return pos.x >= 0 && pos.x < board_size && pos.y >= 0 && pos.y < board_size
	
func is_empty(pos : Vector2):
	return board[pos.x][pos.y] == 0
	
func spin_board():
	#var breakpnt = board_size / 2 - 0.5

	var temp_matrix = board.duplicate(true)
	for y in range(board_size):
		for x in range(board_size):
			if x+y < max_width and x >= y:
				temp_matrix[y][x+1] = board[y][x]
				
			if x+y > max_width and x <= y:
				temp_matrix[y][x-1] = board[y][x]
				
			if x+y >= max_width and x > y:
				temp_matrix[y+1][x] = board[y][x]
				
			if x+y <= max_width and x < y:
				temp_matrix[y-1][x] = board[y][x]
				
	board = temp_matrix
	
	for y in range(board_size - 1, -1, -1):
		print(str(board[y]))
	print()
	print()
	display_board()
	check_win()

func check_win():
	var white_win = false
	var black_win = false
	var counter = 1
	#diagonal 1
	for i in range(1, board_size):
		if board[i][i] != 0 and board[i][i] == board[i-1][i-1]:
				counter += 1
				if counter == win_con and board[i][i] == 1:
					white_win = true
				elif counter == win_con and board[i][i] == -1:
					black_win = true
		else:
			counter = 1
	counter = 1
	#diagonal 2
	for i in range(1, board_size):
		if board[max_width-i][i] != 0 and board[max_width-i][i] == board[max_width-i+1][i-1]:
			counter += 1
			if counter == win_con and board[max_width-i][i] == 1:
				white_win = true
			elif counter == win_con and board[max_width-i][i] == -1:
				black_win = true
		else:
			counter = 1

	counter = 1
	
	#TODO iterative diagonal check ex.: board_size == 6, win_con == 4 
	
	#horizontal
	for y in range(board_size):
		for x in range(1, board_size):
			if board[y][x] != 0 and board[y][x] == board[y][x-1]:
				counter += 1
				if counter == win_con and board[y][x] == 1:
					white_win = true
				elif counter == win_con and board[y][x] == -1:
					black_win = true
		counter = 1
		
	#vertical
	for x in range(board_size):
		for y in range(1, board_size):
			if board[y][x] != 0 and board[y][x] == board[y-1][x]:
				counter += 1
				if counter == win_con and board[y][x] == 1:
					white_win = true
				elif counter == win_con and board[y][x] == -1:
					black_win = true
		counter = 1
		

	if white_win and black_win:
		is_game_over = true
		text.text = "GAME OVER\n It's a tie!"
		text.visible = true
		print("welp, thats a tie")
	elif white_win:
		is_game_over = true
		text.text = "GAME OVER\n White won!"
		text.visible = true
		print("yay, white won")
	elif black_win:
		is_game_over = true
		text.text = "GAME OVER\n Black won!"
		text.visible = true
		print("yay, black won")
	print("FULL:" + str(is_board_full()))
	print("GAME OVER:" + str(is_game_over))
	print("PLACED PIECES:" + str(placed_pieces))
