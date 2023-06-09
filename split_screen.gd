#@tool
extends Control
var screen = preload("res://backend/splitscreen/screen.tscn")
signal screens_changed()
@export var num_of_screens = 1:
	set(new_num_of_screens):
		num_of_screens = new_num_of_screens
		emit_signal("screens_changed")
			
var screens = []

# Called when the node enters the scene tree for the first time.
func _ready():
	#_add_screens()
	emit_signal("screens_changed")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	#if Engine.is_editor_hint():
	#	if screens.size() != num_of_screens:
	#		if screens.size() < num_of_screens:
	#			_add_screens()
	#		else:
	#			_del_screens()
	pass


func _add_screens():
	var s = screen.instantiate()
	$SubContainer.add_child(s)
	screens.append(s)
	s.set_anchors_preset(Control.PRESET_TOP_LEFT)
	_screen_positions()
	
func _del_screens():
	screens[-1].queue_free()
	screens.erase(screens[-1])
	_screen_positions()
	pass


func _on_screens_changed():
	print("Screen size = ",screens.size())
	print("Screens ",screens)
	print("Number of Screens ", num_of_screens)
	if screens.size() != num_of_screens:
		if screens.size() < num_of_screens:
			_add_screens()
		else:
			_del_screens()
	_screen_positions()
	pass # Replace with function body.

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
	
	pass # Replace with function body.
