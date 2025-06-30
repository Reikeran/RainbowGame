extends Control
func _process(_delta: float) -> void:
	$Panel/Label.text = "[rainbow frec = .2 sat = 0.8 val = .9] RAINBOW GAME [/rainbow]"

func _on_playbtn_pressed() -> void:
	Score.ResetScore()
	get_tree().change_scene_to_file("res://Scenes/MainScene/node_2d.tscn")

func _on_quit_btn_pressed() -> void:
	get_tree().quit()
