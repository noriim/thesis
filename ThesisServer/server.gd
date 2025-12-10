extends Node2D

const BOARD_SIZE : int = 4
const MAX_WIDTH : int = BOARD_SIZE - 1
const CELL_WIDTH : int = 18
const WIN : int = 4

var multiplayer_peer = ENetMultiplayerPeer.new()

var connected_peer_ids = []

var turn = true if randi_range(0,1) else false

#Anticheat
var board : Array
var black : bool = true
var state : bool = false
var moves = []
var selected_piece : Vector2
var has_moved : bool = false
var is_timeout : bool = false
var placed_pieces : int = 0
var is_game_over = false

func _ready():
	for i in range(BOARD_SIZE):
		board.append([])
		board[i].resize(BOARD_SIZE)
		board[i].fill(0)
		
	host(9999)
	
func host(port):
	multiplayer_peer.create_server(port)
	multiplayer.multiplayer_peer = multiplayer_peer
	
	multiplayer_peer.peer_connected.connect(
		func(peer_id = multiplayer.get_unique_id()):
			add_player(peer_id)
	)
	
	multiplayer_peer.peer_disconnected.connect(
		func(peer_id = multiplayer.get_unique_id()):
			remove_player(peer_id)
	)
	
func add_player(peer_id):
	if connected_peer_ids.size() < 2:
		connected_peer_ids.append(peer_id)
		if connected_peer_ids.size() == 2:
			rpc_id(connected_peer_ids[0], "give_turn", turn)
			rpc_id(connected_peer_ids[1], "give_turn", !turn)

func remove_player(peer_id):
	connected_peer_ids.erase(peer_id)

@rpc("any_peer")
func send_move_info(start_pos, end_pos, create):
	selected_piece = start_pos
	show_options()
	if multiplayer.get_remote_sender_id() == connected_peer_ids[0] && turn:
		if create or moves.has(end_pos):
			set_move(start_pos, end_pos, create)
			rpc_id(connected_peer_ids[1], "return_enemy_move", start_pos, end_pos, create)
			turn = !turn if create else turn
		else: print("CHEATER!!!")
	elif multiplayer.get_remote_sender_id() == connected_peer_ids[1] && !turn:
		if create or moves.has(end_pos):
			set_move(start_pos, end_pos, create)
			rpc_id(connected_peer_ids[0], "return_enemy_move", start_pos, end_pos, create)
			turn = !turn if create else turn
		else: print("CHEATER!!!")

@rpc("authority")
func return_enemy_move():
	pass
	
@rpc("authority")
func give_turn():
	pass

#Anticheat
func show_options():
	moves = get_moves()
	if moves == []:
		state = false
		return
func set_move(start_pos : Vector2, end_pos : Vector2, create : bool):
	if create:
		board[end_pos.x][end_pos.y] = -1 if black else 1
		placed_pieces += 1
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
