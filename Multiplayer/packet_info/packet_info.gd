## BASECLASS ##

class_name PacketInfo

# Don't make values above 255, since we send "packet_type" as a single byte
enum PACKET_TYPE {
	ID_ASSIGNMENT = 0,
	PLAYER_CLICK = 10,
}

var packet_type: PACKET_TYPE
var flag: int

# Override function in derived classes
func encode() -> PackedByteArray:
	var data: PackedByteArray
	data.resize(1)
	data.encode_u8(0, packet_type)
	return data


# Override function in derived classes
func decode(data: PackedByteArray) -> void:
	packet_type = data.decode_u8(0)


func send(target: ENetPacketPeer) -> void:
	target.send(0, encode(), flag)


func broadcast(server: ENetConnection) -> void:
	server.broadcast(0, encode(), flag)
