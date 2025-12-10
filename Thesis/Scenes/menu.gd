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
	
	back_button.pressed.connect(_on_back_pressed)
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
	# Load the packed Main scene
	var packed_scene = load("res://Scenes/main.tscn")
	var main_scene = packed_scene.instantiate()

	# Debug print (optional)
	print("Instantiated Main:", main_scene)

	# Get values from Settings panel
	var settings = $Settings
	var board_size_value = settings.get_board_size()
	var win_con_value = settings.get_win_con()
	
	# Access the Board node INSIDE the main scene
	var board = main_scene.get_node("Board") # Adjust path if needed

	# Pass values directly to board
	board.board_size = board_size_value
	board.win_con = win_con_value
	board.singleplayer = true
	# --- Replace the current scene with main_scene ---

	# Remove old scene
	get_tree().current_scene.queue_free()

	# Add new scene
	get_tree().root.add_child(main_scene)

	# Mark it as the active scene
	get_tree().current_scene = main_scene



func _on_multi_pressed():
	pass # Replace with function body.
