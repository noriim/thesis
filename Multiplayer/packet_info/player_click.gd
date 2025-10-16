class_name PlayerClick extends PacketInfo

var id: int
var click: InputEvent

static func create(id: int, click: InputEvent) -> PlayerClick:
	var info: PlayerClick = PlayerClick.new()
	info.packet_type = PACKET_TYPE.PLAYER_CLICK
	info.flag = ENetPacketPeer.FLAG_UNSEQUENCED
	info.id = id
	info.click = click
	return info


static func create_from_data(data: PackedByteArray) -> PlayerClick:
	var info: PlayerClick = PlayerClick.new()
	info.decode(data)
	return info


func encode() -> PackedByteArray:
	var data: PackedByteArray = super.encode()
	data.resize(18)
	data.encode_u8(1, id)
	data.encode_float(2, click.pressed)
	data.encode_float(6, click.button_index)
	data.encode_float(10, click.position.x)
	data.encode_float(14, click.position.y)
	return data


func decode(data: PackedByteArray) -> void:
	super.decode(data)
	id = data.decode_u8(1)
	var decoded_click = InputEventMouseButton.new()
	decoded_click.pressed = bool(data.decode_float(2))
	decoded_click.button_index = int(data.decode_float(6))
	decoded_click.position.x = int(data.decode_float(10))
	decoded_click.position.y = int(data.decode_float(14))
	#DEBUG :]
	print("decoded by ID " + str(id) + " as " + decoded_click.as_text())
