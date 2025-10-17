extends Sprite2D

const BOARD_SIZE : int = 4
const MAX_WIDTH : int = BOARD_SIZE - 1
const CELL_WIDTH : int = 18
const WIN : int = 4

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

#Variables
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

func set_turn(turn):
	side = turn
	display_board()
	if !side:
		$"../Camera2D".global_rotation_degrees = 180

func _ready():
	#board.append([1, 1, 1, 1])
	#board.append([0, 0, 0, 0])
	#board.append([0, 0, 0, 0])
	#board.append([-1, -1, -1, -1])
	#display_board()
	for i in range(BOARD_SIZE):
		board.append([])
		board[i].resize(BOARD_SIZE)
		board[i].fill(0)
	is_game_over = false

func _input(event):
	if side != null && side == black:
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
							get_parent().send_move(selected_piece, Vector2(var2, var1), false)
							set_move(selected_piece, Vector2(var2, var1), false)
							
						delete_dots()
						state = false
			elif event.button_index == MOUSE_BUTTON_RIGHT:
				if is_mouse_out(): return
				var var1 = snapped(get_global_mouse_position().x, 0) / CELL_WIDTH
				var var2 = abs(snapped(get_global_mouse_position().y, 0)) / CELL_WIDTH
				if !state && board[var2][var1] == 0:
					get_parent().send_move(Vector2(), Vector2(var2, var1), true)
					set_move(Vector2(), Vector2(var2, var1), true)
					
					if is_board_full():
						for i in 5:
							await get_tree().create_timer(1.0).timeout
							print(i)
							if is_game_over:
								return
							spin_board()
						if !is_game_over:
							print("no winner :(")
							is_game_over = true

func is_board_full():
	return placed_pieces == BOARD_SIZE * BOARD_SIZE

func is_mouse_out():
	if get_global_mouse_position().x < 0 || get_global_mouse_position().x > (BOARD_SIZE * CELL_WIDTH) || get_global_mouse_position().y > 0 || get_global_mouse_position().y < (-1 * BOARD_SIZE * CELL_WIDTH):
		return true
	return false
	
func display_board():
	for child in pieces.get_children():
		child.queue_free()
		
	for i in BOARD_SIZE:
		for j in BOARD_SIZE:
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
	elif !create:
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
	if pos.x >= 0 && pos.x < BOARD_SIZE && pos.y >= 0 && pos.y < BOARD_SIZE: return true
	return false
	
func is_empty(pos : Vector2):
	if board[pos.x][pos.y] == 0: return true
	return false
	
func spin_board():
	#var breakpnt = BOARD_SIZE / 2 - 0.5

	var temp_matrix = board.duplicate(true)
	for y in range(BOARD_SIZE):
		for x in range(BOARD_SIZE):
			if x+y < MAX_WIDTH and x >= y:
				temp_matrix[y][x+1] = board[y][x]
				
			if x+y > MAX_WIDTH and x <= y:
				temp_matrix[y][x-1] = board[y][x]
				
			if x+y >= MAX_WIDTH and x > y:
				temp_matrix[y+1][x] = board[y][x]
				
			if x+y <= MAX_WIDTH and x < y:
				temp_matrix[y-1][x] = board[y][x]
				
	board = temp_matrix
	
	for y in range(BOARD_SIZE - 1, -1, -1):
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
	for i in range(1, BOARD_SIZE):
		if board[i][i] != 0 and board[i][i] == board[i-1][i-1]:
				counter += 1
				if counter == WIN and board[i][i] == 1:
					white_win = true
				elif counter == WIN and board[i][i] == -1:
					black_win = true
		else:
			counter = 1
	counter = 1
	#diagonal 2
	for i in range(1, BOARD_SIZE):
		if board[MAX_WIDTH-i][i] != 0 and board[MAX_WIDTH-i][i] == board[MAX_WIDTH-i+1][i-1]:
			counter += 1
			if counter == WIN and board[MAX_WIDTH-i][i] == 1:
				white_win = true
			elif counter == WIN and board[MAX_WIDTH-i][i] == -1:
				black_win = true
		else:
			counter = 1

	counter = 1
	
	#TODO iterative diagonal check ex.: BOARD_SIZE == 6, WIN == 4 
	
	#horizontal
	for y in range(BOARD_SIZE):
		for x in range(1, BOARD_SIZE):
			if board[y][x] != 0 and board[y][x] == board[y][x-1]:
				counter += 1
				if counter == WIN and board[y][x] == 1:
					white_win = true
				elif counter == WIN and board[y][x] == -1:
					black_win = true
		counter = 1
		
	#vertical
	for x in range(BOARD_SIZE):
		for y in range(1, BOARD_SIZE):
			if board[y][x] != 0 and board[y][x] == board[y-1][x]:
				counter += 1
				if counter == WIN and board[y][x] == 1:
					white_win = true
				elif counter == WIN and board[y][x] == -1:
					black_win = true
		counter = 1
		

	if white_win and black_win:
		is_game_over = true
		print("welp, thats a tie")
	elif white_win:
		is_game_over = true
		print("yay, white won")
	elif black_win:
		is_game_over = true
		print("yay, black won")
	print("FULL:" + str(is_board_full()))
	print("GAME OVER:" + str(is_game_over))
	print("PLACED PIECES:" + str(placed_pieces))
