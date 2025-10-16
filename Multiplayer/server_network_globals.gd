extends Node

signal handle_player_click(peer_id: int, player_click: PlayerClick)

var peer_ids: Array[int]

func _ready() -> void:
	LowLevelNetworkHandler.on_peer_connected.connect(on_peer_connected)
	LowLevelNetworkHandler.on_peer_disconnected.connect(on_peer_disconnected)
	LowLevelNetworkHandler.on_server_packet.connect(on_server_packet)


func on_peer_connected(peer_id: int) -> void:
	peer_ids.append(peer_id)

	IDAssignment.create(peer_id, peer_ids).broadcast(LowLevelNetworkHandler.connection)


func on_peer_disconnected(peer_id: int) -> void:
	peer_ids.erase(peer_id)

	#TODO? IDUnassignment to broadcast to all still connected peers


func on_server_packet(peer_id: int, data: PackedByteArray) -> void:
	match data[0]:
		PacketInfo.PACKET_TYPE.PLAYER_CLICK:
			handle_player_click.emit(peer_id, PlayerClick.create_from_data(data))
		_:
			push_error("Packet type with index ", data[0], " unhandled!")
