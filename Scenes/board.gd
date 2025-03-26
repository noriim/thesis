extends Sprite2D

const BOARD_SIZE = 4
const CELL_WIDTH = 18

const TEXTURE_HOLDER = preload("res://Scenes/texture_holder.tscn")

const BLACK_PIECE = preload("res://Assets/black_ball.png")
const WHITE_PIECE = preload("res://Assets/white_ball.png")

const TURN_BLACK = preload("res://Assets/turn-black.png")
const TURN_WHITE = preload("res://Assets/turn-white.png")

const PIECE_MOVE = preload("res://Assets/Piece_move.png")

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

func _ready():
	board.append([1,-1, 0, 1])
	board.append([0, 0, 0, 0])
	board.append([0, 1, 0, 0])
	board.append([-1, 0, -1, 1])
	
	display_board()
	
func _input(event):
	if event is InputEventMouseButton && event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if is_mouse_out(): return
			if !has_moved:	
				var var1 = snapped(get_global_mouse_position().x, 0) / CELL_WIDTH
				var var2 = abs(snapped(get_global_mouse_position().y, 0)) / CELL_WIDTH
				if !state && (black && board[var2][var1] > 0 || !black && board[var2][var1] < 0):
					selected_piece = Vector2(var2, var1)
					show_options()
					state = true
				elif state: set_move(var2, var1)
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			if is_mouse_out(): return
			var var1 = snapped(get_global_mouse_position().x, 0) / CELL_WIDTH
			var var2 = abs(snapped(get_global_mouse_position().y, 0)) / CELL_WIDTH
			if !state && board[var2][var1] == 0:
				if black:
					board[var2][var1] = -1
				else:
					board[var2][var1] = 1
				black = !black
				has_moved = false
				display_board()				

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
			pieces.add_child(holder)
			holder.global_position = Vector2(j * CELL_WIDTH + (CELL_WIDTH / 2), -i * CELL_WIDTH - (CELL_WIDTH / 2))
			
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
		holder.global_position = Vector2(i.y * CELL_WIDTH + (CELL_WIDTH / 2), -i.x * CELL_WIDTH - (CELL_WIDTH / 2))
		
func delete_dots():
	for child in dots.get_children():
		child.queue_free()
		
func set_move(var2, var1):
	for i in moves:
		if i.x == var2 && i.y == var1:
			board[var2][var1] = board[selected_piece.x][selected_piece.y]
			board[selected_piece.x][selected_piece.y] = 0
			display_board()
			break
	delete_dots()
	state = false
	has_moved = true

func get_moves():
	var _moves = []
	match abs(board[selected_piece.x][selected_piece.y]):
		1: _moves = get_pawn_moves()
	return _moves
	
func get_pawn_moves():
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
	var circles = ceil(BOARD_SIZE / 2)
	var tmp = 0
	var circles_done = 0
	var circles_matrix : Array
	var x = 0
	var y = 0
	circles_matrix.append([[0,0], [0,1], [0,2], [0,3], [1,3], [2,3], [3,3], [3,2], [3,1], [3,0], [2,0], [1,0]])
	circles_matrix.append([[1,1], [1,2], [2,2], [2,1]])
	
