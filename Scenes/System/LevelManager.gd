extends Node

signal score_changed(new_score: int)
var BaseScore : int = 12000
var ScoreVal : int 
var Win: bool 
var current_level_index: int = 0
@export var levels: Array[PackedScene] = []

func reset():
	current_level_index = 0
	
func load_next_level():
	if current_level_index >= levels.size():
		get_tree().change_scene_to_file("res://Scenes/MainScene/Main.menu.tscn")
		return
	var next_level_scene = levels[current_level_index]
	if next_level_scene:
		get_tree().change_scene_to_packed(next_level_scene)
	current_level_index += 1

func ResetScore():
	ScoreVal = BaseScore
	Win = false

func ModifyScore(value:int):
	ScoreVal +=value
	emit_signal("score_changed", ScoreVal)
func WinEnabled():
	Win = true
