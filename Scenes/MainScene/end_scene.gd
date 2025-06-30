extends Control

func _ready() -> void:
	if Score.Win:
		$Panel/Label2.text = "You Win"
	else:
		$Panel/Label2.text = "You Lose"
	$Panel/Label3.text = "Final Score: " + str(Score.ScoreVal)

func _process(delta: float) -> void:
	$Panel/Label.text = "[rainbow frec = .2 sat = 0.8 val = .9] GAME OVER [/rainbow]"


func _on_return_btn_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/MainScene/Main.menu.tscn")
	AudioManager.PlayBgm()

func _on_quit_btn_pressed() -> void:
	get_tree().quit()
