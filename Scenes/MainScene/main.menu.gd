extends Control
func _process(_delta: float) -> void:
	$Panel/Label.text = "[rainbow frec = .2 sat = 0.8 val = .9] RAINBOW GAME [/rainbow]"

func _on_playbtn_pressed() -> void:
	LevelManager.ResetScore()
	LevelManager.reset()
	LevelManager.load_next_level()

func _on_quit_btn_pressed() -> void:
	get_tree().quit()
