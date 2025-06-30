extends Control

@export var RainbowLife : float
@export var ScreenTime : int
@export var EnemyCount: int 
var TimeAcum : float = 0
var EnemiesKilled : int = 0
var Endgame : bool = false


func _ready() -> void:
	AudioManager.PlayBgm()
	$HP_Panel/ProgressBar.max_value = RainbowLife
	$HP_Panel/ProgressBar.value = RainbowLife
	$HP_Panel/Label.text = "Time: " + str(ScreenTime)
	for enemy in get_tree().get_nodes_in_group("Enemies"):
		enemy.connect("OnDeath",Callable(self,"_on_enemy_death"))

func _process(delta: float) -> void:
	if Endgame :
		GameOver()
	TimeAcum += delta
	if TimeAcum >= 1 && ScreenTime > 0 :
		TimeAcum-=1
		ScreenTime -= 1
		Score.ModifyScore(-50)
		$HP_Panel/Label.text = "Time: " + str(ScreenTime)
		UpdateScoreDisplay()
		if ScreenTime == 0:
			Endgame = true

func _on_line_tracer_on_damage_taken(damage: float) -> void:
	$HP_Panel/ProgressBar.value -= damage
	if $HP_Panel/ProgressBar.value <= 0:
		Endgame = true


func UpdateScoreDisplay():
	$Panel/Label.text = "Score: " + str(Score.ScoreVal) 

func GameOver() :
	get_tree().change_scene_to_file("res://Scenes/MainScene/EndScene.tscn")


func _on_student_on_death() -> void:
	Score.ModifyScore(500)
	EnemiesKilled += 1
	if EnemiesKilled >= EnemyCount:
		Score.WinEnabled()
		Endgame = true
