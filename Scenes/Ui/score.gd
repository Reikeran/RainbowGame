extends Node

var BaseScore : int = 12000
var ScoreVal : int 
var Win: bool 

func ResetScore():
	ScoreVal = BaseScore
	Win = false

func ModifyScore(value:int):
	ScoreVal +=value
	
func WinEnabled():
	Win = true
