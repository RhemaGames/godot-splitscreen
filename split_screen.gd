#@tool
extends Control
var screen = preload("res://backend/splitscreen/screen.tscn")
signal screens_changed()
signal game_over()
#var size:Vector2i
@export var num_of_screens = 0:
	set(new_num_of_screens):
		print("Caught screen change should be ",new_num_of_screens)
		if new_num_of_screens >=1:
			num_of_screens = new_num_of_screens
			emit_signal("screens_changed")
		#else:
		#	num_of_screens = 1
		#	emit_signal("screens_changed")
			
var screens = []

var level:Node3D

# Called when the node enters the scene tree for the first time.
func _ready():
	#_add_screens()
	$ScoreBoard.hide()
	$LevelStart.hide()
	size = get_viewport().size
	emit_signal("screens_changed")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	#if Engine.is_editor_hint():
	#if screens.size() != num_of_screens:
	#	if screens.size() < num_of_screens:
	#		_add_screens()
	#	else:
	#		_del_screens()
	pass


func _add_screens():
	if visible:
		print("Adding Screen")
		var s = screen.instantiate()
		$SubContainer.add_child(s)
		s.name = "Screen"+str($SubContainer.get_child_count())
		screens.append(s)
		s.set_anchors_preset(Control.PRESET_TOP_LEFT)
		_screen_positions()
	
func _del_screens():
	if visible and screens.size() > 0:
		print("Deleting Screen")
		screens[-1].queue_free()
		screens.erase(screens[-1])
		_screen_positions()


func _on_screens_changed():
	if visible:
		if screens.size() != num_of_screens:
			if screens.size() < num_of_screens:
				while screens.size() < num_of_screens:
					_add_screens()
			elif screens.size() > num_of_screens:
				while screens.size() < num_of_screens:
					_del_screens()
		_screen_positions()
		print_debug($SubContainer.get_children())
		

func _screen_positions():
	var index = 0
	for scr in screens:
		scr.get_node("Label").text = str(index)
		match num_of_screens:
			2:
				scr.size.x = size.x
				scr.size.y = (size.y / num_of_screens)
				if index == 1:
					scr.position.y = scr.size.y
			3:
				if index == 0 :
					scr.size.x = size.x
					scr.size.y = size.y / 2
				else:
					scr.size.x = size.x / 2
					scr.size.y = size.y / 2
					if index == 1:
						scr.position.y = scr.size.y
					if index == 2:
						scr.position.y = scr.size.y
						scr.position.x = scr.size.x
						
			4:
				scr.size.x = size.x / 2
				scr.size.y = size.y / 2
				if index == 1:
					scr.position.y = scr.size.y
				if index == 2:
					scr.position.y = 0
					scr.position.x = scr.size.x
				if index == 3:
					scr.position.y = scr.size.y
					scr.position.x = scr.size.x
			_:
				scr.size.x = size.x 
				scr.size.y = size.y 
				#s.position.x = screens.size() * s.size.x + 5
				#s.position.y = screens.size() * s.size.y + 5
				#pass
		index += 1


func _on_visibility_changed():
	emit_signal("screens_changed")
	

func start_level():
	print_debug("Starting Level")
	_on_screens_changed()
	level = get_parent().background
	level.queue_free()
	#var tutorial = load("res://scenes/World/Transport/Tutorial.tscn")
	var tutorial = load("res://scenes/World/City/city_level.tscn")
	var song = load("res://assets/music/Electro_Swing_-_Alexey_Anisimov.mp3")
	level = tutorial.instantiate()
	
	$ScoreBoard.matchtime = Mistro.game_settings.time
	$ScoreBoard.maxscore = Mistro.game_settings.score
	add_child(level)
	get_parent().get_node("BGM").stream = song
	
	for screen in $SubContainer.get_children():
		screen.get_node("SubViewport").transparent_bg = false
		print(screen.name)
	#	screen.set_camera3D
		#var background = screen.get_node("SubViewport").get_child(0)
		#background.queue_free()
		#var tutorial = load("res://scenes/World/Transport/Tutorial.tscn")
		#background = tutorial.instantiate()
		#\background.playernum = screen.get_index()+1
	#	screen.get_node("SubViewport").add_child(background)
	$LevelStart.show()
	$LevelStart/AnimationPlayer.play("countdown")


func _on_score_board_scorereached(team, score):
	if visible:
		$ScoreBoard/Timer.stop()
		emit_signal("game_over")


func _on_score_board_time_over():
	if visible:
		$ScoreBoard/Timer.stop()
		$ScoreBoard.hide()
		emit_signal("game_over")


func _on_level_start_visibility_changed():
	if visible:
		print_debug("Level Start")
		$LevelStart/AnimationPlayer.play("countdown")

func _on_animation_player_animation_finished(anim_name):
	if anim_name == "countdown":
		$ScoreBoard.show()
		get_parent().get_node("BGM").play()

func _input(event):
	if visible:
		#print_debug("Split Screen thinks its visible")
		#if event is InputEventJoypadButton or event is InputEventKey:
			for button in ["p1_menu","p2_menu","p3_menu","p4_menu"]:
				if Input.is_action_just_pressed(button):
					if !$PauseScreen.visible:
						match button:
							"p1_menu":
								$PauseScreen.by = "Player 1"
							"p2_menu":
								$PauseScreen.by = "Player 2"
							"p3_menu":
								$PauseScreen.by = "Player 3"
							"p4_menu":
								$PauseScreen.by = "Player 4"
						$PauseScreen.show()
					else:
						$PauseScreen.hide()
			


func _on_game_over():
	get_parent().get_node("BGM").stop()
	$ScoreBoard.matchtime = Mistro.game_settings.time
	$ScoreBoard.maxscore = Mistro.game_settings.score
	if is_instance_valid(level):
		level.end_game()
	self.hide()
