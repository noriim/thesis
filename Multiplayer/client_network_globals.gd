extends Node

signal handle_local_id_assignment(local_id: int)
signal handle_remote_id_assignment(remote_id: int)
signal handle_player_click(player_click: PlayerClick)

var id: int = -1
var remote_ids: Array[int]

func _ready() -> void:
	LowLevelNetworkHandler.on_client_packet.connect(on_client_packet)


func on_client_packet(data: PackedByteArray) -> void:
	var packet_type: int = data.decode_u8(0)
	match packet_type:
		PacketInfo.PACKET_TYPE.ID_ASSIGNMENT:
			manage_ids(IDAssignment.create_from_data(data))

		PacketInfo.PACKET_TYPE.PLAYER_CLICK:
			handle_player_click.emit(PlayerClick.create_from_data(data))

		_:
			push_error("Packet type with index ", data[0], " unhandled!")


func manage_ids(id_assignment: IDAssignment) -> void:
	if id == -1: # When id == -1, the id sent by the server is for us
		id = id_assignment.id
		handle_local_id_assignment.emit(id_assignment.id)

		remote_ids = id_assignment.remote_ids
		for remote_id in remote_ids:
			if remote_id == id: continue
			handle_remote_id_assignment.emit(remote_id)

	else: # When id != -1, we already own an id, and just append the remote ids by the sent id
		remote_ids.append(id_assignment.id)
		handle_remote_id_assignment.emit(id_assignment.id)
