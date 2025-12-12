extends Control

@export var menu: VBoxContainer
@export var settings: VBoxContainer
@export var back_button: Button

@export var single_button: Button
@export var multi_button: Button
@export var settings_button: Button
@export var quit_button: Button

var nav_stack: Array[Control] = []
var current_panel

func _ready():
	current_panel = menu
	_show_panel(menu)
	_update_back_button()
	
	settings_button.pressed.connect(_navigate_to.bind(settings))

func _show_panel(panel: Control):
	panel.visible = true

func _update_back_button():
	back_button.visible = nav_stack.size() > 0

func _navigate_to(panel: Control):
	if current_panel:
		nav_stack.append(current_panel)
		current_panel.visible = false
	
	current_panel = panel
	_show_panel(current_panel)
	_update_back_button()
	
func _on_back_pressed():
	if nav_stack.is_empty():
		return
		
	current_panel.visible = false
	current_panel = nav_stack.pop_back()
	_show_panel(current_panel)
	_update_back_button()


func _on_quit_pressed():
	get_tree().quit()

func _on_single_pressed():
	start(true)

func _on_multi_pressed():
	start(false)

func start(singleplayer: bool):
	var packed_scene = load("res://Scenes/main.tscn")
	var main_scene = packed_scene.instantiate()

	var settingsSceme = $Settings
	var board_size_value = settingsSceme.get_board_size()
	var win_con_value = settingsSceme.get_win_con()
	
	var board = main_scene.get_node("Board")

	board.board_size = board_size_value
	board.win_con = win_con_value
	board.singleplayer = singleplayer

	get_tree().current_scene.queue_free()
	get_tree().root.add_child(main_scene)
	get_tree().current_scene = main_scene
