extends CharacterBody2D

#const SPEED: float = 500.0

var is_authority: bool:
	get: return !LowLevelNetworkHandler.is_server && owner_id == ClientNetworkGlobals.id

var owner_id: int

#func _enter_tree() -> void:
	#ServerNetworkGlobals.handle_player_click.connect(server_handle_player_click)
	#ClientNetworkGlobals.handle_player_click.connect(client_handle_player_click)
#
#
#func _exit_tree() -> void:
	#ServerNetworkGlobals.handle_player_click.disconnect(server_handle_player_click)
	#ClientNetworkGlobals.handle_player_click.disconnect(client_handle_player_click)


func _input(event) -> void:
	if event is not InputEventMouseButton: return # jól szűr :]
	if !is_authority:
		PlayerClick.create(owner_id, event).send(LowLevelNetworkHandler.server_peer) # event = last click that happened
		print("at " + str(owner_id) + ": _input: !is_authority"); return
	if not event.is_pressed(): return
	#DEBUG :]
	print("at " + str(owner_id) + ": _input:" + event.as_text())
	#PlayerClick.create(owner_id, event).send(LowLevelNetworkHandler.server_peer) # event = last click that happened


func server_handle_player_click(peer_id: int, player_click: PlayerClick) -> void:
	if owner_id != peer_id: print("owner_id != peer_id"); return
	print("server handle: " + player_click.to_string())
	var click_event := InputEventMouseButton.new()
	click_event.pressed = player_click.is_pressed
	click_event.button_index = player_click.button_index
	click_event.position = Vector2(player_click.position_x, player_click.position_y)
	#DEBUG
	print("server: " + click_event.as_text())
	Input.parse_input_event(click_event)
	
	PlayerClick.create(owner_id, click_event).broadcast(LowLevelNetworkHandler.connection)
#
#
func client_handle_player_click(player_click: PlayerClick) -> void:
	if is_authority || owner_id != player_click.id: print("is_authority || owner_id != player_click.id"); return
	print("client handle: " + player_click.to_string())
	var click_event := InputEventMouseButton.new()
	click_event.pressed = player_click.is_pressed
	click_event.button_index = player_click.button_index
	click_event.position = Vector2(player_click.position_x, player_click.position_y)
	#DEBUG
	print("client: " + click_event.as_text())
	#Input.parse_input_event(click_event)
