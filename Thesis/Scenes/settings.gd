extends VBoxContainer

@export var board_size: OptionButton
@export var win_con: OptionButton

func _ready():
	var sizes = [4, 5, 6, 7, 8]
	var cons = [4, 5, 6, 7, 8]
	
	for size in sizes:
		board_size.add_item("%d" % size)
	for con in cons:
		win_con.add_item("%d" % con)

func get_board_size() -> int:
	return int(board_size.get_item_text(board_size.get_selected_id()))

func get_win_con() -> int:
	return int(win_con.get_item_text(win_con.get_selected_id()))
