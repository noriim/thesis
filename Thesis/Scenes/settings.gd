extends VBoxContainer

@export var board_size: OptionButton
@export var win_con: OptionButton

func _ready():
	var sizes = [4, 5, 6, 7, 8]

	for size in sizes:
		board_size.add_item("%d" % size)

	board_size.item_selected.connect(_on_board_size_changed)
	_update_win_con_options(get_board_size())

func _on_board_size_changed(_index):
	_update_win_con_options(get_board_size())

func _update_win_con_options(max_value: int):
	win_con.clear()
	for i in range(4, max_value + 1):
		win_con.add_item("%d" % i)
	win_con.select(win_con.get_item_count() - 1)

func get_board_size() -> int:
	return int(board_size.get_item_text(board_size.get_selected_id()))

func get_win_con() -> int:
	return int(win_con.get_item_text(win_con.get_selected_id()))
