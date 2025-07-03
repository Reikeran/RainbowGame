extends Control

func _ready() -> void:
	if LevelManager.Win:
		$Panel/Label2.text = "You Win"
	else:
		$Panel/Label2.text = "You Lose"
	$Panel/Label3.text = "Final Score: " + str(LevelManager.ScoreVal)

func _process(_delta: float) -> void:
	$Panel/Label.text = "[rainbow frec = .2 sat = 0.8 val = .9] GAME OVER [/rainbow]"


func _on_return_btn_pressed() -> void:
	LevelManager.load_next_level()
	AudioManager.PlayBgm()

func _on_quit_btn_pressed() -> void:
	get_tree().quit()
